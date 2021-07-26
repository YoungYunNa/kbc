//
//  EtcUtil.h
//  LiivMate
//
//  Created by KB_CARD_MINI_6 on 2016. 8. 16..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EtcUtil : NSObject

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)centerCropImage:(UIImage *)image;
+ (UIImage *)imageByCroppingImage:(UIImage *)image toSize:(CGSize)size;
+ (UIImage *)imageByResizeImage:(UIImage *)image toSize:(CGSize)size;
+ (NSString*)formatSecretPhoneNumber:(NSString*)simpleNumber;
+ (NSString*)formatSecretPhoneNumber2:(NSString*)simpleNumber;
+ (NSString*)formatPhoneNumber:(NSString*)simpleNumber;
+ (NSString*)formatPhoneNumber2:(NSString*)simpleNumber;
+ (NSString*)formatPhoneNumber3:(NSString*)simpleNumber;
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;
+ (NSMutableAttributedString *)setAttributeWithString:(NSMutableAttributedString *)attString subStr:(NSString *)subStr subFont:(float)subFont;
+ (NSMutableAttributedString *)setAttributeWithColorString:(NSMutableAttributedString *)attString subStr:(NSString *)subStr subColor:(UIColor *)subColor;
+ (NSMutableAttributedString *)setAttributeWithColorString:(NSMutableAttributedString *)attString subStr:(NSString *)subStr subColor:(UIColor *)subColor subFont:(UIFont *)subFont;
+ (void)layerBorder:(id)view;
+ (NSMutableArray *)searchWithGroupedNameArrayByData:(NSArray *)groupedArray andString:(NSString *)numString;
+ (NSMutableArray *)searchWithGroupedNameArrayByData:(NSArray *)groupedArray andArray:(NSArray *)numArray;
+ (NSMutableArray *)searchWithArrayData:(NSArray *)baseArray andString:(NSString *)searchString;
+ (NSMutableArray *)searchWithCommunityArrayData:(NSArray *)baseArray andString:(NSString *)searchString;
+ (NSString *)makePattern:(NSString *)string;
+ (NSInteger)gapMonthOfStartDateAndEndDate:(NSString *)startDate endDate:(NSString *)endDate;
+ (NSInteger)gapDaysOfStartDateAndEndDate:(NSString *)startDate endDate:(NSString *)endDate withFormatStr:(NSString*)format;
+ (UIColor *)getLottoColorWithNumString:(NSString *)lottoNumStr;
+ (NSString *)getDateStringWithOrigin:(NSString *)dateStr from:(NSString *)fromFormat to:(NSString *)toFormat;
// query 파싱 (키 , 밸류 디코딩)
+ (NSMutableDictionary *)parseUrl:(NSString*)url;
+ (NSMutableDictionary *)parseUrlWithoutDecoding:(NSString*)url;
+ (BOOL)checkEmail:(NSString *)email;
+ (NSString *)efdsDeviceInfo;

@end

// 스크래핑 속도개선 
#pragma mark - Synchronized Dictionary, Array

@interface SyncDictionary : NSObject

/**
 * The number of elements in this dictionary.
 */
@property (nonatomic,readonly) NSUInteger count;

/**
 * A class-level convenience method to allocate and initialize a new instance of a GRKConcurrentMutableDictionary.
 *
 * @return A new GRKConcurrentMutableDictionary instance.
 */
+ (id)dictionary;

#pragma mark - Read Operations

- (id)objectForKey:(id)key;

/**
 * Is the receiver equal to the given dictionary.
 *
 * @param otherDictionary The dictionary to compare with.
 *
 * @return `YES` only if the caller is the same object as the given dictionary
 * or if the dictionary contents are equal at the time of this call.
 */
- (BOOL)isEqualToDictionary:(SyncDictionary *)otherDictionary;

#pragma mark - Augmentitive Operations

#pragma mark Augment

