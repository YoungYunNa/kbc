//
//  RegistedPersonsList.m
//  LiivMate
//
//  Created by KB_CARD_MINI_6 on 2016. 8. 3..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import "RegistedPersonsList.h"


static RegistedPersonsList *_instance;

static BOOL isRecieveFriendsList = NO;


@interface RegistedPersonsList ()

@property (nonatomic, strong) NSMutableArray *groupDetailInfoArr;

@end



@implementation RegistedPersonsList


+ (BOOL)isSharedInstance
{
    RegistedPersonsList *si = [RegistedPersonsList sharedInstance];
    if( si == nil )
        return NO;
    
    return YES;
}


#pragma mark - 싱글톤 객체 생성
+ (RegistedPersonsList*)sharedInstance
{
    @synchronized(self) {
        
        if (_instance == nil) {
            
            //객체 생성
            _instance = [[self alloc] init];
        }
    }
    return _instance;
}


#pragma mark - 객체 init
-(instancetype)init
{
    self = [super init];
    
    if( self )
    {
        BOOL isResult = [self requestFriendListInfo];
        if( !isResult )
        {
            return nil;
        }
    }
    
    return self;
}

#pragma mark - 친구 데이터 리로드
+ (BOOL)refreshDataInstance
{
    if( _instance )
    {
        isRecieveFriendsList = NO;
        BOOL isResult = [_instance requestFriendListInfo];
        return isResult;
    }
    else
    {
        if ([RegistedPersonsList sharedInstance] == nil) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)requestFriendListInfo
{
    if( !isRecieveFriendsList ) //친구정보를 받아온적이 없으면
    {
        //통신 요청
		
		NSMutableDictionary *param = [NSMutableDictionary dictionary];
		[param setValue:[AppInfo userInfo].custNo forKey:@"custNo"];
        
        // Ver. 3 친구 목록 조회(KATPS17)
        [Request requestID:KATPS17 body:param waitUntilDone:YES showLoading:YES cancelOwn:self finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
            
            if(IS_SUCCESS(rsltCode))    //성공일 경우
            {
                if( result )
                {
                    // 친구목록 저장
                    if( self.recieveTrDic )
                    {
                        [self.recieveTrDic removeAllObjects];
                        self.recieveTrDic = nil;
                    }
                    
                    self.recieveTrDic = [[NSMutableDictionary alloc] initWithDictionary:result];
                    
                    
                    // 커뮤니티 목록 요청
                    NSMutableDictionary *param2 = [NSMutableDictionary dictionary];
                    [param2 setValue:[AppInfo userInfo].custNo forKey:@"custNo"];
                    [Request requestID:M71200 body:param2 waitUntilDone:YES showLoading:YES cancelOwn:self finished:^(NSDictionary *result2, NSString *rsltCode2, NSString *message2) {
                        
                        if(IS_SUCCESS(rsltCode2))    //성공일 경우
                        {
                            // 커뮤니티목록 저장
                            if( self.recieveCommunityDic )
                            {
                                [self.recieveCommunityDic removeAllObjects];
                                self.recieveCommunityDic = nil;
                            }
                    
                            self.recieveCommunityDic = [[NSMutableDictionary alloc] initWithDictionary:result2];
                            
                            isRecieveFriendsList = YES;
                        }
                        else
                        {
                            isRecieveFriendsList = NO;
                        }
                    }];
                }
            }
            else    //실패일 경우
            {
                isRecieveFriendsList = NO;
            }
        }];
    }
    
    if( !isRecieveFriendsList ) //실패일경우
    {
        return NO; //nil을 리턴
    }
    
    //성공인 경우 초기화 처리
    self.allList = [[NSMutableArray alloc] init];
    self.listByGrouped = [[NSMutableArray alloc] init];
    self.groupList = [[NSMutableArray alloc] init];
    self.groupDetailInfoArr = [[NSMutableArray alloc] init];
    self.communityAllList = [[NSMutableArray alloc] init];
    self.communityListByGrouped = [[NSMutableArray alloc] init];
    self.communityGroupList = [[NSMutableArray alloc] init];
    
    if( self.recieveTrDic == nil )
    {
        isRecieveFriendsList = NO;
        return NO;
    }
    else
    {
        [self dataSettingForRegistedPsersons];
        [self dataSettingForCommunityList];
    }
    
    return YES;
}


