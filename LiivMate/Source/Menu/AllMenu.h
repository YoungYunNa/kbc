//
//  AllMenu.h
//  LiivMate
//
//  Created by KB_CARD_MINI_2 on 2016. 8. 8..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"

#ifndef WIDEGET

#define K_VIEWID								@"screnId"
#define K_LOGIN									@"lginMandanYn"
#define K_ICON_PATH								@"menuIconPath"
#define K_MENU_NAME								@"menuName"
#define K_URL_ADDR								@"urlAddr"
#define K_SCREN_DSTCD							@"screnDstcd" //1 - 네이티브, 2 - 하이브리드, 4 - 제휴및 외부웹사이트

//메뉴에 행당옵선을 지정하면 항상 해당네비게이션으로 동작한다.
#define K_NaviOption							@"naviOption"
#define K_IMAGE_NAME							@"imageName"
#define K_ClassName								@"class"

#define K_MenuEnabled							@"menuEnabled"
#define K_MenuHidden							@"menuHidden"

//하단 앱바 숨겨야 하는 메뉴
#define BottomHiddenMenu   @[MenuID_MateJoin, MenuID_ShopJoinInfo, MenuID_V3_MateJoin] // Ver. 3 회원가입 추가 (MenuID_V3_MateJoin)


typedef NS_ENUM(NSInteger, NavigationOption) {
	NavigationOptionNone = 0,
    NavigationOptionSetRoot,
	NavigationOptionPopRoot,
	NavigationOptionPopView,
	NavigationOptionPopWithViwID,		// 해당 화면이 네비게이션 스텍에 있으면 화면을 보여주고 없으면 메인화면으로.
	NavigationOptionPopRootAndPush,
	NavigationOptionPush,
	NavigationOptionNoneHistoryPush,	// 보내는 화면을 히스토리에 남기지 않는다.
	NavigationOptionNavigationModal,
	NavigationOptionModalPush,
	NavigationOptionModal
};

typedef NS_ENUM(NSInteger, GNBType) {
	GNBType_Normal = 0,
	GNBType_Shop,
    GNBType_Dev,
};

typedef void (^NavigationCallback)(ViewController *vc);
typedef void (^NavigationMoveSuccessCallback)(id mobileWeb, NSString * page);
typedef void (^NavigationMoveFailCallback)(void);


@protocol MenuNavigationDelegate <NSObject>
-(void)navigationWithMenuID:(NSString*)viewID option:(NavigationOption)option callBack:(NavigationCallback)callBack;
-(void)navigationWithMenuID:(NSString*)viewID animated:(BOOL)animated option:(NavigationOption)option callBack:(NavigationCallback)callBack;
-(void)sendBirdDetailPage:(NSString*)page callBack:(NavigationCallback)callBack;
-(void)existPage:(NSString *)page  parent:(id)mobileWeb successCb:(NavigationMoveSuccessCallback)succenssCb failCb:(NavigationMoveFailCallback)failCb;
-(NSString*)getMenuIDForString:(NSString*)pageString;
-(void)goMainViewControllerAnimated:(BOOL)animated;
-(void)openMenu;
-(void)closeMenu;
-(void)setMenuOpen:(BOOL)menuOpen animated:(BOOL)animated;
-(void)checkLoginBlock:(void (^)(void))block;//로그인이 되어있거나 로그인이후 블럭이 호출된다.
@end


@interface AllMenu : NSObject
@property (nonatomic, assign) GNBType gnbType;
@property (nonatomic, strong) NSDictionary *appMenu; // 서버에서 기동시 내려받은 메뉴
@property (nonatomic, readonly) NSArray *appMenuList; // appMenu 의 모든메뉴 를 array에 포함시킨것
@property (nonatomic, readonly) NSDictionary *trgEvtMenu;
@property (nonatomic, strong) NSDictionary *appMenuSearchKeyword; // 서버에서 기동시 내려받은 메뉴검색 키워드
@property (nonatomic, unsafe_unretained) id<MenuNavigationDelegate> delegate;
+(AllMenu*)menu;
+(id<MenuNavigationDelegate>)delegate;
+(NSString*)menuIdForUrl:(NSString*)urlStr;
+(NSDictionary*)menuForID:(NSString*)viewID;
+(NSDictionary*)menuForClass:(NSString*)classStr;
+(NSInteger)groupIndex:(NSString*)viewID;
+(ViewController*)controllerForMenu:(NSDictionary*)menu;
+(NSString*)trgPageIdforViewId:(NSString*)viewID;
+(BOOL)isMenuEnabled:(id)menuItem;
+(BOOL)isMenuHidden:(id)menuItem;

