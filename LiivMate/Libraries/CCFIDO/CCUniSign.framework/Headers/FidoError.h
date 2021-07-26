//
//  Error.h
//  FidoFrameWork
//
//  Created by jwchoi on 2016. 4. 11..
//  Copyright © 2016년 jwchoi. All rights reserved.
//

#ifndef Error_h
#define Error_h


#endif /* Error_h */

#import <Foundation/Foundation.h>


extern NSString *const MSG_ERR_FIDO_RESPONSE_MESSAGE_IS_NULL;
/*
 LibType에서 사용
 */
extern NSString *const MSG_FIDO_LICENSE_CHECK_ERROR;
extern NSString *const MSG_INCORRECT_PASSWORD_ERROR;
extern NSString *const MSG_SAVE_CERT_ERROR;
extern NSString *const MSG_FIDO_LICENSE_IS_USER_VERIFY_NONE;
extern NSString *const MSG_FIDO_LICENSE_TYPE_IS_PURE_FIDO;
extern NSString *const MSG_FIDO_LICENSE_TYPE_IS_CERIFICATE_FIDO;
extern NSString *const MSG_FIDO_LICENSE_DOES_NOT_HAVE_THE_USER_VERIFY_FINGERPRINT;
extern NSString *const MSG_FIDO_LICENSE_DOES_NOT_HAVE_THE_USER_VERIFY_PATTERN;
extern NSString *const MSG_FIDO_LICENSE_DOES_NOT_HAVE_THE_USER_VERIFY_PASSCODE;
extern NSString *const MSG_FIDO_LICENSE_DOES_NOT_HAVE_THE_USER_VERIFY_EYEPRINT;
extern NSString *const MSG_FIDO_LICENSE_DOES_NOT_HAVE_THE_USER_VERIFY_FACEPRINT;
extern NSString *const MSG_FIDO_LICENSE_DOES_NOT_HAVE_THE_USER_VERIFY_VOICE;
extern NSString *const MSG_REGISTERED_PASSWORD;
extern NSString *const MSG_UAFREQUEST_COUNT_IS_0;
extern NSString *const MSG_ALREADY_REGISTERED_AAID;
extern NSString *const MSG_FACETID_IS_NOT_IN_TRUSTEDFACETS;
extern NSString *const MSG_CAN_NOT_USE_TOUCHID;
extern NSString *const MSG_UNREGISTERED_TOUCHID;
extern NSString *const MSG_NO_SUITABLE_AUTHENTICATOR;
extern NSString *const MSG_UNTRUSTED_FACET_ID;
extern NSString *const MSG_MISSING_CCFido_conf_FILE;
extern NSString *const MSG_MISSING_CCFido_dat_FILE;
extern NSString *const MSG_TOUCHID_NOT_SUPPORT_DEVICE;
extern NSString *const MSG_FIDO_DETECTED_CHANGE_BIOMETRICS;
extern NSString *const MSG_THERE_IS_NO_AAID_FROM_SERVER;
extern NSString *const MSG_THERE_IS_NO_AAID_FROM_DEVICE;
extern NSString *const MSG_THERE_IS_NO_POLICY_FROM_SERVER;
extern NSString *const MSG_THERE_IS_NO_REG_KEY_FROM_DEVICE;
extern NSString *const MSG_NO_SUITABLE_CLIENT_AUTHENTICATOR;
extern NSString *const MSG_REGISTERED_KEY_NOT_VALID;
extern NSString *const MSG_THERE_IS_NOT_CONTAIN_CLIENT_AAID;
extern NSString *const MSG_UNREGISTERED;
/*------------------------------------------------------*/

/*
 WebToApp, AppToApp에서 사용
 */
extern NSString *const MSG_SUCCEED;
extern NSString *const MSG_ERR_FIDO_LINCENSE_FAILURE;
extern NSString *const MSG_ERR_FIDO_WRONG_CCFIDO_PROTOCOL;
extern NSString *const MSG_ERR_FIDO_UNAVAILABLE_BIOTYPE;
extern NSString *const MSG_ERR_FIDO_CONNECT_FIDOSERVER_FAILURE;
extern NSString *const MSG_ERR_FIDO_PINCODE_NOT_REGISTERED;
extern NSString *const MSG_ERR_FIDO_ALREADY_REGISTERED;
extern NSString *const MSG_ERR_FIDO_NOT_REGISTERED_USER;
extern NSString *const MSG_ERR_FIDO_NOT_SUPPORT_DEVICE;
extern NSString *const MSG_ERR_FIDO_NOT_SUPPORT_K_FIDO;
extern NSString *const MSG_ERR_FIDO_NOT_SUPPORT_FIDO;
extern NSString *const MSG_ERR_FIDO_VERIFICATION_FAILURE_BY_PINCODE;
extern NSString *const MSG_ERR_FIDO_VERIFICATION_FAILURE_BY_TOUCHID;
extern NSString *const MSG_ERR_FIDO_CAN_NOT_USE_TOUCHID;
extern NSString *const MSG_ERR_FIDO_NO_SUITABLE_AUTHENTICATOR;
extern NSString *const MSG_ERR_FIDO_THERE_IS_NO_CERTIFICATE;
//extern NSString *const MSG_ERR_FIDO_USER_CANCELLED;
extern NSString *const MSG_ERR_FIDO_CANCELED_TO_FINGERPRINT_AUTHENTICATION;
extern NSString *const MSG_ERR_FIDO_AUTHENTICATION_PERMITS_HAS_BEEN_EXCEDED;
extern NSString *const MSG_ERR_FIDO_LICENSE_DOES_NOT_HAVE_THE_USER_VERIFY_FACEPRINT;
/*------------------------------------------------------*/


