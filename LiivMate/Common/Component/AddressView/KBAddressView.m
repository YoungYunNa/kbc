//
//  KBAddressView.m
//  LiivMate
//
//  Created by KB_CARD_MINI_6 on 2016. 7. 27..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import "KBAddressView.h"
#import "MyAddressBook.h"
#import "KBLocalizedIndexedCollationExtend.h"
#import "EdgeTextField.h"
#import <AddressBook/AddressBook.h>
#import "UITableViewCell+Option.h"

#define HEIGHT_KINDOF_HEADER    28
#define HEIGHT_TVCELL_HEADER    48
#define HEIGHT_TVCELL           40
#define HEIGHT_TVCELL_COMMUNITY		84
#define HEIGHT_TVCELL_PHONE_ADDR	84
#define HEIGHT_TVCELL_PHONE_ADDR_HEADER		31

// 직접입력 탭 (뷰 tag)
#define TAG_BTN_SELECT_GROUP    9120		//그룹선택하기 버튼
#define TAG_BTN_CONFIRM         8943		//저장하기 버튼
#define TAG_TF_NAME             2930		//이름 입력 Textfield
#define TAG_TF_PNUM             9243		//전화번호 입력 Textfield
#define TAG_LB_NAME             700			//이름 label
#define TAG_LB_NAME_GUIDE       701			//안내 문구
#define TAG_LB_PNUM             702			//전화번호 타이틀 label
#define TAG_LB_GROUP            703			//그룹지정하기 타이틀 label
#define TAG_LB_GROUP_GUIDE      704			//안내 문구

//커뮤니티 탭의 헤더 이름
#define NAME_COMMUNITY_HEADER       @"커뮤니티계좌"

#define INVITE_ALERT_MESSAGE		@"기가입 회원 입니다."

//타입에 따라 다른변수를 사용하므로 분기코딩을 줄이기 위해 define을 사용
#define ARR_ALL_LIST        [self getAllList]
#define ARR_SECTION_LIST    [self getListByGrouped]
#define ARR_SECTION_HEADER  [self getGroupList]

//테이블뷰의 기본그룹 헤더 인덱스
#define INDEX_FIXEDGROUP_HEADER     0
//테이블뷰의 추가그룹 헤더 인덱스
#define INDEX_ADDGROUP_HEADER       ([[RegistedPersonsList sharedInstance] countOfFriendGroupWithoutCommunity] + 1)

#define INDEX_REAL_GROUP(x)     ( (x < INDEX_ADDGROUP_HEADER) ? (int)(x-1) : (int)(x-2) )
#define INDEX_REAL_SECTION(x)   ( (x < (INDEX_ADDGROUP_HEADER-1)) ? (int)(x+1) : (int)(x+2) )

@implementation KBAccessbilityCell
@end

@implementation KBAddressViewNoListCell
@end

@implementation KBAddressViewCommunityCell
@end

@implementation KBAddressViewPhoneAddressCell
@end

@implementation ContactSelectedView
@end

@interface KBAddressView () <UITextFieldDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
{
	//시작 탭 인덱스
    int mIStartIndex;
    
    //탭 메뉴 목록 배열
    NSMutableArray *menuesArray;
    //block 함수
    contactsBlock ctctBlock;
    //dissmiss 시 애니메이션 여부
    BOOL mDissmissAnimated;
    
    //탭 버튼 배열
    NSMutableArray *buttonsArray;
    
    //현재 선택된 탭
    int mICurTabIndex;
    //현재 실행되고 있는 타입
    CONTACTS_TYPE mContactType;
    //현재 설정된 선택 개수 제한 타입
    LIMITED_TYPE mLimitType;
	
	//탭 버튼의 백그라운드뷰
	__weak IBOutlet UIView *tabBackView;
	__weak IBOutlet NSLayoutConstraint *tabBackViewTop;
	
    //검색바의 백그라운드뷰
    __weak IBOutlet UIView *searchBackView;
	__weak IBOutlet NSLayoutConstraint *searchBackViewTop;
	//검색바
    __weak IBOutlet UISearchBar *contactsSearchBar;
    
    // ~명까지 선택 가능합니다. Label
    __weak IBOutlet UILabel *notiLB;
	__weak IBOutlet UIView *notiView;
	__weak IBOutlet NSLayoutConstraint *notiViewTop;
	
    //테이블뷰
    __weak IBOutlet UITableView *contactsTableView;
	
    //셀 다중 선택 시 나오는 하단 확인 버튼
    __weak IBOutlet UIButton *confirmBtn;
	__weak IBOutlet UIView *confirmView;
	__weak IBOutlet NSLayoutConstraint *confirmViewBottom;
    
    
    //검색 text 삭제 버튼
   
    __weak IBOutlet UIButton *deleteBtn;
    
    __weak IBOutlet UIScrollView *contactSelectedScrollView;
    __weak IBOutlet UIStackView *contactSelectedContentStackView;
    __weak IBOutlet NSLayoutConstraint *contactSelectedViewHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *contactSelectedScrollViewWidthConstraint;
	
    //테이블 목록 없을 때 안내 Label
//    UILabel *nonDataLabel;
    
    //연락처 전체 배열
    NSMutableArray *mABArray;
    //초성으로 나뉘어진 연락처 배열
    NSMutableArray *sectionM_ABArray;
    //localization을 이용한 테이블뷰 헤더 정보 리스트
    KBLocalizedIndexedCollationExtend *collationExtend;
	
	
	// 회원 연락처
	NSMutableArray *mABArrayForMember;
	NSMutableArray *sectionM_ABArrayForMember;

    
    //등록 친구 그룹 펼침 정보를 저장할 배열
    NSMutableArray *friendExtendArray;
    
    //검색 시 보여줄 연락처 배열
    NSMutableArray *searchHistoryArray;
    
    //체크박스 선택된 항목들을 저장할 배열
    NSMutableArray *selectedInfoArray;
    
    /**/
    //직접입력선택시의 백그라운드 뷰
    __weak IBOutlet UIScrollView *userInputView;
	//직접입력선택시의 그룹 지정 백그라운드 뷰
	__weak IBOutlet UIView *selectGroupBackView;
	__weak IBOutlet NSLayoutConstraint *selectGroupBackViewTop;
    //직접입력선택시의 지정 그룹을 표시할 label
    __weak IBOutlet UILabel *showSelectLB;
	__weak IBOutlet NSLayoutConstraint *showSelectLBBackViewTop;
	__weak IBOutlet NSLayoutConstraint *showSelectLBBackViewBottom;
	// 저장하기 버튼 top constraint
	__weak IBOutlet NSLayoutConstraint *saveButtonTop;
    //지정 그룹 목록 배열
    NSMutableArray *userSelectedArr;
    /**/
	
    //특정 그룹의 리스트만 보일때 그룹명으로 사용.
    NSString *groupNameStr;
    
    //직접입력화면에서 그룹명이 직접 넣고싶을때 사용.
    NSString *fixedInputGroupName;
    
    // 전화번호에 대한 회원정보
    NSMutableDictionary *memberInfoDic;
}
@end

@implementation KBAddressView

/*!
 메모리 해제 : viewController 해제 직전 호출
 
 @param
 @returns
 */
#pragma mark - 메모리 해제
-(void)dealloc
{
    
    NSLog(@"%s", __FUNCTION__);
}

- (void)makeMemberABArray
{
	mABArrayForMember = [[NSMutableArray alloc] init];
	for (ContactsData *data in mABArray)
	{
		NSString *cidStr = [memberInfoDic objectForKey:data.searchNum];
		if ([cidStr length] < 1)
		{
			cidStr = data.cId;
		}
		
		if ([cidStr length] > 0)
		{
			[mABArrayForMember addObject:data];
		}
	}
	
	sectionM_ABArrayForMember = [[NSMutableArray alloc] init];
	if( [mABArrayForMember count] )  //단말 [주소록]에서 전화번호가 있을 경우에
	{
		//이름별로 section을 나누기 위한 기준값 지정
		collationExtend = [[KBLocalizedIndexedCollationExtend alloc] init];
		
		NSMutableArray *dataArr = [[NSMutableArray alloc] init];
		for(int i = 0; i < [[collationExtend sectionTitlesExtend] count]; i++)      // section의 기준값 - ㄱ, ㄴ, ㄷ 로 나눈 후에 ㄱ에 대한 배열할당 - 2차원 배열로 할당하는 구조
		{
			NSMutableArray * array = [[NSMutableArray alloc] init];
			[dataArr addObject:array];
		}
		
		for(id object in mABArrayForMember)
		{
			//mABArray에 대해서 fullName을 기준으로 section 으로 나누고, 저장되도록 하는 함수
			//이름에 "성"을 가지고 collationExtend의 index를 찾음, 찾고 난후에 dataArr에 저장
			NSInteger index = [collationExtend sectionForObjectExtend:object collationStringSelector:@selector(fullName) collationString:((ContactsData *)object).fullName];
			
			[[dataArr objectAtIndex:index] addObject:object];
		}
		
		for(NSMutableArray *section in dataArr)
		{
			//sectionM_ABArray에 순서 없이 저장된 data에 대해서 fullName을 기준으로 정렬이 되도록 조정
			[sectionM_ABArrayForMember addObject:[collationExtend sortedArrayFromArrayExtend:section collationStringSelector:@selector(fullName)]];
		}
	}
}


#pragma mark - 타입에 따른 전체 리스트 가져오기
- (NSMutableArray *)getAllList
{
    switch ((int)mContactType) {
		case TYPE_MEMBER_PHONE_CONTACTS:
		{
			return mABArrayForMember;
		}
			break;
        case TYPE_PHONE_CONTACTS:
        {
            return mABArray;
        }
            break;
        case TYPE_FRIEND_CONTACTS:
        {
            return [RegistedPersonsList sharedInstance].allList;
        }
            break;
        case TYPE_COMMUNITY_CONTACTS:
        {
            return [RegistedPersonsList sharedInstance].communityAllList;
        }
            break;
    }
    return nil;
}

#pragma mark - 타입에 따른 그룹화된 리스트 가져오기
- (NSMutableArray *)getListByGrouped
{
    switch ((int)mContactType) {
		case TYPE_MEMBER_PHONE_CONTACTS:
		{
			return sectionM_ABArrayForMember;
		}
			break;
        case TYPE_PHONE_CONTACTS:
        {
            return sectionM_ABArray;
        }
            break;
        case TYPE_FRIEND_CONTACTS:
        {
            return [RegistedPersonsList sharedInstance].listByGrouped;
        }
            break;
        case TYPE_COMMUNITY_CONTACTS:
        {
            return [RegistedPersonsList sharedInstance].communityListByGrouped;
        }
            break;
    }
    return nil;
}

