//
//  EdgeTextField.h
//  Pulmuone_Calendar
//
//  Created by SeungYong Oh on 2014. 3. 17..
//
//

#import <UIKit/UIKit.h>

@protocol EdgeTextFieldDelegate <UITextFieldDelegate>
@optional
-(void)textFieldShouldChange:(UITextField *)textField;
@end

@interface EdgeTextField : UITextField
@property (nonatomic, assign) UIEdgeInsets textInsets;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIImage *highlightedImage;
@property (nonatomic, assign) BOOL showClearButton;
@property (nonatomic, assign) BOOL showUnderlineByStatus;
@property (nonatomic, assign) BOOL showBorderLineByStatus;
@property (nonatomic, assign) BOOL pasteEnabled; //defult YES;

- (void)insertLeftViewWithTitle:(NSString *)title color:(UIColor *)color font:(UIFont *)font;
- (void)setBorderLine;
- (void)setUnderLine:(UIColor *)color borderWidth:(CGFloat)borderWidth;

@end
