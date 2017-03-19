#import "ShinyGradientView.h"
#import "Utility.h"

@implementation ShinyGradientView

@synthesize baseColor;
@synthesize blendColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        CGRect  topHalfRect = CGRectMake(0, 0, frame.size.width, frame.size.height / 2.0f);
        m_topHalfView = [[GradientView alloc] initWithFrame:topHalfRect];
        [self addSubview:m_topHalfView];
        
        CGRect  bottomHalfRect = CGRectMake(0, CGRectGetMaxY (topHalfRect), frame.size.width, topHalfRect.size.height);
        m_bottomHalfView = [[GradientView alloc] initWithFrame:bottomHalfRect];
        [self addSubview:m_bottomHalfView];
        
        baseColor = [UIColor blackColor];
        blendColor = [UIColor darkGrayColor];
        [self computeGradientColors];
    }
    return self;
}

- (void)computeGradientColors
{
    m_topHalfView.topColor = [Utility blendColors:baseColor withBaseWeight:0.55f andBlendColor:[UIColor whiteColor]];
    m_topHalfView.bottomColor = [Utility blendColors:baseColor withBaseWeight:0.75f andBlendColor:[UIColor whiteColor]];
    [m_topHalfView setNeedsDisplay];
    m_bottomHalfView.topColor = baseColor;
    m_bottomHalfView.bottomColor = [Utility blendColors:baseColor withBaseWeight:0.6f andBlendColor:blendColor];
    [m_bottomHalfView setNeedsDisplay];
}

@end
