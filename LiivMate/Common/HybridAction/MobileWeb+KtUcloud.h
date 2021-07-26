//
//  MobileWeb+KtUcloud.h
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2018. 8. 7..
//  Copyright © 2018년 KBCard. All rights reserved.
//

#import "MobileWeb.h"

#ifndef SELECT_SERVER
//운영
#define KT_UCLOUD_API_URL               @"https://ssproxy.ucloudbiz.olleh.com"
#else
//개발
#define KT_UCLOUD_API_URL               @"https://ssproxy.ucloudbiz.olleh.com"
#endif

//KT클라우드 이미지 업로드
@interface selectImageAndUpload : MobileWeb
@end
typedef selectImageAndUpload KtUcloud;

@interface getAuthToken : selectImageAndUpload
@end

@interface getCloudImage : selectImageAndUpload
@end

@interface getCloudImageList : selectImageAndUpload
@end
