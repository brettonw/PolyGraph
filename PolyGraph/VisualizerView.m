#import "VisualizerView.h"
#import "BoxedIndex.h"

#define CIRCLE_DIAMETER     0.45f
#define ANIMATION_RATE      (1.0f / 20.0f)

@implementation VisualizerView

- (void) handlePinch:(UIPinchGestureRecognizer*)pinch
{
    switch (pinch.state)
    {
        case UIGestureRecognizerStateBegan:
            m_savedViewScale = m_viewScale;
            break;
        case UIGestureRecognizerStateChanged:
            m_viewScale = m_savedViewScale * pinch.scale;
            [self setNeedsDisplay];
            break;
        default:
            break;
    }
}

- (NSUInteger) findClosestNodeIndexAtLocation:(Point2*)screenLocation withTolerance:(CGFloat)tolerance
{
    CGFloat     closestLengthSquared = FLT_MAX;
    NSUInteger  closestNode = INVALID_INDEX;
    
    // square the tolerance for faster computation
    CGFloat     toleranceSquared = tolerance * tolerance;
    
    // get the nodes
    NSArray*        nodes = m_graph.nodes;
    NSSet*          view = m_graph.nodesInView;
    for (BoxedIndex* boxedIndex in view)
    {
        GraphNode*  node = (GraphNode*) [nodes objectAtIndex:boxedIndex.index];
        Vector2*    delta = [Point2 subtractLeft:node.screenLocation right:screenLocation];
        CGFloat     deltaLengthSquared = delta.lengthSquared;
        if (deltaLengthSquared < toleranceSquared)
        {
            if (deltaLengthSquared < closestLengthSquared)
            {
                closestLengthSquared = deltaLengthSquared;
                closestNode = boxedIndex.index;
            }
        }
    }
    return closestNode;
}

- (void) showHideMenu:(bool)show
{
}

- (void) buildNodeNameList
{
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGRect  pickerViewRect = CGRectMake(0, statusBarHeight, self.frame.size.width, self.frame.size.height - statusBarHeight);
    m_stringPickerView = [[StringPickerView alloc] initWithFrame:pickerViewRect];
    m_stringPickerView.delegate = m_graph;
    [m_stringPickerView reload];
    [self addSubview:m_stringPickerView];
    m_stringPickerView.frame = CGRectMake(0, self.frame.size.height - m_stringPickerView.frame.size.height, self.frame.size.width, m_stringPickerView.frame.size.height);
}

- (bool) handleMenuAction:(NSInteger)id
{
    switch (id)
    {
        case MENU_ITEM_NEW_NODE:
        {
            NSInteger newNodeIndex = [m_graph addNode];
            GraphNode* graphNode = (GraphNode*) [m_graph.nodes objectAtIndex:newNodeIndex];
            graphNode.name = @"Untitled";
            [m_graph setFocusNodeIndex:newNodeIndex];
            [self setNeedsDisplay];
            return true;
        }
            
        case MENU_ITEM_NEW_EDGE:
        {
            // pop up a list of all the current nodes
            [self buildNodeNameList];
            return true;
        }
        case MENU_ITEM_DELETE:
        {
            return true;
        }
    }
    return false;
}

