//
//  PopView.h
//  FidoFrameWork
//
//  Created by jwchoi on 2017. 5. 25..
//  Copyright © 2017년 jwchoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface PopView : UIViewController {
    NSString *message; ///< 경고창 메시지
    UILabel *messageLabel; ///< 경고창 메시지 라벨
    UIImageView *backgroundImage; ///< 배경 이미지
}

@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) IBOutlet UILabel *messageLabel;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImage;

-(id)initWithMessage:(NSString *)aMessage;
-(void) showDuring:(float)duration;
@end
