#import "Graph.h"
#import "MenuView.h"
#import "StringPickerView.h"

#define MENU_ITEM_BASE      100
#define MENU_ITEM_NEW_NODE  (MENU_ITEM_BASE + 1)
#define MENU_ITEM_NEW_EDGE  (MENU_ITEM_BASE + 2)
#define MENU_ITEM_DELETE    (MENU_ITEM_BASE + 3)

@interface VisualizerView : UIView <MenuViewDelegate>
{
    MenuView*           m_menuView;
    StringPickerView*   m_stringPickerView;
    
    Graph*              m_graph;
    
    Point2*             m_screenCenter;
    Point2*             m_viewCenter;
    CGFloat             m_viewScale;
    
    NSUInteger          m_touchMoved;
    NSUInteger          m_touchedNodeIndex;
    Point2*             m_savedViewCenter;
    CGFloat             m_savedViewScale;
    Point2*             m_touchStart;
}

@end
