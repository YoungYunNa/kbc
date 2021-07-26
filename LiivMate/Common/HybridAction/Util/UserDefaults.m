//
//  UserDefaults.m
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2016. 7. 21..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import "UserDefaults.h"

#define UserDefaultsDirectoryPath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/UserDefaults.dat"]

static UserDefaults *_sharedDefaults = nil;

@implementation UserDefaults
{
	NSMutableDictionary *_dic;
}

+(UserDefaults *)sharedDefaults
{
	if(_sharedDefaults == nil)
	{
		_sharedDefaults = [[UserDefaults alloc] init];
	}
	return _sharedDefaults;
}

-(id)init
{
	self = [super init];
	if(self)
	{
		_dic = [[NSMutableDictionary alloc] init];
		NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithFile:UserDefaultsDirectoryPath];
		[_dic setDictionary:dic];
        //개발용 체크 벨류
        self.isLiveMate3DataValidationCheck = NO;
        self.isLiveMate3UINavigationCheck = NO;
        self.isLiveMate3Dummy1 = NO;
        self.isLiveMate3Dummy2 = NO;
	}
	return self;
}

-(void)dealloc
{
	[_dic removeAllObjects];
	_dic = nil;
}

-(void)removeAllObjects
{
	[_dic removeAllObjects];
	[self setNeedsSynchronize];
}

-(void)removeObjectForKey:(NSString*)aKey
{
	if([aKey respondsToSelector:@selector(encryptAes128)])
		aKey = [aKey encryptAes128];
	[_dic removeObjectForKey:aKey];
	[self setNeedsSynchronize];
}

- (NSArray *)allKeys
{
    NSMutableArray * retArr = [NSMutableArray array];
    NSArray *allKeys = [_dic allKeys];
    
    for (id key in allKeys) {
        if ([key respondsToSelector:@selector(decryptAes128)]) {
            id decKey = [key decryptAes128];
            if(decKey) {
                [retArr addObject:decKey];
            }
        }
    }
    
    return retArr;
}

-(void)setObject:(NSString*)anObject forKey:(NSString*)aKey
{
	if(anObject.length == 0)
	{
		[self removeObjectForKey:aKey];
		return;
	}
	
	if([anObject respondsToSelector:@selector(encryptAes128)])
		anObject = [anObject encryptAes128];
	if([aKey respondsToSelector:@selector(encryptAes128)])
		aKey = [aKey encryptAes128];
	[_dic setValue:anObject forKey:aKey];
	[self setNeedsSynchronize];
}

-(void)setValue:(NSString*)value forKey:(NSString *)key
{
	[self setObject:value forKey:key];
}

-(id)objectForKey:(NSString*)aKey
{
	if([aKey respondsToSelector:@selector(encryptAes128)])
		aKey = [aKey encryptAes128];
	id value = [_dic valueForKey:aKey];
	if([value respondsToSelector:@selector(decryptAes128)])
		value = [value decryptAes128];
	return value;
}

-(id)valueForKey:(NSString *)key
{
	return [self objectForKey:key];
}

-(NSString*)description
{
	return _dic.description;
}

-(NSString*)debugDescription
{
	return _dic.debugDescription;
}

-(void)setNeedsSynchronize
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(synchronize) object:nil];
	[self performSelector:@selector(synchronize) withObject:nil afterDelay:0.001];
}

-(BOOL)synchronize
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(synchronize) object:nil];
	return [NSKeyedArchiver archiveRootObject:_dic toFile:UserDefaultsDirectoryPath];
}

//공지사항 오늘 하루 안보기 체크
-(BOOL)checkDayNoticeNo:(NSString*)noticeNo update:(BOOL)upDate
{
	NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
	[fmt setDateFormat:@"yyyyMMdd"];
	NSString *newNoticeFlag = [NSString stringWithFormat:@"%@_%@",[fmt stringFromDate:[NSDate date]], noticeNo];
	NSString *noticeFlag = [_dic objectForKey:@"noticeFlag"];
	if(upDate)
	{
		[_dic setValue:newNoticeFlag forKey:@"noticeFlag"];
		[self setNeedsSynchronize];
	}
	return ![newNoticeFlag isEqualToString:noticeFlag];
}

//공지사항 더이상 안보기 체크
-(BOOL)checkNoticeNo:(NSString*)noticeNo update:(BOOL)upDate
{
    NSString *noticeFlagForever = [_dic objectForKey:@"noticeFlagForever"];
    if(upDate)
    {
        [_dic setValue:noticeNo forKey:@"noticeFlagForever"];
        [self setNeedsSynchronize];
    }
    return ![noticeNo isEqualToString:noticeFlagForever];
}

//트리거이벤트 오늘하루 안보기 체크
-(BOOL)checkTrgPageId:(NSString*)pageId update:(BOOL)upDate
{
	if(pageId.length == 0) return NO;
	
	NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
	[fmt setDateFormat:@"yyyyMMdd"];
	NSString *dateStr = [fmt stringFromDate:[NSDate date]];
	NSString *newTrgCheckFlag = [NSString stringWithFormat:@"%@_%@",dateStr, pageId];
	NSString *trgCheckFlag = [_dic objectForKey:@"trgCheckFlag"];
	if(upDate)
	{
		NSMutableString *saveFlag = newTrgCheckFlag.mutableCopy;
		NSArray *flagArray = [trgCheckFlag componentsSeparatedByString:@","];
		for(NSString *flag in flagArray)
		{
			if([flag rangeOfString:dateStr].location != NSNotFound
			   && [flag isEqualToString:newTrgCheckFlag] == NO)
			{
				[saveFlag appendFormat:@",%@",flag];
			}
		}
		[_dic setValue:saveFlag forKey:@"trgCheckFlag"];
		[self setNeedsSynchronize];
	}
	return ([trgCheckFlag rangeOfString:newTrgCheckFlag].location == NSNotFound || trgCheckFlag.length == 0);
}