#pragma mark - 전체 리스트 수 얻기
- (int)countOfAllList
{
    return (int)[self.allList count];
}



#pragma mark - 그룹의 개수 얻기
- (int)countOfGroupList
{
    return (int)[self.groupList count];
}


#pragma mark - 친구 그룹의 수 (커뮤니티 제외)
- (int)countOfFriendGroupWithoutCommunity
{
    NSMutableArray *groupListArr = [self.recieveCommunityDic null_objectForKey:@"metgBnkbkList"];
    int iCnt = (int)[groupListArr count];
    
    return (int)[self.groupList count] - iCnt;
}


#pragma mark - 그룹ID 얻기 (그룹이름)
- (NSString *)getGroupIDWithName:(NSString *)name
{
    int index = (int)[self.groupList indexOfObject:name];
    
    return [self getGroupIDWithIndex:index];
}

#pragma mark - 그룹명 얻기 (그룹ID)
- (int)getGroupNameWithGroupID:(NSString *)gId
{
    int iArrCnt = (int)[self.groupDetailInfoArr count];
    
    for( int i=0 ; i<iArrCnt ; i++ )
    {
        NSDictionary *dic = [self.groupDetailInfoArr objectAtIndex:i];
        NSString *idStr = [dic objectForKey:KEY_GROUP_ID];
        if( [gId isEqualToString:idStr] )
        {
            return i;
        }
    }
    
    return -1;
}


#pragma mark - 그룹 ID 얻기 (인덱스)
- (NSString *)getGroupIDWithIndex:(int)index
{
    NSMutableDictionary *dic = [self.groupDetailInfoArr objectAtIndex:index];
    
    return [dic objectForKey:@"grpId"];
}


#pragma mark - 그룹 구분코드 얻기 (인덱스)
- (NSString *)getGroupCodeWithIndex:(int)index
{
    NSMutableDictionary *dic = [self.groupDetailInfoArr objectAtIndex:index];
    
    return [dic objectForKey:@"grpGbnCd"];
}


#pragma mark - 그룹에 멤버가 한명일 경우 해당 정보 얻기
- (NSDictionary *)getIfOneMemberInfoWithIndex:(int)mIndex
{
    int iArrCnt = (int)[self.listByGrouped count];
    if( mIndex < iArrCnt )
    {
        NSArray *inGArr = [self.listByGrouped objectAtIndex:mIndex];
        
        if( [inGArr count] == 1 )
        {
            ContactsData *data = [inGArr firstObject];
            
            NSArray *equalGroupArr = [EtcUtil searchWithGroupedNameArrayByData:[RegistedPersonsList sharedInstance].listByGrouped andString:data.CTNumber];
            if( equalGroupArr == nil )
                equalGroupArr = [[NSArray alloc] init];
            
            NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:data.fullName, KEY_NAME, data.CTNumber, KEY_NUM, [self.groupList objectAtIndex:mIndex], KEY_GROUP, equalGroupArr, KEY_ARR_GROUP, nil];
            return resultDic;
        }
    }
    
    return nil;
}


#pragma mark - 전체 리스트 갱신
-(void)refreshAllGroupList
{
    [self.allList removeAllObjects];
    
    for( NSArray *subArr in self.listByGrouped )
    {
        int iArrCnt = (int)[subArr count];
        for( int j=0 ; j<iArrCnt ; j++ )
        {
            [self.allList addObject:[subArr objectAtIndex:j]];
        }
    }
}


#pragma mark - 주어진 이름이 그룹명 리스트에 존재하는지 확인
- (BOOL)isExistGroupName:(NSString *)gName
{
    if( [self.groupList containsObject:gName] )
    {
        return YES;
    }
    
    return NO;
}


