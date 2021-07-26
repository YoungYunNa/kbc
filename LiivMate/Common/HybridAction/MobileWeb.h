//
//  MobileWeb.h
//  LiivMate
//
//  Created by KB_CARD_MINI_6 on 2016. 8. 31..
//  Copyright © 2016년 KBCard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HybridActionManager.h"

#define mobWeb_ErrCode_1001     @"1001" //에러 발생시 사용자 알림 처리가 필요한 경우
#define mobWeb_ErrCode_1002     @"1002" //에러 발생시 사용자 알림 처리 후 화면 이동이 필요한 경우(ex 스크래핑 중 주민번호가 틀린 경우)
#define mobWeb_ErrCode_1003     @"1003" //에러 발생시 사용자 알림 처리 후 메인으로 이동(ex 라이브러리 오류로 프로세스 진행 불가)
#define mobWeb_ErrCode_1004     @"1004" //에러 발생시 사용자 알림 후 앱 종료가 필요한 경우
#define mobWeb_ErrCode_1099     @"1099" //사용자 취소 등 화면 및 알림이 불필요한 경우(ex 보안키패드 닫기)

#define mobWeb_not_action               @"9999"
#define mobWeb_openapi_not_actionKey    @"8999"
#define mobWeb_openapi_not_jsonStr      @"8998"
#define mobWeb_openapi_not_spec         @"8997"
#define mobWeb_openapi_term_cancel      @"8996"

@interface MobileWeb : NSObject
@property (nonatomic, unsafe_unretained) id<WebView> webView;
@property (nonatomic, strong) NSNumber *tag;
@property (nonatomic, strong) NSDictionary *paramDic;
@property (nonatomic, strong) NSString *successCallback;
@property (nonatomic, strong) NSString *failCallback;
-(void)finishedActionWithResult:(NSDictionary*)result success:(BOOL)success;
-(void)cancel;
-(void)run;
-(void)runWithParam:(NSDictionary*)param callback:(void (^)(NSDictionary *result, BOOL success))finishedCallback;
+(instancetype)runWithParam:(NSDictionary*)param callback:(void (^)(NSDictionary *result, BOOL success))finishedCallback;
@end

//전화번호부 전달
@interface requestAddressBook4MobileWeb : MobileWeb		// param : @{@"isMemberOnly" : @"Y" or @"N", "mCount" : 최대선택가능수 }
														// output param : 성공 (@{@"contactsList" : [ {"name":이름, "phone":전화번호}, ...] })
														//                실패 - 아무것도 선택하지 않은 경우 (없음)
@end

//포인트리 전달
@interface requestPoint : MobileWeb
@end

//포인트리 변동알림
@interface refreshPoint : MobileWeb
@end

//회원가입 완료
@interface joinSuccess : MobileWeb
@end

//앱아이디 조회
@interface requestAppId : MobileWeb
@end

//앱버전 조회
@interface requestAppVsn : MobileWeb
@end

//보안키패드 호출
@interface requestKeyPad : MobileWeb
@end

//보안키패드 호출(블럭체인및 FIDO 모드 사용)
@interface requestKeyPad2 : MobileWeb
@end

//라온키패드 호출
@interface requestRaonKeyPad : MobileWeb
@end

//네이티브 화면이동
@interface go2Page : MobileWeb
@end

//네이티브 화면닫기
@interface closeView : MobileWeb
@end

//네비게이션 상단 버튼및 타이틀 셋팅
@interface setTopMenu : MobileWeb
@end

//로그인요청
@interface requestLogin : MobileWeb
@end

//공유하기 팝업 호출(퀴즈)
@interface requestSharePop : MobileWeb
@end
typedef requestSharePop SharePopup;

@interface getRecommendCd : MobileWeb
@end

//화면밝기 조정 호출(바코드 표시)
@interface requestLight : MobileWeb
@end

// 스크래핑 (KB Easy 대출)
@interface requestScrapingInfo : MobileWeb
@end

//공인인증서 목록 가져오기
@interface requestCertifyList : MobileWeb
@end

// 공인인증서 가져오기
@interface saveCertify : MobileWeb
@end

// 공인인증서 삭제
@interface deleteCertify : MobileWeb
@end

//뒤로가기
@interface backBtnCall : MobileWeb
@end

