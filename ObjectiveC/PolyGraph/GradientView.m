#import "GradientView.h"
#import "Utility.h"

typedef struct {
    CGFloat   topRed;
    CGFloat   topGreen;
    CGFloat   topBlue;

    CGFloat   bottomRed;
    CGFloat   bottomGreen;
    CGFloat   bottomBlue;
} GradientParameters;

static void gradientCallback (void* info, const CGFloat* input, CGFloat* output)
{
    GradientParameters*    params = (GradientParameters*) info;
    CGFloat   interpolantB = *input;
    CGFloat   interpolantA = 1.0 - interpolantB;
    output[0] = (params->topRed * interpolantA) + (params->bottomRed * interpolantB);
    output[1] = (params->topGreen * interpolantA) + (params->bottomGreen * interpolantB);
    output[2] = (params->topBlue * interpolantA) + (params->bottomBlue * interpolantB);
    output[3] = 1.0;
}

@implementation GradientView

@synthesize topColor;
@synthesize bottomColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        bottomColor = [UIColor blackColor];
        topColor = [UIColor whiteColor];
    }
    return self;
}

- (void)drawRect:(CGRect)unusedRect
{
    CGContextRef context = UIGraphicsGetCurrentContext ();

    static const CGFloat inputValueRanges[2] = {0, 1};
    static const CGFloat outputValueRanges[8] = {0, 1, 0, 1, 0, 1, 0, 1};
    CGFunctionCallbacks callbacks = {0, gradientCallback, nil};
    static GradientParameters gradientParameters;
    COPY_COLOR (topColor.CGColor, gradientParameters.top)
    COPY_COLOR (bottomColor.CGColor, gradientParameters.bottom)
    CGFunctionRef gradientFunction = CGFunctionCreate (&gradientParameters, 1, inputValueRanges, 4, outputValueRanges, &callbacks);
    
    CGPoint startPoint = CGPointMake (0, 0);
    CGPoint endPoint = CGPointMake (0, self.frame.size.height);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB ();
    CGShadingRef shading = CGShadingCreateAxial (colorspace, startPoint, endPoint, gradientFunction, false, false);
    
    CGContextSaveGState (context);
    CGContextDrawShading (context, shading);
    CGContextRestoreGState (context);
    
    CGShadingRelease (shading);
    CGColorSpaceRelease (colorspace);
    CGFunctionRelease (gradientFunction);
}

@end
