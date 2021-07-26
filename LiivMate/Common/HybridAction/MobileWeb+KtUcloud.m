//
//  MobileWeb+KtUcloud.m
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2018. 8. 7..
//  Copyright © 2018년 KBCard. All rights reserved.
//

#import "MobileWeb+KtUcloud.h"
#import <Photos/PHAsset.h>
#import <Photos/PHImageManager.h>

#define k_Token		@"X-Auth-Token"
#define k_User		@"X-Auth-User"
#define k_Key		@"X-Auth-Key"
#define k_Url		@"X-Storage-Url"
#define k_Expires	@"X-Auth-Token-Expires"

static long long limitExpireMilliSec;

//KT클라우드 이미지 업로드
@implementation selectImageAndUpload
{
	BOOL _createContainerTry;
}

-(void)run
{
	if([AppInfo sharedInfo].isLogin == NO)
	{
		[self finishedActionWithResult:@{@"resultMessage" : @"loginErr"} success:NO];
		return;
	}
	
	// 0 : 선택, 1 : 앨범, 2 : 카메라
	NSInteger sourceType = [self.paramDic[@"type"] integerValue];
	switch (sourceType) {
		case 1:
		{
			[Permission checkPhotoLibrarySettingAlert:YES permission:^(PERMISSION_STATUS statusNextProccess) {
				if(statusNextProccess == PERMISSION_USE)
					[self showImagePickerWithSourceType:(UIImagePickerControllerSourceTypePhotoLibrary)];
			}];
		}break;
		case 2:
		{
			[Permission checkCameraSettingAlert:YES permission:^(PERMISSION_STATUS statusNextProccess) {
				if(statusNextProccess == PERMISSION_USE)
					[self showImagePickerWithSourceType:(UIImagePickerControllerSourceTypeCamera)];
			}];
		}break;
		default:
		{
			[BlockAlertView showBlockAlertWithTitle:@"이미지 선택" message:nil dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex) {
				if(buttonIndex != 0)
				{
					[self showImagePickerWithSourceType:(buttonIndex == 1 ? UIImagePickerControllerSourceTypePhotoLibrary : UIImagePickerControllerSourceTypeCamera)];
				}
				else
					[self finishedActionWithResult:@{@"resultMessage" : @"cancel"} success:NO];
			} cancelButtonTitle:AlertCancel buttonTitles:@"사진 선택", @"직접 촬영", nil];
		}break;
	}
}

-(void)showImagePickerWithSourceType:(UIImagePickerControllerSourceType)type
{
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.sourceType = type;
	imagePicker.delegate = (id)self;
	imagePicker.allowsEditing = YES;
	//	[self.webView.parentViewController presentViewController:imagePicker animated:YES completion:nil];
	[(UIViewController*)[AllMenu delegate] presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    PHImageManager *manager = [PHImageManager defaultManager];
    
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    requestOptions.synchronous = true;
    
    [manager requestImageDataForAsset: [info objectForKey: UIImagePickerControllerPHAsset] options:requestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        NSLog(@"Data UTI :%@ \t Info :%@",dataUTI,info);
        if (imageData) {
            NSData *imageFileData = imageData;
            NSArray * arrDataUTI = [dataUTI split:@"."];
            NSString *imageType = arrDataUTI.lastObject;
            
            [self uploadImageFileWithData:imageFileData imageType:imageType callback:^(NSDictionary *result, NSString *imageUrl) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [IndicatorView hide];
                    if(imageUrl.length)
                    {
                        NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
                        //[RemoteImageManager saveImage:imageFileData imageUrl:imageUrl];
                        [resultDic setValue:imageFileData.base64EncodedString forKey:@"imageData"];
                        [resultDic setValue:imageUrl forKey:@"imageUrl"];
                        [self finishedActionWithResult:resultDic success:YES];
                    }
                    else
                    {
                        [self finishedActionWithResult:result success:NO];
                    }
                    NSLog(@"이미지 업로드 -- %@",result.jsonStringPrint);
                });
            }];
            
        }
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissViewControllerAnimated:YES completion:^{
		[self finishedActionWithResult:@{@"resultMessage" : @"cancel"} success:NO];
	}];
}