+(NSMutableDictionary*)getGa360DefaultDictionary;

+(void)setStatusBarStyle:(BOOL)enableMainColor viewController:(UIViewController*)vc;
+(NSDictionary*)getEtcMenuDictionary:(NSString*)menuID;
+(void)checkLoginBlock:(void (^)(void))block;//로그인이 되어있거나 로그인이후 블럭이 호출된다.
    
@end
#endif//WIDEGET

/**
 @brief 화면ID : 2차에 서비스하지 않는 화면
 */
static NSString *const MenuID_DEPRECATED					=	@"DEPRECATED";

/**
 @brief 화면ID : 로그인만을 위한 화면이동.
 */
static NSString *const MenuID_Login							=	@"login";

/**
 @brief 화면ID : 메인화면 MYPage
 */
static NSString *const MenuID_MainPage						=	@"KAT_FTMA_001";

/**
 @brief 화면ID : 금융상품. // 사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_FinancialProduct				=	@"KAT_FIPR_001";

/**
 @brief 화면ID : 소비매니저
 */
static NSString *const MenuID_PayMngCnsmRpt					=	@"KAT_CNMN_001";

/**
 @brief 화면ID : 마이페이지
 */
static NSString *const MenuID_Mypage						=	@"KAT_MYPG_001";

/**
 @brief 화면ID : 쿠폰함
 */
static NSString *const MenuID_CouponStorage					=	@"KAT_MYPG_006";

/**
 @brief 화면ID : 간편결제
 */
static NSString *const MenuID_SimplePayment					=	@"KAT_PABA_001";
static NSString *const MenuID_SimplePaymentQR				=	@"KAT_PAQR_001";

/**
 @brief 화면ID : 간편결제-바코드결제 사용가능 가맹점
 */
static NSString *const MenuID_PaymentShopList				=	@"KAT_PABA_002";

/**
 @brief 화면ID : 간편결제-바코드결제 바코드 확대
 */
static NSString *const MenuID_PaymentBarcodeZoom			=	@"KAT_PABA_003";

/**
 @brief 화면ID : QR코드 스캐너 //  사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_ScannerSend					=	@"KAT_PONT_006"; // 보내기 QR스캐너
static NSString *const MenuID_ScannerCancel					=	@"KAT_SHOP_080"; // 결제취소 QR스캐너

/**
 @brief 화면ID : 마이페이지-LiivMate카드설정
 */
static NSString *const MenuID_CardSetting					=	@"KAT_MYPG_024";

/**
 @brief 화면ID : 설정-간편결제 알림바 설정 안내 // 사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_WidgetSetting					=	@"KAT_CUSA_006";

/**
 @brief 화면ID : 포인트리-거래내역조회
 */
static NSString *const MenuID_PointreeHistory				=	@"KAT_PONT_001";

/**
 @brief 화면ID : 포인트리-충전하기
 */
static NSString *const MenuID_PointreeCharge				=	@"KAT_PONT_011";

/**
 @brief 화면ID : 간편결제완료
 */
static NSString *const MenuID_SimplePaymentComplete			=	@"KAT_PAQR_002";

/**
 @brief 화면ID : 간편결제내역조회
 */
static NSString *const MenuID_PaymentHistory				=	@"KAT_PARE_001";

/**
 @brief 화면ID : 할부거래계약서조회
 */
static NSString *const MenuID_InstTransactionContract		=	@"KAT_PARE_004";

/**
 @brief 화면ID : 튜토리얼(하이브리드)  // 사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_Tutorial						=	@"KAT_OPTU_002"; // 전체

/**
 @brief 화면ID : 내가게위치등록을 위한 리스트 // 사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_AffiliateLocRegister			=	@"KAT_SHOP_022";

/**
 @brief 화면ID : 내가게위치등록 // 사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_AffiliateLocRegisterSingle	=	@"KAT_SHOP_023";

/**
 @brief 화면ID : 이용가능가게
 */
