#import "Utility.h"

@implementation Utility

+ (void) cleanOutSubviews:(UIView*)view withTag:(NSInteger)tag
{
    for (NSInteger i = 0; i < view.subviews.count;) 
    {
        UIView* subview = (UIView*) [view.subviews objectAtIndex:i];
        if (subview.tag == tag)
        {
            [subview removeFromSuperview];
        }
        else
        {
            ++i;
        }
    }
}

+ (UIImageView*) createImageView:(NSString*)resourceName
{
	UIImage *img = [UIImage imageNamed:resourceName];
	if (img == nil) return nil;
	
	UIImageView *view = [[UIImageView alloc] initWithImage:img];
	//view.frame = CGRectMake(0.0, 0.0, img.size.width, img.size.height);
	return view;
}

+ (CGFloat) addLineInView:(UIView*)view atY:(CGFloat)y withColor:(UIColor*)color
{
    CGRect  frame = CGRectMake(0, y, view.frame.size.width, 1);
    UIView* lineView = [[UIView alloc] initWithFrame:frame];
    lineView.backgroundColor = color;
    [view addSubview:lineView];
    return CGRectGetMaxY(frame);
}

+ (void) xyCenterView:(UIView*)view
{
    UIView* superview = view.superview;
    CGRect  superframe = superview.frame;
    CGRect  frame = view.frame;
    frame.origin.x = (superframe.size.width - frame.size.width) / 2;
    frame.origin.y = (superframe.size.height - frame.size.height) / 2;
    view.frame = frame;
}

+ (void) yCenterView:(UIView*)view
{
    UIView* superview = view.superview;
    CGRect  superframe = superview.frame;
    CGRect  frame = view.frame;
    frame.origin.y = (superframe.size.height - frame.size.height) / 2;
    view.frame = frame;
}

+ (UIColor*) blendColors:(UIColor*)colorA withBaseWeight:(CGFloat)baseWeight andBlendColor:(UIColor*)colorB
{
    float   baseRed, baseGreen, baseBlue;
    float   blendRed, blendGreen, blendBlue;
    COPY_COLOR (colorA.CGColor, base)
    COPY_COLOR (colorB.CGColor, blend)
    float   blendWeight = 1.0f - baseWeight;
    float   resultRed = (baseRed * baseWeight) + (blendRed * blendWeight);
    float   resultGreen = (baseGreen * baseWeight) + (blendGreen * blendWeight);
    float   resultBlue = (baseBlue * baseWeight) + (blendBlue * blendWeight);
    return [UIColor colorWithRed:resultRed green:resultGreen blue:resultBlue alpha:1.0f];
}


@end