-(void)removeCheckTrgFlag
{
	[_dic removeObjectForKey:@"trgCheckFlag"];
	[self setNeedsSynchronize];
}

#pragma mark - setter & getter

-(void)setAppID:(NSString *)appID
{
	[self setObject:appID forKey:@"appID"];
}

-(NSString*)appID
{
	return [self objectForKey:@"appID"];
}


- (void)setRecentPureAppDataDecryptString:(NSString *)recentPureAppDataDecryptString
{
    [self setObject:recentPureAppDataDecryptString forKey:@"recentPureAppDataDecryptString"];
}

- (NSString *)recentPureAppDataDecryptString
{
    return [self objectForKey:@"recentPureAppDataDecryptString"];
}

-(void)setRecentPureAppDataString:(NSString *)recentPureAppDataString
{
    [self setObject:recentPureAppDataString forKey:@"recentPureAppDataStringV3"];
}

-(NSString*)recentPureAppDataString
{
    return [self objectForKey:@"recentPureAppDataStringV3"];
}

-(NSString*)recentPureAppLib
{
    return [self objectForKey:@"recentPureAppDataStringV3"];
}

- (void)setSplashVer:(NSString *)splashVer
{
    [self setObject:splashVer forKey:@"splashVer"];
}

- (NSString *)splashVer
{
    return [self objectForKey:@"splashVer"];
}

-(void)setGatheringOrderType:(NSString *)gatheringOrderType
{
    [self setObject:gatheringOrderType forKey:@"gatheringOrderType"];
}

-(NSString*)gatheringOrderType
{
    return [self objectForKey:@"gatheringOrderType"];
}

-(void)setShowTutorial:(BOOL)showTutorial
{
	[self setObject:[[NSNumber numberWithBool:showTutorial] stringValue] forKey:@"showTutorial"];
}

-(BOOL)showTutorial
{
	return [[self objectForKey:@"showTutorial"] boolValue];
}

-(void)setShowDeviceUseAgreement:(BOOL)showDeviceUseAgreement
{
	[self setObject:[[NSNumber numberWithBool:showDeviceUseAgreement] stringValue] forKey:@"showDeviceUseAgreement"];
}

-(BOOL)showDeviceUseAgreement
{
	return [[self objectForKey:@"showDeviceUseAgreement"] boolValue];
}

-(void)setShowMainTutorial:(BOOL)showMainTutorial
{
	[self setObject:[[NSNumber numberWithBool:showMainTutorial] stringValue] forKey:@"showMainTutorial"];
}

-(BOOL)showMainTutorial
{
	return [[self objectForKey:@"showMainTutorial"] boolValue];
}

-(void)setIsFirstRun:(BOOL)isFirstRun
{
	[self setObject:[[NSNumber numberWithBool:isFirstRun] stringValue] forKey:@"isFirstRun"];
}

-(BOOL)isFirstRun
{
	NSString *firstRun = [self objectForKey:@"isFirstRun"];
	if(firstRun == nil) return YES;
	return [firstRun boolValue];
}

-(BOOL)isRegistedFido
{
    NSString *isRegistedFido;
    // 한국전자인증 FIDO
    if ([UserDefaults sharedDefaults].isFidoTestTOBE) {
        isRegistedFido = [self objectForKey:@"registedFidoCrosscert"];
    }
    // 브이피 FIDO
    else {
        isRegistedFido = [self objectForKey:@"registedFido"];
    }
    
    if(isRegistedFido == nil) return NO;
    return [isRegistedFido boolValue];
}

-(void)setIsRegistedFido:(BOOL)isRegistedFido
{
    // 한국전자인증 FIDO
    if ([UserDefaults sharedDefaults].isFidoTestTOBE) {
        [self setObject:[[NSNumber numberWithInteger:isRegistedFido] stringValue] forKey:@"registedFidoCrosscert"];
    }
    // 브이피 FIDO
    else {
        [self setObject:[[NSNumber numberWithInteger:isRegistedFido] stringValue] forKey:@"registedFido"];
    }
}

-(BOOL)isPort
{
    NSString *isPort = [self objectForKey:@"isPort"];
    if(isPort == nil) return NO;
    return [isPort boolValue];
}

-(void)setIsPort:(BOOL)isPort
{
    [self setObject:[[NSNumber numberWithInteger:isPort] stringValue] forKey:@"isPort"];
}

-(void)setUseFido:(FidoUseSetting)useFido
{
    [self setObject:[[NSNumber numberWithInteger:useFido] stringValue] forKey:@"useFido"];
}

-(FidoUseSetting)useFido
{
    return [[self objectForKey:@"useFido"] integerValue];
}

-(void)joinReset
{
    [self removeObjectForKey:@"useFido"];
    
    if ([UserDefaults sharedDefaults].isFidoTestTOBE) {
        [self removeObjectForKey:@"registedFidoCrosscert"];
    }
    else {
        [self removeObjectForKey:@"registedFido"];
    }
}

-(BOOL)isFidoTestTOBE
{
    NSString *isRegistedFido = [self objectForKey:@"isFidoTestTOBE"];
    if(isRegistedFido == nil) return NO;
    return [isRegistedFido boolValue];
}

-(void)setIsFidoTestTOBE:(BOOL)isFidoTestTOBE
{
    [self setObject:[[NSNumber numberWithInteger:isFidoTestTOBE] stringValue] forKey:@"isFidoTestTOBE"];
}

@end
