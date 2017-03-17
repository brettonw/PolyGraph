#define MENU_ITEM_HEIGHT        40
#define MENU_ITEM_TAG           1234
#define MENU_ITEM_DO_NOTHING    -1

@class MenuItem;
@protocol MenuItemDelegate <NSObject>
@optional
- (bool) isMenuItemVisible:(MenuItem*)item;
- (bool) isMenuItemEnabled:(MenuItem*)item;
@end

@interface MenuItem : NSObject
{
    NSInteger                   m_tag;
    NSString*                   m_label;
    NSObject<MenuItemDelegate>* m_delegate;
}

@property (strong)      NSString*                   label;
@property (readonly)    NSInteger                   tag;
@property (strong)      NSObject<MenuItemDelegate>* delegate;
@property (readonly)    bool                        isVisible;
@property (readonly)    bool                        isEnabled;

- (id) initWithLabel:(NSString*)label andTag:(NSInteger)tag;

@end