- (void) buildTestGraph
{
    m_graph = [Graph new];
    
    NSUInteger  bret = [m_graph addNode];
    NSUInteger  roxy = [m_graph addNode];
    NSUInteger  eileen = [m_graph addNode];
    NSUInteger  martine = [m_graph addNode];
    NSUInteger  rain = [m_graph addNode];
    NSUInteger  christen = [m_graph addNode];
    NSUInteger  danielle = [m_graph addNode];
    NSUInteger  oliver = [m_graph addNode];
    NSUInteger  ame = [m_graph addNode];
    NSUInteger  david = [m_graph addNode];
    NSUInteger  brian = [m_graph addNode];
    NSUInteger  joh = [m_graph addNode];
    
    NSArray*    nodes = m_graph.nodes;
    ((GraphNode*) [nodes objectAtIndex:bret]).name = @"Bret";
    ((GraphNode*) [nodes objectAtIndex:roxy]).name = @"Roxy";
    ((GraphNode*) [nodes objectAtIndex:eileen]).name = @"Eileen";
    ((GraphNode*) [nodes objectAtIndex:martine]).name = @"Martine";
    ((GraphNode*) [nodes objectAtIndex:rain]).name = @"Rain";
    ((GraphNode*) [nodes objectAtIndex:christen]).name = @"Christen";
    ((GraphNode*) [nodes objectAtIndex:danielle]).name = @"Danielle";
    ((GraphNode*) [nodes objectAtIndex:oliver]).name = @"Oliver";
    ((GraphNode*) [nodes objectAtIndex:ame]).name = @"Ame";
    ((GraphNode*) [nodes objectAtIndex:david]).name = @"David";
    ((GraphNode*) [nodes objectAtIndex:brian]).name = @"Brian";
    ((GraphNode*) [nodes objectAtIndex:joh]).name = @"Joh";
    
    [m_graph addEdgeFrom:bret to:roxy length:1.0];
    [m_graph addEdgeFrom:bret to:eileen length:1.0];
    [m_graph addEdgeFrom:bret to:martine length:2.0];
    [m_graph addEdgeFrom:bret to:joh length:2.0];
    [m_graph addEdgeFrom:bret to:christen length:2.0];

    [m_graph addEdgeFrom:roxy to:brian length:3.0];

    [m_graph addEdgeFrom:eileen to:oliver length:3.0];
    
    [m_graph addEdgeFrom:oliver to:ame length:1.0];

    [m_graph addEdgeFrom:ame to:david length:2.0];

    [m_graph addEdgeFrom:martine to:rain length:3.0];

    [m_graph addEdgeFrom:christen to:danielle length:3.0];

    [m_graph initSolver];
    m_graph.focusNodeIndex = bret;
}

- (id)init
{
    CGRect  frame = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:frame];
    if (self) {
        // add the menu
        CGRect  clientRect = self.frame;
        m_menuView = [[MenuView alloc] initWithParentFrame:clientRect];
        [self addSubview:m_menuView];
        m_menuView.delegate = self;
        
        // add the menu options
        [m_menuView addMenuItemWithLabel:@"New Node" andTag:MENU_ITEM_NEW_NODE];
        [m_menuView addMenuItemWithLabel:@"New Edge" andTag:MENU_ITEM_NEW_EDGE];
        [m_menuView addMenuItemWithLabel:@"Delete" andTag:MENU_ITEM_DELETE];

        // set up the pinch gesture recognizer
        UIPinchGestureRecognizer*   pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        [self addGestureRecognizer:pinch];
        
        self.backgroundColor = [UIColor whiteColor];
        
        // compute the center of the screen
        CGFloat     midX = self.frame.size.width * 0.5f;
        CGFloat     midY = self.frame.size.height * 0.5f;
        m_screenCenter = [Point2 pointWithX:midX Y:midY];
        
        m_viewScale = 48.0f;
        m_viewCenter = [[Point2 alloc] initWithX:0.0f Y:0.0f];
        
        [self buildTestGraph];
    }
    return self;
}

- (void) animateSolution:(NSTimer*)timer
{
    [self setNeedsDisplay];
}

- (Point2*) computeLocation:(Point2*)screenLocation
{
    Vector2*    scaledDelta = [Point2 subtractLeft:screenLocation right:m_screenCenter];
    Vector2*    viewDelta = [Vector2 scaleLeft:scaledDelta right:(1.0f / m_viewScale)];
    Point2*     location = [Point2 addLeftPoint:m_viewCenter rightVector:viewDelta];
    return location;
}

