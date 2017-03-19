#import "Point2.h"

@interface GraphNode : NSObject
{
    Point2*     m_location;
    Point2*     m_screenLocation;
    NSString*   m_name;
}

@property (strong) NSString*    name;
@property (strong) Point2*      location;
@property (strong) Point2*      screenLocation;

@end
