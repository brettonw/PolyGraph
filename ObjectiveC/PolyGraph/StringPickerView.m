#import "StringPickerView.h"
#import "ShinyGradientView.h"
#import "Utility.h"
#import "UIButton+Glass.h"

#define TOOLBAR_HEIGHT  40.0f

@implementation StringPickerView

@synthesize delegate = m_delegate;

- (NSString*) pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [m_delegate getString:row];
}

- (CGFloat) pickerView:(UIPickerView*)pickerView rowHeightForComponent:(NSInteger)component
{
    return 32.0f;
}

- (CGFloat) pickerView:(UIPickerView*)pickerView widthForComponent:(NSInteger)component
{
    return self.frame.size.width;
}

- (void) pickerView:(UIPickerView*)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // yeah, and? call the delegate to get the selection index?
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
    return 1;
}
    
- (NSInteger) pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [m_delegate getStringCount];
}

- (void) closePicker
{
    [self removeFromSuperview];
}

- (void) cancelAction:(UISegmentedControl*)button
{
    [self closePicker];
}

- (void) doneAction:(UISegmentedControl*)button
{
    [self closePicker];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.backgroundColor = [UIColor whiteColor];
        CGFloat y = 0.0f;
        y = [Utility addLineInView:self atY:y withColor:[UIColor colorWithWhite:0.1f alpha:0.90f]];
        y = [Utility addLineInView:self atY:y withColor:[UIColor colorWithWhite:0.5f alpha:0.25f]];
        
        CGRect  toolbarFrame = CGRectMake(0, y, frame.size.width, TOOLBAR_HEIGHT);
        UIView* toolbarView = [[UIView alloc] initWithFrame:toolbarFrame];
        [self addSubview:toolbarView];
        y = CGRectGetMaxY(toolbarFrame);
        
        CGRect  gradientFrame = CGRectMake(0, 0, frame.size.width, TOOLBAR_HEIGHT);
        ShinyGradientView*  gradientView = [[ShinyGradientView alloc] initWithFrame:gradientFrame];
        gradientView.baseColor = [UIColor grayColor];
        [gradientView computeGradientColors];
        [toolbarView addSubview:gradientView];
        
        /*
         UIButton*   cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
         cancelButton.frame = CGRectMake(3, 3, 60, 32);
         [cancelButton setGlass:[UIColor blueColor] forState:UIControlStateNormal];
         [toolbarView addSubview:cancelButton];
         [Utility yCenterView:cancelButton];
         */
        
        // create the done and cancel buttons
        UISegmentedControl* cancelButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Cancel"]];
        //cancelButton.segmentedControlStyle = UISegmentedControlStyleBar;
        cancelButton.momentary = YES;
        cancelButton.tintColor = [UIColor colorWithRed:0.85f green:0.0f blue:0.0f alpha:1.0f];
        cancelButton.frame = CGRectMake(0, 0, 80.0f, cancelButton.frame.size.height);
        cancelButton.center = CGPointMake (20 + (cancelButton.frame.size.width / 2), TOOLBAR_HEIGHT / 2);
        [cancelButton addTarget:self  action:@selector(cancelAction:) forControlEvents:UIControlEventValueChanged];
        [toolbarView addSubview:cancelButton];

        UISegmentedControl* doneButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Done"]];
        //doneButton.segmentedControlStyle = UISegmentedControlStyleBar;
        doneButton.momentary = YES;
        doneButton.tintColor = [UIColor blueColor];
        doneButton.frame = CGRectMake(0, 0, 80.0f, cancelButton.frame.size.height);
        doneButton.center = CGPointMake (frame.size.width - (20 + (doneButton.frame.size.width / 2)), TOOLBAR_HEIGHT / 2);
        [doneButton addTarget:self  action:@selector(doneAction:) forControlEvents:UIControlEventValueChanged];
        [toolbarView addSubview:doneButton];
                
        CGRect  pickerViewFrame = CGRectMake(0, y, frame.size.width, frame.size.height - y);
        m_pickerView = [[UIPickerView alloc] initWithFrame:pickerViewFrame];
        m_pickerView.delegate = self;
        m_pickerView.dataSource = self;
        m_pickerView.showsSelectionIndicator = YES;
        [self addSubview:m_pickerView];
        
}
    return self;
}

- (void) reload
{
    [m_pickerView reloadAllComponents];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, CGRectGetMaxY(m_pickerView.frame));
}

@end