- (Point2*) computeScreenLocation:(Point2*)location
{
    // compute the screen location of the node
    Vector2*    viewDelta = [Point2 subtractLeft:location right:m_viewCenter];
    Vector2*    scaledDelta = [Vector2 scaleLeft:viewDelta right:m_viewScale];
    Point2*     screenLocation = [Point2 addLeftPoint:m_screenCenter rightVector:scaledDelta];
    return screenLocation;
}

- (void) drawNode:(GraphNode*)node inContext:(CGContextRef)contextRef
{
    CGFloat     circleDisplayDiameter = CIRCLE_DIAMETER * m_viewScale;
    CGFloat     circleDisplayRadius = circleDisplayDiameter * 0.5f;
    
    Point2*     nodeCenterPt = node.screenLocation;
    CGRect  circleRect = CGRectMake (nodeCenterPt.x - circleDisplayRadius, nodeCenterPt.y - circleDisplayRadius, circleDisplayDiameter, circleDisplayDiameter);
    CGContextFillEllipseInRect(contextRef, circleRect);
    CGContextStrokeEllipseInRect(contextRef, circleRect);
    
    // draw the names
    CGContextSetRGBFillColor (contextRef, 0.0f, 0.0f, 0.0f, 1.0f);
    CGAffineTransform xform = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0);
    CGContextSetTextMatrix (contextRef, xform);
    CGFloat fontSize = m_viewScale * 0.25f;
    CGContextSelectFont(contextRef, "Helvetica", fontSize, kCGEncodingMacRoman);
    CGPoint startTextPosition = CGContextGetTextPosition (contextRef);
    CGContextSetTextDrawingMode(contextRef, kCGTextInvisible);
    CGContextShowText(contextRef, [node.name UTF8String], node.name.length);
    CGPoint endTextPosition = CGContextGetTextPosition (contextRef);
    CGFloat textWidth = endTextPosition.x - startTextPosition.x;
    
    CGContextSetTextPosition(contextRef, nodeCenterPt.x - (textWidth * 0.5f), nodeCenterPt.y + circleDisplayRadius + fontSize);
    CGContextSetTextDrawingMode(contextRef, kCGTextFill);
    CGContextShowText(contextRef, [node.name UTF8String], node.name.length);
}

