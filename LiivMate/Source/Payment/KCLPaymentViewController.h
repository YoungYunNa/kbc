//
//  KCLPaymentViewController.h
//  LiivMate
//
//  Created by KB on 4/30/21.
//  Copyright © 2021 KBCard. All rights reserved.
//

/**
@file KCLPaymentViewController
@date 2021.04.30
@brief 간편결제
*/

#import "WebViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KCLPaymentViewController : WebViewController

-(void)dimmBarcodeView:(BOOL)value;     // Barcode 영역 dimm 처리
-(void)pushNewWebPage:(NSString*)url;
-(NSMutableArray *)getMyCardList;       // 원패쓰에서 사용할 카드 목록을 전달
-(NSString *)getReloadPoin;             // 포인트리 재조회
- (void)selectCardInfo:(NSDictionary *)cardinfo;
- (void)simplePayReoload;

@end

NS_ASSUME_NONNULL_END
