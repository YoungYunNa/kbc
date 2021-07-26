//
//  TransKey+Extension.h
//  LiivMate
//
//  Created by KB_CARD_MINI_10 on 2019. 2. 22..
//  Copyright © 2019년 KBCard. All rights reserved.
//

#import "TransKey.h"
#import "TransKeyView.h"

@interface TransKey (Extension)

+ (void)loadResource:(id _Nullable )vc;
+(TransKey *_Nullable)getRandomKeypad:(id _Nullable )delegate
                              license:(NSString *_Nullable)license
                        type:(TransKeyResourceType)type;

- (void)setMaxLen:(NSInteger)maxLen;
- (void)setKeyPadTypeCert;
- (NSString *_Nullable)getPublicKeyEnc:(nonnull NSString *)keyfileName;
- (NSString *_Nullable)getPublicKeyEnc:(nonnull NSString *)keyfileName encStr:(NSString *_Nullable)encStr;

typedef void (^PlainText)(char plain[_Nullable 256]);
- (void)getPlainText:(PlainText _Nullable )completion;

@end