#pragma mark - 타입에 따른 그룹 리스트 가져오기
- (NSMutableArray *)getGroupList
{
    switch ((int)mContactType) {
		case TYPE_MEMBER_PHONE_CONTACTS:
		{
			return [collationExtend sectionTitlesExtend];
		}
			break;
        case TYPE_PHONE_CONTACTS:
        {
            return [collationExtend sectionTitlesExtend];
        }
            break;
        case TYPE_FRIEND_CONTACTS:
        {
            return [RegistedPersonsList sharedInstance].groupList;
        }
            break;
        case TYPE_COMMUNITY_CONTACTS:
        {
            return [RegistedPersonsList sharedInstance].communityGroupList;
        }
            break;
    }
    return nil;
}


/*!
 객체 생성 및 초기화
 
 @param     index : 선택된 탭 인덱스 , completeBlock : block 함수 , menuTypes : 메뉴 목록들
 @returns   (instancetype)객체
 */
#pragma mark - 객체 생성 및 초기화

+(instancetype)initWithLimitedType:(LIMITED_TYPE)limitType filterType:(NSString *)filterType title:(NSString* )mTitle dismissAnimated:(BOOL)dissmissAnimated completeBlock:(contactsBlock)completeBlock menues:(NSString *)menuTypes, ...
{
	KBAddressView *addressVC = [[UIStoryboard storyboardWithName:@"Component" bundle:nil] instantiateViewControllerWithIdentifier:@"KBAddressView"];
    addressVC.viewID = MenuID_AddressBook;;
    addressVC.filterType = filterType;
    addressVC.mTitle = mTitle;

	if (addressVC){
        
        //메뉴 정보 저장
        addressVC->menuesArray = [[NSMutableArray alloc] init];
        
        va_list args;
        va_start(args, menuTypes);
        for (NSString *type = menuTypes; type != nil; type = va_arg(args, NSString *))
        {
            if( [TYPES containsObject:type] || [TYPES_DISABLE containsObject:type] )
            {
                if( [addressVC->menuesArray containsObject:type] )
                    continue;
                [addressVC->menuesArray addObject:type];
            }
        }
        va_end(args);
        
        
        //예외처리 menuesArray에 내용이 없을때 [주소록, 등록친구]를 디폴트로 함.
        if( [addressVC->menuesArray count] == 0 )
        {
            [addressVC->menuesArray addObject:TYPE_PHOHE];
            [addressVC->menuesArray addObject:TYPE_FRIEND];
        }
		
		
		// ???? TODO : 확인 요망 (리브메이트 v.2 - 주소록은 내폰 주소록 한개만 사용한다.)
		///*
		if ([addressVC->menuesArray containsObject:TYPE_MEMBER_PHONE])
		{
			[addressVC->menuesArray removeAllObjects];
			[addressVC->menuesArray addObject:TYPE_MEMBER_PHONE];
		}
		else
		{
			[addressVC->menuesArray removeAllObjects];
			[addressVC->menuesArray addObject:TYPE_PHOHE];
		}
		//*/
        
        //선택 개수 제한 타입
        addressVC->mLimitType = limitType;
        
        //시작 탭 정보 저장
        addressVC->mIStartIndex = 0;
        //        if( index < 0 || index > (MAX_MENU_COUNT-1) )
        //            mIStartIndex = 0;
        
        //block 함수 저장
        addressVC->ctctBlock = completeBlock;
        
        //dissmiss 시 애니메이션 여부
        addressVC->mDissmissAnimated = dissmissAnimated;
    }
    return addressVC;
}


- (void)setGroupName:(NSString *)groupName
{
    groupNameStr = groupName;
}


#pragma mark - 화면 진입 시 그룹명 고정으로 하고싶을때 사용
- (void)setUserInputGroup:(NSString *)userInputGroupName
{
    fixedInputGroupName = userInputGroupName;
}


/*!
 view 로드 : view 로드 후 자동 호출
 
 @param
 @returns
 */
#pragma mark - viewDidLoad
-(void)viewDidLoad
{
    [super viewDidLoad];
    
//    if (self.mTitle.length > 0) {
//        self.title = self.mTitle;
//    } else {
//    self.title = @"주소록";
//    }
    
    if( [groupNameStr length] > 0 )
    {
        self.title = groupNameStr;
    }
	
    searchHistoryArray = [[NSMutableArray alloc] init];
    buttonsArray = [[NSMutableArray alloc] init];
    friendExtendArray = [[NSMutableArray alloc] init];
    userSelectedArr = [[NSMutableArray alloc] init];
    if (selectedInfoArray == nil) {
        selectedInfoArray = [[NSMutableArray alloc] init];
    }
    
    [deleteBtn setHidden:YES];
    [self gridView];
}


/*!
 view가 보여질때 호출
 
 @param
 @returns
 */
#pragma mark - viewWillAppear
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    for(UIView *view in contactSelectedContentStackView.subviews){
        [view removeFromSuperview];
    }
    [contactsTableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self drawSearchBar];
}


/*!
 화면 생성
 
 @param
 @returns
 */
#pragma mark - UI 생성 (탭바 및 연락처)
- (void)gridView
{
	// 탭 바
	{
		//버튼 Array의 개수만큼 버튼을 만들어주자.
		int iBtnCnt = (int)[menuesArray count];
		//버튼의 width는 n빵.
		int iPosX = 0;
		int iPosY = 0;
		int iWidth = (int)(tabBackView.bounds.size.width/iBtnCnt);
		int iHeight = tabBackView.bounds.size.height - 1;
		for( int i=0 ; i<iBtnCnt ; i++ )
		{
			if( i == (iBtnCnt-1) )  //정확히 n등분되지 않을 수 있으니, 마지막은 꽉 채워주자.
				iWidth = (tabBackView.bounds.size.width - iPosX);
			
			//해당 스트링은 .h파일에 define되어있음.
			NSString *sType = [menuesArray objectAtIndex:i];
			
			// 탭 비활성화 여부
			BOOL isDiable = NO;
			
			//타이틀도 .h파일에 define되어있음.
			int iIndex = (int)[TYPES indexOfObject:sType];
			if( iIndex >= 0 && mIStartIndex == 0 )
			{
				mIStartIndex = i;
			}
			
			if( iIndex < 0 )
			{
				iIndex = (int)[TYPES_DISABLE indexOfObject:sType];
				if( iIndex >= 0 )
				{
					isDiable = YES;
				}
			}
			
			UIButton *tabBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			[tabBtn setFrame:CGRectMake(iPosX, iPosY, iWidth, iHeight)];
			[tabBtn setIsAccessibilityElement:YES];
			[tabBtn setTag:iIndex];
			[tabBtn setBackgroundColor:[UIColor whiteColor]];
			[tabBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
			[tabBtn setTitle:[TITLES objectAtIndex:iIndex] forState:UIControlStateNormal];
			[tabBtn setAccessibilityLabel:[TITLES objectAtIndex:iIndex]];
			[tabBtn setTitleColor:[EtcUtil colorWithHexString:@"333333"] forState:UIControlStateNormal];
			
			UIImage *norImg = [UIImage imageNamed:@"tab_select.png"];
			norImg = [norImg resizableImageWithCapInsets:UIEdgeInsetsMake(5, 1, 5, 1)];
			[tabBtn setBackgroundImage:norImg forState:UIControlStateSelected];
			
			[tabBtn addTarget:self action:@selector(tabButtonAction:) forControlEvents:UIControlEventTouchUpInside];
			[tabBtn addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
			[tabBtn addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDragEnter];
			[tabBtn addTarget:self action:@selector(buttonTouchCancel:) forControlEvents:UIControlEventTouchCancel];
			[tabBtn addTarget:self action:@selector(buttonTouchCancel:) forControlEvents:UIControlEventTouchDragExit];
			[tabBtn addTarget:self action:@selector(buttonTouchCancel:) forControlEvents:UIControlEventTouchUpOutside];
			
			tabBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
			[tabBackView addSubview:tabBtn];
			
			if( isDiable )
			{
				[tabBtn setEnabled:NO];
			}
			
			[buttonsArray addObject:tabBtn];
			
			iPosX += iWidth;
		}
	}

    
	//특정 그룹만 보여줄때는 탭 바가 안보인다.
	// 리브메이트 버전 2에서 탭 안보여준다. (나중을 위해 남겨둠)
	if( [groupNameStr length] > 0 || buttonsArray.count <= 1)
	{
		[tabBackView setHidden:YES];
		// 위로 이동
		tabBackViewTop.constant = -1 * tabBackView.bounds.size.height;
	}

    
    //서치 바
    [self drawSearchBar];
  
	
	//특정 그룹만 보여줄때는 서치바가 안보인다.
	if( [groupNameStr length] > 0 )
	{
		/*
		[searchBackView setHidden:YES];
		// 위로 이동
		searchBackViewTop.constant = -1 * searchBackView.bounds.size.height;
		*/
	}

	
    if( mLimitType > TYPE_ONE_LIMITED  && mLimitType != TYPE_UNLIMITED)
    {
        int iInfoArrCnt = (int)[selectedInfoArray count];
        NSString *strTitle = [NSString stringWithFormat:@"최대 %d명까지 선택 가능합니다.", (int)mLimitType - iInfoArrCnt];
        [notiLB setIsAccessibilityElement:YES];
        [notiLB setAccessibilityLabel:strTitle];
        [notiLB setText:strTitle];
    }
    else
    {
		[notiView setHidden:YES];
		// 위로 이동
		notiViewTop.constant = -1 * notiView.bounds.size.height;
        
        contactSelectedViewHeightConstraint.constant = 0;
    }
    
    //다중선택 시에는 하단 확인버튼이 있다.
    if( mLimitType > TYPE_ONE_LIMITED )
    {
//		[confirmBtn setBackgroundImage:[[confirmBtn backgroundImageForState:UIControlStateNormal] stretchableImageWithCapWidthRatio:0.5 capHeightRatio:0.5] forState:UIControlStateNormal];
        [confirmBtn setBackgroundImage:[EtcUtil imageWithColor:UIColorFromRGB(0x086cfd)] forState:UIControlStateNormal];
        [confirmBtn setBackgroundImage:[EtcUtil imageWithColor:UIColorFromRGB(0xc3c3c3)] forState:UIControlStateDisabled];

        BOOL isEvent = self.filterType.length > 0;
        NSString * btnTitle = isEvent ? @"선택 완료" : @"인원 추가";
        
        [confirmBtn setIsAccessibilityElement:NO];
        [confirmBtn setAccessibilityLabel:btnTitle];
        [[confirmBtn titleLabel] setText:btnTitle];
        if(selectedInfoArray.count > 0){
            [confirmBtn setTitle:[NSString stringWithFormat:@"%@(%lu)", btnTitle, (unsigned long)selectedInfoArray.count] forState:UIControlStateNormal];
            [confirmBtn setEnabled:YES];
        } else {
            btnTitle = isEvent ? @"선택 완료(0)" : @"인원 추가";
            [confirmBtn setTitle:btnTitle forState:UIControlStateDisabled];
            [confirmBtn setEnabled:NO];
        }
    }
	else
	{
		[confirmView setHidden:YES];
		// 아래로 이동
		confirmViewBottom.constant = -1 * confirmView.bounds.size.height;
	}
    
    
    //직접입력뷰를 생성함
    [self gridUserInputView];
    
    
    //시작하고 싶은 인덱스의 버튼을 클릭한 효과
    [self tabButtonAction:[buttonsArray objectAtIndex:mIStartIndex]];
}

- (void)drawSearchBar
{
    {
        NSLog(@"drawSearchBar");
//        NSString *strTitle = @"성명 또는 연락처를 검색해 주세요.";
        NSString *strTitle = @"받는사람 이름, 또는 연락처";
        [contactsSearchBar setAccessibilityTraits:UIAccessibilityTraitSearchField];
        [contactsSearchBar setIsAccessibilityElement:YES];
        [contactsSearchBar setAccessibilityLabel:strTitle];
//        [contactsSearchBar.text
//        [contactsSearchBar setBackgroundImage:[EtcUtil imageWithColor:[EtcUtil colorWithHexString:@"8D9CFD"]]];
        
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
        //toolBar.barStyle = UIBarStyleBlackTranslucent;
        //toolBar.barTintColor = [EtcUtil colorWithHexString:@"8D9CFD"];
        //toolBar.tintColor = [EtcUtil colorWithHexString:@"FFFFFF"];
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemFlexibleSpace) target:nil action:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemDone) target:contactsSearchBar action:@selector(resignFirstResponder)];
        toolBar.items = [NSArray arrayWithObjects:space,doneButton, nil];
        contactsSearchBar.inputAccessoryView = toolBar;
        
        UITextField *txtSearchField =  nil;
        if (@available(iOS 13.0, *)) {
             if ([self respondsToSelector:NSSelectorFromString(@"setModalInPresentation:")]) {
                 
                txtSearchField = [contactsSearchBar valueForKey:@"searchTextField"];//contactsSearchBar.searchTextField;
                contactsSearchBar.searchTextPositionAdjustment = UIOffsetMake(-30, 0);
             } else {
                 txtSearchField = [contactsSearchBar valueForKey:@"_searchField"];
             }
            
        } else {
            txtSearchField = [contactsSearchBar valueForKey:@"_searchField"];
        }
        
        [txtSearchField setBorderStyle:UITextBorderStyleNone];
        [txtSearchField setTextAlignment:NSTextAlignmentLeft];
//        [txtSearchField setTextColor:[EtcUtil colorWithHexString:@"FFFFFF"]];
        [txtSearchField setFont:[UIFont systemFontOfSize:16]];
        [txtSearchField setLeftViewMode:UITextFieldViewModeNever];
        [txtSearchField setClearButtonMode:UITextFieldViewModeNever];
        txtSearchField.clipsToBounds = NO;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        NSMutableAttributedString *attString =
        [[NSMutableAttributedString alloc] initWithString:strTitle
                                               attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16],
                                                            NSForegroundColorAttributeName: [EtcUtil colorWithHexString:@"FFFFFF"],
                                                            NSParagraphStyleAttributeName: paragraphStyle}];
        [txtSearchField setAttributedPlaceholder:attString];
        