// JPG(손실 압축)
-(NSData*)resizeJpegData:(UIImage *)choiceImage {
	NSData *imgData = UIImageJPEGRepresentation(choiceImage, 0.2);
	
//	float compressionRate = 10;
//	int maxFileSize = 1024 * 1024;
//	while (imgData.length > maxFileSize) {
//		if (compressionRate > 0.5) {
//			compressionRate = compressionRate - 1.0;
//			imgData = UIImageJPEGRepresentation(choiceImage, compressionRate/10);
//			NSLog(@"resizeImageData1 : %lu", (unsigned long)imgData.length);
//		} else {
//			return imgData;
//			NSLog(@"resizeImageData2 : %lu", (unsigned long)imgData.length);
//		}
//	}
	return imgData;
}

// PNG(가로 세로 크기 조절)
- (NSData *)resizePngData:(UIImage*)image {
	
	NSData *finalData = nil;
	NSData *unscaledData = UIImagePNGRepresentation(image);
	
	int maxFileSize = 1024 * 1024;
	if (unscaledData.length > maxFileSize) {
		//if image size is greater than 1MB dividing its height and width maintaining proportions
		UIImage *scaledImage = [self imageWithImage:image andWidth:image.size.width/2 andHeight:image.size.height/2];
		finalData = UIImagePNGRepresentation(scaledImage);
		
		if (finalData.length > maxFileSize ) {
			finalData = [self resizePngData:scaledImage];
		}
		//scaled image will be your final image
	}
	
	if(!finalData)
		finalData = unscaledData;
	
	return finalData;
}

// PNG 이미지 리사이즈(jpg도 가능)
- (UIImage*)imageWithImage:(UIImage*)image andWidth:(CGFloat)width andHeight:(CGFloat)height {
	UIGraphicsBeginImageContext( CGSizeMake(width, height));
	[image drawInRect:CGRectMake(0,0,width,height)];
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}


//토큰획득
-(void)getAuthToken:(void (^)(NSString *resultCode))callback {
	//    NSString *url = @"https://ssproxy.ucloudbiz.olleh.com/auth/v1.0";
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/auth/v1.0", KT_UCLOUD_API_URL]]];
	[req setHTTPMethod:@"GET"];
	[req setValue:[AppInfo sharedInfo].ktCloudAuthUser forHTTPHeaderField:k_User];
	[req setValue:[AppInfo sharedInfo].ktCloudAuthKey forHTTPHeaderField:k_Key];
	
	[[[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSLog(@"response : %@", response);
			NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
			NSString *resultCode = [NSString stringWithFormat:@"%ld", (long)[httpResponse statusCode]];
			TXLog(@"%s : resultCode : %@",__func__,resultCode);
			if([resultCode isEqualToString:@"200"]) {
				NSDictionary *headers = [httpResponse allHeaderFields];
				[AppInfo sharedInfo].ktUcloudAuthToken = [headers objectForKey:k_Token];
				[AppInfo sharedInfo].ktStroageUrl = [headers objectForKey:k_Url];
				NSString *strexpires = [NSString stringWithFormat:@"%@", headers[k_Expires]];
				NSNumber *expireMilliSec = [NSNumber numberWithInt:[strexpires intValue] * 1000];
				
				limitExpireMilliSec = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0) + [expireMilliSec longLongValue];
				NSLog(@"response : %lld", limitExpireMilliSec);
			}
			callback(resultCode);
		});
	}] resume];
}