/**
 * Perform operations on the dictionary within a serial block.
 * This can be used to perform any number of serial operations on the underlying mutable
 * dictionary while no other augmentative operations are occurring. This is especially useful
 * for operations which depend on the contents of the dictionary.
 *
 * @param block The block which will be executed to allow batched serial operations to be performed on the dictionary.
 */
- (void)augmentWithBlock:(void(^)(NSMutableDictionary *dictionary))block;

#pragma mark Add

- (void)addEntriesFromDictionary:(NSDictionary *)dictionary;

#pragma mark Set

- (void)setObject:(id)obj forKey:(id<NSCopying>)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key NS_AVAILABLE(10_8, 6_0);

#pragma mark Remove

- (void)removeAllObjects;
- (void)removeObjectForKey:(id)aKey;
- (void)removeObjectsForKeys:(NSArray *)keyArray;

#pragma mark Identity

- (void)setDictionary:(NSDictionary *)otherDictionary;

#pragma mark - Snapshot

/**
 * Returns a new NSDictionary object containing all the objects within this GRKConcurrentMutableDictionary.
 *
 * @return A new NSDictionary instance containing all the objects in this dictionary.
 */
- (NSDictionary *)nonConcurrentDictionary;

/**
 * Empties this dictionary into a new NSDictionary object which is not concurrent
 *
 * @return A new NSDictionary instance with the contents of this dictionary.
 */
- (NSDictionary *)drainIntoNonConcurrentDictionary;

@end

@interface SyncArray : NSObject

/**
 * The number of elements in this array.
 */
@property (nonatomic,readonly) NSUInteger count;

/**
 * A class-level convenience method to allocate and initialize a new instance of a GRKConcurrentMutableArray.
 *
 * @return A new GRKConcurrentMutableArray instance.
 */
+ (id)array;

#pragma mark - Read Operations

- (BOOL)containsObject:(id)anObject;

/**
 * Is the receiver equal to the given array.
 *
 * @param otherArray The array to compare with.
 *
 * @return `YES` only if the caller is the same object as the given array
 * or if the array contents are equal at the time of this call.
 */
- (BOOL)isEqualToArray:(SyncArray *)otherArray;

#pragma mark - Augmentitive Operations

#pragma mark Augment

/**
 * Perform operations on the array within a serial block.
 * This can be used to perform any number of serial operations on the underlying mutable
 * array while no other augmentative operations are occurring. This is especially useful
 * for operations which depend on the index of array elements.
 *
 * @param block The block which will be executed to allow batched serial operations to be performed on the array.
 */
- (void)augmentWithBlock:(void(^)(NSMutableArray *array))block;

- (id)objectForIndex:(NSUInteger)index;

#pragma mark Add

- (void)addObject:(id)anObject;
- (void)addObjectsFromArray:(NSArray *)otherArray;

#pragma mark Remove
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)removeObject:(id)anObject;
- (void)removeAllObjects;
- (void)removeObjectIdenticalTo:(id)anObject;
- (void)removeObjectsInArray:(NSArray *)otherArray;

#pragma mark Identity

- (void)setArray:(NSArray *)otherArray;

#pragma mark Sort

- (void)sortUsingFunction:(NSInteger (*)(id, id, void *))compare context:(void *)context;
- (void)sortUsingSelector:(SEL)comparator;
- (void)sortUsingComparator:(NSComparator)cmptr NS_AVAILABLE(10_6, 4_0);
- (void)sortWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr NS_AVAILABLE(10_6, 4_0);

#pragma mark Filter

- (void)filterUsingPredicate:(NSPredicate *)predicate;

#pragma mark - Snapshot

/**
 * Returns a new NSArray object containing all the objects within this GRKConcurrentMutableArray.
 *
 * @return A new NSArray instance containing all the objects in this array.
 */
- (NSArray *)nonConcurrentArray;

/**
 * Empties this array into a new NSArray object which is not concurrent
 *
 * @return A new NSArray instance with the contents of this array.
 */
- (NSArray *)drainIntoNonConcurrentArray;

@end