#if 0 //deprecated: first deprecated in iOS 9.0 (SM 수정 로직 추가)
            [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                                      [EtcUtil colorWithHexString:@"FFFFFF"],
                                                                                                      NSForegroundColorAttributeName,
                                                                                                      [UIFont systemFontOfSize:16],
                                                                                                      NSFontAttributeName,
                                                                                                      nil]
                                                                                            forState:UIControlStateNormal];
#else
        [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                                      [EtcUtil colorWithHexString:@"FFFFFF"],
                                                                                                      NSForegroundColorAttributeName,
                                                                                                      [UIFont systemFontOfSize:16],
                                                                                                      NSFontAttributeName,
                                                                                                      nil]
                                                                                            forState:UIControlStateNormal];
#endif
    }
}



- (void)gridUserInputView
{
	//이름 label
	UILabel *nameLB = (UILabel *)[userInputView viewWithTag:TAG_LB_NAME];
    [nameLB setIsAccessibilityElement:YES];
    [nameLB setAccessibilityLabel:nameLB.text];
	
    //이름 입력 Textfield
	EdgeTextField *nameTF = (EdgeTextField *)[userInputView viewWithTag:TAG_TF_NAME];
    [nameTF setIsAccessibilityElement:YES];
    [nameTF setShowUnderlineByStatus:YES];
	
    //안내 문구
	UILabel *notiLB2 = (UILabel *)[userInputView viewWithTag:TAG_LB_NAME_GUIDE];
    [notiLB2 setIsAccessibilityElement:YES];
    [notiLB2 setAccessibilityLabel:notiLB2.text];
	
    //전화번호 타이틀 label
    UILabel *numLB = (UILabel *)[userInputView viewWithTag:TAG_LB_PNUM];
    [numLB setIsAccessibilityElement:YES];
    [numLB setAccessibilityLabel:numLB.text];
	
    //전화번호 입력 Textfield
    EdgeTextField *numTF = (EdgeTextField *)[userInputView viewWithTag:TAG_TF_PNUM];
    [numTF setIsAccessibilityElement:YES];
    [numTF setShowUnderlineByStatus:YES];
	
    if( !(self.hiddenSelectGroupView) )
    {
        if( [fixedInputGroupName length] < 1 )
        {
            //그룹지정하기 타이틀 label
            UILabel *groupLB = (UILabel *)[userInputView viewWithTag:TAG_LB_GROUP];
            [groupLB setIsAccessibilityElement:YES];
            [groupLB setAccessibilityLabel:groupLB.text];
			
            //안내 문구
            UILabel *notiLB2 = (UILabel *)[userInputView viewWithTag:TAG_LB_GROUP_GUIDE];
            [notiLB2 setIsAccessibilityElement:YES];
            [notiLB2 setAccessibilityLabel:notiLB2.text];
        }
		else
		{
			showSelectLBBackViewTop.constant = 16;
		}
        
        //지정할 그룹을 보여줄 label
		if( [fixedInputGroupName length] < 1 )
			[self setUserSelectedGroupWithData:nil];
		else
			[self setUserSelectedGroupWithData:[[NSArray alloc] initWithObjects:fixedInputGroupName, nil]];
        [showSelectLB setIsAccessibilityElement:YES];
        [showSelectLB setAccessibilityLabel:showSelectLB.text];
		
        if( [fixedInputGroupName length] < 1 )
        {
            //그룹선택하기 버튼
            UIButton *selectGroupBtn = (UIButton *)[userInputView viewWithTag:TAG_BTN_SELECT_GROUP];
            [selectGroupBtn setIsAccessibilityElement:YES];
            [selectGroupBtn setAccessibilityLabel:[selectGroupBtn titleForState:UIControlStateNormal]];
            selectGroupBtn.layer.cornerRadius = 4;
            selectGroupBtn.layer.masksToBounds = YES;
         }
		else
		{
			showSelectLBBackViewBottom.constant = 0;
		}
    }
	else
	{
		selectGroupBackView.hidden = YES;
		selectGroupBackViewTop.constant = -1 * selectGroupBackView.bounds.size.height;
	}
    
	// 저장하기 버튼
    UIButton *saveBtn = (UIButton *)[userInputView viewWithTag:TAG_BTN_CONFIRM];
    [saveBtn setIsAccessibilityElement:YES];
    [saveBtn setAccessibilityLabel:[saveBtn titleForState:UIControlStateNormal]];
}


/*!
 view의 layout 설정
 
 @param
 @returns
 */
#pragma mark - viewWillLayoutSubviews
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
	//NSLog(@"\n[contentSize] : %d, [frame] : %d", (int)(userInputView.contentSize.height), (int)(userInputView.frame.size.height));
	
    /*직접입력화면*/
	if (userInputView.contentSize.height > 0 && userInputView.contentSize.height < userInputView.frame.size.height)
	{
		saveButtonTop.constant += (userInputView.frame.size.height - userInputView.contentSize.height);
	}
}


- (int)setUserSelectedGroupWithData:(NSArray *)dataArray
{
    if( dataArray != nil )
    {
        [userSelectedArr removeAllObjects];
        [userSelectedArr setArray:dataArray];
    }
    
    
    NSMutableString *groupsStr = [[NSMutableString alloc] init];
    int iArrCnt = (int)[dataArray count];
    if( iArrCnt > 0 )
    {
        for( int i=0 ; i<iArrCnt ; i++ )
        {
            [groupsStr appendFormat:@"%@", [dataArray objectAtIndex:i]];
            if( i != (iArrCnt-1) )
            {
                [groupsStr appendString:@", "];
            }
        }
    }
    else
    {
        [groupsStr setString:@"미지정"];
    }
    
    
    [showSelectLB setText:groupsStr];
	
    return (int)(showSelectLB.bounds.size.height);
}

- (void)setSelectedListData:(NSArray*)dataArray
{
    if( dataArray != nil )
    {
        selectedInfoArray = [NSMutableArray arrayWithArray:dataArray];
        [contactsTableView reloadData];
    }
}


/*!
 연락처 접근 권한 설정 처리
 
 @param
 @returns
 */
#pragma mark - 연락처 접근 권한 설정 처리
- (void)setContactsDataForDevice
{
#if 0 //deprecated: first deprecated in iOS 9.0 (SM 수정 로직 추가)
    if(ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)   //수락
    {
        [self getContactsFromDevice];
    }
    else if(ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
    {
        CFErrorRef err;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &err);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error){
            if(granted)
            {
                NSLog(@"granted");
            }
            else
            {
                NSLog(@"not granted");
            }
        });
        
        if(&ABAddressBookRequestAccessWithCompletion != NULL)
        {
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRef localAddressBook = ABAddressBookCreate();
            ABAddressBookRequestAccessWithCompletion(localAddressBook, ^(bool granted, CFErrorRef error) {
                dispatch_semaphore_signal(sema);
            });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            CFRelease(localAddressBook);
        }
        CFRelease(addressBook);
        
        if(ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied)   //거절
        {
            [BlockAlertView showBlockAlertWithTitle:@"알림" message:@"단말기의 [설정 > 개인정보보호 > 연락처]에서 설정을 변경해주세요." dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex){
				if(buttonIndex == 1) {
						[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
				}
            } cancelButtonTitle:@"취소" buttonTitles:@"설정", nil];
            
            [self tableViewApplyToData:nil];
        }
        else    //수락
        {
            [self getContactsFromDevice];
        }
    }
    else    //거절
    {
        [BlockAlertView showBlockAlertWithTitle:@"알림" message:@"단말기의 [설정 > 개인정보보호 > 연락처]에서 설정을 변경해주세요." dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex){
			if(buttonIndex == 1) {
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
			}
        } cancelButtonTitle:@"취소" buttonTitles:@"설정", nil];
        
        [self tableViewApplyToData:nil];
    }
