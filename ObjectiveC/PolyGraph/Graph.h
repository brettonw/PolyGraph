#import "GraphNode.h"
#import "GraphEdge.h"
#import "Point2.h"
#import "StringPickerView.h"

#define INVALID_INDEX   UINT_MAX

@interface Graph : NSObject <StringPickerViewDataSource>
{
    NSMutableArray* m_nodeList;
    NSMutableSet*   m_edgeSet;
    
    // cached values for the view
    NSUInteger      m_focusNodeIndex;
    NSSet*          m_nodesInView;
    NSArray*        m_edgesInView;
    
    // parameters for solving and animating
    CGFloat         m_lastStepDelta;
    CGFloat         m_springFactor;
}

@property (readonly) NSArray*   nodes;
@property (readonly) NSUInteger nodeCount;
@property (readonly) NSArray*   edges;
@property (readonly) NSUInteger edgeCount;
@property            NSUInteger focusNodeIndex;
@property (readonly) NSSet*     nodesInView;
@property (readonly) NSArray*   edgesInView;
@property (readonly) CGFloat    springFactor;

- (void) initSolver;
- (void) touchWithReset:(bool)reset;
- (bool) solveStep;

- (NSUInteger) addNode;

- (void) addEdgeFrom:(NSUInteger)from to:(NSUInteger)to length:(CGFloat)length;
- (GraphEdge*) getEdgeFrom:(NSUInteger)from to:(NSUInteger)to;

@end
