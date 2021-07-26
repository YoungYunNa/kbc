//
//  GifProgress.m
//  LiivMate
//
//  Created by kbcard-macpro-a on 13/05/2019.
//  Copyright © 2019 KBCard. All rights reserved.
//

#import "GifProgress.h"
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"

@implementation GifProgress

static GifView *gifView;
+ (void)showGifWithName:(gifType)type completion:(GifProgressFinish)completion {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(gifView == nil){
            @try {
                gifView = [GifView makeView:type];
                gifView.frame = [UIScreen mainScreen].bounds;
                
                UIWindow *win = [[UIApplication sharedApplication] keyWindow];

                [win addSubview:gifView];
                if (completion) {
                    completion(nil, YES);
                }
            } @catch (NSException *exception) {
                if (completion) {
                    completion(nil, NO);
                }
            }
        }else {
            [gifView setGif:type completion:completion];
        }
        
    });
    
}

+ (void)hideGif:(GifProgressFinish)completion {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        @try {
            
            [gifView stopDispatchQue];
            [gifView removeFromSuperview];
            gifView = nil;
            
            if (completion) {
                completion(nil, YES);
            }
        } @catch (NSException *exception) {
            if (completion) {
                completion(nil, NO);
            }
        }
    });
    
}
@end