#else
    [Permission checkContactsSettingAlert:YES permission:^(PERMISSION_STATUS statusNextProccess) {

         switch (statusNextProccess) {
             case PERMISSION_USE:
                 [self getContactsFromDevice];
                 break;
             default:
                 break;
         }
         [self tableViewApplyToData:nil];
     }];
#endif

}


/*!
 주소록 가져오기
 
 @param
 @returns
 */
#pragma mark - 주소록 가져오기
- (void)getContactsFromDevice
{
    sectionM_ABArray = [[NSMutableArray alloc] init];
    // 단말에 저장된 [주소록]을 읽어올수 있는 객체 생성
    MyAddressBook * mab = [MyAddressBook new];
    mABArray = [NSMutableArray array];
    // 단말에 저장된 [주소록]을 "이름/전화번호" 형태로 얻어오는 함수 호출
    mABArray = [mab getContactsInfo];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 회원여부 요청을 위한 데이터 만들기
            NSMutableArray *reqArr = [[NSMutableArray alloc] init];
            int iArrCnt = (int)[self->mABArray count];
            for( int i=0 ; i<iArrCnt ; i++ )
            {
                ContactsData *cd = [self->mABArray objectAtIndex:i];
                NSString *pNum = cd.searchNum;
                if( pNum != nil && [pNum length] )
                {
                    [reqArr addObject:pNum];
                }
            }
            
            
            // 연락처 정보대 대한 가입여부 전문 요청
            if( [reqArr count] && [self->memberInfoDic count] < 1 && [AppInfo userInfo].custNo.length)
            {
                NSMutableDictionary *params = [NSMutableDictionary dictionary];
                [params setObject:[AppInfo userInfo].custNo forKey:@"custNo"];
                [params setObject:reqArr forKey:@"telNoList"];
                [params setObject:self.filterType forKey:@"filterType"];
                NSLog(@"request Cnt: %lu",(unsigned long)[reqArr count]);
                
                // Ver. 3 주소록 회원여부 체크(KATPS16)
                [Request requestID:KATPS16 body:params waitUntilDone:NO showLoading:YES cancelOwn:self finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
                    
                    if(IS_SUCCESS(rsltCode))    //성공일 경우
                    {
                        NSArray *numList = [result null_objectForKey:@"telNoList"];
                        NSLog(@"response Cnt: %lu",(unsigned long)[numList count]);
                        int iArrCnt = (int)[numList count];
                        
                        if(!nilCheck(self->_filterType)) {
                            NSMutableDictionary * tempDict = [NSMutableDictionary dictionary];
                            for(int i=0; i<[numList count]; i++) {
                                [tempDict setObject:@"Y" forKey:numList[i][@"telNo"]];
                            }
                            
                            
                            int totAddCnt = (int)[self->mABArray count];
                            NSMutableArray * arrDel = [NSMutableArray array];
                            
                            for( int i=0 ; i<totAddCnt ; i++ )
                            {
                                ContactsData *cd = [self->mABArray objectAtIndex:i];
                                NSString *pNum = cd.searchNum;

                                if( pNum.length == 0 || !tempDict[pNum])
                                {
                                    [arrDel addObject:cd];
                                }
                            }
                            
                            [self->mABArray removeObjectsInArray:arrDel];
                            [self->sectionM_ABArray removeAllObjects];
                            [self reloadMBArray];
                        }
                        
                        if( iArrCnt > 0 )
                        {
                            if( self->memberInfoDic != nil )
                            {
                                [self->memberInfoDic removeAllObjects];
                                self->memberInfoDic = nil;
                            }
                            self->memberInfoDic = [[NSMutableDictionary alloc] init];
                            
                            for( int i=0 ; i<iArrCnt ; i++ )
                            {
                                NSDictionary *infoDic = [numList objectAtIndex:i];
                                
                                NSString *keyStr = [infoDic null_objectForKey:@"telNo"];
                                NSString *valueStr = [infoDic null_objectForKey:@"cid"];
                                
                                if( [keyStr length] && [valueStr length] )
                                {
                                    [self->memberInfoDic setObject:valueStr forKey:keyStr];
                                    
                                    
                                    //NSMutableDictionary *mDic = [[RegistedPersonsList sharedInstance].cidDic objectForKey:valueStr];
                                    //if( mDic == nil )
                                    //{
                                    //    NSMutableDictionary *oneDic = [[NSMutableDictionary alloc] initWithDictionary:@{@"name":@"", @"phone":[MyAddressBook phoneFormat:keyStr], @"num":keyStr, @"group":@[]}];
                                        //[[RegistedPersonsList sharedInstance].cidDic setObject:oneDic forKey:valueStr];
                                    //}
                                }
                            }
                            
                            // 회원들만의 배열 생성 (회원만 표시되는 주소록 type 추가)
                            [self makeMemberABArray];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self->contactsTableView reloadData];
                            });
                        }
                    }
                    else
                    {
                        if (!nilCheck(self->_filterType)) {
                            
                            [self->mABArray removeAllObjects];
                            [self->sectionM_ABArray removeAllObjects];
                            [self reloadMBArray];
                            
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
        //                        [BlockAlertView showBlockAlertWithTitle:@"알림" message:message dismisTitle:@"확인"];
                        });
                    }
                }];
            }
    });
    
    [self reloadMBArray];
}

- (void)processZeroMbArray
{
    [self dismissViewControllerAnimated:mDissmissAnimated completion:^(void)
     {
         if (self->ctctBlock){
             [self callbackWithSuccess:YES type:self->mContactType infoArray:[NSMutableArray array]];
         }
     }];
}

- (void)reloadMBArray
{
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    if( [mABArray count] > 0 )  //단말 [주소록]에서 전화번호가 있을 경우에
    {
        //이름별로 section을 나누기 위한 기준값 지정
        collationExtend = [[KBLocalizedIndexedCollationExtend alloc] init];
        
        for(int i = 0; i < [[collationExtend sectionTitlesExtend] count]; i++)      // section의 기준값 - ㄱ, ㄴ, ㄷ 로 나눈 후에 ㄱ에 대한 배열할당 - 2차원 배열로 할당하는 구조
        {
            NSMutableArray * array = [[NSMutableArray alloc] init];
            [dataArr addObject:array];
        }
        
        for(id object in mABArray)
        {
            //mABArray에 대해서 fullName을 기준으로 section 으로 나누고, 저장되도록 하는 함수
            //이름에 "성"을 가지고 collationExtend의 index를 찾음, 찾고 난후에 dataArr에 저장
            NSInteger index = [collationExtend sectionForObjectExtend:object collationStringSelector:@selector(fullName) collationString:((ContactsData *)object).fullName];
            
            [[dataArr objectAtIndex:index] addObject:object];
        }
        
        for(NSMutableArray *section in dataArr)
        {
            //sectionM_ABArray에 순서 없이 저장된 data에 대해서 fullName을 기준으로 정렬이 되도록 조정
            [sectionM_ABArray addObject:[collationExtend sortedArrayFromArrayExtend:section collationStringSelector:@selector(fullName)]];
        }
        
         [self tableViewApplyToData:sectionM_ABArray];
    } else {
        if (self.filterType.length > 0) {
            [self processZeroMbArray];
        }
    }
}


#pragma mark - 데이터 수신 콜백 함수 (등록친구목록 수신)
- (void)receiveFriendsInfo
{
    //그룹의 수만큼 셀 확장 정보를 "Y"로 설정해주자.
    int iGroupCnt = (int)[[RegistedPersonsList sharedInstance].groupList count];
    [friendExtendArray removeAllObjects];
    for( int i=0 ; i<iGroupCnt ; i++ )
    {
        [friendExtendArray addObject:@"Y"];
    }
    
    
    [self changeView];
    
    //통신 성공 시 탭의 selected속성을 바꿔줌.
    [self setSeletedButtonAtIndex:mICurTabIndex];
    //받은 친구 목록 데이터를 전달
    [self tableViewApplyToData:[RegistedPersonsList sharedInstance].listByGrouped];
}

//#pragma mark - 커뮤니티 탭 선택 시
//- (void)selectCommunityTab
//{
//    if( communityAllList == nil )
//    {
//        communityAllList = [[NSMutableArray alloc] init];
//        communityListByGrouped = [[NSMutableArray alloc] init];
//        communityGroupList = [[NSMutableArray alloc] initWithObjects:NAME_COMMUNITY_HEADER, nil];
//        
//        
//        NSMutableDictionary *param = [NSMutableDictionary dictionary];
//        [param setObject:[AppInfo sharedInfo].custNo forKey:@"custNo"];
//        [param setObject:[NSNumber numberWithInteger:100] forKey:@"pageSize"];  // 한 페이지의 항목 수
//        [param setObject:[NSNumber numberWithInteger:1] forKey:@"pageNo"];      // 요청 페이지 번호
//        [Request requestID:M70100 body:param waitUntilDone:YES showLoading:YES cancelOwn:self finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
//            
//            if(IS_SUCCESS(rsltCode))    //성공일 경우
//            {
//                NSArray *cmntyArr = [result null_objectForKey:@"metgBnkbkList"];
//                [self setCommunityData:cmntyArr];
//                
//                [self receiveCommunityInfo:communityAllList];
//            }
//            else    //실패일 경우
//            {
//                [BlockAlertView showBlockAlertWithTitle:@"알림" message:message dismisTitle:@"확인"];
//            }
//        }];
//    }
//    else
//    {
//        [self receiveCommunityInfo:communityAllList];
//    }
//}
//
//#pragma mark - 커뮤니티 데이터 설정
//- (void)setCommunityData:(NSArray *)cmntyArray
//{
//    if( communityAllList == nil )
//    {
//        communityAllList = [[NSMutableArray alloc] init];
//        communityListByGrouped = [[NSMutableArray alloc] init];
//        communityGroupList = [[NSMutableArray alloc] initWithObjects:NAME_COMMUNITY_HEADER, nil];
//    }
//    
//    if( cmntyArray != nil )
//    {
//        [communityAllList removeAllObjects];
//        [communityListByGrouped removeAllObjects];
//        
//        [communityAllList setArray:cmntyArray];
//        [communityListByGrouped addObject:cmntyArray];
//    }
//}

