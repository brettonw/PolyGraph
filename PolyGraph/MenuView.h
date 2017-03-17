#import "MenuItem.h"

#define MENU_GRILL_HEIGHT   40.0f

@protocol MenuViewDelegate <NSObject>
@optional
- (void) showHideMenu:(bool)show;
- (bool) handleMenuAction:(NSInteger)id;
@end

@interface MenuView : UIView
{
    UIButton*                   m_menuButton;
    UIView*                     m_menuView;
    bool                        m_open;
    CGFloat                     m_viewTop;
    NSMutableArray*             m_menuItems;
}

@property (weak) NSObject<MenuViewDelegate>*   delegate;

- (id) initWithParentFrame:(CGRect)frame;
- (MenuItem*) addMenuItemWithLabel:(NSString*)label andTag:(NSInteger)tag;
- (void) closeMenu;

@end