static NSString *const MenuID_AffiliateStoreList			=	@"KAT_MYPG_023";

/**
 @brief 화면ID : 스탬프 사용/적립 QR  // 사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_AffiliateStampQR				=	@"KAT_SHOP_061";

/**
 @brief 화면ID : 내 QR 코드 // 사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_MyQR							=	@"KAT_MYPG_005";

/**
 @brief 화면ID : Splash (인트로)  // 사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_Splash						=	@"KAT_OPTU_001";

/**
 @brief 화면ID : 주소록 // 사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_AddressBook					=	@"KAT_PONT_004";

/**
 @brief 화면ID : Pin번호 입력 (Penta) // 사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_SecureKeypad					=	@"KAT_COMM_002";

/**
 @brief 화면ID : 라이프샵
 */
static NSString *const MenuID_MateLifeShop					=	@"KAT_LIBE_060";

/**
 @brief 화면ID : 설정화면
 */
static NSString *const MenuID_SettingHome					=	@"KAT_SETT_001";

/**
 @brief 화면ID : 고객센터홈 > 광고수신동의
 */
static NSString *const MenuID_CSCenterHomeAd				=	@"KAT_CUSA_018";

/**
 @brief 화면ID : 고객센터홈  // 사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_CSCenterHome					=	@"KAT_CUSA_001";

/**
 @brief 화면ID : 고객센터 - Tip
 */
static NSString *const MenuID_CSCenterTip					=	@"KAT_CUSA_004";

/**
 @brief 화면ID : 회원가입/본인인증(하이브리드)
 */
static NSString *const MenuID_MateJoin						=	@"KAT_JOIN_001";

/**
 @brief 화면ID : 비밀번호 찾기(하이브리드)
 */
static NSString *const MenuID_PwdReset						=	@"KAT_JOIN_006";


//////////////////가맹점////////////////////////////
/**
 @brief 화면ID : 가맹점 회원가입 안내페이지
 */
static NSString *const MenuID_ShopJoinInfo					=	@"KAT_MYST_001";

/**
 @brief 화면ID : 가맹점 내가게-내가게서비스-메인
 */
static NSString *const MenuID_ShopHome						=	@"KAT_MYST_006"; // 관리자

/**
 @brief 화면ID : 가맹점 내가게-내가게서비스-QR결제
 */
static NSString *const MenuID_ShopPayment					=	@"KAT_MYST_051";

/**
 @brief 화면ID : 가맹점 내가게-내가게서비스-QR결제취소
 */
static NSString *const MenuID_ShopCancelPayment				=	@"KAT_MYST_054";

/**
 @brief 화면ID : 가맹점 내가게-내가게서비스-탈퇴
 */
static NSString *const MenuID_ShopDraw						=	@"KAT_MYST_007";

/**
 @brief 화면ID : 가맹점 내가게-내가게서비스-고객스탬프
 */
static NSString *const MenuID_ShopStemp						=	@"KAT_SHOP_060";

/**
 @brief 화면ID : 웹뷰 컨트롤러  // 사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_WebViewVC						=	@"MenuID_WebViewVC";

/**
 @brief 화면ID : 제휴및 외부 홈페이지, cID를 넘겨주는 웹뷰 // 사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_AlianceWeb					=	@"MenuID_AlianceWeb";

/**
 @brief 화면ID : 로그인 웹뷰 컨트롤러 // 사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_LoginWebViewVC				=	@"MenuID_LoginWebViewVC";

/**
 @brief 화면ID : Cat Crush 앱에서 로그인 인증 요청시  // 사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_V1_CatCrushLogIn				=	@"LiivmateAuth";

/**
 @brief 화면ID : Cat Crush 앱에서 로그인 인증 요청시 약관동의 // 사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_V1_CatCrushTermAgree			=	@"LiivmateLogin";

/**
 @brief 화면ID : QR코드 결제 detail okpos webview(테이블결제) // 사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_V1_QRCodePaymentDetail		=	@"QRCodePaymentDetail";

/**
 @brief 화면ID : QR코드 결제 detail okpos webview(테이블결제) // 사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_V1_QRCodePaymentMixDetail		=	@"QRCodePaymentMixDetail";

/**
 @brief 화면ID : 콘텐츠 - LTE비디오 포털
 */