#pragma mark - 커뮤니티 탭에 대한 UI 갱신
- (void)receiveCommunityInfo:(NSArray *)listArray
{
    [self changeView];
    
    //통신 성공 시 탭의 selected속성을 바꿔줌.
    [self setSeletedButtonAtIndex:mICurTabIndex];
    //받은 친구 목록 데이터를 전달
    [self tableViewApplyToData:listArray];
}


/*!
 연락처 목록을 테이블뷰에 적용
 
 @param
 @returns   dataArr : 연락처 목록 NSArray
 */
- (void)tableViewApplyToData:(NSArray *)dataArr
{
    [contactsTableView setHidden:NO];
    
    [contactsTableView reloadData];
}


/*!
 상단 탭 버튼에 대한 Action
 
 @param     sender : 버튼
 @returns
 */
#pragma mark - 탭 버튼 Action (상단 탭버튼에 따른 이동 로직)
- (void)tabButtonAction:(id)sender
{
    //이미 선택되어있으므로 다시 실행 안함.
    if( [sender isSelected] )
        return;
    
    //버튼의 태그 ( view 타입과 같음 )
    int iTag = (int)[sender tag];
    //현재 선택된 상태를 저장
    mContactType = iTag;
    
    //버튼배열에서 해당 버튼의 인덱스
    int iBtnIndex = (int)[buttonsArray indexOfObject:sender];
    //버튼 인덱스를 저장 ( 등록친구의 경우 통신 후에 사용 )
    mICurTabIndex = iBtnIndex;
    
    //서치바 초기화
    [contactsSearchBar setText:@""];
    
    switch (iTag) {
		case TYPE_MEMBER_PHONE_CONTACTS:   //회원 주소록
		{
			[self setSeletedButtonAtIndex:iBtnIndex];
			
			[self changeView];
			
			[self setContactsDataForDevice];
		}
			break;
       case TYPE_PHONE_CONTACTS:   //폰 주소록
        {
            [self setSeletedButtonAtIndex:iBtnIndex];
            
            [self changeView];
            
            [self setContactsDataForDevice];
        }
            break;
        case TYPE_FRIEND_CONTACTS:  //등록 친구
        {
            [self receiveFriendsInfo];
        }
            break;
        case TYPE_COMMUNITY_CONTACTS:   //커뮤니티
        {
            [self receiveFriendsInfo];
//            [self selectCommunityTab];
        }
            break;
        case TYPE_INPUT_CONTACTS:   //직접 입력
        {
            [self setSeletedButtonAtIndex:iBtnIndex];
            
            [self changeView];
        }
            break;
            
        default:
            break;
    }
    
    [self.view endEditing:YES];
}

- (void)changeView
{
    if( mContactType == TYPE_INPUT_CONTACTS )
    {
        CGPoint point = contactsTableView.contentOffset;
        [contactsTableView setContentOffset:point animated:NO];
        
        
        [searchBackView setHidden:YES];
        [contactsTableView setHidden:YES];
        
        //직접입력뷰 보임
        [userInputView setHidden:NO];
		[userInputView.superview bringSubviewToFront:userInputView];
     
    }
    else
    {
//        if( [groupNameStr length] > 0 )
//        {
//            [searchBackView setHidden:YES];
//        }
//        else
//        {
            [searchBackView setHidden:NO];
//        }
        [contactsTableView setHidden:NO];
        
        //직접입력뷰 히든
        [userInputView setHidden:YES];
  
    }
}

#pragma mark - 다중 선택 확인 버튼 Action
- (IBAction)confirmButtonAction:(id)sender
{
    int iArrCnt = (int)[selectedInfoArray count];
    
    if( iArrCnt > 0 )
    {
        NSMutableArray *resultArr = [[NSMutableArray alloc] init];
        
        for( int i=0 ; i<iArrCnt ; i++ )
        {
            NSString *infoStr = [selectedInfoArray objectAtIndex:i];
            
            NSArray *infoArr = [infoStr componentsSeparatedByString:@"/"];
            
            NSMutableDictionary *infoDic = [[NSMutableDictionary alloc] init];
            [infoDic setObject:[infoArr objectAtIndex:0] forKey:KEY_NAME];
            [infoDic setObject:[infoArr objectAtIndex:1] forKey:KEY_NUM];
            
            NSArray *equalGroupArr = [EtcUtil searchWithGroupedNameArrayByData:[RegistedPersonsList sharedInstance].listByGrouped andString:[infoArr objectAtIndex:1]];
            [infoDic setObject:equalGroupArr forKey:KEY_ARR_GROUP];
            
            if( [fixedInputGroupName length] > 0 )
            {
                [infoDic setObject:fixedInputGroupName forKey:KEY_GROUP];
            }
            else
            {
                [infoDic setObject:[infoArr objectAtIndex:2] forKey:KEY_GROUP];
            }
            
            if( [infoArr count] > 3 )
            {
                [infoDic setObject:[infoArr objectAtIndex:3] forKey:KEY_CID];
            }
            
            [resultArr addObject:infoDic];
        }
        
        if (ctctBlock){
            [self callbackWithSuccess:YES type:mContactType infoArray:resultArr];
        }
    }
    else
    {
        [BlockAlertView showBlockAlertWithTitle:@"알림" message:@"선택된 항목이 없습니다." dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex){
            
        } cancelButtonTitle:nil buttonTitles:@"확인", nil];
        
        return;
    }
    
    [self dismissViewControllerAnimated:mDissmissAnimated completion:nil];
}

- (void)callbackWithSuccess:(BOOL)isSuccess type:(CONTACTS_TYPE)type infoArray:(NSMutableArray *)infoArr
{
    NSMutableArray *sendArr = [[NSMutableArray alloc] init];
    
    int iArrCnt = (int)[infoArr count];
    
    for( int i=0 ; i<iArrCnt ; i++ )
    {
        NSMutableDictionary *infoDic = [infoArr objectAtIndex:i];
        NSString *cidStr = [infoDic objectForKey:KEY_CID];
        if( [cidStr length] )
        {
            [sendArr addObject:cidStr];
        }
    }
    
    if( [sendArr count] )
    {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:sendArr forKey:@"cidList"];
        [params setObject:self.filterType forKey:@"filterType"];
        
         // Ver. 3 주소록 회원정보 조회 (Array로 관리) - KATPS13
        [Request requestID:KATPS13 body:params waitUntilDone:NO showLoading:YES cancelOwn:self finished:^(NSDictionary *result, NSString *rsltCode, NSString *message) {
                    
                    if(IS_SUCCESS(rsltCode))    //성공일 경우
                    {
                        NSMutableArray *resultArr = [[NSMutableArray alloc] initWithArray:infoArr];
                        
                        NSArray *receiveArr = [result null_objectForKey:@"mberList"];
                        int iRcvCnt = (int)[receiveArr count];
                        
                        
                        for( int i=0 ; i<iRcvCnt ; i++ )
                        {
                            NSDictionary *mberDic = [receiveArr objectAtIndex:i];
                            NSString *mberCidStr = [mberDic null_objectForKey:@"cid"];
                            NSString *mberName = [mberDic null_objectForKey:@"mberNm"];
                            
                            if( [mberCidStr length] && [mberName length] )
                            {
                                for( int j=0 ; j<iArrCnt ; j++ )
                                {
                                    NSMutableDictionary *mDic = [resultArr objectAtIndex:j];
                                    NSString *mStr = [mDic objectForKey:KEY_CID];
                                    if( [mberCidStr isEqualToString:mStr] )
                                    {
                                        [mDic setObject:mberName forKey:KEY_NAME];
                                        
                                        break;
                                    }
                                }
                            }
                        }
                        
                        self->ctctBlock(isSuccess, type, resultArr);
                    }
                    else
                    {
        //                dispatch_async(dispatch_get_main_queue(), ^{
        //                    [BlockAlertView showBlockAlertWithTitle:@"알림" message:message dismisTitle:@"확인"];
        //                });
                        
                        self->ctctBlock(isSuccess, type, infoArr);
                    }
        }];
    }
    else
    {
        ctctBlock(isSuccess, type, infoArr);
    }
}


#pragma mark - 직접입력 저장, 그룹선택하기 버튼 Action
- (IBAction)buttonAction:(id)sender
{
    int iTag = (int)[sender tag];
    
    switch (iTag) {
        case TAG_BTN_SELECT_GROUP:
        {
            //그룹선택하기 화면으로 이동
            //SelectGroupViewController *vc = [[SelectGroupViewController alloc] init];
            //[self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case TAG_BTN_CONFIRM:
        {
            EdgeTextField *nameTF = (EdgeTextField *)[userInputView viewWithTag:TAG_TF_NAME];
            EdgeTextField *numTF = (EdgeTextField *)[userInputView viewWithTag:TAG_TF_PNUM];
            
            if( [nameTF.text length] == 0 )
            {
                [BlockAlertView showBlockAlertWithTitle:@"알림" message:@"이름을 입력해주세요." dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex){
                    
                } cancelButtonTitle:nil buttonTitles:@"확인", nil];
            }
            else if( [numTF.text length] == 0 )
            {
                [BlockAlertView showBlockAlertWithTitle:@"알림" message:@"전화번호를 입력해주세요." dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex){
                    
                } cancelButtonTitle:nil buttonTitles:@"확인", nil];
            }
            else
            {
                NSMutableDictionary *infoDic = [[NSMutableDictionary alloc] init];
                
                [infoDic setObject:[nameTF text] forKey:KEY_NAME];
                [infoDic setObject:[numTF text] forKey:KEY_NUM];
                [infoDic setObject:userSelectedArr forKey:KEY_GROUP];
                
                NSArray *equalGroupArr = [EtcUtil searchWithGroupedNameArrayByData:[RegistedPersonsList sharedInstance].listByGrouped andString:[numTF text]];
                [infoDic setObject:equalGroupArr forKey:KEY_ARR_GROUP];
                
                //해당 정보를 콜백으로 넘겨줌.
                NSMutableArray *resultArr = [[NSMutableArray alloc] initWithObjects:infoDic, nil];
                [self dismissViewControllerAnimated:mDissmissAnimated completion:^(void)
                 {
                     if (self->ctctBlock){
                         self->ctctBlock(YES, self->mContactType, resultArr);
                     }
                 }];
            }
        }
            break;
        default:
            break;
    }
}

- (void)buttonTouchDown:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if( ![button isSelected] )
        [button.titleLabel setFont:[UIFont systemFontOfSize:18]];
}

#pragma mark - 버튼 취소 Action
- (void)buttonTouchCancel:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if( ![button isSelected] )
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
}

