#import "MenuItem.h"

@implementation MenuItem

@synthesize label = m_label;
@synthesize tag = m_tag;
@synthesize delegate = m_delegate;

@dynamic isVisible;
- (bool) isVisible
{
    bool result = true;
    if ((m_delegate != nil) AND [m_delegate respondsToSelector:@selector(isMenuItemVisible:)])
    {
        result = [m_delegate isMenuItemVisible:self];
    }
    return result;
}

@dynamic isEnabled;
- (bool) isEnabled
{
    bool result = true;
    if ((m_delegate != nil) AND [m_delegate respondsToSelector:@selector(isMenuItemEnabled:)])
    {
        result = [m_delegate isMenuItemEnabled:self];
    }
    return result;
}

- (id) initWithLabel:(NSString*)label andTag:(NSInteger)tag
{
    self = [super init];
    if (self != nil) 
    {
        m_delegate = nil;
        
        m_label = label;
        m_tag = tag;
    }
    return self;
}

@end