//네비게이션 상단 버튼및 타이틀 셋팅 ver.2
@interface setTopMenuV2 : MobileWeb
@end

//progressBar
@interface callProgressBar : MobileWeb
@end

//팝업
@interface showAlert : MobileWeb
@end

#pragma mark - V2 인터페이스
//자동로그인 설정
@interface setAutoLogin : MobileWeb                 // param : 없음 (기동 전문에서 가져온 native 저장 값 사용)
                                                    // output param : 성공(P00904 result), 실패(@{@"errorMessage" : 오류 메시지})
@end

//비밀번호 확인
@interface verifyPassword : MobileWeb               // param : 없음
                                                    // output param : 성공(KATL010 result), 실패(@{@"errorMessage" : 오류 메시지})
@end

//비밀번호 변경
@interface changePassword : MobileWeb               // param : 없음
                                                    // output param : 취소 ->실패(없음), 성공(KATL020 result), 실패(@{@"errorMessage" : 오류 메시지})
@end

//회원가입시 기존회원일경우 인증 (재구현)
@interface certifiedMember : MobileWeb              // param : 없음
                                                    // output param : 성공(없음)
@end

//본인인증 결과
@interface certifiedResult : MobileWeb
@end

//기기 정보 조회 (native에서 읽어야 할 정보 모두 보낸다)
@interface getDeviceInfo : MobileWeb                // param : 없음
                                                    // output param : 성공(@{@"authenticationType" : @"FIDO" or @"PASSWORD",
                                                    //                      @"appCardInstalled" : @"Y" or @"N",
                                                    //                      @"paymentType" :@"QR" or @"BARCODE",
                                                    //                      @"isFidoRegistered" :@"Y" or @"N",
                                                    //                      @"isFidoDevice" : @"Y" or @"N",
                                                    //                      @"isFidoRegisteredInDevice" : @"Y" or @"N"})
@end


//로그인
@interface login : MobileWeb                        // param : 없음
                                                    // output param : 성공(없음), 실패(없음)
@end

//로그아웃 (native 정보 정리, 자동로그인 설정 해제)
@interface logout : MobileWeb                       // param : 없음
                                                    // output param : 성공(없음)
@end

//회원정보 수정
@interface modifiedMemberInfo : MobileWeb           // param : @{@"moblNo" : 휴대폰번호,  @"email" : 이메일주소,  @"com" : 통신사코드 }
                                                    // output param : 성공(없음)
@end

//회원탈퇴
@interface memberDropedOut : MobileWeb              // param : 없음
                                                    // output param : 성공(없음)
@end

//통신시 사용되는 httpRequsetHeaderField
@interface getHttpHeader : MobileWeb                // param : 없음
                                                    // output param : jsonObject (User-Agent, appId, token, modelNm, jbValue, chnlCd, lts)
@end

//QR코드 스캔
@interface scannQRCode : MobileWeb                  // param : @{@"type" : @"0"} 0 : 포인트리 보내기, 1 : 결제취소및 etc
@end                                                // output param : {@"result" : (스캔된 텍스트를 그대로 전달) ex)@"liivmate://QR?type=""&code=12312421"}

//정보저장
@interface setUserInfo : MobileWeb                  // param : @{@"pushEvtRecv":@"Y",@"pushUseRecv":@"N",...} 저장하고자하는 json
@end                                                // output param : {@"fail" : @[@"pushEvtRecv",@"pushUseRecv",...]} 저장에 실패한 json Key Array

//정보획득
@interface getUserInfo : MobileWeb                  // param : @{"getList" : @[@"pushEvtRecv",@"pushUseRecv",...]} 획득하고자하는 json Key array
@end                                                // output param : {@"pushEvtRecv" : @"Y", @"pushUseRecv" : @"N", ....} 들어온 key 에대한 valu를  json형태로 리턴

//바코드 확대 출력
@interface showExtendedBarcode : MobileWeb          // param : @{@"barcode" : @"XXXXXXXX"}
                                                    // output param : 성공(없음)
@end

//결제취소 바코드 출력
@interface showPaymentCancelBarcode : MobileWeb     // param : @{ @"validTime" : @"180",
                                                    //              @"barcode" : @"XXXXXXXX" }
                                                    // output param : 성공(없음), 바코드재생성요청(유효시간초과) -> 실패(@{@"errorMessage" : @"timeout"})