-(void)getToken:(void (^)(NSDictionary *result, BOOL success))finishedCallback
{
	long long currentMilliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
	if(currentMilliseconds > limitExpireMilliSec || [AppInfo sharedInfo].ktStroageUrl.length == 0 || [AppInfo sharedInfo].ktUcloudAuthToken.length == 0)
	{
		[self getAuthToken:^(NSString *resultCode) {
			if([resultCode isEqualToString:@"200"])
			{
				if(finishedCallback)
					finishedCallback(@{k_Token : [AppInfo sharedInfo].ktUcloudAuthToken} ,YES);
			}
			else
			{
				if(finishedCallback)
					finishedCallback(@{@"message" : @"토큰생성 실패", @"resultCode" : resultCode} ,NO);
			}
		}];
	}
	else
	{
		if(finishedCallback)
			finishedCallback(@{k_Token : [AppInfo sharedInfo].ktUcloudAuthToken} ,YES);
	}
}

-(NSString *)containerPath
{
	//https://ssproxy.ucloudbiz.olleh.com/v1/AUTH_d4ea23b0-ea3f-4b12-bd90-27b6a2a493d0/lm_8b4d224d5593ad61a63c02b18ffa7595e2411693744b20f5a9f381d824c324b6/lm_20181021171035643.jpg
	NSString *cId = [AppInfo userInfo].cId.length ? [AppInfo userInfo].cId : @"container";
	return [NSString stringWithFormat:@"%@/lm_%@",[AppInfo sharedInfo].ktStroageUrl,cId];
}

-(void)createContainer:(void (^)(NSString *resultCode))callback {
	
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self containerPath]]];
	[req setHTTPMethod:@"PUT"];
	[req setValue:[AppInfo sharedInfo].ktUcloudAuthToken forHTTPHeaderField:k_Token];
	
	[[[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSLog(@"response : %@", response);
			NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
			NSString *resultCode = [NSString stringWithFormat:@"%ld", (long)[httpResponse statusCode]];
			TXLog(@"%s : resultCode : %@",__func__,resultCode);
			callback(resultCode);
		});
	}] resume];
}

-(void)uploadImageFileWithData:(NSData *)imageData imageType:(NSString *)imgType callback:(void (^)(NSDictionary *result, NSString *imageUrl))callback {
	
	long long currentMilliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
	//토큰 체크
	if(currentMilliseconds > limitExpireMilliSec || [AppInfo sharedInfo].ktStroageUrl.length == 0)
	{
		[self getAuthToken:^(NSString *resultCode) {
			NSLog(@"resultCode : %@", resultCode);
			if([resultCode isEqualToString:@"200"])
			{
				[self uploadImageFileWithData:imageData imageType:imgType callback:callback];
			}
			else
			{
				callback(@{@"resultCode" : resultCode, @"message" : @"토큰 생성 실패"},nil);
			}
		}];
		return;
	}
	
	
	NSString *url =  nil;
	if(self.paramDic[@"imageUrl"])
		url = self.paramDic[@"imageUrl"];
	else
	{
		// 파일 이름 생성
		NSDate *today = [NSDate date];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
		NSString *strFileName = [NSString stringWithFormat:@"lm_%@.%@", [dateFormatter stringFromDate:today], imgType];//@"lm_20181021171035643.jpg";//
		url = [NSString stringWithFormat:@"%@/%@", [self containerPath], strFileName];
	}
	
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
	[req setHTTPMethod:@"PUT"];
	[req setValue:[AppInfo sharedInfo].ktUcloudAuthToken forHTTPHeaderField:k_Token];
	if([imgType isEqualToString:@"jpg"])
		[req setValue:@"image/jpg" forHTTPHeaderField: @"Content-Type"];
    else if([imgType isEqualToString:@"gif"])
        [req setValue:@"image/gif" forHTTPHeaderField: @"Content-Type"];
	else
		[req setValue:@"image/png" forHTTPHeaderField: @"Content-Type"];
	
	[req setHTTPBody:imageData];
	[req setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[imageData length]] forHTTPHeaderField:@"Content-Length"];
	
	[[[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSLog(@"response : %@", response);
			NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
			NSString *resultCode = [NSString stringWithFormat:@"%ld", (long)[httpResponse statusCode]];
			TXLog(@"%s : resultCode : %@",__func__,resultCode);
			TXLog(@"\n%@\nresultDic = %@ %@",req.URL, [NSJSONSerialization JSONObjectWithData:data
																					  options:NSJSONReadingMutableContainers
																						error:NULL],[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
			if([resultCode isEqualToString:@"201"])
			{
				callback(@{@"resultCode" : resultCode},url);
			}
			else
			{
				if(self->_createContainerTry == NO && [resultCode isEqualToString:@"404"])
				{
					[self createContainer:^(NSString *resultCode2) {
						NSLog(@"컨테이너 생성  resultCode : %@", resultCode2);
						if([resultCode2 isEqualToString:@"201"] || [resultCode2 isEqualToString:@"202"])
						{
							self->_createContainerTry = YES;
							[self uploadImageFileWithData:imageData imageType:imgType callback:callback];
						}
						else
						{
							callback(@{@"resultCode" : resultCode2, @"message":@"컨테이너 생성 실패"},nil);
						}
					}];
					return;
				}
				callback(@{@"resultCode" : resultCode, @"message":@"이미지 업로드 실패"},nil);
			}
		});
	}] resume];
}