// 백버튼 액션.
- (IBAction)backButtonAction:(UIButton*)sender
{
    if (self->ctctBlock){
        [self callbackWithSuccess:NO type:self->mContactType infoArray:nil];
    }
    
    [super backButtonAction:sender];
}

#pragma mark - 버튼 검색 Action
- (IBAction)searchButtonClicked:(id)sender
{
	if ([contactsSearchBar isFirstResponder]) [contactsSearchBar resignFirstResponder];
	else [contactsSearchBar becomeFirstResponder];
}

-(IBAction)closeSearchBar:(id)sender{
    [contactsSearchBar resignFirstResponder];
   
    [contactsSearchBar setText:@""];
    [self searchBar:contactsSearchBar textDidChange:@""];
}


/*!
 상단 탭 버튼에 대한 selected 설정
 
 @param     bIndex : 버튼 Array에서 해당 index
 @returns
 */
#pragma mark - 탭 버튼 seleted 효과 설정
- (void)setSeletedButtonAtIndex:(int)bIndex
{
    int iBtnCnt = (int)[buttonsArray count];
    for( int i=0 ; i<iBtnCnt ; i++)
    {
        UIButton *btn = (UIButton *)[buttonsArray objectAtIndex:i];
        if( i == bIndex )
        {
            [btn setSelected:YES];
            [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
        }
        else
        {
            [btn setSelected:NO];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:18]];
        }
    }
}



#pragma mark - UITextField Delegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField.tag == TAG_TF_PNUM) {
        textField.text = [EtcUtil formatPhoneNumber:textField.text];
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //최대 10자까지만 허용.
    if( [string length] > 0 && [textField.text length] > 19 )
        return NO;
    
    return YES;
}



#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int iArrCnt = (int)[ARR_ALL_LIST count];
	if( (iArrCnt < 1) || ([contactsSearchBar.text length] > 0 && [searchHistoryArray count] == 0))  // 리스트가 없을 경우, 검색 리스트가 없을 경우
	{
		return tableView.frame.size.height / 2;
	}
	
	if( mContactType == TYPE_FRIEND_CONTACTS )
	{
		return HEIGHT_TVCELL_PHONE_ADDR;	//HEIGHT_TVCELL;
	}
	else if( mContactType == TYPE_COMMUNITY_CONTACTS )
	{
		return HEIGHT_TVCELL_COMMUNITY;
	}
	else if( mContactType == TYPE_PHONE_CONTACTS || mContactType == TYPE_MEMBER_PHONE_CONTACTS )
	{
		return HEIGHT_TVCELL_PHONE_ADDR;
	}
    else
    {
        return HEIGHT_TVCELL_PHONE_ADDR;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	// ????
    int iArrCnt = (int)[ARR_ALL_LIST count];
    if( iArrCnt < 1 )  // 리스트가 없을 경우
    {
        return 0;
    }
    
    if( [contactsSearchBar.text length] > 0 )
	{
        return 0;
	}
	
	// ????
    if( [groupNameStr length] > 0 )
    {
        return 0;
    }
	
	if (mContactType == TYPE_COMMUNITY_CONTACTS)
	{
		return 0;
	}
	
	if (mContactType == TYPE_PHONE_CONTACTS || mContactType == TYPE_MEMBER_PHONE_CONTACTS)
	{
		if ([ARR_SECTION_LIST count] > section && [[ARR_SECTION_LIST objectAtIndex:section] count] > 0)
			return HEIGHT_TVCELL_PHONE_ADDR_HEADER;
		else
			return 0;
	}

    if (mContactType == TYPE_FRIEND_CONTACTS)
    {
        if( section == INDEX_FIXEDGROUP_HEADER || section == INDEX_ADDGROUP_HEADER )
        {
            return HEIGHT_KINDOF_HEADER;
        }
		else
		{

			if ([ARR_SECTION_LIST count] == 0) return 0;

			// ???? 위에 있는데...
			/*
			//특정 그룹만 보여주기
			int iSection = INDEX_REAL_GROUP(section);
			if( [groupNameStr length] > 0 )
			{
				//특정 그룹이 아니면 안보여줌.
				if( ![[ARR_SECTION_HEADER objectAtIndex:iSection] isEqualToString:groupNameStr] )
				{
					return 0;
				}
			}
			*/

			//리스트가 없어도 보여준다.
			return HEIGHT_TVCELL_HEADER;
		}
    }
	
	return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if( [contactsSearchBar.text length] > 0 )
	{
        return nil;
	}
	
	if (mContactType == TYPE_COMMUNITY_CONTACTS)
	{
		return nil;
	}
	
	if (mContactType == TYPE_PHONE_CONTACTS || mContactType == TYPE_MEMBER_PHONE_CONTACTS)
	{
		if ([ARR_SECTION_LIST count] > section && [[ARR_SECTION_LIST objectAtIndex:section] count] > 0)
		{
			UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, HEIGHT_TVCELL_PHONE_ADDR_HEADER)];
			headerView.backgroundColor = [EtcUtil colorWithHexString:@"F9F9F9"];
			
			CGFloat padding = 20.0;
			UILabel *nameLB = [[UILabel alloc] initWithFrame:CGRectMake(padding, 0, headerView.frame.size.width - padding*2, headerView.frame.size.height)];
			[nameLB setBackgroundColor:[UIColor clearColor]];
			[nameLB setFont:[UIFont systemFontOfSize:14]];
			[nameLB setTextColor:[EtcUtil colorWithHexString:@"333333"]];
			[headerView addSubview:nameLB];
			
			[nameLB setText:[ARR_SECTION_HEADER objectAtIndex:section]];

			return headerView;
		}
		else return nil;
	}

	if (mContactType == TYPE_FRIEND_CONTACTS)
	{
		if (section == INDEX_FIXEDGROUP_HEADER || section == INDEX_ADDGROUP_HEADER)
		{
			CGRect tvRect = tableView.bounds;
			tvRect.size.height = HEIGHT_KINDOF_HEADER;
			
			UIView *headerView = [[UIView alloc] initWithFrame:tvRect];
			[headerView setBackgroundColor:[EtcUtil colorWithHexString:@"ACACB4"]];
			
			int iPosX = 15;
			int iWidth = tvRect.size.width - iPosX*2;
			int iHeight = 12;
			int iPosY = (tvRect.size.height - iHeight)/2;
			
			UILabel *titleLB = [[UILabel alloc] initWithFrame:CGRectMake(iPosX, iPosY, iWidth, iHeight)];
			[titleLB setBackgroundColor:[UIColor clearColor]];
			[titleLB setTextColor:[UIColor whiteColor]];
			[titleLB setFont:[UIFont systemFontOfSize:iHeight]];
			if ( section == INDEX_FIXEDGROUP_HEADER ) [titleLB setText:@"기본그룹"];
			else [titleLB setText:@"커뮤니티그룹"];
			[headerView addSubview:titleLB];
			
			return headerView;
		}
		else
		{
			CGRect tvRect = tableView.bounds;
			tvRect.size.height = HEIGHT_TVCELL_HEADER;

			UIView *headerView = headerView = [[UIView alloc] initWithFrame:tvRect];
			[headerView setBackgroundColor:[EtcUtil colorWithHexString:@"F9F9F9"]];

			int iSection = INDEX_REAL_GROUP(section);
			
			//펼치기 접기 버튼
			{
				UIButton *extendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
				[extendBtn setIsAccessibilityElement:YES];
				[extendBtn setFrame:CGRectMake(tvRect.size.width - HEIGHT_TVCELL_HEADER - 10, 0, HEIGHT_TVCELL_HEADER, HEIGHT_TVCELL_HEADER)];
				[extendBtn setBackgroundColor:[UIColor clearColor]];
				[extendBtn setTag:iSection];
				if( [[friendExtendArray objectAtIndex:iSection] isEqualToString:@"Y"] )
				{
					NSString *acsbStr = [NSString stringWithFormat:@"%@그룹 닫기", [ARR_SECTION_HEADER objectAtIndex:iSection]];
					[extendBtn setAccessibilityLabel:acsbStr];
					[extendBtn setImage:[UIImage imageNamed:@"img_arrow_u02.png"] forState:UIControlStateNormal];
				}
				else
				{
					NSString *acsbStr = [NSString stringWithFormat:@"%@그룹 펼치기", [ARR_SECTION_HEADER objectAtIndex:iSection]];
					[extendBtn setAccessibilityLabel:acsbStr];
					[extendBtn setImage:[UIImage imageNamed:@"img_arrow_d02.png"] forState:UIControlStateNormal];
				}
				int iLeftInset = (HEIGHT_TVCELL_HEADER - 11)/2;
				int iTopInset = (HEIGHT_TVCELL_HEADER - 6)/2;
				[extendBtn setImageEdgeInsets:UIEdgeInsetsMake(iTopInset, iLeftInset, HEIGHT_TVCELL_HEADER-6-iTopInset, HEIGHT_TVCELL_HEADER-11-iLeftInset)];
				[extendBtn addTarget:self action:@selector(extendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
				[headerView addSubview:extendBtn];
			}
			
			// 그룹명 (0명)
			{
				int iPosX = 16;
				UILabel *nameLB = [[UILabel alloc] initWithFrame:CGRectMake(iPosX, 0, tvRect.size.width-iPosX, tvRect.size.height)];
				[nameLB setBackgroundColor:[UIColor clearColor]];
				[nameLB setFont:[UIFont systemFontOfSize:14]];
				[nameLB setTextColor:[EtcUtil colorWithHexString:@"333333"]];
				[headerView addSubview:nameLB];
				{
					int iCnt = (int)[[ARR_SECTION_LIST objectAtIndex:iSection] count];
					NSString *strCount = [NSString stringWithFormat:@"( %d명 )", iCnt];
					NSString *strLB = [NSString stringWithFormat:@"%@ %@", [ARR_SECTION_HEADER objectAtIndex:iSection], strCount];
					NSRange subRange = [strLB rangeOfString:strCount];
					
					NSMutableAttributedString *string =
					[[NSMutableAttributedString alloc] initWithString:strLB
														   attributes:@{NSFontAttributeName:[nameLB font],
																		NSForegroundColorAttributeName:[EtcUtil colorWithHexString:@"333333"]}];
					
					if( subRange.location != NSNotFound )
					{
						NSDictionary * attriDic = @{NSFontAttributeName:[UIFont systemFontOfSize:13], NSForegroundColorAttributeName:[EtcUtil colorWithHexString:@"888888"]};
						[string setAttributes:attriDic range:subRange];
					}
					[nameLB setAttributedText:string];
				}
			}

			/*
			UIView *tline = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tvRect.size.width, 1)];
			[tline setBackgroundColor:[EtcUtil colorWithHexString:@"D2D2D2"]];
			[headerView addSubview:tline];
			*/
			
			UIView *bline = [[UIView alloc] initWithFrame:CGRectMake(0, tvRect.size.height-1, tvRect.size.width, 1)];
			[bline setBackgroundColor:[EtcUtil colorWithHexString:@"D2D2D2"]];
			[headerView addSubview:bline];
			
			return headerView;
		}
	}
	
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int iArrCnt = (int)[ARR_ALL_LIST count];
    if( (iArrCnt < 1) || ([contactsSearchBar.text length] > 0 && [searchHistoryArray count] == 0))  // 리스트가 없을 경우
    {
        return;
    }
    
    int iSection = (int)[indexPath section];
    if( mContactType == TYPE_FRIEND_CONTACTS )
    {
        iSection = INDEX_REAL_GROUP(iSection);
        
        if(iSection < 0) // 주소록에서 동일인이 여러개로 검색시, 체크박스 누르면 앱 크래시.
            iSection = 0;
    }
    
    int iRow = (int)[indexPath row];
    
    if( mLimitType == TYPE_ONE_LIMITED )
    {
        if( mContactType == TYPE_COMMUNITY_CONTACTS )   // 커뮤니티 탭일 경우 해당 dictionary를 그대로 넘김
        {
            NSArray *SecArr = [ARR_SECTION_LIST objectAtIndex:iSection];
            NSDictionary *data = [SecArr objectAtIndex:iRow];
            NSMutableArray *resultArr = [[NSMutableArray alloc] initWithObjects:data, nil];
            
            [self dismissViewControllerAnimated:mDissmissAnimated completion:^(void)
             {
                 if (self->ctctBlock){
                     self->ctctBlock(YES, self->mContactType, resultArr);
                 }
             }];
        }
        else
        {
            ContactsData *data = nil;
            if( [contactsSearchBar.text length] > 0 )
            {
                data = [searchHistoryArray objectAtIndex:iRow];
            }
            else
            {
                NSArray *SecArr = [ARR_SECTION_LIST objectAtIndex:iSection];
                data = [SecArr objectAtIndex:iRow];
            }
			
			if(_inviteMode && data.cId.length)
			{
				[BlockAlertView showBlockAlertWithTitle:@"알림" message:INVITE_ALERT_MESSAGE dismisTitle:AlertConfirm];
				return;
			}
            
            NSMutableDictionary *infoDic = [[NSMutableDictionary alloc] init];
            
            [infoDic setObject:data.fullName forKey:KEY_NAME];
            [infoDic setObject:data.CTNumber forKey:KEY_NUM];
            [infoDic setObject:[ARR_SECTION_HEADER objectAtIndex:iSection] forKey:KEY_GROUP];
            
            NSString *tailCid = data.cId;
            if( ![tailCid length] )
                tailCid = @"";
            [infoDic setObject:tailCid forKey:KEY_CID];
            
            NSArray *equalGroupArr = [EtcUtil searchWithGroupedNameArrayByData:[RegistedPersonsList sharedInstance].listByGrouped andString:data.CTNumber];
            [infoDic setObject:equalGroupArr forKey:KEY_ARR_GROUP];
            
            NSMutableArray *resultArr = [[NSMutableArray alloc] initWithObjects:infoDic, nil];
            
            [self dismissViewControllerAnimated:mDissmissAnimated completion:^(void)
             {
                 if (self->ctctBlock){
                     [self callbackWithSuccess:YES type:self->mContactType infoArray:resultArr];
                 }
             }];
        }
    }
	else
	{
		if (mContactType == TYPE_PHONE_CONTACTS || mContactType == TYPE_MEMBER_PHONE_CONTACTS || mContactType == TYPE_FRIEND_CONTACTS)
		{
			KBAddressViewPhoneAddressCell *cell = [tableView cellForRowAtIndexPath:indexPath];
			[self checkButtonAction:cell.checkButton];
		}
	}
}

// 주소록에 인덱스 리스트 표시 여부 설정
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if(((int)mContactType != TYPE_PHONE_CONTACTS && (int)mContactType != TYPE_MEMBER_PHONE_CONTACTS) )
        return nil;
        
    return ARR_SECTION_HEADER;
}

