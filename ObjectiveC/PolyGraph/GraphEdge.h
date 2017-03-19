@interface GraphEdge : NSObject <NSObject>
{
    NSUInteger   m_from;
    NSUInteger   m_to;
    CGFloat      m_length;
}

@property NSUInteger from;
@property NSUInteger to;
@property CGFloat    length;

- (id) initWithFrom:(NSUInteger)from to:(NSUInteger)to length:(CGFloat)length;
+ (GraphEdge*) edgeWithFrom:(NSUInteger)from to:(NSUInteger)to length:(CGFloat)length;
@end
