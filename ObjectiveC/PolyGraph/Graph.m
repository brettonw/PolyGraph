#import "Graph.h"
#import "BoxedIndex.h"

#define SPRING_FACTOR_MAX       0.75f
#define MINIMUM_SEPARATION      0.5f
#define STARTING_CIRCLE_RADIUS  1.0e1f
#define SOLUTION_TOLERANCE      1.0e-4f

@implementation Graph

- (NSSet*) getConnectedNodes:(NSUInteger)nodeIndex
{    
    // walk over all of the edges looking to see if any of them refer to the
    // node we are gathering connections to
    NSMutableSet*   connectedNodes = [NSMutableSet setWithCapacity:m_nodeList.count - 1];
    for (GraphEdge* edge in m_edgeSet)
    {
        if (edge.from == nodeIndex)
        {
            [connectedNodes addObject:[BoxedIndex boxedIndex:edge.to]];
        }
        else if (edge.to == nodeIndex)
        {
            [connectedNodes addObject:[BoxedIndex boxedIndex:edge.from]];
        }
    }
    return connectedNodes;
}

- (NSSet*) computeNodesInView
{
    NSMutableSet*   view = [NSMutableSet setWithCapacity:m_nodeList.count];
    [view addObject:[BoxedIndex boxedIndex:m_focusNodeIndex]];
    
    // get the immediatey connected nodes
    NSSet*   connectedNodes = [self getConnectedNodes:m_focusNodeIndex];
    for (BoxedIndex* boxedIndex in connectedNodes)
    {
        [view addObject:boxedIndex];
        NSSet* secondaryConnections = [self getConnectedNodes:boxedIndex.index];
        [view addObjectsFromArray:[secondaryConnections allObjects]];
    }
    return view;
}

- (NSArray*) computeEdgesInView:(NSSet*)nodesInView
{
    NSMutableArray* edges = [NSMutableArray arrayWithCapacity:m_edgeSet.count];
    for (GraphEdge* edge in m_edgeSet)
    {
        // if both of the nodes is in the view
        if ([nodesInView containsObject:[BoxedIndex boxedIndex:edge.from]] AND [nodesInView containsObject:[BoxedIndex boxedIndex:edge.to]])
        {
            [edges addObject:edge];
        }
    }
    return edges;
}

- (void) halfStepNode:(GraphNode*)node toLocation:(Point2*)location
{
    Vector2*    delta = [Point2 subtractLeft:node.location right:location];
    delta = [Vector2 scaleLeft:delta right:m_springFactor * -0.5f];
    m_lastStepDelta = MAX (delta.length, m_lastStepDelta);
    node.location = [Point2 addLeftPoint:node.location rightVector:delta];
}

- (void) stageOneStep
{
    // set node 0 at (0, 0)
    GraphNode*  node = (GraphNode*) [m_nodeList objectAtIndex:0];
    Point2*     origin = [Point2 pointWithX:0.0f Y:0.0f];
    Vector2*    originDelta = [Point2 subtractLeft:node.location right:origin];
    m_lastStepDelta = originDelta.length;
    node.location = origin;
    
    // loop over all of the edges
    for (GraphEdge* edge in m_edgeSet)
    {
        // fetch the two nodes referred to by this edge
        GraphNode* nodeFrom = (GraphNode*) [m_nodeList objectAtIndex:edge.from];
        GraphNode* nodeTo = (GraphNode*) [m_nodeList objectAtIndex:edge.to];
        
        // move each of them half the distance to the desired separation (2.0)
        Vector2*    nodeDelta = [Point2 subtractLeft:nodeFrom.location right:nodeTo.location];
        CGFloat     nodeDeltaLength = nodeDelta.length;
        CGFloat     nodeDeltaScale = (1.0f / nodeDeltaLength) * ((nodeDeltaLength - edge.length) * m_springFactor * 0.5f);
        m_lastStepDelta = MAX(fabs (nodeDeltaScale), m_lastStepDelta);
        nodeDelta = [Vector2 scaleLeft:nodeDelta right:nodeDeltaScale];
        
        nodeTo.location = [Point2 addLeftPoint:nodeTo.location rightVector:nodeDelta];
        nodeDelta = [Vector2 scaleLeft:nodeDelta right:-1.0f];
        nodeFrom.location = [Point2 addLeftPoint:nodeFrom.location rightVector:nodeDelta];
    }
}