static NSString *const MenuID_V1_LGVOD						=	@"KAT_LIBE_059";

//-------------------------------------------------------------------------
// 2020.04.13 V3 화면ID : 화면아이디 매칭여부 결정
//-------------------------------------------------------------------------
/**
 @brief 화면ID_V3 : V3 메인화면 MYPage
 */
static NSString *const MenuID_V3_MainPage                   =    @"MYD4_MA0100"; // 확인 필요 (투데이와 메인이 같은지) @"MYD4_MA0100" <- 변경예정

/**
 @brief 화면ID_V3 : 2차에 서비스하지 않는 화면
 */
static NSString *const MenuID_V3_DEPRECATED                 =    @"DEPRECATED";

/**
 @brief 화면ID_V3 : 로그인만을 위한 화면이동.
 */
static NSString *const MenuID_V3_Login                      =    @"login";

//-----------------------------------------------------------------------------//
// 메인 4개 탭 화면 ID - 삭제 예정
//-----------------------------------------------------------------------------//
/**
 @brief 화면ID_V3 : 메인탭 메뉴 - 금융
 */
static NSString *const MenuID_V3_TabMenu_Finance            =    @"MYD4_FI0100"; // 전체메뉴 URL2 <통합조회> -> 계좌조회(/uaasv3/FIN0011.do)

//-----------------------------------------------------------------------------//
// 기타 화면 ID
//-----------------------------------------------------------------------------//
/**
 @brief 화면ID_V3 : 쿠폰함
 */
static NSString *const MenuID_V3_CouponStorage              =    @"MYD4_MW0500";  // uaasv3/KATB500.do

/**
 @brief 화면ID_V3 : 알림함
 */
static NSString *const MenuID_V3_Notification               =    @"MYD4_MY0200";

/**
 @brief 화면ID_V3 : 앱설정
 */
static NSString *const MenuID_V3_AppConfiguration           =    @"MYD4_AM0500";

/**
 @brief 화면ID_V3 : 간편결제
 */
static NSString *const MenuID_V3_SimplePayment              =    @"MYD4_MW0100"; // Native 화면 확인 필요

/**
 @brief 화면ID_V3 : 간편결제-바코드결제 사용가능 가맹점
 */
static NSString *const MenuID_V3_PaymentShopList            =    @"MYD4_MW0112";  // MIG 미정의

/**
 @brief 화면ID_V3 : 간편결제-바코드결제 바코드 확대
 */
static NSString *const MenuID_V3_PaymentBarcodeZoom         =    @"KAT_PABA_003";  // Native 화면 확인 필요

/**
 @brief 화면ID_V3 : QR코드 스캐너
 */
static NSString *const MenuID_V3_ScannerSend                =    @"KAT_PONT_006"; // 보내기 QR스캐너 - // Native 화면 확인 필요
static NSString *const MenuID_V3_ScannerCancel              =    @"KAT_SHOP_080"; // 결제취소 QR스캐너 - // Native 화면 확인 필요

/**
 @brief 화면ID_V3 : 포인트리-거래내역조회
 */
static NSString *const MenuID_V3_Pointree                   =    @"MYD4_PO0101";

/**
 @brief 화면ID_V3 : 포인트리-거래내역조회
 */
static NSString *const MenuID_V3_PointreeHistory            =    @"MYD4_PO0101";  // Native 확인 필요

/**
 @brief 화면ID_V3 : 포인트리-충전하기
 */
static NSString *const MenuID_V3_PointreeCharge             =    @"MYD4_PO0400";   // /katsv2/KATPH02.do

/**
 @brief 화면ID_V3 : 간편결제내역조회
 */
static NSString *const MenuID_V3_PaymentHistory             =    @"MYD4_MW0110";   // katsv2/KATB401.do

/**
 @brief 화면ID_V3 : 이용가능가게
 */
static NSString *const MenuID_V3_AffiliateStoreList         =    @"KAT_MYPG_023"; // Native 화면 확인 필요

