//
//  JSONModel+networking.h
//  JSONModel
//

#import "CCJSONModel.h"
#import "CCJSONHTTPClient.h"

typedef void (^JSONModelBlock)(id model, CCJSONModelError *err) DEPRECATED_ATTRIBUTE;

@interface CCJSONModel (Networking)

@property (assign, nonatomic) BOOL isLoading DEPRECATED_ATTRIBUTE;
- (instancetype)initFromURLWithString:(NSString *)urlString completion:(JSONModelBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)getModelFromURLWithString:(NSString *)urlString completion:(JSONModelBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)postModel:(CCJSONModel *)post toURLWithString:(NSString *)urlString completion:(JSONModelBlock)completeBlock DEPRECATED_ATTRIBUTE;

@end
