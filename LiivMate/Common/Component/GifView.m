//
//  GifView.m
//  LiivMate
//
//  Created by kbcard-macpro-a on 15/05/2019.
//  Copyright © 2019 KBCard. All rights reserved.
//

#import "GifView.h"

@implementation GifView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (GifView *)makeView:(gifType)type
{
    GifView *gifView = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"Component" owner:nil options:nil];
    for (id obj in objects)
    {
        if ([obj isKindOfClass:[GifView class]])
        {
            gifView = obj;
            break;
        }
    }
    
    [gifView setGif:type completion:nil];
    
    return gifView;
}

- (void)setGif:(gifType)type completion:(GifProgressFinish)completion{
    @try {
        NSURL *url;
        if (type == gifType_jump) {
            url = [[NSBundle mainBundle] URLForResource:@"loading_jump" withExtension:@"gif"];
            self.lblTitle.text = @"소득/재직 정보 확인 중...";
            self.lblSubTitle.text = @"좀 더 정확한 한도∙금리 산출을 위해\n고객님의 정보를 확인 중입니다.";
            self.lblSubTitle2.hidden = YES;
            self.constContentHeight.constant = 330;
        }else if (type == gifType_greet){
            url = [[NSBundle mainBundle] URLForResource:@"loading_greet" withExtension:@"gif"];
            self.lblTitle.text = @"소득/재직 정보 확인 완료!";
            self.lblSubTitle.text = @"선택하신 금융사의 최적 상품을 조회합니다.";
            self.lblSubTitle2.hidden = YES;
            self.constContentHeight.constant = 330;
        }else if (type == gifType_heart){
            url = [[NSBundle mainBundle] URLForResource:@"loading_heart" withExtension:@"gif"];
            self.lblTitle.text = @"최적 상품 조회 중...";
            self.lblSubTitle.text = @"고객님께 딱 맞는 금리와 한도를 조회 중입니다.\n약 1분 정도 소요될 예정입니다.\n\n대출신청 방법 안내";
            self.lblSubTitle2.text = @"① 원하는 대출상품 선택 및 확인 클릭!";
            if(!work){
                cnt = 1;
                work = dispatch_block_create(0, ^{
                    NSLog(@"chagneText");
                    if (self->cnt == 1) {
                        self->cnt = 2;
                        self.lblSubTitle2.text = @"② 해당 금융사 대출 신청하기 클릭!";
                        [self changeText];
                    }else if(self->cnt == 2){
                        self->cnt = 3;
                        self.lblSubTitle2.text = @"③ 연동화면에서 대출 신청 진행!";
                        [self changeText];
                    }else if(self->cnt == 3){
                        self->cnt = 1;
                        self.lblSubTitle2.text = @"① 원하는 대출상품 선택 및 확인 클릭!";
                        [self changeText];
                    }
                });
                [self changeText];
            }
            self.lblSubTitle2.hidden = NO;
            self.constContentHeight.constant = 390;
        }else if (type == gifType_cheer){
            url = [[NSBundle mainBundle] URLForResource:@"loading_cheer" withExtension:@"gif"];
            self.lblTitle.text = @"최적 상품 구성 중...";
            self.lblSubTitle.text = @"고객님을 위한 최적 상품 구성 중 입니다.\n잠시만 기다려 주세요.";
            self.lblSubTitle2.hidden = YES;
            self.constContentHeight.constant = 330;
        }
        NSData *data = [NSData dataWithContentsOfURL:url];
        FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:data];
        [self.imgGif performSelectorOnMainThread:@selector(setAnimatedImage:) withObject:animatedImage waitUntilDone:NO];
        if (completion) {
            completion(nil, YES);
        }
    } @catch (NSException *exception) {
        if (completion) {
            completion(nil, NO);
        }
    }
}

- (void)changeText {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), work);
}
- (void)stopDispatchQue {
    if (work) {
        dispatch_block_cancel(work);
    }
}
@end
