@protocol StringPickerViewDataSource <NSObject>
@required
- (NSInteger) getStringCount;
- (NSString*) getString:(NSInteger)index;
@end

@interface StringPickerView : UIView <UIPickerViewDelegate, UIPickerViewDataSource>
{
    UIPickerView*                           m_pickerView;
    NSObject<StringPickerViewDataSource>*   m_delegate;
}

@property (strong) NSObject<StringPickerViewDataSource>*    delegate;

- (void) reload;

@end
