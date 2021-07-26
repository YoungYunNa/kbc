//
//  MyAddressBook.m
//  livebank-ios
//
//  Created by KDS on 2015. 10. 12..
//  Copyright (c) 2015년 ATSolutions. All rights reserved.
//

#import "MyAddressBook.h"
#if 0 //deprecated: first deprecated in iOS 9.0 (SM 수정 로직 추가)
#import <AddressBook/AddressBook.h>
#else
#import <Contacts/Contacts.h>
#endif
#define CELLPHONE_PREFIX_ARRAY      [NSArray arrayWithObjects:@"010", @"011", @"017",@"018",@"019", nil]

@implementation MyAddressBook

- (NSMutableArray *)getAddressData
{
    NSMutableArray *mArray = [NSMutableArray new];
    
#if 0 //deprecated: first deprecated in iOS 9.0 (SM 수정 로직 추가)
    CFErrorRef *error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    __block BOOL accessGranted = NO;
    if (&ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if (accessGranted) {
        // Do whatever you want here.
    }
    
    //ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, error);
    NSMutableArray *contactRefs = [[NSMutableArray alloc] init];
    CFArrayRef sources = ABAddressBookCopyArrayOfAllSources(addressBook);
    CFIndex iArrRefCnt = CFArrayGetCount(sources);
    for( int i=0 ; i<iArrRefCnt ; i++ )
    {
        ABRecordRef source = CFArrayGetValueAtIndex(sources, i);
        CFArrayRef refs = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, ABPersonGetSortOrdering());
        [contactRefs addObjectsFromArray:CFBridgingRelease(refs)];
    }
    
    for (int i = 0; i < [contactRefs count]; i++)
    {
        //data model
        _contacts = [ContactsData new];
        
        NSArray *refs = CFBridgingRelease((__bridge ABRecordRef)[contactRefs objectAtIndex:i]);
        
        CFStringRef lastName = (CFStringRef)ABRecordCopyValue((__bridge ABRecordRef)(refs),kABPersonLastNameProperty);
        CFStringRef firstName = (CFStringRef)ABRecordCopyValue((__bridge ABRecordRef)(refs),kABPersonFirstNameProperty);
        _contacts.firstNames = [(__bridge NSString*)firstName copy];
        if (firstName != NULL) {
            CFRelease(firstName);
        }
        _contacts.lastNames = [(__bridge NSString*)lastName copy];
        
        if (lastName != NULL) {
            CFRelease(lastName);
        }
        
        
        if(_contacts.lastNames==nil){
            _contacts.lastNames=@"";
        }
        if (_contacts.firstNames==nil) {
            _contacts.firstNames=@"";
        }
        
        _contacts.fullName=[NSString stringWithFormat:@"%@%@",_contacts.lastNames,_contacts.firstNames];
        
        
        //이미지
        ABRecordRef source = (__bridge ABRecordRef)refs;
        if( ABPersonHasImageData(source) )
        {
            CFDataRef imgData = ABPersonCopyImageData(source);
            _contacts.personImage = [UIImage imageWithData:(__bridge NSData *)imgData];
            
            if (imgData != NULL) {
                CFRelease(imgData);
            }
        }
        
        _contacts.recordID = [NSString stringWithFormat:@"%d", ABRecordGetRecordID((__bridge ABRecordRef)(refs))];
        NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
        ABMultiValueRef multiPhones = ABRecordCopyValue((__bridge ABRecordRef)(refs), kABPersonPhoneProperty);
        
        for(CFIndex index=0; index < ABMultiValueGetCount(multiPhones); index++)
        {
            CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, index);
            NSString *phoneNumber = CFBridgingRelease(phoneNumberRef);
            if (phoneNumber != nil)
                [phoneNumbers addObject:phoneNumber];
        }
        
        if (multiPhones != NULL)
        {
            CFRelease(multiPhones);
        }
        
        
        for (int j=0; j<[phoneNumbers count]; j++)
        {
            _contacts.CTNumber = [[[phoneNumbers objectAtIndex:j] componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
            
        }
        [_contacts setNumbers:phoneNumbers];
        [mArray addObject:_contacts];
    }
    
    CFRelease(sources);
    //    CFRelease(addressBook);
#else
    NSError* contactError;
    CNContactStore* addressBook = [[CNContactStore alloc]init];
    NSLog(@"addressBook.defaultContainerIdentifier : %@", addressBook.defaultContainerIdentifier);
//    [addressBook containersMatchingPredicate:[CNContainer predicateForContainersWithIdentifiers: @[addressBook.defaultContainerIdentifier]] error:&contactError];
    NSArray * keysToFetch =@[CNContactPhoneNumbersKey, CNContactFamilyNameKey, CNContactGivenNameKey, CNContactImageDataKey, CNContactIdentifierKey];
    CNContactFetchRequest * request = [[CNContactFetchRequest alloc]initWithKeysToFetch:keysToFetch];
    
    [addressBook enumerateContactsWithFetchRequest:request error:&contactError usingBlock:^(CNContact * __nonnull contact, BOOL * __nonnull stop){
        
        ContactsData * contactsData = [ContactsData new];
        
        NSString * firstName =  contact.givenName;
        NSString * lastName =  contact.familyName;

        contactsData.lastNames = lastName?lastName:@"";
        contactsData.firstNames = firstName?firstName:@"";
        contactsData.fullName=[NSString stringWithFormat:@"%@%@",contactsData.lastNames,contactsData.firstNames];
        
        contactsData.recordID = contact.identifier;
        
        //프로필 이미지
        if (contact.imageData) {
            contactsData.personImage = [UIImage imageWithData:contact.imageData];
        }
        
        NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
        
        for (CNLabeledValue * number in contact.phoneNumbers) {
            if ([number.value stringValue]) {
                [phoneNumbers addObject:[number.value stringValue]];
            }
        }
        
        for (int i=0; i<[phoneNumbers count]; i++) {
            contactsData.CTNumber = [[[phoneNumbers objectAtIndex:i] componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
        }
        
        contactsData.numbers = phoneNumbers;
        
        [mArray addObject:contactsData];
    }];
#endif
    return mArray;
}

- (NSMutableArray *)getContactsInfo
{
    NSMutableArray *mArray = [self getAddressData];
    NSMutableArray *rtArray = [NSMutableArray new];
    
    for (int i = 0; i < [mArray count]; i++)
    {
        ContactsData *cd = (ContactsData *)[mArray objectAtIndex:i];
        
        if(cd.numbers && [cd.numbers count] > 1)
        {
            for(NSString * phonenumber in cd.numbers)
            {
                ContactsData * multiContactsData = [ContactsData new];
                
                NSDate * now = [[NSDate alloc] init];
                int64_t tempRecordID = [now timeIntervalSince1970] * 10000.0;
                
                multiContactsData.fullName = cd.fullName;
                multiContactsData.recordID = [NSString stringWithFormat:@"%qi",tempRecordID];
                
                NSString * changeFormatPhoneNumber = phonenumber;
                
                if (phonenumber != nil)
                {
                    changeFormatPhoneNumber = [MyAddressBook phoneFormat:[[phonenumber componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""]];
                    
                    if(![changeFormatPhoneNumber hasPrefix:@"+82"])
                    {
                        if([self cellPhoneNumber:changeFormatPhoneNumber] == NO)
                            continue;
                    }
                    multiContactsData.CTNumber = changeFormatPhoneNumber;
                    
                    [rtArray addObject:multiContactsData];
                }
                
            }
        }
        else
        {
            if (cd.CTNumber != nil)
            {
                cd.CTNumber = [MyAddressBook phoneFormat:[[cd.CTNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""]];
                
                if(![cd.CTNumber hasPrefix:@"+82"])
                {
                    if([self cellPhoneNumber:cd.CTNumber] == NO)
                        continue;
                }
                
                cd.CTNumber = [MyAddressBook phoneFormat:cd.CTNumber];
                [rtArray addObject:cd];
            }
        }
    }
    
    return rtArray;
}


- (BOOL) cellPhoneNumber:(NSString *)numStr
{
    BOOL isCellPhoneNumber = NO;
    
    if(numStr && [numStr length] > 3)
    {
        NSString * prefixNumber = [numStr substringWithRange:NSMakeRange(0, 3)];
        
        return [CELLPHONE_PREFIX_ARRAY containsObject:prefixNumber];
    }
    return isCellPhoneNumber;
}

+ (NSString *)phoneFormat:(NSString *)numStr
{
    NSMutableString * finalString = [NSMutableString new];
    NSMutableString * workingPhoneString = [NSMutableString stringWithString:numStr];
    BOOL        isCountry = NO ;
    
    if(workingPhoneString.length > 1)
    {
        // +82 (0) 10-1234-1234 형식으로 저장된 번호는 특수문자가빠지고 8201012341234 형태로 해당 함수에 입력되어져서
        // 정상적인 전화번호로 처리하지 않기 때문에 820으로 시작하는 번호는 82로 시작하게 replace
        if ([workingPhoneString hasPrefix:@"820"]) {
            workingPhoneString = [NSMutableString stringWithString:[workingPhoneString stringByReplacingOccurrencesOfString:@"820" withString:@"82"]];
        }
        
        if ([[workingPhoneString substringToIndex:2] isEqualToString:@"82"])
        {
//            [finalString appendString:@"+82 "];
            [workingPhoneString replaceCharactersInRange:NSMakeRange(0, 2) withString:@"0"];
//            isCountry = YES;
            isCountry = NO;
        }
        
        if(isCountry == NO && workingPhoneString.length > 1)
        {
            if ([[workingPhoneString substringToIndex:2] isEqualToString:@"02"])
            {
                [finalString appendString:@"02-"];
                [workingPhoneString replaceCharactersInRange:NSMakeRange(0, 2) withString:@""];
            }
        }
        
        if (workingPhoneString.length < 5)
        {
            [finalString appendString:[NSString stringWithFormat:@"%@", workingPhoneString]];
            
        }
        else if (workingPhoneString.length < 6)
        {
            [finalString appendString:[NSString stringWithFormat:@"%@-%@",
                                       [workingPhoneString substringWithRange:NSMakeRange(0, 3)],
                                       [workingPhoneString substringFromIndex:3]]];
            
        }
        else if (workingPhoneString.length < 9)
        {
            [finalString appendString:[NSString stringWithFormat:@"%@-%@",
                                       [workingPhoneString substringWithRange:NSMakeRange(0, 4)],
                                       [workingPhoneString substringFromIndex:4]]];
        }
        else if (workingPhoneString.length < 10)
        {
            [finalString appendString:[NSString stringWithFormat:@"%@-%@-%@",
                                       [workingPhoneString substringWithRange:NSMakeRange(0, 2)],
                                       [workingPhoneString substringWithRange:NSMakeRange(2, 3)],
                                       [workingPhoneString substringFromIndex:5]]];
        }
        else if (workingPhoneString.length < 11)
        {
            if(isCountry == NO)
            {
                [finalString appendString:[NSString stringWithFormat:@"%@-%@-%@",
                                           [workingPhoneString substringWithRange:NSMakeRange(0, 3)],
                                           [workingPhoneString substringWithRange:NSMakeRange(3, 3)],
                                           [workingPhoneString substringFromIndex:6]]];
            }
            else
            {
                [finalString appendString:[NSString stringWithFormat:@"%@ %@-%@",
                                           [workingPhoneString substringWithRange:NSMakeRange(0, 2)],
                                           [workingPhoneString substringWithRange:NSMakeRange(2, 4)],
                                           [workingPhoneString substringFromIndex:6]]];
            }
        }
        else if (workingPhoneString.length < 12)
        {
            [finalString appendString:[NSString stringWithFormat:@"%@-%@-%@",
                                       [workingPhoneString substringWithRange:NSMakeRange(0, 3)],
                                       [workingPhoneString substringWithRange:NSMakeRange(3, 4)],
                                       [workingPhoneString substringFromIndex:7]]];
        }
        else
        {
            finalString = workingPhoneString;
        }
    }
    
    
    return finalString;
}

@end