// 주소록 인덱스 리스트 클릭시, 해당 인덱스 이동
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
//    [contactsSearchBar setText:title];
//    [self searchBar:contactsSearchBar textDidChange:title];
    
    return index;
}


#pragma mark - 펼치기 / 접기 버튼 Action
- (void)extendButtonAction:(id)sender
{
    int iTag = (int)[sender tag];
    
    int iArrCnt = (int)[friendExtendArray count];
    
    if( iTag < 0 || iTag >= iArrCnt )
        return;
    
    NSString *extendStr = [friendExtendArray objectAtIndex:iTag];
    if( [extendStr isEqualToString:@"Y"] )
    {
        [friendExtendArray replaceObjectAtIndex:iTag withObject:@"N"];
    }
    else
    {
        [friendExtendArray replaceObjectAtIndex:iTag withObject:@"Y"];
    }
    
    int iSectionIndex = INDEX_REAL_SECTION(iTag);
    [contactsTableView reloadSections:[NSIndexSet indexSetWithIndex:iSectionIndex] withRowAnimation:UITableViewRowAnimationFade];
    
    
    int iSecCnt = (int)[[[RegistedPersonsList sharedInstance].listByGrouped objectAtIndex:iTag] count];
    if( [extendStr isEqualToString:@"N"] && iSecCnt > 0 )
    {
        [contactsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:iSectionIndex] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}


#pragma mark - 체크박스 버튼 Action
- (UITableViewCell *)tableViewCell:(UIView *)view
{
    UIResponder *responder = view;
    while (![responder isKindOfClass:[UITableViewCell class]]) {
        responder = [responder nextResponder];
        if (nil == responder) {
            break;
        }
    }
    return (UITableViewCell *)responder;
}

- (IBAction)checkButtonAction:(id)sender
{
    UITableViewCell *cell = [self tableViewCell:sender];
    NSIndexPath *indexPath = [cell indexPath];
    
    int iSection = (int)[indexPath section];
    if( mContactType == TYPE_FRIEND_CONTACTS )
    {
        iSection = INDEX_REAL_GROUP(iSection);
        
        if(iSection < 0) // 주소록에서 동일인이 여러개로 검색시, 체크박스 누르면 앱 크래시.
            iSection = 0;
    }
    int iRow = (int)[indexPath row];
    
    ContactsData *data = nil;
    if( [contactsSearchBar.text length] > 0 )
    {
        data = [searchHistoryArray objectAtIndex:iRow];
    }
    else
    {
        data = [[ARR_SECTION_LIST objectAtIndex:iSection] objectAtIndex:iRow];
    }
	
	if(_inviteMode && data.cId.length)
	{
		[BlockAlertView showBlockAlertWithTitle:@"알림" message:INVITE_ALERT_MESSAGE dismisTitle:AlertConfirm];
		return;
	}
	
    NSString *tailCid = data.cId;
    if( ![tailCid length] )
        tailCid = @"";
    NSString *infoStr = [[NSString alloc] initWithFormat:@"%@/%@/%@/%@", data.fullName, data.CTNumber, [ARR_SECTION_HEADER objectAtIndex:iSection], tailCid];
    
    if( [selectedInfoArray containsObject:infoStr] )
    {
        [selectedInfoArray removeObject:infoStr];
    }
    else
    {
        for( int i=0 ; i<[selectedInfoArray count] ; i++ )
        {
            NSArray *aArr = [(NSString *)[selectedInfoArray objectAtIndex:i] componentsSeparatedByString:@"/"];
            if( [aArr count] > 1 )
            {
                if( [[[aArr objectAtIndex:1] getDecimalString] isEqualToString:data.searchNum] )
                {
                    NSString *strMessage = @"같은 전화번호의 친구가 이미 포함되어있습니다.";
                    [BlockAlertView showBlockAlertWithTitle:@"알림" message:strMessage dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex){
                        
                    } cancelButtonTitle:nil buttonTitles:@"확인", nil];
                    
                    return;
                }
            }
        }
        
        if( [selectedInfoArray count] > ((int)mLimitType -1) )
        {
            NSString *strMessage = [NSString stringWithFormat:@"최대 %d명까지 선택 가능합니다.", (int)mLimitType];
            [BlockAlertView showBlockAlertWithTitle:@"알림" message:strMessage dismissedCallback:^(BlockAlertView *alertView, NSInteger buttonIndex){
                
            } cancelButtonTitle:nil buttonTitles:@"확인", nil];
            
            return;
        }
        [selectedInfoArray addObject:infoStr];
    }
    
    [self updateSelectedContactView:selectedInfoArray];
    [contactsTableView reloadData];
    
    [self changeMultiSelectLayout];
    
}

- (void)changeMultiSelectLayout
{
    int iInfoArrCnt = (int)[selectedInfoArray count];
    NSString *strTitle = [NSString stringWithFormat:@"최대 %d명까지 선택 가능합니다.", (int)mLimitType - iInfoArrCnt];
    [notiLB setText:strTitle];
    
    //
    //다중선택 시에는 하단 확인버튼이 있다.
    if( mLimitType > TYPE_ONE_LIMITED )
    {
        [confirmBtn setBackgroundImage:[[confirmBtn backgroundImageForState:UIControlStateNormal] stretchableImageWithCapWidthRatio:0.5 capHeightRatio:0.5] forState:UIControlStateNormal];

        [confirmBtn setIsAccessibilityElement:NO];
        
        BOOL isEvent = self.filterType.length > 0;
        NSString * btnTitle = isEvent ? @"선택 완료" : @"인원 추가";
        
        [confirmBtn setAccessibilityLabel:btnTitle];
        [[confirmBtn titleLabel] setText:btnTitle];
        if(selectedInfoArray.count > 0){
            [confirmBtn setTitle:[NSString stringWithFormat:@"%@(%lu)", btnTitle,(unsigned long)selectedInfoArray.count] forState:UIControlStateNormal];
            [confirmBtn setEnabled:YES];
        } else {
            btnTitle = isEvent ? @"선택 완료(0)" : @"인원 추가";
            [confirmBtn setTitle:btnTitle forState:UIControlStateDisabled];
            [confirmBtn setEnabled:NO];
        }
    }
}

