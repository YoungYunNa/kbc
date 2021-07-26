//
//  USHTTPHelper.h
//  UniSignLibrary
//
//  Created by gychoi on 2014. 8. 11..
//
//

#import <Foundation/Foundation.h>

typedef enum _USHTTPMethod {
    kUSHTTPMethodGet    = 1,
    kUSHTTPMethodPost   = 2,
    kUSHTTPMethodPut    = 3,
    kUSHTTPMethodDelete = 4,
    kUSHTTPMethodTrace  = 5,
    
    kUSHTTPMethodUnknown    = -1,
} USHTTPMethod;

typedef enum _USHTTPError {
    kUSHTTPErrorOK      = 0,
    kUSHTTPErrorE21001  = 21001,
    kUSHTTPErrorE21002  = 21002,
    kUSHTTPErrorE21003  = 21003,
    kUSHTTPErrorE21004  = 21004,
    kUSHTTPErrorE21005  = 21005,
    kUSHTTPErrorE21006  = 21006,
    kUSHTTPErrorE21007  = 21007,
    kUSHTTPErrorE21008  = 21008,
    kUSHTTPErrorE21009  = 21009,
    kUSHTTPErrorE21010  = 21010,
    kUSHTTPErrorE21011  = 21011,
    
    kUSHTTPErrorUnknown = 21099,
} USHTTPError;

@interface USHTTPHelper : NSObject {
    USHTTPMethod        _method;
    NSMutableDictionary *_params;
    NSURL               *_url;
}

+ (NSString *) errorMessage:(USHTTPError)errorCode;
+ (BOOL) isAvailable:(USHTTPMethod)method;
+ (BOOL) isEnableBody:(USHTTPMethod)method;

+ (NSMutableDictionary *) excute:(NSURL *)url;

- (id) init:(USHTTPMethod)method;
- (NSString *) getURL;
- (BOOL) setAddress:(NSString *)address;
- (BOOL) addParam:(NSString *)key value:(NSString *)value;
- (NSMutableDictionary *) excute;

@end
