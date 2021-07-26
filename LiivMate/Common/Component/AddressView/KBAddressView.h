//
//  KBAddressView.h
//  LiivMate
//
//  Created by KB_CARD_MINI_6 on 2016. 7. 27..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KBAccessbilityCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *accessibilityLabel;
@property (weak, nonatomic) IBOutlet UIImage *accessibilityImage;
@property (weak, nonatomic) IBOutlet UIButton *accessibilityButton;
@end

@interface KBAddressViewNoListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *descImageView;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@end

@interface KBAddressViewCommunityCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@end

@interface KBAddressViewPhoneAddressCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *typeImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * profileImgWidth;
@end

@interface ContactSelectedView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (strong, nonatomic) NSString *contactId;
@property (assign, nonatomic) NSInteger nSelectedIndexPathRow;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *viewCloseButton;
@property (strong, nonatomic) NSString *selectedInfoString;

@end




/*!
 화면에 보여줄 정보의 타입
 
 @enum  TYPE_PHONE_CONTACTS (주소록) , TYPE_FRIEND_CONTACTS (등록 친구)
 */
typedef NS_ENUM(NSInteger, CONTACTS_TYPE)
{
    TYPE_PHONE_CONTACTS,
    TYPE_FRIEND_CONTACTS,
    TYPE_COMMUNITY_CONTACTS,
    TYPE_INPUT_CONTACTS,
	TYPE_MEMBER_PHONE_CONTACTS
};

typedef NS_ENUM(NSInteger, LIMITED_TYPE)
{
    TYPE_ONE_LIMITED = 1,
    TYPE_FIVE_LIMITED = 5,
    TYPE_MULTI_LIMITED = 10,
    TYPE_UNLIMITED = 999
};

typedef void(^contactsBlock)  (BOOL success, CONTACTS_TYPE typeContact, NSArray* result);

#define MAX_MENU_COUNT  4

#define TYPE_PHOHE      @"TYPE_PHONE"
#define TYPE_FRIEND     @"TYPE_FRIEND"
#define TYPE_COMMUNITY  @"TYPE_COMMUNITY"
#define TYPE_CUSTINPUT  @"TYPE_CUSTINPUT"
#define TYPE_MEMBER_PHONE      @"TYPE_MEMBER_PHONE"

#define TYPE_PHOHE_DISABLE      @"TYPE_PHONE_DISABLE"
#define TYPE_FRIEND_DISABLE     @"TYPE_FRIEND_DISABLE"
#define TYPE_COMMUNITY_DISABLE  @"TYPE_COMMUNITY_DISABLE"
#define TYPE_CUSTINPUT_DISABLE  @"TYPE_CUSTINPUT_DISABLE"
#define TYPE_MEMBER_PHONE_DISABLE      @"TYPE_MEMBER_PHONE_DISABLE"

#define TYPES           @[TYPE_PHOHE, TYPE_FRIEND, TYPE_COMMUNITY, TYPE_CUSTINPUT, TYPE_MEMBER_PHONE]
#define TYPES_DISABLE   @[TYPE_PHOHE_DISABLE, TYPE_FRIEND_DISABLE, TYPE_COMMUNITY_DISABLE, TYPE_CUSTINPUT_DISABLE, TYPE_MEMBER_PHONE_DISABLE]
#define TITLES          @[@"내 폰 주소록", @"등록친구", @"커뮤니티", @"직접입력", @"폰 주소록(회원)"]




@interface KBAddressView : ViewController

//초대전용모드 기존회원 선택시 팝업및 선택못함
@property (nonatomic, assign) BOOL inviteMode;
@property (nonatomic, strong) NSString * filterType;
@property (nonatomic, strong) NSString * mTitle;
@property (nonatomic, strong) NSMutableDictionary * filterDict;
@property (nonatomic, assign) BOOL hiddenSelectGroupView;

/*!
 객체 생성 및 초기화
 
 @param     limitType : 다중 선택 타입 , completeBlock : block 함수 , menuTypes : 메뉴 목록들
 @returns   (instancetype)객체
 */
+(instancetype)initWithLimitedType:(LIMITED_TYPE)limitType filterType:(NSString *)filterType title:(NSString* )mTitle dismissAnimated:(BOOL)dissmissAnimated completeBlock:(contactsBlock)completeBlock menues:(NSString *)menuTypes, ...;

- (void)setGroupName:(NSString *)groupName;

- (void)setUserInputGroup:(NSString *)userInputGroupName;

- (int)setUserSelectedGroupWithData:(NSArray *)dataArray;

- (void)setSelectedListData:(NSArray*)dataArray;            //선택된 리스트를 보내기 위한 처리

@end
