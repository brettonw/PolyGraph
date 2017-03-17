@interface BoxedIndex : NSObject <NSObject>
{
    NSUInteger  m_index;
}
@property NSUInteger index;

- (id) initWithIndex:(NSUInteger)index;
+ (BoxedIndex*) boxedIndex:(NSUInteger)index;

@end
