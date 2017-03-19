#import "GraphNode.h"

@implementation GraphNode

@synthesize name = m_name;
@synthesize location = m_location;
@synthesize screenLocation = m_screenLocation;

- (id) init
{
    self = [super init];
    if (self) 
    {
        m_name = @"Unnamed";
        m_location = [[Point2 alloc] initWithX:0 Y:0];
    }
    return self;
}

@end
