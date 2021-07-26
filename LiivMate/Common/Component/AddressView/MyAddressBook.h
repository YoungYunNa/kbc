//
//  MyAddressBook.h
//  livebank-ios
//
//  Created by KDS on 2015. 10. 12..
//  Copyright (c) 2015년 ATSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MyAddressBook : NSObject

@property(nonatomic,strong) ContactsData *contacts;

- (NSMutableArray *)getContactsInfo;
- (NSMutableArray *)getAddressData;

+ (NSString *)phoneFormat:(NSString *)numStr;

@end
