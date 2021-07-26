//
//  NSDictionary+NSNull.m
//  KBCardShop
//
//  Created by KB_CARD_MINI_5 on 2014. 10. 9..
//  Copyright (c) 2014년 Seeroo Inc. All rights reserved.
//

#import "NSDictionary+NSNull.h"
//#import <objc/runtime.h>

@implementation NSDictionary (NSNull)

-(id)null_objectForKey:(NSString*)key
{
    id value = [self objectForKey:key];
    return [value isEqual:[NSNull null]] ? nil : value;
}

-(id)null_valueForKey:(NSString*)key
{
    id value = [self valueForKey:key];
    return [value isEqual:[NSNull null]] ? nil : value;
}
@end