- (void) drawRect:(CGRect)rect
{
    // get the nodes
    NSArray*        nodes = m_graph.nodes;

    // get the focus node
    NSUInteger      focusNodeIndex = m_graph.focusNodeIndex;
    GraphNode*      focusNode = (GraphNode*) [nodes objectAtIndex:focusNodeIndex];
    
    // get the view we want to draw, and project all of the nodes in the view
    NSSet*          view = m_graph.nodesInView;
    for (BoxedIndex* boxedIndex in view)
    {
        GraphNode*  node = (GraphNode*) [nodes objectAtIndex:boxedIndex.index];
        node.screenLocation = [self computeScreenLocation:node.location];
    }
    
    // get the drawing contexts
    CGContextRef    contextRef = UIGraphicsGetCurrentContext ();
    CGContextSaveGState (contextRef);
    
    {
        // draw some grid lines
        Point2*         origin = [self computeScreenLocation:[Point2 pointWithX:0.0f Y:0.0f]];
        CGContextSetRGBStrokeColor(contextRef, 0.9f, 0.9f, 0.9f, 1.0f);
        CGContextBeginPath (contextRef);
        CGContextMoveToPoint(contextRef, origin.x, -1024.0f);
        CGContextAddLineToPoint(contextRef, origin.x, 1024.0f);
        CGContextMoveToPoint(contextRef, -1024.0f, origin.y);
        CGContextAddLineToPoint(contextRef, 1024.0f, origin.y);
        CGContextStrokePath (contextRef);
        
        // draw some concentric circles
        for (NSUInteger i = 1; i <= 5; ++i)
        {
            CGFloat radius = 2.0f * i * m_viewScale;
            CGFloat diameter = radius * 2.0f;
            CGRect  circleRect = CGRectMake (origin.x - radius, origin.y - radius, diameter, diameter);
            CGContextStrokeEllipseInRect(contextRef, circleRect);
        }
    }
    
    // draw the connected edges
    NSArray*    edges = m_graph.edgesInView;
    NSUInteger  edgeCount = edges.count;
    CGContextSetRGBStrokeColor (contextRef, 1.0f, 0.0f, 0.0, 1.0f);
    CGContextSetLineWidth(contextRef, 1.5f);
    CGContextBeginPath (contextRef);
    for (NSUInteger i = 0; i < edgeCount; ++i) 
    {
        // get the edge
        GraphEdge*  edge = [edges objectAtIndex:i];
        
        // check to see if the edge is an immediately connected one
        if ((edge.from == focusNodeIndex) OR (edge.to == focusNodeIndex))
        {
            // get the two nodes referred to by this edge
            GraphNode*  nodeFrom = [nodes objectAtIndex:edge.from];
            GraphNode*  nodeTo = [nodes objectAtIndex:edge.to];
            
            // get the points for the edge endpoints
            Point2*     nodeFromPt = nodeFrom.screenLocation;
            Point2*     nodeToPt = nodeTo.screenLocation;
            
            // draw a line between the two points
            CGContextMoveToPoint (contextRef, nodeFromPt.x, nodeFromPt.y);
            CGContextAddLineToPoint (contextRef, nodeToPt.x, nodeToPt.y);
            CGContextStrokePath (contextRef);
        }
    }
    CGContextStrokePath (contextRef);
    
    // draw the unconnected edges
    CGContextSetRGBStrokeColor (contextRef, 1.0f, 0.0f, 0.0, 0.15f);
    CGContextSetLineWidth(contextRef, 1.0f);
    CGContextBeginPath (contextRef);
    for (NSUInteger i = 0; i < edgeCount; ++i) 
    {
        // get the edge
        GraphEdge*  edge = [edges objectAtIndex:i];
        
        // check to see if the edge is an unconnected one
        if ((edge.from != focusNodeIndex) AND (edge.to != focusNodeIndex))
        {
            // get the two nodes referred to by this edge
            GraphNode*  nodeFrom = [nodes objectAtIndex:edge.from];
            GraphNode*  nodeTo = [nodes objectAtIndex:edge.to];
            
            // get the points for the edge endpoints
            Point2*     nodeFromPt = nodeFrom.screenLocation;
            Point2*     nodeToPt = nodeTo.screenLocation;
            
            // draw a line between the two points
            CGContextMoveToPoint (contextRef, nodeFromPt.x, nodeFromPt.y);
            CGContextAddLineToPoint (contextRef, nodeToPt.x, nodeToPt.y);
            CGContextStrokePath (contextRef);
        }
    }
    CGContextStrokePath (contextRef);
    
    // draw the nodes in this view
    CGContextSetLineWidth(contextRef, 1.0f);
    CGContextSetRGBStrokeColor (contextRef, 0.0f, 0.0f, 1.0f, 0.5f);
    for (BoxedIndex* boxedIndex in view)
    {
        if (boxedIndex.index == focusNodeIndex)
        {
            CGContextSetRGBFillColor (contextRef, 0.5f, 1.0f, 0.5f, 1.0f);
            [self drawNode:focusNode inContext:contextRef];
        }
        else
        {
            CGContextSetRGBFillColor (contextRef, 0.9f, 0.9f, 1.0f, 1.0f);
            [self drawNode:[nodes objectAtIndex:boxedIndex.index] inContext:contextRef];
        }
    }
    
    CGContextRestoreGState (contextRef);
    
    if ([m_graph solveStep])
    {
        // set the view center to be the focus node location
        Point2*     origin = [Point2 pointWithX:0.0f Y:0.0f];
        if (NOT [Point2 equalLeft:origin right:m_viewCenter])
        {
            Vector2*    accumulator = [[Vector2 alloc] initWithTuple:m_viewCenter];
            accumulator = [Vector2 scaleLeft:accumulator right:1.0f - m_graph.springFactor];
            m_viewCenter = [[Point2 alloc] initWithTuple:accumulator];
        }
        [NSTimer scheduledTimerWithTimeInterval:ANIMATION_RATE target:self selector:@selector(animateSolution:) userInfo:nil repeats:NO];
    }
}

