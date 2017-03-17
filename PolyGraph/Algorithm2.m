//------------------------------------------------------------------------------
//  Copyright 2010. All rights reserved.
//------------------------------------------------------------------------------
#import "Algorithm2.h"
#import "Constants2.h"

//------------------------------------------------------------------------------
// implementation
//------------------------------------------------------------------------------
@implementation Algorithm2

//------------------------------------------------------------------------------
// private methods
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// properties
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// public methods
//------------------------------------------------------------------------------
+ (bool) preciseCompareLeft:(double)left right:(double)right withTolerance:(double)tolerance
{
    return (fabs (left - right) <= tolerance); 
}

//------------------------------------------------------------------------------
+ (double) signum:(double)value
{
    return ((value < -EPSILON) ? -1.0 : (value > EPSILON) ? 1.0 : 0.0);
}

//------------------------------------------------------------------------------
+ (NSInteger) quadraticA:(double)a B:(double)b C:(double)c roots:(double*)roots
{
    double  discriminant = (b * b) - (4 * a * c);
    if (discriminant == 0)
    {
        // there is only one real root (or rather, both roots are the same)
        roots[0] = -b / (a + a);
        return 1;
    }
    else if (discriminant > 0)
    {
        // there are two real roots, calculate them in a numerically robust
        // manner since we could have significant error in floating point
        // arithmetic if the two roots are dramatically different in
        // magnitude or if a is very small
        double  root = sqrt (discriminant);
        double  q = -0.5 * (b + ([Algorithm2 signum:b] * root));
        double  root1 = c / q;
        double  root2 = q / a;
        
        // deliver the roots in sorted order
        if (root1 <= root2)
        {
            roots[0] = root1;
            roots[1] = root2;
        }
        else
        {
            roots[0] = root2;
            roots[1] = root1;
        }
        return 2;
    }
    else
    {
        // there are no real roots
        return 0;
    }
}

//------------------------------------------------------------------------------
@end

//------------------------------------------------------------------------------
