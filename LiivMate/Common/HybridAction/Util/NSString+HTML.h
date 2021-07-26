//
//  NSString+HTML.h
//  LiivMate
//
//  Created by KB_CARD_MINI_6 on 2016. 9. 23..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HTML)

- (NSString *)stringByConvertingHTMLToPlainText;
- (NSString *)stringByDecodingHTMLEntities;
- (NSString *)stringByEncodingHTMLEntities;
- (NSString *)stringByEncodingHTMLEntities:(BOOL)isUnicode;
- (NSString *)stringWithNewLinesAsBRs;
- (NSString *)stringByRemovingNewLinesAndWhitespace;
- (NSString *)stringByLinkifyingURLs;

@end