#pragma mark - 그룹명으로 그룹 추가
- (void)addGroupWithInfoDic:(NSMutableDictionary *)infoDic
{
    NSString *groupName = [infoDic objectForKey:@"grpNm"];
    
    if( [groupName length] < 1 )
        return;
    
    int iInsertIndex = [self countOfFriendGroupWithoutCommunity];
    
    [self.groupList insertObject:groupName atIndex:iInsertIndex];
    
    [infoDic removeObjectForKey:@"frdGrpList"];
    if( [[infoDic objectForKey:@"frdGrpGbnCd"] length] )
    {
        [infoDic setObject:[infoDic objectForKey:@"frdGrpGbnCd"] forKey:@"grpGbnCd"];
        [infoDic removeObjectForKey:@"frdGrpGbnCd"];
    }
    [self.groupDetailInfoArr insertObject:infoDic atIndex:iInsertIndex];
    
    NSMutableArray *oneGroup = [[NSMutableArray alloc] init];
    [self.listByGrouped insertObject:oneGroup atIndex:iInsertIndex];
}



#pragma mark - 그룹명으로 그룹 삭제
- (void)removeGroupName:(NSString *)groupName
{
    int iGroupIndex = (int)[self.groupList indexOfObject:groupName];
    if( iGroupIndex < COUNT_FIXED_GROUP )       //그룹명이 존재하지 않거나, 고정된 리스트이면 리턴
    {
        if( iGroupIndex < 0 )
        {
            NSLog(@"No exxist group [%d]", iGroupIndex);
        }
        else
        {
            NSLog(@"Fixed group [%d]", iGroupIndex);
        }
        return;
    }
    
    //그룹명 삭제.
    [self.groupList removeObjectAtIndex:iGroupIndex];
    //그룹리스트에서 삭제.
    [self.listByGrouped removeObjectAtIndex:iGroupIndex];
    
    [self refreshAllGroupList];
}



#pragma mark - 인덱스로 그룹 삭제
- (void)removeGroupIndex:(int)groupIndex
{
    if( groupIndex < COUNT_FIXED_GROUP )       //그룹명이 존재하지 않거나, 고정된 리스트이면 리턴
    {
        if( groupIndex < 0 )
        {
            NSLog(@"No exxist group [%d]", groupIndex);
        }
        else
        {
            NSLog(@"Fixed group [%d]", groupIndex);
        }
        return;
    }
    
    //그룹명 삭제.
    [self.groupList removeObjectAtIndex:groupIndex];
    //그룹리스트에서 삭제.
    [self.listByGrouped removeObjectAtIndex:groupIndex];
    
    [self refreshAllGroupList];
}


#pragma mark - 그룹ID, 이름, 전화번호 배열을 이용해 멤버 추가
- (void)addPersonWithArray:(NSMutableArray *)personArr
{
    int iArrCnt = (int)[personArr count];
    for( int i=0 ; i<iArrCnt ; i++ )
    {
        [self addPerson:[personArr objectAtIndex:i]];
    }
}


#pragma mark - 그룹ID, 이름, 전화번호를 이용해 멤버 추가
- (void)addPerson:(NSDictionary *)personDic
{
    NSString *groupID = [personDic objectForKey:KEY_GROUP_ID];
    int iGroupIndex = [self getGroupNameWithGroupID:groupID];
    if( iGroupIndex < 0 )
    {
        NSLog(@"그룹인덱스가 존재하지 않으므로 리턴");
        return;
    }
    
    
    NSString *nameStr = [personDic objectForKey:KEY_NAME];
    if( [nameStr length] < 1 )      //이름 없으면 리턴
    {
        NSLog(@"이름이 없으므로 리턴");
        return;
    }
    
    NSString *numStr = [personDic objectForKey:KEY_NUM];
    if( [numStr length] < 1 )       //전화번호 없으면 리턴
    {
        NSLog(@"전화번호가 없으므로 리턴");
        return;
    }
    
    ContactsData *data = [ContactsData new];
    data.fullName = nameStr;
    data.CTNumber = [EtcUtil formatPhoneNumber:numStr];
    data.frdRegNo = [personDic objectForKey:@"frdRegNo"];
    data.frdMembYn = [personDic objectForKey:@"frdMembYn"];
    
    [[self.listByGrouped objectAtIndex:iGroupIndex] addObject:data];
    [self.allList addObject:data];
    NSLog(@"추가 성공 : [%@]", nameStr);
}



