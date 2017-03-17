#import "GraphEdge.h"

@implementation GraphEdge

@synthesize from = m_from;
@synthesize to = m_to;
@synthesize length = m_length;

- (id) initWithFrom:(NSUInteger)from to:(NSUInteger)to length:(CGFloat)length
{
    self = [super init];
    if (self) 
    {
        m_from = MIN (from, to);
        m_to = MAX (from, to);
        m_length = length;
    }
    return self;
}

+ (GraphEdge*) edgeWithFrom:(NSUInteger)from to:(NSUInteger)to length:(CGFloat)length
{
    return [[GraphEdge alloc] initWithFrom:from to:to length:length];
}

- (NSUInteger) hash
{
    // figure whichever one is the larger of the two
    return (m_from << 16) | m_to;
}

- (BOOL) isEqual:(id)object
{
    GraphEdge*  testEdge = (GraphEdge*) object;
    return (testEdge.from == m_from) AND (testEdge.to == m_to);
}

@end