/*
WebToApp, AppToApp에서 사용 - PINPAD
 */
extern NSString *const MSG_ERR_FIDO_WRONG_CCPINPAD_PROTOCOL;
extern NSString *const MSG_ERR_FIDO_PINPAD_REGIST_FAILURE;
extern NSString *const MSG_ERR_FIDO_PINPAD_ALREADY_REGISTERED;
extern NSString *const MSG_ERR_FIDO_PINPAD_MODIFY_FAILURE;
extern NSString *const MSG_ERR_FIDO_PINPAD_REMOVE_FAILURE;
extern NSString *const MSG_ERR_FIDO_NO_PIN_REGISTERED;





/*
 NO_ERROR of type short
 The operation completed with no error condition encountered. Upon receipt of this code, an application should no longer expect an associated UAFResponseCallback to fire.

 WAIT_USER_ACTION of type short
 Waiting on user action to proceed. For example, selecting an authenticator in the FIDO client user interface, performing user verification, or completing an enrollment step with an authenticator.

 INSECURE_TRANSPORT of type short
 window.location.protocol is not "https" or the DOM contains insecure mixed content.

 USER_CANCELLED of type short
 The user declined any necessary part of the interaction to complete the registration.

 UNSUPPORTED_VERSION of type short
 The UAFMessage does not specify a protocol version supported by this FIDO UAF Client.

 NO_SUITABLE_AUTHENTICATOR of type short
 No authenticator matching the authenticator policy specified in the UAFMessage is available to service the request, or the user declined to consent to the use of a suitable authenticator.

 PROTOCOL_ERROR of type short
 A violation of the UAF protocol occurred. The interaction may have timed out; the origin associated with the message may not match the origin of the calling DOM context, or the protocol message may be malformed or tampered with.

 UNTRUSTED_FACET_ID of type short
 The client declined to process the operation because the caller's calculated facet identifier was not found in the trusted list for the application identifier specified in the request message.
 
 UNKNOWN of type short
 An error condition not described by the above-listed codes.
 */
@interface FidoError : NSError {

    #pragma mark FIDO SPEC에 정의된  에러
    enum{
        NO_ERROR                    = 0x0,
        WAIT_USER_ACTION            = 0x1,
        INSECURE_TRANSPORT          = 0x2,
        USER_CANCELLED              = 0x3,
        UNSUPPORTED_VERSION         = 0x4,
        NO_SUITABLE_AUTHENTICATOR   = 0x5,
        PROTOCOL_ERROR              = 0x6,
        UNTRUSTED_FACET_ID          = 0x7,
        UNKNOWN                     = 0xFF
    };
    

