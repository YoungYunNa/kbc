//
//  RegistedPersonsList.h
//  LiivMate
//
//  Created by KB_CARD_MINI_6 on 2016. 8. 3..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactsData.h"

#define COUNT_FIXED_GROUP       2
#define ARRAY_FIXED_GROUP       @[@"가족", @"애인"]


@interface RegistedPersonsList : NSObject

// 친구 + 커뮤니티
@property (nonatomic, strong)       NSMutableArray *allList;
@property (nonatomic, strong)       NSMutableArray *listByGrouped;
@property (nonatomic, strong)       NSMutableArray *groupList;

// 커뮤니티 그룹만 저장한 정보 배열
@property (nonatomic, strong)       NSMutableArray *communityAllList;
@property (nonatomic, strong)       NSMutableArray *communityListByGrouped;
@property (nonatomic, strong)       NSMutableArray *communityGroupList;


// 친구 목록 데이터
@property (nonatomic, strong)       NSMutableDictionary *recieveTrDic;
// 커뮤니티 목록 데이터
@property (nonatomic, strong)       NSMutableDictionary *recieveCommunityDic;


// cid를 키로하는 dictionary
@property (nonatomic, strong)       NSMutableDictionary *cidDic;


+ (BOOL)isSharedInstance;
+ (RegistedPersonsList*)sharedInstance;
+ (BOOL)refreshDataInstance;

//전체 리스트 수
- (int)countOfAllList;
//그룹의 수
- (int)countOfGroupList;
//친구 그룹의 수 (커뮤니티 제외)
- (int)countOfFriendGroupWithoutCommunity;

//그룹ID 얻기 (그룹이름)
- (NSString *)getGroupIDWithName:(NSString *)name;
//그룹 index 얻기 (그룹ID)
- (int)getGroupNameWithGroupID:(NSString *)gId;
//그룹 ID 얻기 (인덱스)
- (NSString *)getGroupIDWithIndex:(int)index;
//그룹 구분코드 얻기 (인덱스)
- (NSString *)getGroupCodeWithIndex:(int)index;
//그룹에 멤버가 한명일 경우 해당 정보 얻기
- (NSDictionary *)getIfOneMemberInfoWithIndex:(int)mIndex;

//주어진 이름이 그룹명 리스트에 존재하는지 확인
- (BOOL)isExistGroupName:(NSString *)gName;

//그룹 추가
- (void)addGroupWithInfoDic:(NSMutableDictionary *)infoDic;
//그룹 삭제
- (void)removeGroupName:(NSString *)groupName;
- (void)removeGroupIndex:(int)groupIndex;

//그룹원 추가
- (void)addPersonWithArray:(NSMutableArray *)personArr;
- (void)addPerson:(NSDictionary *)personDic;
//그룹원 삭제
- (void)removePerson:(NSDictionary *)personDic;
- (void)removePersonWithGroupIndex:(int)groupIndex memberIndex:(int)memberIndex;


@end