-(void)updateSelectedContactView:(NSMutableArray*)selectedContact{
    
    int nViewWidth = 100;
    int nViewHeight = 100;
    
    for(UIView *view in contactSelectedContentStackView.subviews){
        [view removeFromSuperview];
    }
    
    for( int i=0 ; i<[selectedInfoArray count] ; i++ )
    {
        NSArray *aArr = [(NSString *)[selectedInfoArray objectAtIndex:i] componentsSeparatedByString:@"/"];
        if( [aArr count] > 1 )
        {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"Component" owner:nil options:nil];
            ContactSelectedView *contactSelectedView;
            for (id obj in objects)
            {
                if ([obj isKindOfClass:[ContactSelectedView class]])
                {
                    contactSelectedView = obj;
                    break;
                }
            }
            
            contactSelectedView.frame = CGRectMake(nViewWidth*i, 0, nViewWidth, nViewHeight);
            contactSelectedView.selectedInfoString = [[NSString alloc] initWithString:[selectedInfoArray objectAtIndex:i]];
            contactSelectedView.nameLabel.text = [aArr objectAtIndex:0]; //이름
//            contactSelectedView.phoneLabel.text = [aArr objectAtIndex:1]; //전화번호
            contactSelectedView.contactId = [[NSString alloc] initWithString:[aArr objectAtIndex:3]];
//            contactSelectedView.nSelectedIndexPathRow = (NSInteger)[aArr objectAtIndex:4];
            contactSelectedView.tag = i;
            contactSelectedView.closeButton.tag = i;
            [contactSelectedView.closeButton addTarget:self action:@selector(didTouchSelectedContactClose:) forControlEvents:UIControlEventTouchUpInside];
            
//            contactSelectedView.viewCloseButton.tag = i;
//            [contactSelectedView.viewCloseButton addTarget:self action:@selector(didTouchSelectedContactClose:) forControlEvents:UIControlEventTouchUpInside];
            
            [contactSelectedContentStackView addSubview:contactSelectedView];
        }
    }
    contactSelectedScrollView.contentSize = CGSizeMake(selectedInfoArray.count*nViewWidth, nViewHeight);
//    contactSelectedScrollView.contentSize = CGSizeMake(1400, nViewHeight);
    
}

-(void)didTouchSelectedContactClose:(UIButton*)sender{

    NSString *infoStr = [selectedInfoArray objectAtIndex:sender.tag];
    
    if( [selectedInfoArray containsObject:infoStr]){
        [selectedInfoArray removeObject:infoStr];
    }

    [self updateSelectedContactView:selectedInfoArray];
    [contactsTableView reloadData];
    
    [self changeMultiSelectLayout];
}


#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if( [contactsSearchBar.text length] > 0 )
        return 1;
    
    if([ARR_ALL_LIST count] == 0 )
        return 1;
    
    if( mContactType == TYPE_FRIEND_CONTACTS )
    {
        return [ARR_SECTION_HEADER count] + 2;
    }
    
    return [ARR_SECTION_HEADER count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int iArrCnt = (int)[ARR_ALL_LIST count];
    if( (iArrCnt < 1) || ([contactsSearchBar.text length] > 0 && [searchHistoryArray count] == 0))  // 리스트가 없을 경우, 검색 리스트가 없을 경우
    {
        if( section == 0 )
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }
    
    
    if( [contactsSearchBar.text length] > 0 )
    {
		NSUInteger count = [searchHistoryArray count];
		return count > 0 ? count : 1;
    }
    
    
    int iSection = (int)section;
    if( mContactType == TYPE_FRIEND_CONTACTS )
    {
        if( section == INDEX_FIXEDGROUP_HEADER || section == INDEX_ADDGROUP_HEADER )
        {
            return 0;
        }
        
        iSection = INDEX_REAL_GROUP(iSection);
    }
    
    
    if( mContactType == TYPE_FRIEND_CONTACTS )
    {
        if( [[friendExtendArray objectAtIndex:iSection] isEqualToString:@"N"] )
        {
            return 0;
        }
    }
    
    //특정 그룹만 보여주기
    if( [groupNameStr length] > 0 )
    {
        if( ![[ARR_SECTION_HEADER objectAtIndex:iSection] isEqualToString:groupNameStr] )
        {
            return 0;
        }
    }
    
    return [[ARR_SECTION_LIST objectAtIndex:iSection] count];
}


#define TAG_MEMBER_IMGV     9111

#define TAG_CELL_CHECK      1043
#define WIDTH_CELL_CHECK    24

//#define TAG_CELL_IMG        2348
//#define WIDTH_CELL_IMG      40

#define TAG_CELL_LB_NAME    2394
#define TAG_CELL_LB_NUM     9123

#define TAG_UNDERLINE       9234
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int iArrCnt = (int)[ARR_ALL_LIST count];
    if( (iArrCnt < 1) || ([contactsSearchBar.text length] > 0 && [searchHistoryArray count] == 0))  // 리스트가 없을 경우, 검색 리스트가 없을 경우
    {
        // 리스트 없음 안내 화면을 테이블뷰 크기만큼 그림.
        
        if (iArrCnt < 1){
            KBAccessbilityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NO_ACCESSIBILITY_CELL"];
            return cell;
        }
        else{
            KBAddressViewNoListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NO_ADDRESS_LIST"];
            return cell;
        }
        
        
    }
	
	
    int iSection = (int)[indexPath section];
	int iRow = (int)[indexPath row];
    if( [contactsSearchBar.text length] > 0 )
    {
        iSection = 0;
    }
    else if( mContactType == TYPE_FRIEND_CONTACTS )
    {
        iSection = INDEX_REAL_GROUP(iSection);
    }
	
	ContactsData *data = nil;
	if( [contactsSearchBar.text length] > 0 )
	{
		data = [searchHistoryArray objectAtIndex:iRow];
	}
	else
	{
		data = [[ARR_SECTION_LIST objectAtIndex:iSection] objectAtIndex:iRow];
	}

	
	if (mContactType == TYPE_COMMUNITY_CONTACTS)
	{
		NSString *ideneifier = @"COMMUNITY_CELL";
		KBAddressViewCommunityCell *cell = [tableView dequeueReusableCellWithIdentifier:ideneifier];
		cell.nameLabel.text = [(NSDictionary *)data null_objectForKey:@"metgBnkbkNm"];
		return cell;
	}

	if (mContactType == TYPE_PHONE_CONTACTS || mContactType == TYPE_MEMBER_PHONE_CONTACTS || mContactType == TYPE_FRIEND_CONTACTS)
	{
		NSString *ideneifier = @"PHONE_ADDRESS_CELL";
		KBAddressViewPhoneAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:ideneifier];
		cell.nameLabel.text = data.fullName;
		cell.nameLabel.accessibilityLabel = cell.nameLabel.text;
		
		cell.phoneLabel.text = data.CTNumber;
		cell.phoneLabel.accessibilityLabel = cell.phoneLabel.text;
        
        // 이벤트 타입이면(필터타입이 있으면) 프로필 이미지 안보이도록 처리
        if (self.filterType.length > 0) {
            cell.profileImgWidth.constant = 0.f;
        }

		cell.checkButton.hidden = !( mLimitType > TYPE_ONE_LIMITED );
		if (!cell.checkButton.hidden)
		{
			NSString *tailCid = data.cId;
			if (![tailCid length]) tailCid = @"";
			NSString *infoStr = [[NSString alloc] initWithFormat:@"%@/%@/%@/%@", data.fullName, data.CTNumber, [ARR_SECTION_HEADER objectAtIndex:iSection], tailCid];
			
			[cell.checkButton setSelected:[selectedInfoArray containsObject:infoStr]];
			[cell.checkButton setAccessibilityLabel:[NSString stringWithFormat:@"%@, 체크박스, %@", data.fullName, (cell.checkButton.selected ? @"선택됨" : @"선택안됨")]];
		}

		{
			NSString *cidStr = [memberInfoDic objectForKey:data.searchNum];
			if ([cidStr length] < 1)
			{
				cidStr = data.cId;
			}
			else
			{
				if (![data.cId length])
				{
					data.cId = cidStr;
				}
			}

			cell.typeImageView.highlighted = ([cidStr length] > 0);
			cell.typeImageView.accessibilityLabel = cell.typeImageView.highlighted ? @"리브메이트, 회원" : @"리브메이트, 비회원";
		}
		
		cell.accessibilityLabel = [NSString stringWithFormat:@"%@, %@, %@, %@",
								   cell.typeImageView.accessibilityLabel,
								   cell.nameLabel.text,
								   cell.phoneLabel.text,
								   (cell.checkButton.hidden ? @"" : (cell.checkButton.selected ? @"선택됨" : @"선택안됨"))];
		cell.accessibilityHint = [NSString stringWithFormat:@"%@을 선택합니다.", cell.nameLabel.text];
		if (!cell.checkButton.hidden && cell.checkButton.selected) cell.accessibilityHint = [NSString stringWithFormat:@"%@을 선택해제 합니다.", cell.nameLabel.text];

		return cell;
	}
	
    return nil;
}


#pragma mark - UISearchBar Delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if([searchBar.text length])
    {
        //searchBar.showsCancelButton = NO;
        [deleteBtn setHidden:NO];
    }
    else
    {
        //searchBar.showsCancelButton = YES;
        [deleteBtn setHidden:YES];
    }
    
    return YES;
}


- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    //searchBar.showsCancelButton = NO;
    
    return YES;
}

/*
 *  UISearch 동작중에 "취소" 버튼 Action이 발생을 했을때 실행되는 UISearchBar의 delegate 함수
 */
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if([ARR_ALL_LIST count] == 0)
        return;
    
    //searchBar.showsCancelButton = NO;
    [searchBar setText:@""];
    [searchHistoryArray removeAllObjects];
    
    [contactsTableView reloadData];
    
    [self.view endEditing:YES];
}

/*
 *  검색 모드에서 글자 입력할때마다 [주소록]을 검색하는 메소드 */
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if([searchBar.text length])
    {
        //searchBar.showsCancelButton = NO;
        [deleteBtn setHidden:NO];
    }
    else
    {
        //searchBar.showsCancelButton = YES;
        [deleteBtn setHidden:YES];
    }
    
    [searchHistoryArray removeAllObjects];      /* 글자 입력할때마다 검색되어졌던 값 초기화 */
    
    if( mContactType == TYPE_COMMUNITY_CONTACTS )
    {
        [searchHistoryArray addObjectsFromArray:[EtcUtil searchWithCommunityArrayData:ARR_ALL_LIST andString:searchText]];
    }
    else
    {
        /* 글자 패턴으로 [주소록] fullName을 검색하는 메소드 호촐 */
        /* 글자 패턴으로 myABArray 검색을 해서 검색된 내용을 searchHistoryArray에 저장 */
        [searchHistoryArray addObjectsFromArray:[EtcUtil searchWithArrayData:ARR_ALL_LIST andString:searchText]];
    }
    
    [contactsTableView reloadData];
    //[self sectionIndexTitlesForTableView:contactsTableView];
   
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
}

#pragma mark - 접근권한설정
- (IBAction)btnSetContactsDataForDevice:(id)sender {
    [self setContactsDataForDevice];
}
@end
