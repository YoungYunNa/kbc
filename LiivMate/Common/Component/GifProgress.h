//
//  GifProgress.h
//  LiivMate
//
//  Created by kbcard-macpro-a on 13/05/2019.
//  Copyright © 2019 KBCard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GifView.h"


@interface GifProgress : NSObject

+ (void)showGifWithName:(gifType)type completion:(GifProgressFinish)completion;
+ (void)hideGif:(GifProgressFinish)completion;
@end

