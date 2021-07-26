//
//  ContactsData.m
//  livebank-ios
//
//  Created by KDS on 2015. 10. 12..
//  Copyright (c) 2015년 ATSolutions. All rights reserved.
//

#import "ContactsData.h"

@implementation ContactsData

-(void)setCTNumber:(NSString *)CTNumber
{
    _CTNumber = CTNumber;
    self.searchNum = [_CTNumber getDecimalString];
}

@end