/**
 @brief 화면ID_V3 : 내 QR 코드  // 사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_V3_MyQR                       =    @"KAT_MYPG_005"; // Native 화면 확인 필요 (ADMIN 없음)

/**
 @brief 화면ID_V3 : Splash (인트로) // 사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_V3_Splash                     =    @"KAT_OPTU_001"; // Native 화면 확인 필요 (ADMIN 없음)

/**
 @brief 화면ID_V3 : 주소록  // 사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_V3_AddressBook                =    @"KAT_PONT_004"; // Native 화면 확인 필요

/**
 @brief 화면ID_V3 : 라이프샵  // 사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_V3_MateLifeShop               =    @"MYD4_PO0609";  // /katsv2/KATPU03.do

/**
 @brief 화면ID_V3 : 설정화면
 */
static NSString *const MenuID_V3_SettingHome                =    @"MYD4_AM0500"; // /katsv2/KATWA01.do

/**
 @brief 화면ID_V3 : 고객센터홈
 */
static NSString *const MenuID_V3_CSCenterHome               =    @"MYD4_AM0200"; // /katsv2/KATWC01.do

/**
 @brief 화면ID_V3 : 고객센터 - Tip
 */
static NSString *const MenuID_V3_CSCenterTip                =    @"MYD4_AM0203"; // /katsv2/KATWC04.do

/**
 @brief 화면ID_V3 : 회원가입/본인인증(하이브리드)
 */
static NSString *const MenuID_V3_MateJoin                   =    @"MYD4_JO0100"; // /katsv2/KATJ031.do

/**
 @brief 화면ID_V3 : 비밀번호 찾기(하이브리드)
 */
static NSString *const MenuID_V3_PwdReset                   =    @"MYD4_LO0103"; // /katsv2/KATL006.do

/**
 @brief 화면ID_V3 : 웹뷰 컨트롤러 // 사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_V3_WebViewVC                  =    @"MenuID_V3_WebViewVC";

/**
 @brief 화면ID_V3 : 제휴및 외부 홈페이지, cID를 넘겨주는 웹뷰 // 사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_V3_AlianceWeb                 =    @"MenuID_V3_AlianceWeb";

/**
 @brief 화면ID_V3 : 로그인 웹뷰 컨트롤러  // 사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_V3_LoginWebViewVC             =    @"MenuID_V3_LoginWebViewVC";

/**
 @brief 화면ID_V3 : QR코드 결제 detail okpos webview(테이블결제)  // 사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_V3_QRCodePaymentDetail        =    @"QRCodePaymentDetail";

/**
 @brief 화면ID_V3 : QR코드 결제 detail okpos webview(테이블결제) // 사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_V3_QRCodePaymentMixDetail     =    @"QRCodePaymentMixDetail";

/**
 @brief 화면ID_V3 : 제휴사프로모션완료 // 사용되지 않는  ID 삭제 예정
 */
static NSString *const MenuID_V3_PROMOTION_COMPLETE         =    @"MYD4_PR1310";  // uaasv3/FIN7101.do


//-------------------------------------------------------------------------
// 2021.06.17 V4 화면ID
//-------------------------------------------------------------------------
/**
 @brief 화면ID_V4 : 메인화면 MYPage
 */
static NSString *const MenuID_V4_MainPage                   =    @"MYD4_APP_MAIN"; // "MYD_APP_MAIN"(앱 메인 MYD_MA0100 -> MYD_APP_MAIN)

/**
 @brief 화면ID_V4 : 투데이
 */
static NSString *const MenuID_V4_Today                      =    @"MYD4_MMA0100";

/**
 @brief 화면ID_V4 : 간편결제 (마이포켓)
 */
static NSString *const MenuID_V4_SimplePayment              =    @"MYD4_MMW0100";

/**
 @brief 화면ID_V4 : 자산메인.
 */
static NSString *const MenuID_V4_ASSETLINKAGE_MainPage     =    @"MYD4_MML0300";

/**
 @brief 화면ID_V4 : 소비메인
 */
static NSString *const MenuID_V4_PayMngCnsmRpt             =   @"MYD4_MCS0200";

/**
 @brief 화면ID_V4 : 톡톡메인
 */
static NSString *const MenuID_V4_TocToc                    =   @"MYD4_MPS0101";

/**
 @brief 화면ID_V4 : 오픈뱅킹
 */
static NSString *const MenuID_V4_OpenBanking               =   @"MYD4_OB0601";

/**
 @brief 화면ID_V4 : 자산연동
 */
static NSString *const MenuID_V4_ASSET_LINKAGE             =    @"MYD4_MML0702";
