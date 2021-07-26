//
//  UIView+ParentViewController.h
//  NewKBCardWallet
//
//

/**
 @file UIView+ParentViewController.h
 @date 2013.02.21
 @author 이승우
 @brief 뷰에서 부모 뷰컨트롤러를 구하기 위한 카테고리
 */

#import <Foundation/Foundation.h>

@interface UIView (ParentViewController)

- (UIViewController*)parentViewController;
-(void)removeMaskView;
-(void)showMaskView:(BOOL)autoRemove;
-(BOOL)isShowMaskView;
-(void)selectView;
-(void)deSelectView;
-(void)unLoadView;
-(CGRect)superRectWithView:(UIView*)view visibleRect:(BOOL)visibleRect;
-(CGRect)getVisibleRect;
-(NSArray*)searchView:(NSString*)className depth:(NSInteger)depth;
@end