#pragma mark - 그룹명, 이름, 전화번호를 이용해 멤버 삭제
- (void)removePerson:(NSDictionary *)personDic
{
    NSString *groupStr = [personDic objectForKey:KEY_GROUP];
    if( [groupStr length] < 1 )     //그룹명 없으면 리턴
        return;
    
    NSString *nameStr = [personDic objectForKey:KEY_NAME];
    if( [nameStr length] < 1 )      //이름 없으면 리턴
        return;
    
    NSString *numStr = [personDic objectForKey:KEY_NUM];
    if( [numStr length] < 1 )       //전화번호 없으면 리턴
        return;
    
    
    
    int iGroupIndex = (int)[self.groupList indexOfObject:groupStr];
    if( iGroupIndex < 0 )       //그룹명이 존재하지 않으면 리턴
        return;
    
    
    
    NSMutableArray *arr = [self.listByGrouped objectAtIndex:iGroupIndex];
    int iArrCnt = (int)[arr count];
    for( int i=0 ; i<iArrCnt ; i++ )
    {
        ContactsData *data = [arr objectAtIndex:i];
        if( [data.CTNumber isEqualToString:numStr] )
        {
            [(NSMutableArray *)[self.listByGrouped objectAtIndex:iGroupIndex] removeObjectAtIndex:i];
            
            break;
        }
    }
    
    
    
    [self refreshAllGroupList];
}



#pragma mark - 인덱스를 이용해 멤버 삭제
- (void)removePersonWithGroupIndex:(int)groupIndex memberIndex:(int)memberIndex
{
    if( groupIndex < 0 || groupIndex >= [self countOfGroupList] )   //그룹 인덱스가 맞지 않으면 리턴
    {
        NSLog(@"Not exist group index %d", groupIndex);
        return;
    }
    
    
    int iMemberCnt = (int)[[self.listByGrouped objectAtIndex:groupIndex] count];
    if( memberIndex < 0 || memberIndex >= iMemberCnt )  //멤버 인덱스가 맞지 않으면 리턴
    {
        NSLog(@"Not exist member index %d", memberIndex);
        return;
    }
    
    
    
    [[self.listByGrouped objectAtIndex:groupIndex] removeObjectAtIndex:memberIndex];
    
    [self refreshAllGroupList];
}