    #pragma mark LibType에서 사용
    enum{
        FIDO_LICENSE_CHECK_ERROR                                = 10000,
        FIDO_INCORRECT_PASSWORD_ERROR                           = 10001,
        DB_INSERT_ERROR                                         = 10002,
        FIDO_LICENSE_IS_USER_VERIFY_NONE                        = 10003,
        FIDO_LICENSE_TYPE_IS_PURE_FIDO                          = 10004,
        FIDO_LICENSE_TYPE_IS_CERIFICATE_FIDO                    = 10005,
        FIDO_LICENSE_DOES_NOT_HAVE_THE_USER_VERIFY_FINGERPRINT  = 10006,
        FIDO_LICENSE_DOES_NOT_HAVE_THE_USER_VERIFY_PATTERN      = 10007,
        FIDO_LICENSE_DOES_NOT_HAVE_THE_USER_VERIFY_PASSCODE     = 10008,
        FIDO_LICENSE_DOES_NOT_HAVE_THE_USER_VERIFY_EYEPRINT     = 10009,
        PASSWORD_IS_NOT_REGISTERED                              = 10010,
        UAFREQUEST_COUNT_IS_0                                   = 10011,
        ALREADY_REGISTERED_AAID                                 = 10012,
        //        AUTHETICATION_CONFIRM_FAILED                            = 10013,
        //        DEREGISTRATION_FAILED                                   = 10013,
        //        RESPONSE_DATA_PARSING_ERROR                             = 10014,
        CAN_NOT_USE_TOUCHID                                     = 10013,
        TOOLKIT_ERROR                                           = 10014,
        MISSING_CCFido_conf_FILE                                = 10015,
        MISSING_CCFido_dat_FILE                                 = 10016,
        TOUCHID_NOT_SUPPORT_DEVICE                              = 10017,
        UNREGISTERED_TOUCHID                                    = 10018,
        FIDO_LICENSE_DOES_NOT_HAVE_THE_USER_VERIFY_VOICE        = 10019,
        FIDO_LICENSE_DOES_NOT_HAVE_THE_USER_VERIFY_FACEPRINT    = 10020,
        USER_CANCEL                                             = 10021,
        USER_FALLBACK                                           = 10022,
        SYSTEM_CANCEL                                           = 10023,
        APP_CANCEL                                              = 10024,
        LOCK_OUT                                                = 10025,
        BIOMETRICS_CHANGES_DETECTED                             = 10026,
        FIDO_GEN_AUTH_FAILURE                                   = 10027,
        NO_AAID_FROM_SERVER                                     = 10028,
        NO_AAID_FROM_DEVICE                                     = 10029,
        NO_POLICY_FROM_SERVER                                   = 10030,
        REQUEST_DOES_NOT_CONTAIN_CLIENT_AAID                    = 10031,
        UNREGISTERED                                            = 10032,
        REGISTERED_KEY_NOT_VALID                                = 10033,
        NO_SUITABLE_CLIENT_AUTHENTICATOR                        = 10034

    };

    #pragma mark WebToApp, AppToApp에서 사용
    enum{
        SUCCEED                                     = 0,
        ERR_UNKONWN                                 = -1000,
        ERR_FIDO_LINCENSE_FAILURE                   = -1001,
        ERR_FIDO_WRONG_CCFIDO_PROTOCOL              = -1002,
        ERR_FIDO_UNAVAILABLE_BIOTYPE                = -1003,
        ERR_FIDO_CONNECT_FIDOSERVER_FAILURE         = -1004,
        ERR_FIDO_PINCODE_NOT_REGISTERED             = -1005,
        ERR_FIDO_ALREADY_REGISTERED                 = -1006,
        ERR_FIDO_NOT_REGISTERED_USER                = -1007,
        ERR_FIDO_NOT_SUPPORT_DEVICE                 = -1008,
        ERR_FIDO_NOT_SUPPORT_K_FIDO                 = -1009,
        ERR_FIDO_NOT_SUPPORT_FIDO                   = -1010,
        //-1011 TA : Only Android
        ERR_FIDO_VERIFICATION_FAILURE_BY_PINCODE    = -1012,
        ERR_FIDO_VERIFICATION_FAILURE_BY_TOUCHID    = -1013,
        ERR_FIDO_CAN_NOT_USE_TOUCHID                = -1014,
        ERR_FIDO_UNREGISTERED_TOUCHID               = -1015,

        ERR_FIDO_FAILED_TO_FIDO_REGISTRATION        = -1016,
        ERR_FIDO_FAILED_TO_FIDO_AUTHENTICATION      = -1017,
        ERR_FIDO_FAILED_TO_FIDO_DELETION            = -1018,
        ERR_FIDO_CANCELED_TO_FINGERPRINT_AUTHENTICATION  = -1019,
        ERR_FIDO_AUTHENTICATION_PERMITS_HAS_BEEN_EXCEDED = -1020,
        //        Only Android                = -1021,
        ERR_FIDO_UNREGISTERED_FACET_ID              = -1022,
        ERR_FIDO_NO_SUITABLE_AUTHENTICATOR          = -1023,
        //        Only Android          = -1024,
        ERR_BIOMETRICS_CHANGES_DETECTED             = -1025,
        ERR_FIDO_THERE_IS_NO_CERTIFICATE            = -1100,
        ERR_FIDO_LINCENSE_FAILURE_VERIFY_FACEPRINT  = -1101,
    };

    #pragma mark WebToApp, AppToApp에서 사용 - PINPAD
    enum{
        ERR_FIDO_WRONG_CCPINPAD_PROTOCOL            = -2002,
        ERR_FIDO_PINPAD_REGIST_FAILURE              = -2005,
        ERR_FIDO_PINPAD_ALREADY_REGISTERED          = -2006,
        ERR_FIDO_PINPAD_MODIFY_FAILURE              = -2007,
        ERR_FIDO_PINPAD_REMOVE_FAILURE              = -2008
    };
}

@end
