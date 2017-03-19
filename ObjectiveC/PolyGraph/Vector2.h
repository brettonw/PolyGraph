//------------------------------------------------------------------------------
//  Copyright 2010. All rights reserved.
//------------------------------------------------------------------------------
#import "Tuple2.h"

//------------------------------------------------------------------------------
// interface
//------------------------------------------------------------------------------
@interface Vector2 : Tuple2 
{
}

//------------------------------------------------------------------------------
// properties
//------------------------------------------------------------------------------
@property (nonatomic, readonly) Vector2*    perpendicular;
@property (nonatomic, readonly) double      lengthSquared;
@property (nonatomic, readonly) double      length;
@property (nonatomic, readonly) bool        isUnit;

//------------------------------------------------------------------------------
// public methods
//------------------------------------------------------------------------------
- (bool) isUnitWithTolerance:(double)tolerance;
+ (Vector2*) subtractLeft:(Vector2*)left right:(Vector2*)right;
+ (Vector2*) addLeft:(Vector2*)left right:(Vector2*)right;
+ (Vector2*) scaleLeft:(Vector2*)left right:(double)right;
+ (Vector2*) normalize:(Vector2*)vector;
+ (double) crossProductLeft:(Vector2*)left right:(Vector2*)right;
+ (Vector2*) vectorWithX:(CGFloat)x Y:(CGFloat)y;

//------------------------------------------------------------------------------
@end

//------------------------------------------------------------------------------
