//
//  KCLServerSetting.h
//  LiivMate
//
//  Created by KB on 4/20/21.
//  Copyright © 2021 KBCard. All rights reserved.
//

/**
@file KCLServerSetting.h
@date 2021.04.20
@brief 서버 설정 디파인 값
*/

#ifndef KCLServerSetting_h
#define KCLServerSetting_h

#ifdef DEBUG
//////////////////////////////////////////////////////////
//테스트 서버 접속여부 0 - 운영서버, 1 - 테스트서버
#define USE_TEST_SERVER                    1
//////////////////////////////////////////////////////////
#endif


//웹뷰 및 리퀘스트에 들어가는 버전 ex) "User-Agent" = "LiivMate_I/2;";
//대규모 업데이트시 변경
#define User_Agent_Ver      @"6"

//운영서버
#define SERVER_URL_REAL     @"https://m.liivmate.com/katsv4"
//운영서버 보안키패드 퍼브키
#define ServerPubKey_REAL   "ADCBiAKBgHEhZzpWUF0nDSBc1NGSslpMZBZiR7sJRJdX7y0DsQTQYhqppmS7RlsqDD/IiogWW9GJYIHx9CPLf/NPxhIhPxSHlXs6G5RR4mWxD4RMKXNSFlZ5yXEt9u4a7iGV1wo4wrO0H3ZchjsfCzJIcCP6m9QlcKS02hOs0oJfPMUdHkOPAgMBAAE="
//운영서버 FIDO 모드
#define FidoMode_REAL       @"REAL"

//Fido관련
#if !(defined(DEBUG) && USE_TEST_SERVER)
    #define FIDO_SERVER_URL     @"https://cardfido.kbcard.com:2443/RPS/LiivMate/Interface"
#else//개발서버
    #define FIDO_SERVER_URL     @"https://dcardfido.kbcard.com:8443/RPS/LiivMate/Interface"
#endif


//릴리즈 빌드에서는 무조껀 리얼셋팅, 디버그빌드에서는 상단 서버접속여부로 판단.
#if !(defined(DEBUG) && USE_TEST_SERVER)
    #define SERVER_URL                      SERVER_URL_REAL
    #define ServerPubKey                    ServerPubKey_REAL
    #define FidoMode                        FidoMode_REAL
    #define KAKAO_REST_API_KEY              @"6e3022893fe2871e4e8b7d11402eb052"
#else//개발서버
    #define SELECT_SERVER                   @"1"
    #define SERVER_URL                      [(NSObject *)[UIApplication sharedApplication].delegate valueForKey:@"server"]

    #define DEV_SERVER_URL                  @"https://dm.liivmate.com/katsv4" // 리브메이트 개발

    #define STA_SERVER_URL                  @"https://sm.liivmate.com/katsv4" // 리브메이트 스테이징

    #define ServerPubKey                    "ADCBiAKBgHgWQm5CVQBNaGlIgTgv06HhOXQqSuuBPY2EvPvPsEL120jnT5HCU7lMbP8qVvb2qpGmxN+3PUVUXG1yHKqEGkNc77/eOq4KReHFeezH2wPoLnRkivm0pE4MfWwL2N6la5G1lktZdbtsWMAT7GJeEpbbDkTqatbf4XQkG2Cixq/jAgMBAAEA"
    #define FidoMode                        @"TEST"
    #define KAKAO_REST_API_KEY              @"6e3022893fe2871e4e8b7d11402eb052"
#endif

#ifndef SELECT_SERVER
#define WizveraAPI  @"https://m.liivmate.com/katsv4/wizvera/delfino/svc/delfino_certRelay.jsp" //운영
//https://m.liivmate.com/wizvera/delfino/svc/delfino_certRelay.jsp
//"https://m.kbcard.com/cxhr/delfino_certRelay_real.jsp" //운영
#else
#define WizveraAPI  @"https://dm.liivmate.com/katsv4/wizvera/delfino/svc/delfino_certRelay.jsp" //개발
//https://dm.liivmate.com/wizvera/delfino/svc/delfino_certRelay.jsp
// @"https://dm.kbcard.com/cxhr/delfino_certRelay.jsp"

#endif

#endif /* KCLServerSetting_h */