@end

//Toast 메시지 출력
@interface showToast : MobileWeb                    // param : @{@"message" : 메시지}
                                                    // output param : 성공(없음)
@end

//웹뷰 히스토리 쌓기
@interface addHistoryStack : MobileWeb              // param : @{@"url" : @"http://....", @"params" : @{}, @"useYN" : @"Y" or @"N" }
                                                    // output param : 성공(없음)
@end

//웹뷰 히스토리 지우기
@interface removeHistoryStack : MobileWeb           // param : @{@"cnt" : @"2"}
                                                    // output param : @{@"resCd":@"0000", @"historyStack" : @[@{@"url" : @"http://....", @"params" : @{}, @"useYN" : @"Y" or @"N" }, ....]}
@end

//웹뷰 히스토리 스택 지우기
@interface clearHistoryStack : MobileWeb            // param : 없음
                                                    // output param : 성공(없음)
@end

//로딩화면
@interface lodingIndicator : MobileWeb              // param : @{@"show" : @"Y"}
@end                                                // output param : 성공(없음)

//하이브리드 화면이동
@interface openNewPage : MobileWeb                  // param : {"screnId" : "KAT_FIPR_001", "openUrl" : "http://", "params" : {key : value},"closeYn" : "Y" , "externalYn" : "Y"}
@end                                                // output param : 성공(없음)

//앱 메인화면 또는 가맹점 메인화면 GNB변환및 각 메인화면으로 이동.
@interface goMainView : MobileWeb                   // param : 없음
@end                                                // output param : 성공(없음)

//클립보드 복사
@interface copyToClipboard : MobileWeb              // param : @{@"message" : 메시지}
                                                    // output param : 성공(없음)
@end

//json객체 보안키패드 공개키 암호화
@interface encJson : MobileWeb                      // param : 서버에서 넘겨주는 json 객체
                                                    // output param : 성공(@{@"result" : 암호화된 스트링})
@end

@interface ajaxCall : MobileWeb                     // param : @{@"url" : 리퀘스트아이디, @"params" : 암호화할 파라메타들, @"trxCd" : 해더에 셋팅될 trxCd값 }
@end

#pragma mark - V3 인터페이스
//해외여행자보험가입용 전화번호부 전달
@interface requestAddressMultiMobileWeb : MobileWeb // param : @{@"maxCount" : 최대선택가능 인원수 }
                                                    // output param : 성공 (@{@"contactsList" : [ {"name":이름, "phone":전화번호},
                                                    // 실패 - 아무것도 선택하지 않은 경우 (없음)
@end

//CardList 데이터 전달 (원패쓰)
@interface requestBarcodeCardList : MobileWeb       // param : {}
@end                                                // output param : 성공 {@"myCardList" : [{카드정보} , {}]}

//Push 상태값 (OS Push)
@interface requestOSPushState : MobileWeb           // param : {}
@end                                                // output param : 성공 {@"pushYn" : "Y"} // Y : 푸쉬수신, N : 푸쉬거부

//UUID 값 전달 (신규 KB Open API용)
@interface requestUUID : MobileWeb                  // param : {}
@end                                                // output param : 성공 {@"UUID" : "123dsafaf"} // AppInfo에 저장되어 있는 UUID 값

//버즈빌 (버즈빌 Feed호출)
@interface requestBuzzvilFeed : MobileWeb           // param : {title:"보고쌓기"}
@end

//GA360 (신규 GA360)
@interface requestGA360SendData : MobileWeb         // param : GA360 가이디 데이터 (JSon)
@end

//인터널 푸시로 더해진 스택을 모두 지운다.
@interface clearInterHistoryStack : MobileWeb
@end

//간편결제 카드선택
@interface requestSelectCard : MobileWeb
@end

// 카카오링크
@interface sendKakaoTalkLink : MobileWeb
@end

#pragma mark - V4 인터페이스
// OpenAPI 라온키패드
@interface requestRaonKeyPadV4 : MobileWeb
@end

// Popup webView 화면(modal view)
@interface requestPopUpWebView : MobileWeb
@end

// Open API 개별인증을 위한 App  설치 유/무
@interface requestInstalledAppScheme : MobileWeb
@end
