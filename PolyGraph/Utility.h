#define COPY_COLOR(src, dst)                                                    \
{                                                                               \
    const CGFloat* colorComponents = CGColorGetComponents (src);                \
    size_t         colorComponentCount = CGColorGetNumberOfComponents (src);    \
    if (colorComponentCount >= 3) {                                             \
        dst##Red = colorComponents[0];                                          \
        dst##Green = colorComponents[1];                                        \
        dst##Blue = colorComponents[2];                                         \
    } else if (colorComponentCount >= 1) {                                      \
        dst##Red = colorComponents[0];                                          \
        dst##Green = colorComponents[0];                                        \
        dst##Blue = colorComponents[0];                                         \
    }  else {                                                                   \
        dst##Red = dst##Green = dst##Blue = 0;                                  \
    }                                                                           \
}


@interface Utility : NSObject

+ (void) cleanOutSubviews:(UIView*)view withTag:(NSInteger)tag;
+ (UIImageView*) createImageView:(NSString*)resourceName;
+ (CGFloat) addLineInView:(UIView*)view atY:(CGFloat)y withColor:(UIColor*)color;
+ (void) xyCenterView:(UIView*)view;
+ (void) yCenterView:(UIView*)view;
+ (UIColor*) blendColors:(UIColor*)colorA withBaseWeight:(CGFloat)baseWeight andBlendColor:(UIColor*)colorB;
@end