- (void) stageTwoStep
{
    [self stageOneStep];
    
    // make sure that none of the nodes are touching each other (separated 
    // by at least 1.0), for now this is a stupid n^2 algorithm
    NSUInteger  nodeCount = m_nodeList.count;
    for (NSUInteger i = 0; i < nodeCount; ++i)
    {
        for (NSUInteger j = i + 1; j < nodeCount; ++j)
        {
            GraphEdge*  edgeTest = [GraphEdge edgeWithFrom:i to:j length:0];
            if (NOT [m_edgeSet containsObject:edgeTest])
            {
                // fetch the two nodes referred to by this edge
                GraphNode* nodeFrom = (GraphNode*) [m_nodeList objectAtIndex:i];
                GraphNode* nodeTo = (GraphNode*) [m_nodeList objectAtIndex:j];
                
                // move each of them half the distance needed for separation
                Vector2*    nodeDelta = [Point2 subtractLeft:nodeFrom.location right:nodeTo.location];
                CGFloat     nodeDeltaLength = nodeDelta.length;
                if (nodeDeltaLength < MINIMUM_SEPARATION)
                {
                    CGFloat     nodeDeltaScale = (1.0f / nodeDeltaLength) * ((nodeDeltaLength - MINIMUM_SEPARATION) * m_springFactor * 0.5f);
                    nodeDelta = [Vector2 scaleLeft:nodeDelta right:nodeDeltaScale];
                    m_lastStepDelta = MAX(nodeDelta.length, m_lastStepDelta);
                    
                    nodeTo.location = [Point2 addLeftPoint:nodeTo.location rightVector:nodeDelta];
                    nodeDelta = [Vector2 scaleLeft:nodeDelta right:-1.0f];
                    nodeFrom.location = [Point2 addLeftPoint:nodeFrom.location rightVector:nodeDelta];
                }
            }
        }
    }
}

- (void) focusOneStep
{
    // move the focus node to the center
    GraphNode*  focusNode = (GraphNode*) [m_nodeList objectAtIndex:m_focusNodeIndex];
    Point2*     origin = [Point2 pointWithX:0.0f Y:0.0f];
    [self halfStepNode:focusNode toLocation:origin];
    
    // sort all of the nodes into connected and unconnected to the focus node
    NSUInteger      nodeCount = m_nodeList.count;
    NSMutableArray* connectedEdges = [NSMutableArray arrayWithCapacity:nodeCount];
    NSMutableArray* unconnectedEdges = [NSMutableArray arrayWithCapacity:nodeCount];
    for (NSUInteger i = 0; i < nodeCount; ++i)
    {
        if (i != m_focusNodeIndex)
        {
            GraphEdge*  edge = [GraphEdge edgeWithFrom:m_focusNodeIndex to:i length:0];
            if ([m_edgeSet containsObject:edge])
            {
                // get the real object and save it for later
                edge = [m_edgeSet member:edge];
                [connectedEdges addObject:edge];
            }
            else
            {
                [unconnectedEdges addObject:edge];
            }
        }
    }
    
    // move the immediate neighbors into position distributed evenly around the circle
    {
        NSUInteger  nodeCount = connectedEdges.count;
        CGFloat     angleSpacing = (M_PI * 2.0f) / (nodeCount + ((nodeCount & 0x01) ? 0 : 1));
        for (NSUInteger i = 0; i < nodeCount; ++i)
        {
            GraphEdge*  edge = [connectedEdges objectAtIndex:i];
            NSUInteger  nodeIndex = (edge.from == m_focusNodeIndex) ? edge.to : edge.from;
            GraphNode*  node = [m_nodeList objectAtIndex:nodeIndex];
            CGFloat     angle = (i + 0.3333f) * angleSpacing;
            CGFloat     x = cosf (angle) * edge.length;
            CGFloat     y = sinf (angle) * edge.length;
            Point2*     nodeLocation = [Point2 pointWithX:x Y:y];
            [self halfStepNode:node toLocation:nodeLocation];
        }
    }
    
    // all other neighbors go back to the outer circle
    {
        NSUInteger  nodeCount = unconnectedEdges.count;
        CGFloat     angleSpacing = (M_PI * 2.0f) / nodeCount;
        CGFloat     radius = 1.0e1f;
        for (NSUInteger i = 0; i < nodeCount; ++i)
        {
            GraphEdge*  edge = [unconnectedEdges objectAtIndex:i];
            NSUInteger  nodeIndex = (edge.from == m_focusNodeIndex) ? edge.to : edge.from;
            GraphNode*  node = [m_nodeList objectAtIndex:nodeIndex];
            CGFloat angle = (i + 0.3333f) * angleSpacing;
            CGFloat x = cosf (angle) * radius;
            CGFloat y = sinf (angle) * radius;
            Point2*     nodeLocation = [Point2 pointWithX:x Y:y];
            [self halfStepNode:node toLocation:nodeLocation];
        }
    }
}