#pragma mark - 서버에서 받은 데이터를 이용해 정보 설정
- (void)dataSettingForRegistedPsersons
{
    // cid Dictionary가 없으면 객체 생성
    if( !self.cidDic )
    {
        _cidDic = [[NSMutableDictionary alloc] init];
    }
    else
    {
        [_cidDic removeAllObjects];
    }
    
    
    //그룹 리스트 초기화
    [self.groupList removeAllObjects];
    [self.groupList setArray:ARRAY_FIXED_GROUP];
    
    //그룹 정보 리스트 초기화
    [self.groupDetailInfoArr removeAllObjects];
    
    //그룹으로 나누어진 친구 리스트 초기화
    [self.listByGrouped removeAllObjects];
    int iFixCnt = (int)[self.groupList count];
    for( int i=0 ; i<iFixCnt ; i++ )
    {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [self.listByGrouped addObject:arr];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [self.groupDetailInfoArr addObject:dic];
    }
    
    //모든 친구리스트 초기화
    [self.allList removeAllObjects];
    
    
    NSMutableArray *groupListArr = [self.recieveTrDic objectForKey:@"grpList"];
    int iCnt = (int)[groupListArr count];
    for( int i=0 ; i<iCnt ; i++ )
    {
        NSMutableDictionary *groupDic = [groupListArr objectAtIndex:i];
        NSMutableString *groupName = [groupDic objectForKey:@"grpNm"];
        NSMutableArray *friendArr = [groupDic objectForKey:@"frdList"];
        int iInsertIndex = -1;
        if( [ARRAY_FIXED_GROUP containsObject:groupName] )
        {
            iInsertIndex = (int)[ARRAY_FIXED_GROUP indexOfObject:groupName];
        }
        else
        {
            [self.groupList addObject:groupName];
            [self.listByGrouped addObject:[[NSMutableArray alloc] init]];
            [self.groupDetailInfoArr addObject:[[NSMutableDictionary alloc] init]];
            iInsertIndex = (int)[self.groupList count] - 1;
        }
        
        
        //그룹정보 설정 (데이터가 커서 리스트는 삭제)
        NSMutableDictionary * gInfoDic = [self.groupDetailInfoArr objectAtIndex:iInsertIndex];
        [gInfoDic setDictionary:groupDic];
        [gInfoDic removeObjectForKey:@"frdList"];
        
        
        // 친구 정보 설정
        int iFriendArrCnt = (int)[friendArr count];
        for( int j=0 ; j<iFriendArrCnt ; j++ )
        {
            NSMutableDictionary *friendDic = [friendArr objectAtIndex:j];
            ContactsData *data = [ContactsData new];
            data.fullName = [friendDic objectForKey:@"frdNm"];
            data.CTNumber = [EtcUtil formatPhoneNumber:[friendDic objectForKey:@"frdMoblNo"]];
            data.frdMembYn = [friendDic objectForKey:@"frdMembYn"];
            data.frdRegNo = [friendDic objectForKey:@"frdRegNo"];
            data.cId = [friendDic null_objectForKey:@"frdCid"];
            id idAutoSendList = [friendDic objectForKey:@"autoSendList"];
            if( [idAutoSendList isKindOfClass:[NSArray class]] )
            {
                data.autoSendList = idAutoSendList;
            }
            
            [[self.listByGrouped objectAtIndex:iInsertIndex] addObject:data];
            [self.allList addObject:data];
            
            
            /* key 를 cid로 하는 dictionary 데이터 설정 (메이트톡에서 사용하기 위해 만들기 시작함) */
            NSString *cidStr = data.cId;
            if( [cidStr length] )
            {
                NSMutableDictionary *oneDic = [_cidDic objectForKey:cidStr];
                if( oneDic )
                {
                    NSMutableArray *grArr = [oneDic objectForKey:@"group"];
                    if( grArr == nil )
                    {
                        grArr = [[NSMutableArray alloc] init];
                    }
                    
                    if( ![grArr containsObject:groupName] )
                    {
                        if( [grArr count] > 0 && [[grArr firstObject] isEqualToString:@"미지정"] )
                        {
                            [grArr insertObject:groupName atIndex:0];
                        }
                        else
                        {
                            [grArr addObject:groupName];
                        }
                        [oneDic setObject:grArr forKey:@"group"];
                    }
                }
                else
                {
                    NSString *nameStr = data.fullName;
                    if( [nameStr length] < 1 )
                        nameStr = @"";
                    
                    NSString *phnStr = data.CTNumber;
                    if( [phnStr length] < 1 )
                        phnStr = @"";
                    
                    NSString *numStr = data.searchNum;
                    if( [numStr length] < 1 )
                        numStr = @"";
                    
                    NSMutableArray *grArr = [[NSMutableArray alloc] init];
                    if( [groupName length] )
                    {
                        if( [grArr count] > 0 && [[grArr firstObject] isEqualToString:@"미지정"] )
                        {
                            [grArr insertObject:groupName atIndex:0];
                        }
                        else
                        {
                            [grArr addObject:groupName];
                        }
                    }
                    
                    NSMutableDictionary *oneDic = [[NSMutableDictionary alloc] initWithDictionary:@{@"name":nameStr, @"phone":phnStr, @"num":numStr, @"group":grArr}];
                    [_cidDic setObject:oneDic forKey:cidStr];
                }
            }
            /* */
        }
    }
}

