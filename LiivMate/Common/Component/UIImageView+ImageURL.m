//
//  UIImageView+ImageURL.m
//  KBWalletDemo
//
//  Created by KB_CARD_MINI_5 on 2014. 9. 15..
//  Copyright (c) 2014년 Oh seung yong. All rights reserved.
//

#import "UIImageView+ImageURL.h"
#import <objc/runtime.h>

#ifdef DEBUG
@interface NSURLRequest (IgnoreSSL)

@end
@implementation NSURLRequest (IgnoreSSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
	return YES;
}

@end
#endif

@interface RemoteImageManager ()
{
    NSMutableDictionary *imageViewDic;
    NSMutableArray *waitingPool;
}
+(RemoteImageManager*)manager;
-(UIImage*)getRemoteImage:(NSString*)urlStr ownObject:(id)ownObject;
-(void)saveImage:(UIImage*)image imageUrl:(NSString *)urlStr;
-(void)removeOwnObject:(id)ownObject;
@property (nonatomic, weak) id pOwnObject;
@end

@implementation RemoteImageManager
static RemoteImageManager *_manager = nil;
+(RemoteImageManager*)manager {
    if(_manager == nil) {
        _manager = [[RemoteImageManager alloc] init];
    }
    
    return _manager;
}

+(void)removeCachesImages {
	[[NSFileManager defaultManager] removeItemAtPath:DirectoryPath error:nil];
}

+(NSData*)getCacheImage:(NSString*)urlStr {
	urlStr = [[self manager] getImageFilePathWithUrl:urlStr];
	return [NSData dataWithContentsOfFile:urlStr];;
}

+(void)saveImage:(NSData*)imageData imageUrl:(NSString *)urlStr {
	[imageData writeToFile:[[self manager] getImageFilePathWithUrl:urlStr] atomically:NO];
}

-(id)init {
    self = [super init];
    if(self) {
        [[NSFileManager defaultManager] createDirectoryAtPath:DirectoryPath withIntermediateDirectories:NO attributes:nil error:NULL];
        imageViewDic = [[NSMutableDictionary alloc] init];
        waitingPool = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)dealloc {
	
}

-(NSString*)getImageFilePathWithUrl:(NSString*)urlStr {
    return [DirectoryPath stringByAppendingFormat:@"/%@.png",urlStr.hashSHA1.stringByUrlEncoding];
}

-(void)saveImage:(UIImage*)image imageUrl:(NSString *)urlStr {
    if(image == nil || urlStr == nil) {
        if(urlStr != nil) {
            [[NSFileManager defaultManager] removeItemAtPath:[self getImageFilePathWithUrl:urlStr] error:NULL];
        }
        return;
    }
    
    NSString *imagePhth = [self getImageFilePathWithUrl:urlStr];
    
    NSData *imageData = nil;
    
    if([[urlStr lowercaseString] rangeOfString:@".png"].location != NSNotFound) {
        imageData = UIImagePNGRepresentation(image);
    }
    else {
        imageData = UIImageJPEGRepresentation(image, 1.0);
    }
    
    [imageData writeToFile:imagePhth atomically:NO];
}

-(UIImage*)getRemoteImage:(NSString*)urlStr ownObject:(id)ownObject {
	return [self getRemoteImage:urlStr ownObject:ownObject force:NO];
}

-(UIImage*)getRemoteImage:(NSString*)urlStr ownObject:(id)ownObject force:(BOOL)force {
    self.pOwnObject = ownObject;
    
    if(ownObject == nil || [urlStr isEqual:[NSNull null]] || urlStr == nil) {
        return nil;
    }
    
    if(urlStr == nil) {
        [self removeOwnObject:ownObject];
        return nil;;
    }
    
    NSString *imagePhth = [self getImageFilePathWithUrl:urlStr];
    NSData *imageData = [NSData dataWithContentsOfFile:imagePhth];
	UIImage *retImage = [UIImage imageWithData:imageData];
    if(retImage  != nil  && force == NO) {
        if([ownObject isKindOfClass:[UIImageView class]]) {
            [ownObject performSelector:@selector(removeMaskView)];
        }
		
		if([urlStr rangeOfString:@"/kbcard/upload/img/product/"].location != NSNotFound) {
			CGFloat width = retImage.size.width;
			CGFloat height = retImage.size.height;
			CGFloat heightRatio = height/width;
			if(heightRatio>1.5f&&heightRatio<1.6f) {
				retImage = [UIImage imageWithCGImage:retImage.CGImage scale:1.0 orientation:(UIImageOrientationLeft)];
			}
		}
    }
    else {
		NSMutableArray *objArray = [imageViewDic objectForKey:urlStr];
		if(retImage == nil) {
			if([ownObject isKindOfClass:[UIImageView class]]) {
				retImage = ((UIImageView*)ownObject).image;
			}
			else if ([ownObject isKindOfClass:[UIButton class]]) {
				retImage = ((UIButton*)ownObject).currentImage;
			}
		}
		
        if(objArray != nil) {
			[objArray addObject:ownObject];
			return retImage;
        }
		objArray = [NSMutableArray arrayWithObject:ownObject];
        [imageViewDic setObject:objArray forKey:urlStr];
        
        if(waitingPool.count >= maxThreadCount) {
            [waitingPool insertObject:urlStr atIndex:0];
        }
        else {
            [self performSelectorInBackground:@selector(loadImageOnBackground:) withObject:urlStr];
        }
        
    }
    return retImage;
}

-(void)checkWaitingPool {
    NSString* imageUrl = waitingPool.lastObject;
    if(imageUrl != nil)
    {
        [waitingPool removeLastObject];
        [self performSelectorInBackground:@selector(loadImageOnBackground:) withObject:imageUrl];
    }
}

-(void)finishLoadImage:(NSDictionary*)dic {
    NSString *urlStr = [dic objectForKey:@"imageUrl"];
    UIImage *image = [dic objectForKey:@"image"];
    NSMutableArray *objArray = [imageViewDic objectForKey:urlStr];
	
	if([urlStr rangeOfString:@"/kbcard/upload/img/product/"].location != NSNotFound) {
		CGFloat width = image.size.width;
		CGFloat height = image.size.height;
		CGFloat heightRatio = height/width;
		if(heightRatio>1.5f&&heightRatio<1.6f) {
			image = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:(UIImageOrientationLeft)];
		}
	}
	
	if(image) {
		for(id ownObject in objArray) {
			if([ownObject isKindOfClass:[UIImageView class]]) {
				((UIImageView*)ownObject).image = image;
			}
			else if ([ownObject isKindOfClass:[UIButton class]]) {
				[ownObject setBackgroundImage:image forState:(UIControlStateNormal)];
			}
		}
	}
	[objArray removeAllObjects];
	[imageViewDic removeObjectForKey:urlStr];
    
    if( [self.pOwnObject respondsToSelector:@selector(sender)] ) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if( [[self.pOwnObject sender] respondsToSelector:@selector(finishImageLoading)] ) {
            [[self.pOwnObject sender] performSelectorOnMainThread:@selector(finishImageLoading) withObject:nil waitUntilDone:NO];
        }
#pragma clang diagnostic pop
    }
}

