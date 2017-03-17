#import "UIButton+Glass.h"
#import "Utility.h"

#define kCornerRadius 6.0f
#define kStrokeColor [UIColor colorWithWhite:0.1f alpha:0.5f]
#define kStrokeWidth 1.0f

@implementation UIButton (Glass)

/*
- (void)computeGradientColors
{
    baseColor = [UIColor blackColor];
    blendColor = [UIColor darkGrayColor];
    
    m_topHalfView.topColor = [Utility blendColors:baseColor withBaseWeight:0.55f andBlendColor:[UIColor whiteColor]];
    m_topHalfView.bottomColor = [Utility blendColors:baseColor withBaseWeight:0.75f andBlendColor:[UIColor whiteColor]];
    [m_topHalfView setNeedsDisplay];
    m_bottomHalfView.topColor = baseColor;
    m_bottomHalfView.bottomColor = [Utility blendColors:baseColor withBaseWeight:0.6f andBlendColor:blendColor];
    [m_bottomHalfView setNeedsDisplay];
}
 */

- (void)setGlass:(UIColor*)baseColor forState:(UIControlState)state
{
    // create an image context and use it to draw
    CGSize imageSize = CGSizeMake (self.bounds.size.width, self.bounds.size.height);
    UIGraphicsBeginImageContext (imageSize);
    CGContextRef context = UIGraphicsGetCurrentContext ();

    CGContextSetBlendMode (context, kCGBlendModeOverlay);
    
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB ();
    
    UIColor*    gradientStart = [UIColor colorWithWhite:1.0f alpha:0.5f];
    UIColor*    gradientEnd = [UIColor colorWithWhite:1.0f alpha:0.0f];
    NSArray*    colors = [NSArray arrayWithObjects:(id) gradientStart.CGColor, (id) gradientEnd.CGColor, nil];
    CGFloat     locations[] = {0.0f, 0.5f};
    CGGradientRef _gradient = CGGradientCreateWithColors (rgb, (__bridge CFArrayRef)colors, locations);
    CGColorSpaceRelease (rgb);
    CGContextDrawLinearGradient (context, _gradient, CGPointMake (0.0, 0.0f), CGPointMake (0.0, self.bounds.size.height), 0);
    //CGContextFlush (context);
    
    UIBezierPath*   outsideEdge = [UIBezierPath bezierPathWithRoundedRect:CGRectMake (0.0f, 0.0f, imageSize.width, imageSize.height) cornerRadius:kCornerRadius];
    [baseColor setFill];
    [kStrokeColor setStroke];
    outsideEdge.lineWidth = kStrokeWidth;
    [outsideEdge fill];
    
    CGContextSetBlendMode (context, kCGBlendModeNormal);
    [outsideEdge stroke];
    
    // Create the background image
    UIImage*    image = UIGraphicsGetImageFromCurrentImageContext ();    
    UIGraphicsEndImageContext (); 
    
    // Set image as button's background image (stretchable) for the given state
    [self setBackgroundImage:[image stretchableImageWithLeftCapWidth:kCornerRadius topCapHeight:0.0] forState:state];
    
    // Ensure rounded button
    self.clipsToBounds = YES;
    self.layer.cornerRadius = kCornerRadius;
}

@end