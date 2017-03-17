//------------------------------------------------------------------------------
//  Copyright 2010. All rights reserved.
//------------------------------------------------------------------------------
#import "Vector2.h"
#import "Algorithm2.h"
#import "Constants2.h"

//------------------------------------------------------------------------------
// implementation
//------------------------------------------------------------------------------
@implementation Vector2

//------------------------------------------------------------------------------
// private methods
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// properties
//------------------------------------------------------------------------------
@dynamic perpendicular;
@dynamic lengthSquared;
@dynamic length;
@dynamic isUnit;

//------------------------------------------------------------------------------
- (Vector2*) perpendicular
{
    return [[Vector2 alloc] initWithX:m_y Y:-m_x];
}

//------------------------------------------------------------------------------
- (double) lengthSquared
{
    return [Tuple2 dotProductLeft:self right:self];
}

//------------------------------------------------------------------------------
- (double) length
{
    return sqrt ([self lengthSquared]);
}

//------------------------------------------------------------------------------
- (bool) isUnit
{
    return [self isUnitWithTolerance:EPSILON];
}

//------------------------------------------------------------------------------
// public methods
//------------------------------------------------------------------------------
- (bool) isUnitWithTolerance:(double)tolerance
{
    return [Algorithm2 preciseCompareLeft:[self length] right:1.0 withTolerance:tolerance];
}

//------------------------------------------------------------------------------
+ (Vector2*) subtractLeft:(Vector2*)left right:(Vector2*)right
{
    return [[Vector2 alloc] initWithX:left.x - right.x Y:left.y - right.y];
}

//------------------------------------------------------------------------------
+ (Vector2*) addLeft:(Vector2*)left right:(Vector2*)right
{
    return [[Vector2 alloc] initWithX:left.x + right.x Y:left.y + right.y];
}

//------------------------------------------------------------------------------
+ (Vector2*) scaleLeft:(Vector2*)left right:(double)right
{
    return [[Vector2 alloc] initWithX:left.x * right Y:left.y * right];
}

//------------------------------------------------------------------------------
+ (Vector2*) normalize:(Vector2*)vector
{
    return [Vector2 scaleLeft:vector right:(1.0 / vector.length)];
}

//------------------------------------------------------------------------------
+ (double) crossProductLeft:(Vector2*)left right:(Vector2*)right
{
    return (left.x * right.y) + (left.y * right.x);
}

//------------------------------------------------------------------------------
+ (Vector2*) vectorWithX:(CGFloat)x Y:(CGFloat)y
{
    return [[Vector2 alloc] initWithX:x Y:y];
}

//------------------------------------------------------------------------------
- (NSString*) description
{
    return [NSString stringWithFormat:@"V %@", [super description]];
}

//------------------------------------------------------------------------------
@end

//------------------------------------------------------------------------------