-(void)failLoadImage:(NSString*)urlStr {
	NSMutableArray *objArray = [imageViewDic objectForKey:urlStr];
	[objArray removeAllObjects];
	[imageViewDic removeObjectForKey:urlStr];
    
    if( [self.pOwnObject respondsToSelector:@selector(sender)] ) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if( [[self.pOwnObject sender] respondsToSelector:@selector(finishImageFail)] ) {
            [[self.pOwnObject sender] performSelectorOnMainThread:@selector(finishImageFail) withObject:nil waitUntilDone:NO];
        }
#pragma clang diagnostic pop
    }
}

-(void)loadImageOnBackground:(NSString*)urlStr {
	@autoreleasepool {
		NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
		UIImage *image = [UIImage imageWithData:imageData];
		
		if(image) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[imageData writeToFile:[self getImageFilePathWithUrl:urlStr] atomically:NO];
			});
			[self performSelectorOnMainThread:@selector(finishLoadImage:) withObject:@{@"image": image, @"imageUrl" : urlStr} waitUntilDone:YES];
		}
		else {
			[self performSelectorOnMainThread:@selector(failLoadImage:) withObject:urlStr waitUntilDone:YES];
		}
		[self performSelectorOnMainThread:@selector(checkWaitingPool) withObject:nil waitUntilDone:NO];
	}
}

-(void)removeOwnObject:(id)ownObject {
    if(ownObject == nil || imageViewDic.count == 0) return;
	
	[imageViewDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
		NSMutableArray *arr = obj;
		[arr removeObject:ownObject];
		if(arr.count == 0)
			[self->imageViewDic removeObjectForKey:key];
	}];
	
    if([ownObject respondsToSelector:@selector(removeMaskView)]) {
        [ownObject removeMaskView];
    }
}

@end

@implementation UIImageView (ImageURL)

-(id)sender {
    return objc_getAssociatedObject(self, @selector(sender));
}

-(void)setSender:(id)sender {
    objc_setAssociatedObject(self, @selector(sender), sender, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)setImageWithUrl:(NSString *)imageUrl force:(BOOL)force {
	self.image = [[RemoteImageManager manager] getRemoteImage:imageUrl ownObject:self force:force];
}

-(void)setImageWithUrlNonSinglton:(NSString *)imageUrl {
    RemoteImageManager *mng = [[RemoteImageManager alloc] init];
    self.image = [mng getRemoteImage:imageUrl ownObject:self force:NO];
}

-(void)setImageWithUrl:(NSString*)imageUrl {
	[self setImageWithUrl:imageUrl force:NO];
}

-(void)setImageWithUrl:(NSString*)imageUrl withImage:(UIImage*)image {
    self.image = image;
    [[RemoteImageManager manager] saveImage:image imageUrl:imageUrl];
}

@end

@implementation UIButton (ImageURL)

-(void)setBackgroundImageUrl:(NSString *)imageUrl force:(BOOL)force {
	UIImage *image = [[RemoteImageManager manager] getRemoteImage:imageUrl ownObject:self force:force];
	[self setBackgroundImage:image forState:(UIControlStateNormal)];
}

-(void)setBackgroundImageUrl:(NSString *)imageUrl {
	[self setBackgroundImageUrl:imageUrl force:NO];
}

-(void)setImageUrl:(NSString *)imageUrl force:(BOOL)force {
	UIImage *image = [[RemoteImageManager manager] getRemoteImage:imageUrl ownObject:self force:force];
	[self setImage:image forState:(UIControlStateNormal)];
}

-(void)setImageUrl:(NSString *)imageUrl {
	[self setImageUrl:imageUrl force:NO];
}

@end



