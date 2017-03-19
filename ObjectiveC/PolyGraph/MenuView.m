#import "MenuView.h"
#import "ShinyGradientView.h"
#import "Utility.h"

@implementation MenuView

- (UIButton*) addButtonItemLabel:(NSString*)label frame:(CGRect)itemFrame tag:(NSInteger)itemTag
{
    // create the view that will be used to contain the button
    UIView* itemView = [[UIView alloc] initWithFrame:itemFrame];
    itemView.tag = MENU_ITEM_TAG;
    itemView.clipsToBounds = YES;
    itemView.backgroundColor = [UIColor colorWithWhite:0.1f alpha:0.9f];
    itemView.opaque = YES;
    
    // create the button
    UIButton*   itemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    itemButton.frame = CGRectMake(0, 0, itemFrame.size.width, itemFrame.size.height);
    if (label != nil)
    {
        [itemButton setTitle:label forState:UIControlStateNormal];
        [itemButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [itemButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        itemButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        itemButton.titleLabel.numberOfLines = 0;
        itemButton.titleLabel.textAlignment = UITextAlignmentCenter;
    }
    itemButton.tag = itemTag;
    [itemButton addTarget:self action:@selector(buttonActionHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    // install the new subviews
    [itemView addSubview:itemButton];
    [Utility addLineInView:itemButton atY:0 withColor:[UIColor colorWithWhite:1.0f alpha:0.25f]];
    [Utility addLineInView:itemButton atY:itemFrame.size.height - 1 withColor:[UIColor colorWithWhite:0.0f alpha:0.25f]];
    [self addSubview:itemView];
    
    // return the button for any further manipulation
    return itemButton;
}

- (NSInteger) buildMenu
{
    // clear out any existing buttons
    [Utility cleanOutSubviews:self withTag:MENU_ITEM_TAG];
    
    // save the animation state
    BOOL    animationsAreEnabled = [UIView areAnimationsEnabled];
    [UIView setAnimationsEnabled:NO];
    
    // count the visible items
    NSInteger   itemCount = 0;
    for (NSInteger i = 0; i < [m_menuItems count]; ++i)
    {
        MenuItem*   item = (MenuItem*) [m_menuItems objectAtIndex:i];
        if (item.isVisible)
        {
            ++itemCount;
        }
    }
    
    // loop over all the items adding buttons
    CGFloat y = MENU_GRILL_HEIGHT;
    for (NSInteger i = 0; i < [m_menuItems count]; ++i)
    {
        MenuItem*   item = (MenuItem*) [m_menuItems objectAtIndex:i];
        if (item.isVisible)
        {
            // create a new item
            CGRect  itemFrame = CGRectMake(0, y, self.frame.size.width, MENU_ITEM_HEIGHT);
            [self addButtonItemLabel:item.label frame:itemFrame tag:item.tag];
            y += MENU_ITEM_HEIGHT;
        }
    }
    
    // set the frame height
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, y);
    
    // re-enable animations
    [UIView setAnimationsEnabled:animationsAreEnabled];
    
    // return the number of rows created
    return itemCount;
}

- (bool) internalOpenMenu
{
    bool        result = false;
    NSInteger   rows = [self buildMenu];
    if (rows > 0)
    {
        // set up an animation
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.25f];
        
        // open the menu
        CGFloat     y = m_viewTop - (rows * MENU_ITEM_HEIGHT);
        self.frame = CGRectMake(0, y, self.frame.size.width, self.frame.size.height);
        
        // commit the animations
        [UIView commitAnimations];
        
        // call the delegate for the change
        m_open = true;
        if ((delegate != nil) AND [delegate respondsToSelector:@selector(showHideMenu:)])
        {
            [delegate showHideMenu:m_open];
        }
        result = true;
    }
    return result;
}

- (void) internalCloseMenu
{
    // set up an animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25f];
    
    // close the menu
    self.frame = CGRectMake(0, m_viewTop, self.frame.size.width, self.frame.size.height);
    
    // commit the animations
    [UIView commitAnimations];
    
    // call the delegate for the change
    m_open = false;
    if ((delegate != nil) AND [delegate respondsToSelector:@selector(showHideMenu:)])
    {
        [delegate showHideMenu:m_open];
    }
}

- (void) buttonActionHandler:(UIView*)view
{
    [self internalCloseMenu];
    
    // call back out to the delegate with the action code from the sender tag
    if ((delegate != nil) AND [delegate respondsToSelector:@selector(handleMenuAction:)])
    {
        [delegate handleMenuAction:view.tag];
    }
}

- (void) handleSwipeUpGesture:(UISwipeGestureRecognizer*)recognizer
{
    if (NOT m_open)
    {
        [self internalOpenMenu];
    }
}

- (void) handleSwipeDownGesture:(UISwipeGestureRecognizer*)recognizer
{
    if (m_open)
    {
        [self internalCloseMenu];
    }
}

@synthesize delegate;

- (id) initWithParentFrame:(CGRect)frame
{
    // create the menu bar as a gradient view
    CGRect              grillBackgroundRect = CGRectMake(0, 0, frame.size.width, MENU_GRILL_HEIGHT);
    ShinyGradientView*  grillBackgroundView = [[ShinyGradientView alloc] initWithFrame:grillBackgroundRect];
                                            
    // load the grill view to size the menu bar
    //UIImageView*    grillBackgroundView = [self createImageView:@"GrillBackground"];
    CGRect  menuFrame = CGRectMake(0, frame.origin.y + (frame.size.height - MENU_GRILL_HEIGHT), frame.size.width, MENU_GRILL_HEIGHT);
    self = [super initWithFrame:menuFrame];
    if (self != nil) 
    {
        // add the grill at the top
        [self addSubview:grillBackgroundView];
        UIImageView*    grillView = [Utility createImageView:@"Grill"];
        [grillBackgroundView addSubview:grillView];
        [Utility xyCenterView:grillView];
        
        // add a couple of shading lines
        [Utility addLineInView:grillBackgroundView atY:0 withColor:[UIColor colorWithWhite:1.0f alpha:0.25f]];
        [Utility addLineInView:grillBackgroundView atY:(MENU_GRILL_HEIGHT - 1) withColor:[UIColor colorWithWhite:0.0f alpha:0.25f]];
        
        // stop the stupid view from stretching when we resize it
        self.contentMode = UIViewContentModeTop;
        
        // default state
        m_open = false;
        m_viewTop = menuFrame.origin.y;
        m_menuItems = [[NSMutableArray alloc] initWithCapacity:10];
        self.backgroundColor = [UIColor clearColor];

        // set up gesture recognizers for swiping the menu up and down
        UISwipeGestureRecognizer*   recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUpGesture:)];
        recognizer.direction = UISwipeGestureRecognizerDirectionUp;
        [self addGestureRecognizer:recognizer];

        recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDownGesture:)];
        recognizer.direction = UISwipeGestureRecognizerDirectionDown;
        [self addGestureRecognizer:recognizer];
}
    return self;
}

- (MenuItem*) addMenuItemWithLabel:(NSString*)label andTag:(NSInteger)tag
{
    MenuItem*   item = [[MenuItem alloc] initWithLabel:label andTag:tag];
    [m_menuItems addObject:item];
    return item;
}

- (void) closeMenu
{
    if (m_open)
    {
        [self internalCloseMenu];
    }
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
}

- (void) touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
}

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
}

@end


