#import "BoxedIndex.h"

@implementation BoxedIndex

@synthesize index = m_index;

- (id) initWithIndex:(NSUInteger)index
{
    self = [super init];
    if (self != nil)
    {
        m_index = index;
    }
    return self;
}

+ (BoxedIndex*) boxedIndex:(NSUInteger)index
{
    return [[BoxedIndex alloc] initWithIndex:index];
}

- (NSUInteger) hash
{
    // figure whichever one is the larger of the two
    return m_index;
}

- (BOOL) isEqual:(id)object
{
    BoxedIndex*  test = (BoxedIndex*) object;
    return (test.index == m_index);
}

@end