- (void)dataSettingForCommunityList
{
    // cid Dictionary가 없으면 객체 생성
    if( !self.cidDic )
        _cidDic = [[NSMutableDictionary alloc] init];
    
    
    NSMutableArray *groupListArr = [self.recieveCommunityDic null_objectForKey:@"metgBnkbkList"];
    int iCnt = (int)[groupListArr count];
    for( int i=0 ; i<iCnt ; i++ )
    {
        NSMutableDictionary *groupDic = [groupListArr objectAtIndex:i];
        NSMutableString *groupName = [groupDic objectForKey:@"metgBnkbkNm"];
        NSMutableArray *friendArr = [groupDic objectForKey:@"mberList"];
        
        
        [self.groupList addObject:groupName];
        [self.listByGrouped addObject:[[NSMutableArray alloc] init]];
        
        
        //그룹정보 설정
        NSMutableDictionary * gInfoDic = [[NSMutableDictionary alloc] init];
        [gInfoDic setDictionary:groupDic];
        [gInfoDic removeObjectForKey:@"mberList"];
        // 모든 그룹 정보를 저장하는 변수
        [self.groupDetailInfoArr addObject:gInfoDic];
        // 커뮤니티 그룹 정보만 저장할 변수
        [self.communityAllList addObject:gInfoDic];
        
        // 친구 정보 설정
        int iFriendArrCnt = (int)[friendArr count];
        for( int j=0 ; j<iFriendArrCnt ; j++ )
        {
            NSMutableDictionary *friendDic = [friendArr objectAtIndex:j];
            ContactsData *data = [ContactsData new];
            data.fullName = [friendDic objectForKey:@"mberNm"];
            data.CTNumber = [EtcUtil formatPhoneNumber:[friendDic objectForKey:@"mberTel"]];
            data.cId = [friendDic null_objectForKey:@"mberCid"];
            
            
            [[self.listByGrouped lastObject] addObject:data];
            [self.allList addObject:data];
            
            /* key 를 cid로 하는 dictionary 데이터 설정 (메이트톡에서 사용하기 위해 만들기 시작함) */
            NSString *cidStr = data.cId;
            if( [cidStr length] )
            {
                NSMutableDictionary *oneDic = [_cidDic objectForKey:cidStr];
                if( oneDic )
                {
                    NSMutableArray *cmtArr = [oneDic objectForKey:@"community"];
                    if( cmtArr == nil )
                    {
                        cmtArr = [[NSMutableArray alloc] init];
                    }
                    
                    if( ![cmtArr containsObject:groupName] )
                    {
                        [cmtArr addObject:groupName];
                        [oneDic setObject:cmtArr forKey:@"community"];
                    }
                }
                else
                {
                    NSString *nameStr = data.fullName;
                    if( [nameStr length] < 1 )
                        nameStr = @"";
                    
                    NSString *phnStr = data.CTNumber;
                    if( [phnStr length] < 1 )
                        phnStr = @"";
                    
                    NSString *numStr = data.searchNum;
                    if( [numStr length] < 1 )
                        numStr = @"";
                    
                    NSMutableArray *cmtArr = [[NSMutableArray alloc] init];
                    if( [groupName length] )
                    {
                        [cmtArr addObject:groupName];
                    }
                    
                    NSMutableDictionary *oneDic = [[NSMutableDictionary alloc] initWithDictionary:@{@"name":nameStr, @"phone":phnStr, @"num":numStr, @"community":cmtArr}];
                    [_cidDic setObject:oneDic forKey:cidStr];
                }
            }
            /* */
        }
    }
    
    [self.communityListByGrouped removeAllObjects];
    [self.communityListByGrouped addObject:self.communityAllList];
    
    [self.communityGroupList removeAllObjects];
    [self.communityGroupList addObject:@"커뮤니티"];
}



@end
