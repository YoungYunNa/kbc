//
//  ContactsData.h
//  livebank-ios
//
//  Created by KDS on 2015. 10. 12..
//  Copyright (c) 2015년 ATSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactsData : NSObject

@property (nonatomic, strong) NSMutableArray *numbers;
@property (nonatomic, strong) NSString *CTNumber;
@property (nonatomic, strong) NSString *searchNum;
@property (nonatomic, strong) NSMutableArray *emails;
@property (nonatomic, strong) NSString *firstNames;
@property (nonatomic, strong) NSString *lastNames;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *cId;

@property (nonatomic, strong) NSString * recordID;

@property (nonatomic, strong) UIImage *personImage;


@property (nonatomic, strong) NSString *frdMembYn;
@property (nonatomic, strong) NSString *frdRegNo;
@property (nonatomic, strong) NSMutableArray *autoSendList;


@end