@end

@implementation getAuthToken
-(void)run
{
	[self getToken:^(NSDictionary *result, BOOL success) {
		[self finishedActionWithResult:result success:success];
	}];
}
@end

@implementation getCloudImage
-(void)run
{
	NSString *imageUrl = self.paramDic[@"imageUrl"];
	NSString *script = self.paramDic[@"script"];
	if(imageUrl.length == 0)
	{
		NSString *message = imageUrl.length == 0 ?@"not imageUrl":@"";
		NSMutableDictionary *dic = self.paramDic.mutableCopy;
		[dic setValue:message forKey:@"resultMessage"];
		[self finishedActionWithResult:dic success:NO];
		return;
	}
	
	NSData *imageData = [RemoteImageManager getCacheImage:imageUrl];
	if(imageData)
	{
		//스크립트로 이미지를 직접 셋팅해준다.
		if(script && [script rangeOfString:@"@@@"].location != NSNotFound)
		{
			script = [script stringByReplacingOccurrencesOfString:@"@@@" withString:imageData.base64EncodedString];
			[self.webView stringByEvaluatingJavaScriptFromString:script completionHandler:^(NSString * _Nullable result) {
				[self finishedActionWithResult:self.paramDic success:YES];
			}];
		}
		else
		{
			NSDictionary *dic = self.paramDic.mutableCopy;
			[dic setValue:imageData.base64EncodedString forKey:@"imageData"];
			[self finishedActionWithResult:dic success:YES];
		}
		return;
	}
	
	[self getToken:^(NSDictionary *result, BOOL success) {
		if(success)
		{
			NSMutableURLRequest *rq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
			[rq setValue:[AppInfo sharedInfo].ktUcloudAuthToken forHTTPHeaderField:@"X-Auth-Token"];
			
			[[[NSURLSession sharedSession] dataTaskWithRequest:rq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
				NSHTTPURLResponse *resp = (id)response;
				dispatch_async(dispatch_get_main_queue(), ^{
					if(resp.statusCode == 200 && data.length)
					{
						[RemoteImageManager saveImage:data imageUrl:imageUrl];
						if(script && [script rangeOfString:@"@@@"].location != NSNotFound)
						{
							NSString *scriptStr = [script stringByReplacingOccurrencesOfString:@"@@@" withString:data.base64EncodedString];
							[self.webView stringByEvaluatingJavaScriptFromString:scriptStr completionHandler:^(NSString * _Nullable result) {
								[self finishedActionWithResult:self.paramDic success:YES];
							}];
						}
						else
						{
							NSDictionary *dic = self.paramDic.mutableCopy;
							[dic setValue:data.base64EncodedString forKey:@"imageData"];
							[self finishedActionWithResult:dic success:YES];
						}
					}
					else
					{
						NSMutableDictionary *dic = self.paramDic.mutableCopy;
						[dic setValue:@"ktApiError" forKey:@"resultMessage"];
						[dic setValue:@(resp.statusCode) forKey:@"errCd"];
						[self finishedActionWithResult:dic success:NO];
					}
				});
			}] resume];
		}
		else
		{
			[self finishedActionWithResult:result success:NO];
		}
	}];
}
@end