// touch strategies
// - touch and release on a node, recenter the focus on that node
// - touch a node and drag, adjust the length of the edge ffrom the touched node to the focused node
// - touch empty space and drag, move viewpoint around
// - double touch, zoom in or out

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    if (touches.count == 1)
    {
        // we just started the touch, so it hasn't moved
        m_touchMoved = false;
        
        // get the touch start
        UITouch*    touch = (UITouch*) [touches anyObject];
        CGPoint     touchPt = [touch locationInView:self];
        m_touchStart = [Point2 pointWithX:touchPt.x Y:touchPt.y];
        
        // check to see if this is a touch on a node
        m_touchedNodeIndex = [self findClosestNodeIndexAtLocation:m_touchStart withTolerance:20.0f];
        if ((m_touchedNodeIndex != INVALID_INDEX) AND (m_touchedNodeIndex != m_graph.focusNodeIndex))
        {
            // if the user drags, they will adjust the length of the edge 
            // connecting the clicked node to the focused node, otherwise they
            // will focus on the selected node on release
        }
        else
        {
            // drag viewpoint mode
            m_savedViewCenter = m_viewCenter;
        }
    }
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    if (touches.count == 1)
    {
        // the touch moved
        m_touchMoved = true;
        
        // precompute some common aspects of the calculations
        UITouch*    touch = (UITouch*) [touches anyObject];
        CGPoint     touchPt = [touch locationInView:self];
        Point2*     touchMovedPt = [Point2 pointWithX:touchPt.x Y:touchPt.y];
        
        // based on the mode, decide what to do
        if ((m_touchedNodeIndex != INVALID_INDEX) AND (m_touchedNodeIndex != m_graph.focusNodeIndex))
        {
            // adjust the length of the edge connecting the clicked node to the focused node
            GraphEdge*  edge = [m_graph getEdgeFrom:m_graph.focusNodeIndex to:m_touchedNodeIndex];
            if (edge != nil)
            {
                // compute the world distance between the focus node and the touched point
                NSArray*    nodes = m_graph.nodes;
                GraphNode*  focusNode = (GraphNode*) [nodes objectAtIndex:m_graph.focusNodeIndex];
                Point2*     touchedLocation = [self computeLocation:touchMovedPt];
                Vector2*    touchedLocationDelta = [Point2 subtractLeft:focusNode.location right:touchedLocation];
                CGFloat     newLength = touchedLocationDelta.length;
                edge.length = newLength;
                [m_graph touchWithReset:false];
                [self setNeedsDisplay];
            }
        }
        else
        {
            // drag viewpoint mode
            Vector2*    touchDelta = [Point2 subtractLeft:m_touchStart right:touchMovedPt];
            Vector2*    scaledTouchDelta = [Vector2 scaleLeft:touchDelta right:1.0f / m_viewScale];
            m_viewCenter = [Point2 addLeftPoint:m_savedViewCenter rightVector:scaledTouchDelta];
            [self setNeedsDisplay];
        }
    }
}

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    if (touches.count == 1)
    {
        if (NOT m_touchMoved)
        {
            if ((m_touchedNodeIndex != INVALID_INDEX) AND (m_touchedNodeIndex != m_graph.focusNodeIndex))
            {
                m_graph.focusNodeIndex = m_touchedNodeIndex;
                [self setNeedsDisplay];
            }
        }
    }
}

- (void) touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
    [super touchesCancelled:touches withEvent:event];
}

@end
