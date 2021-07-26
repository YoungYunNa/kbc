//
//  NSDictionary+NSNull.h
//  KBCardShop
//
//  Created by KB_CARD_MINI_5 on 2014. 10. 9..
//  Copyright (c) 2014년 Seeroo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (NSNull)
-(id)null_objectForKey:(NSString*)key;
-(id)null_valueForKey:(NSString*)key;
@end
