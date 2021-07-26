//
//  GifView.h
//  LiivMate
//
//  Created by kbcard-macpro-a on 15/05/2019.
//  Copyright © 2019 KBCard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"

typedef NS_ENUM(NSInteger, gifType) {
    gifType_jump,
    gifType_greet,
    gifType_heart,
    gifType_cheer
};

@interface GifView : UIView
{
    dispatch_block_t work;
    int cnt;
}
@property (weak, nonatomic) IBOutlet UILabel * _Nullable lblTitle;
@property (weak, nonatomic) IBOutlet UILabel * _Nullable lblSubTitle;
@property (weak, nonatomic) IBOutlet UILabel * _Nullable lblSubTitle2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * _Nullable constContentHeight;
@property (weak, nonatomic) IBOutlet FLAnimatedImageView * _Nullable imgGif;


typedef void (^GifProgressFinish)(NSDictionary * _Nullable result, BOOL isSuccess);

+ (GifView *_Nullable)makeView:(gifType)type;
- (void)setGif:(gifType)type completion:(GifProgressFinish _Nullable )completion;
- (void)stopDispatchQue;
@end
