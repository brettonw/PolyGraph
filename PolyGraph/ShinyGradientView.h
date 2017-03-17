#import "GradientView.h"

@interface ShinyGradientView : UIView
{
    GradientView*   m_topHalfView;
    GradientView*   m_bottomHalfView;
}

@property (strong) UIColor*  baseColor;
@property (strong) UIColor*  blendColor;

- (void)computeGradientColors;

@end
