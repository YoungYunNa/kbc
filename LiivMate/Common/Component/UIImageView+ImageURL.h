//
//  UIImageView+ImageURL.h
//  KBWalletDemo
//
//  Created by KB_CARD_MINI_5 on 2014. 9. 15..
//  Copyright (c) 2014년 Oh seung yong. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DirectoryPath					[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/CachesImages"]
#define maxThreadCount                  5

@interface RemoteImageManager : NSObject
+(RemoteImageManager*)manager;
+(void)removeCachesImages;
+(NSData*)getCacheImage:(NSString*)urlStr;
+(void)saveImage:(NSData*)imageData imageUrl:(NSString *)urlStr;
@end

@interface UIImageView (ImageURL)
-(void)setImageWithUrl:(NSString*)imageUrl;
-(void)setImageWithUrl:(NSString *)imageUrl force:(BOOL)force;
-(void)setImageWithUrl:(NSString*)imageUrl withImage:(UIImage*)image;
-(void)setImageWithUrlNonSinglton:(NSString *)imageUrl;
@property (nonatomic, strong) id sender;
@end

@interface UIButton (ImageURL)
- (void)setBackgroundImageUrl:(NSString *)imageUrl;
- (void)setBackgroundImageUrl:(NSString *)imageUrl force:(BOOL)force;
- (void)setImageUrl:(NSString *)imageUrl force:(BOOL)force;
- (void)setImageUrl:(NSString *)imageUrl;
@end