@implementation getCloudImageList
{
	NSMutableArray *_list;
	NSURL *_url;
	BOOL _cancel;
}
-(void)run
{
	NSArray *list = self.paramDic[@"list"];
	_url = self.webView.request.URL;
	if(list.count)
	{
		_list = [NSMutableArray arrayWithArray:list];
		[self loadImage];
	}
	else
	{
		[self finishedActionWithResult:@{@"resultMessage" : @"list Count 0"} success:NO];
	}
}

-(void)loadImage
{
	NSDictionary *imageInfo = _list.firstObject;
	
	if(_cancel || [_url.path isEqualToString:self.webView.request.URL.path] == NO)
	{
		NSLog(@"\n%@\n%@",self->_url.absoluteString,self.webView.request.URL.absoluteString);
		[self cancel];
		return;
	}
	
	if(imageInfo == nil)
	{
		[self finishedActionWithResult:nil success:YES];
		return;
	}
	
	NSString *imageUrl = imageInfo[@"imageUrl"];
	NSString *script = imageInfo[@"script"];
	if(imageUrl.length == 0)
	{
		[_list removeObject:imageInfo];
		[self loadImage];
		return;
	}
	
	NSData *imageData = [RemoteImageManager getCacheImage:imageUrl];
	if(imageData)
	{
		//스크립트로 이미지를 직접 셋팅해준다.
		if(script && [script rangeOfString:@"@@@"].location != NSNotFound)
		{
			script = [script stringByReplacingOccurrencesOfString:@"@@@" withString:imageData.base64EncodedString];
			[self.webView stringByEvaluatingJavaScriptFromString:script completionHandler:^(NSString * _Nullable result) {
				[self->_list removeObject:imageInfo];
				[self loadImage];
			}];
		}
		else
		{
			[self->_list removeObject:imageInfo];
			[self loadImage];
		}
		return;
	}
	
	[self getToken:^(NSDictionary *result, BOOL success) {
		if(success)
		{
			NSMutableURLRequest *rq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
			[rq setValue:[AppInfo sharedInfo].ktUcloudAuthToken forHTTPHeaderField:@"X-Auth-Token"];
			
			[[[NSURLSession sharedSession] dataTaskWithRequest:rq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
				NSHTTPURLResponse *resp = (id)response;
				dispatch_async(dispatch_get_main_queue(), ^{
					if(resp.statusCode == 200 && data.length)
					{
						[RemoteImageManager saveImage:data imageUrl:imageUrl];
						NSLog(@"\n%@\n%@",self->_url.absoluteString,self.webView.request.URL.absoluteString);
						if(self->_cancel ||[self->_url.path isEqualToString:self.webView.request.URL.path] == NO)
						{
							[self cancel];
							return;
						}
						
						if(script && [script rangeOfString:@"@@@"].location != NSNotFound)
						{
							NSString *scriptStr = [script stringByReplacingOccurrencesOfString:@"@@@" withString:data.base64EncodedString];
							[self.webView stringByEvaluatingJavaScriptFromString:scriptStr completionHandler:^(NSString * _Nullable result) {
								[self->_list removeObject:imageInfo];
								[self loadImage];
							}];
						}
						else
						{
							[self->_list removeObject:imageInfo];
							[self loadImage];
						}
					}
					else
					{
						[self->_list removeObject:imageInfo];
						[self loadImage];
					}
				});
			}] resume];
		}
		else
		{
			[self finishedActionWithResult:@{@"resultMessage" : @"다운로드 실패"} success:NO];
		}
	}];
}

-(void)cancel
{
	[_list removeAllObjects];
	_cancel = YES;
	[super cancel];
}

@end