@dynamic nodes;
@dynamic nodeCount;
@dynamic edges;
@dynamic edgeCount;
@dynamic focusNodeIndex;
@synthesize nodesInView = m_nodesInView;
@synthesize edgesInView = m_edgesInView;
@synthesize springFactor = m_springFactor;


- (NSArray*) nodes
{
    return m_nodeList;
}

- (NSUInteger) nodeCount
{
    return m_nodeList.count;
}

- (NSArray*) edges
{
    return [m_edgeSet allObjects];
}

- (NSUInteger) edgeCount
{
    return m_edgeSet.count;
}

- (NSUInteger) focusNodeIndex
{
    return m_focusNodeIndex;
}

- (void) setFocusNodeIndex:(NSUInteger)focusNodeIndex
{
    m_focusNodeIndex = focusNodeIndex;
    [self touchWithReset:true];
    m_nodesInView = [self computeNodesInView];
    m_edgesInView = [self computeEdgesInView:m_nodesInView];
}

- (id) init
{
    self = [super init];
    if (self) 
    {
        m_nodeList = [NSMutableArray array];
        m_edgeSet = [NSMutableSet set];
        
        m_focusNodeIndex = 0;
        m_lastStepDelta = FLT_MAX;
    }
    return self;
}

- (void) initSolver
{
    // move all of the nodes to an outer circle to start
    NSUInteger  nodeCount = m_nodeList.count;
    CGFloat     angleSpacing = (M_PI * 2.0f) / nodeCount;
    for (NSUInteger i = 0; i < nodeCount; ++i)
    {
        GraphNode*  node = [m_nodeList objectAtIndex:i];
        CGFloat angle = i * angleSpacing;
        CGFloat x = cosf (angle) * STARTING_CIRCLE_RADIUS;
        CGFloat y = sinf (angle) * STARTING_CIRCLE_RADIUS;
        Point2*     nodeLocation = [Point2 pointWithX:x Y:y];
        node.location = nodeLocation;
    }
    
    [self touchWithReset:true];
}

- (void) touchWithReset:(bool)reset;
{
    // set the last step delta to insure continued iteration
    m_lastStepDelta = FLT_MAX;
    if (reset)
    {
        m_springFactor = SPRING_FACTOR_MAX * 0.5f * 0.5f * 0.5f * 0.5f;
    }
}

- (bool) solveStep
{
    if (m_lastStepDelta > SOLUTION_TOLERANCE)
    {
        m_lastStepDelta = 0.0f;
        [self focusOneStep];
        
        // update the spring factor
        m_springFactor = MIN(m_springFactor * 2.0f, SPRING_FACTOR_MAX);
        return true;
    }
    m_springFactor = 1.0f;
    return false;
}

- (NSUInteger) addNode
{
    GraphNode*  node = [GraphNode new];
    [m_nodeList addObject:node];
    return m_nodeList.count - 1;
}

- (void) addEdgeFrom:(NSUInteger)from to:(NSUInteger)to length:(CGFloat)length
{
    GraphEdge*  edge = [GraphEdge edgeWithFrom:from to:to length:length];
    [m_edgeSet addObject:edge];
}

- (GraphEdge*) getEdgeFrom:(NSUInteger)from to:(NSUInteger)to
{
    GraphEdge*  edge = [GraphEdge edgeWithFrom:from to:to length:0];
    if ([m_edgeSet containsObject:edge])
    {
        // get the real object and save it for later
        edge = [m_edgeSet member:edge];
        return edge;
    }
    return nil;
}

- (NSInteger) getStringCount
{
    return m_nodeList.count;
}

- (NSString*) getString:(NSInteger)index
{
    return ((GraphNode*) [m_nodeList objectAtIndex:index]).name;
}

@end
