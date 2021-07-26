//
//  PushDefaultNotificationInfo.m
//

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "PushDefaultNotification.h"

@interface NSString (Encoding)

- (NSStringEncoding)encodingValue;

@end

@implementation NSString (Encoding)

- (NSStringEncoding)encodingValue {
    CFStringEncoding cfEncoding = CFStringConvertIANACharSetNameToEncoding( (CFStringRef)self );
    NSStringEncoding nsEncoding = CFStringConvertEncodingToNSStringEncoding(cfEncoding);

    if(nsEncoding == -1) {
        NSStringEncoding defaultEncoding = [NSString defaultCStringEncoding];
        NSLog(@"not found match NSStringEncoding.return default encoding [%d]", (int)defaultEncoding);
        return defaultEncoding;
    }

    return nsEncoding;
}

@end

@interface PushDefaultNotification ()

@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) NSString *text;
@property (nonatomic, readonly) NSString *template;
@property (nonatomic, readonly) NSString *content;

@end

@implementation PushDefaultNotification

- (id)initWithUserInfo:(NSDictionary *)userInfo {
    self = [super init];
    if ( self ) {
        self.userInfo = userInfo;
        
        if ( [self.ext rangeOfString:@"|"].location != NSNotFound ) {
            self.extComponents = [self.ext componentsSeparatedByString:@"|"];
        }
    }
    return self;
}

- (NSDictionary *)aps {
    return [self.userInfo objectForKey:@"aps"];
}

- (NSDictionary *)mps {
    return [self.userInfo objectForKey:@"mps"];
}

- (NSString *)title {
    return [self.aps objectForKey:@"alert"];
}

- (NSString *)ext {
    return [self.mps objectForKey:@"ext"];
}

- (NSString *)type {
    return [self.mps objectForKey:@"TYPE"];
}

- (NSURL *)requestURL {
    return self.hasExtURL ? [NSURL URLWithString:self.ext] : nil;
}

- (BOOL)hasExtURL {
    if ( ([self.ext hasSuffix:@"_msp.html"] || [self.ext hasSuffix:@"_ext.html"]) ) {
        return YES;
    }

    return NO;
}

- (PushNotificationCategory)category {
    if ( self.extComponents.count <= 0 ) {
        return PushNotificationCagegoryUnknown;
    }

    return  (PushNotificationCategory)[[self.extComponents objectAtIndex:0] integerValue];
}

- (NSURL *)imageURL {
    if ( self.extComponents.count <= 2 ) {
        return nil;
    }

    if ( self.category < PushNotificationCategorySecurity ) {
        return nil;
    }

    id object = [self.extComponents objectAtIndex:2];

    if ( ! [object isKindOfClass:[NSString class]] ) {
        return nil;
    }

    return [NSURL URLWithString:[NSString stringWithString:object]];
}

- (NSString *)text {
    if ( self.extComponents.count <= 1 ) {
        return nil;
    }

    id object = [self.extComponents objectAtIndex:1];

    if ( ! [object isKindOfClass:[NSString class]] ) {
        return nil;
    }

    return [NSString stringWithString:object];
}

- (NSString *)message {

    if ( self.isTemplateContent ) {
        return self.content;
    }

    return self.text;
}

- (NSString *)template {

    if ( self.isTemplateContent == NO ) {
        return nil;
    }

    return self.text;
}

- (NSString *)content {
    NSString *content = [self template];
    NSString *values = [self.mps objectForKey:@"VAR"];

    if ( values ) {
        NSArray *vars = ( [values rangeOfString:@"|"].length != NSNotFound ) ? [values componentsSeparatedByString:@"|"] : @[values];

        for ( NSInteger i=0; i<vars.count; i++ ) {
            NSString *keyName = [NSString stringWithFormat:@"VAR%@", @(i+1)];
            NSString *keyValue = [vars objectAtIndex:i];
            NSString *templateKey = [NSString stringWithFormat:@"%%%@%%", keyName];

            NSError *error   = nil;
            NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:templateKey options:0 error:&error];

            if ( error ) {
                continue;
            }

            content = [regexp stringByReplacingMatchesInString:content options:0 range:NSMakeRange(0, content.length) withTemplate:keyValue];
        }
    }
    
    return content;
}

- (NSURL *)contentURL {

    if ( self.category == PushNotificationCategoryWebPage || self.category == PushNotificationCategoryVideo ) {
        if ( self.extComponents.count <= 3 ) {
            return nil;
        }
        
        id object = [self.extComponents objectAtIndex:3];
    
        if ( ! [object isKindOfClass:[NSString class]] ) {
            return nil;
        }
        
        NSString *url = [NSString stringWithString:object];

        url = [[[url stringByReplacingOccurrencesOfString:@"\n\r" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
        return [NSURL URLWithString:url];
    }
    else if ( self.category == PushNotificationCategoryImage || self.category == PushNotificationCategorySecurity ) {
        if ( self.extComponents.count <= 2 ) {
            return nil;
        }
        
        id object = [self.extComponents objectAtIndex:2];
    
        if ( ! [object isKindOfClass:[NSString class]] ) {
            return nil;
        }
        
        NSString *url = [NSString stringWithString:object];
        
        url = [[[url stringByReplacingOccurrencesOfString:@"\n\r" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
        return [NSURL URLWithString:url];
    }
    
    return nil;
}

- (BOOL)isTemplateContent {
    return ( [self.type isEqualToString:@"R"] && [self.mps objectForKey:@"VAR"] != nil );
}

- (BOOL)isWebContent {
    return ( self.contentURL != nil ) ? YES : NO;
}

- (void)load:(id)sender completionHandler:(PushNotificationExtLoadHandler)handler {
    
    if ( ! self.hasExtURL ) {
        if ( sender && handler ) {
            handler(false, self, nil);
        }
        return;
    }
    
    [NSURLConnection
            sendAsynchronousRequest:[NSURLRequest requestWithURL:self.requestURL]
                            queue:[NSOperationQueue mainQueue]
                            completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if ( connectionError != nil ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( sender && handler ) {
                    handler(false, self, connectionError);
                }
            });
            return;
        }
        
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse *)response;
            
        if ( httpResponse.statusCode != 200 ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( sender && handler ) {
                    handler(false, self, nil);
                }
            });
            return;
        }
        
        NSStringEncoding textEncoding = ( [response textEncodingName] ) ? [response textEncodingName].encodingValue : NSUTF8StringEncoding;
        
        NSString* result = [[NSString alloc] initWithData:data encoding:textEncoding];

        result = [result stringByRemovingPercentEncoding];

        self.extComponents = [result componentsSeparatedByString:@"|"];

        dispatch_async(dispatch_get_main_queue(), ^{
            if ( sender && handler ) {
                handler(true, self, nil);
            }
        });
    }];
}

@synthesize userInfo = _userInfo, extComponents;
@dynamic aps, mps, ext, requestURL, hasExtURL, category, title, message, imageURL, contentURL, isWebContent, isTemplateContent, type, text, template, content;

@end
