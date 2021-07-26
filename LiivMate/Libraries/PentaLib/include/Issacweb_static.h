#ifndef _ISSACWEB_H_
#define _ISSACWEB_H_
#define KCMVP

#include <time.h>

#ifdef __cplusplus
extern "C" {
#endif

#ifndef IN
#define IN
#endif      //  IN

#ifndef OUT
#define OUT
#endif      //  OUT

//  2011.08.19 added by Lee.Y.S.
//  for managing the version, define the version of this core module.
//  The most least version should be defined in the wrapping code(XCODE, Java Class).
//  RULE
//      type : 1.2.3.4
//          - 1 : serious change(core)
//          - 2 : just add / remove / modify APIs(core)
//          - 3 : bug fix or add comments, log(core)
//          - 4 : OS specific change(wrap)
//      1, 2, 3
//          - must define newly after the agreement should be reached between android & iOS.
//      4
//          - it can be done as the person in charge thinks best.

//  version(core)
#define IW_VERSION_1        (1)
#define IW_VERSION_2        (9)
#define IW_VERSION_3        (0)
#define IW_VERSION_4        (0)

enum {
    IW_SUBJECT_NAME = 1,
    IW_ISSUER_NAME,
    IW_ISSUE_DATE,
    IW_EXPIRE_DATE,
    IW_CERT_SERIAL,
    IW_KEY_USAGE,   // 6
    IW_ALGORITHM,
    IW_BASIC_CONSTRAINTS,
    IW_CERT_POLICY
};

//  2011.08.09 added by Lee.Y.S.
//  because this defined value is referenced by not only iOS but also android,
//  just moved from .c.
enum {
    IW_RSA_SHA1 = 0
};

enum {
    ALG_GENKEY_RSA = 0,
    ALG_GENKEY_DSA
};

enum IW_SUPPORTED_BCIPHER_ALGORITHM {
    IW_ALG_SEED,
    IW_ALG_ARIA,
    IW_ALG_AES,
    IW_ALG_LEA
};

enum {
    IW_NPAD = 0,
    IW_PAD = 1
};

enum IW_SUPPORTED_HASH_ALGORITHM {
    IW_ALG_SHA1 = 0,
    IW_ALG_SHA256,
    IW_ALG_HAS160
};

enum IW_SUPPORTED_OAEP_VER {
    IW_RSA_OAEP21 = 0,
    IW_RSA_OAEP15,
    IW_RSA_OAEP11
};

enum IW_SUPPORTED_SIGNEDDATA_VER {
    SIGDATA_VER0 = 0,
    SIGDATA_VER1
};

enum IW_SUPPORTED_BCIPHER_MODE {
    IW_MODE_ECB = 1,
    IW_MODE_CBC = 2,
    IW_MODE_CFB = 3,
    IW_MODE_CFB_BYTE = 4,
    IW_MODE_OFB = 5,
    IW_MODE_OFB_BYTE = 6,
    IW_MODE_CTS = 7,
    IW_MODE_CFB1 = 8,
    IW_MODE_CTR = 9,
    IW_MODE_MCFB = 10
};

enum IW_ERR_LIST {
    IW_SUCCESS = 0,
    IW_ERR_INVALID_CERTIFICATE = 3000,
    IW_ERR_INVALID_PRIVATEKEY,
    IW_ERR_INVALID_INPUT,
    IW_ERR_FAIL_TO_GET_RANDNUM,
    IW_ERR_FAIL_TO_VERIFY_VID,
    IW_ERR_BASE64_DECODE_FAIL,
    IW_ERR_BASE64_ENCODE_FAIL,
    IW_ERR_CERTIFICATE_READ_FAIL,
    IW_ERR_INVALID_DATA,
    IW_ERR_WRONG_PIN,
    IW_ERR_CANNOT_MAKE_SIGNEDDATA,  // 3010
    IW_ERR_CANNOT_WRITE_FILE,
    IW_ERR_INSUFFICIENT_ALLOC_LEN,
    IW_ERR_CANNOT_ENCRYPT_PRIVATEKEY,
    IW_ERR_INVALID_ALGORITHM,
    IW_ERR_CANNOT_READ_FILE,
    IW_ERR_ENCRYPT_FAIL,
    IW_ERR_DECRYPT_FAIL,
    IW_ERR_PRIVATEKEY_MISMATCH,
    IW_ERR_INVALID_SIGNATURE_FORMAT,
    IW_ERR_VERIFYSIGNATURE_FAILURE,  // 3020
    IW_ERR_INPUTDATA_TOOSHORT_OR_TOOLONG,
    IW_ERR_PUBKEY_DECODE_FAIL,
    IW_ERR_INVALID_PUBKEY,
    IW_ERR_PUB_FAIL_TO_ENC_MSG,
    IW_ERR_PUB_FAIL_TO_DEC_MSG,
    IW_ERR_LICENSE_EXPIRED,
    IW_ERR_LICENSE_INVALID_CERT,
    IW_ERR_LICENSE_INVALID_IP,
    IW_ERR_LICENSE_INVALID_TYPE,
    IW_ERR_LICENSE_CANNOT_LOAD_CERT,  // 3030
    IW_ERR_LICENSE_CANNOT_LOAD_CACERT,
    IW_ERR_WRONG_PIN_PFX,
    IW_ERR_CANNOT_CREATE_PFX,
    IW_ERR_CANNOT_MAKE_RESPONSE,
    IW_ERR_MEMORY_ALLOCATION,
    IW_ERR_GENERATE_KEYPAIR_FAIL,
    IW_ERR_INVALID_KEYSIZE
};

enum IW_PBKDF_PKCS12_TYPE {
    PKCS12_ID_ENCKEY = 0,
    PKCS12_ID_IV = 1,
    PKCS12_ID_MACKEY = 2
};

typedef int IW_RETURN;

typedef struct _certificate {
    void *certificate;
} CERTIFICATE;

typedef struct _privatekey {
    void *privatekey;
    int   epki;
} PRIVATEKEY;

typedef struct _eprivatekey {
    void *epki;
} EPRIVATEKEY;

typedef struct _publickey {
    void *publickey;
    int epki;
} PUBLICKEY;

//  accessor - get
//  RULE
//      int(bit) : 12345678 90123456 78901234 56789012
//                 -------- -------- -------- --------
//      arrange  : ver_1    ver_2    ver_3    reserved
//      ex) version = 1.2.3
//          ((1 << 24) | (2 << 16) | (3 << 8)) & FFF0
int IW_GetVersion();

/**
 인증서 객체를 초기화한다. 사용이 끝난 후 IW_CERTIFICATE_Delete()를 호출하여 사용된 메모리를 해제해줘야 한다.
 
 @param cert 인증서 객체
 @return IW_SUCCES - 성공
 @return IW_ERR_INVALID_INPUT - 잘못된 형식의 데이터 입력
 */
IW_RETURN IW_CERTIFICATE_Create(CERTIFICATE *cert);

IW_RETURN IW_CERTIFICATE_Delete(CERTIFICATE *cert);

IW_RETURN IW_CERTIFICATE_Read(CERTIFICATE *cert, const char *pszEncodedCertificate);

IW_RETURN IW_CERTIFICATE_Write(char *pszEncodedCert, const int buffer_alloc_len, CERTIFICATE *cert);

IW_RETURN IW_CERTIFICATE_GetInfo(CERTIFICATE *cert, int nInfo, char *pszBuf, int nBufLen);

IW_RETURN IW_PRIVATEKEY_Create(PRIVATEKEY *privKey);

IW_RETURN IW_PRIVATEKEY_Delete(PRIVATEKEY *privKey);

IW_RETURN IW_PRIVATEKEY_Read(PRIVATEKEY *privKey, const char *pszEncodedPrivateKey, const char *pszPin);

IW_RETURN IW_PRIVATEKEY_Write(char *pszEncodedPrivKey, int buffer_alloc_len, PRIVATEKEY *privatekey, const char *pin,
                              const int nCipher_id);

IW_RETURN IW_PRIVATEKEY_CheckPair(PRIVATEKEY *privKey, CERTIFICATE *cert);

IW_RETURN IW_GenerateRsaKeyPair(char *pszPubKey, unsigned int nPubKeyBuffSize, char *pszPriKey,
                                unsigned int nPriKeyBuffSize, int nKeySizeInBit);

IW_RETURN IW_CheckVID(CERTIFICATE *cert, PRIVATEKEY *privKey, const char *pszVid);

IW_RETURN IW_Encrypt(char *pszEncodedEncryptedMsg, const unsigned int nBufferSize, const unsigned char *pszSecretKey,
                     const int nSecretKeyLen, const int nAlgorithm, const unsigned char *pszPlainMsg,
                     const int nPlainMsgLen);

IW_RETURN IW_Decrypt(unsigned char *pszPlainMsg, unsigned int *nPlainMsgLen, const unsigned int nBufferSize,
                     const unsigned char *pszSecretKey, const int nSecretKeyLen, const int nAlgorithm,
                     const char *pszEncodedEncryptedMsg);

IW_RETURN IW_MakeResponse(char *pszEncodedResponse, int *nBufferSize, const void *pszEncodedChallenge,
                          int nChallnegeLen, PRIVATEKEY *private_key, CERTIFICATE *certificate);

IW_RETURN IW_MakeSignature(char *pszEncodedSignature, int *nBufferSize, const void *pszMessage, int nMessageLen,
                           PRIVATEKEY *private_key, CERTIFICATE *certificate, time_t sign_time);

IW_RETURN IW_MakeSignatureWithHashAlg(char *pszEncodedSignature, int *nBufferSize, const void *pszMessage,
                                      int nMessageLen, PRIVATEKEY *private_key, CERTIFICATE *certificate,
                                      time_t sign_time, enum IW_SUPPORTED_HASH_ALGORITHM hashAlg);

IW_RETURN IW_MakeSignatureEx(char *pszEncodedSignature, int *nBufferSize, const void *pszMessage, int nMessageLen,
                             PRIVATEKEY *private_key, CERTIFICATE *certificate, time_t sign_time, int nSigVer);

IW_RETURN IW_MakeSignatureExWithHashAlg(char *pszEncodedSignature, int *nBufferSize, const void *pszMessage,
                                        int nMessageLen, PRIVATEKEY *private_key, CERTIFICATE *certificate,
                                        time_t sign_time, int nSigVer, enum IW_SUPPORTED_HASH_ALGORITHM hashAlg);

IW_RETURN IW_VerifySignature(const char *pszEncodedSignedData);

IW_RETURN IW_HybridEncrypt(char *pszEncodedEncData, const int nBufferSize, void *pKey, const void *pPlainData,
                           const int nPlainLen, const char *pszPubKey, int nCipher_id);

IW_RETURN IW_HybridEncryptEx(char *pszEncodedEncData, const int nBufferSize, void *pKey, int key_len,
                             const void *pPlainData, const int nPlainLen, const char *pszPubKey, int nCipher_id);

IW_RETURN IW_HybridDecryptEx(void *pDecryptedData, const int nBufferSize, int *decryptedSize,
                             const char *pEncryptedB64, const char *pszPriKey, const int nCipher_id);

IW_RETURN IW_CERTIFICATE_Read_From_PKCS12(CERTIFICATE *cert, PRIVATEKEY *privKey, const char *pszEncodedPfx,
        const char *pszPin);

IW_RETURN IW_CERTIFICATE_Read_From_PKCS12_WithoutKey(OUT CERTIFICATE *cert, OUT PRIVATEKEY *privKey,
        IN const char *pszEncodedPfx, IN const char *pszPin);

IW_RETURN IW_CERTIFICATE_Write_To_PKCS12(char *pszEncodedPfx, const int nBufferSize, const char *pszPin,
        CERTIFICATE *cert, PRIVATEKEY *privKey);

IW_RETURN IW_CERTIFICATE_GetSubjectName(char *pszSubjectDN, const int nSubjectNameSize, CERTIFICATE *cert);

IW_RETURN IW_CERTIFICATE_GetIssuerName(char *pszIssuerName, const int nIssuerNameSize, CERTIFICATE *cert);

IW_RETURN IW_CERTIFICATE_MakeCertReadable(IN CERTIFICATE *cert, OUT char *psz_outbuf, IN int outbuf_len);

IW_RETURN IW_PRIVATEKEY_GetRandomNum(char *pszEncodedRandomNum, const unsigned int nBufferSize, PRIVATEKEY *privKey);

IW_RETURN IW_PRIVATEKEY_MakePrvkeyReadable(IN PRIVATEKEY *prvkey, OUT char *psz_outbuf, IN int outbuf_len);

IW_RETURN IW_HMAC(unsigned char *pbyMacBuffer, unsigned int *pnMacBufferSize, unsigned char *pbyKey,
                  unsigned int nKeySize, unsigned char *pbyMessage, unsigned int nMessageSize);

IW_RETURN IW_Hash(IN const char *pszData, IN OUT int *len, OUT char *pszHash, IN int alg);

// HASH 된 값을 HEXA 값으로 출력한다.
IW_RETURN IW_HASH_HEXA(IN const char *pszInData, IN int *inputlen, OUT char *pszHexaHash, OUT int *outlen,
                       IN int outBufMax, IN int alg);

// HASH 된 값을 base64 Encoding 된 값으로 출력한다.
IW_RETURN IW_HASH_BASE64(IN const char *pszInData, IN int *inputlen, OUT char *pszBase64Hash, OUT int *outlen,
                         IN int outBufMax, IN int alg);

IW_RETURN IW_GenerateRandom(OUT char *pszRand, IN int len);

char *IW_GETVERSION();

IW_RETURN IW_EPRIVATEKEY_Create(EPRIVATEKEY *epki);

IW_RETURN IW_EPRIVATEKEY_Delete(EPRIVATEKEY *epki);

IW_RETURN IW_EPRIVATEKEY_Write(char *pszEncodedPrivKey, int buffer_alloc_len, EPRIVATEKEY *epki);

IW_RETURN IW_CERTIFICATE_Read_From_PKCS12_EPKI(OUT CERTIFICATE *signCert, OUT PRIVATEKEY *signPri,
        OUT CERTIFICATE *kmCert, OUT PRIVATEKEY *kmPri, OUT CERTIFICATE **otherCerts, IN OUT int *otherCertCount,
        IN const char *pfxB64, IN const char *pfxPassword);

// 이 함수는 [SEED], [ECB, CBC, OFB], [SHA1, SHA256, HAS160] 만 지원
IW_RETURN IW_CERTIFICATE_Write_To_PKCS12_EPKI(OUT char *pszEncodedPfx, IN int nBufferSize, IN const char *pfxPin,
        IN CERTIFICATE *signCert, IN PRIVATEKEY *signPri, IN CERTIFICATE *kmCert, IN PRIVATEKEY *kmPri,
        IN CERTIFICATE **otherCerts, IN int otherCertCount, enum IW_SUPPORTED_BCIPHER_ALGORITHM symmAlg,
        enum IW_SUPPORTED_BCIPHER_MODE opMode, enum IW_SUPPORTED_HASH_ALGORITHM hashAlg, const unsigned char *salt,
        int saltSize, int iteration);

IW_RETURN IW_PRIVATEKEY_Read_From_EPRIVATEKEY(PRIVATEKEY *privKey, EPRIVATEKEY *epki, const char *pszPin);

IW_RETURN IW_PRIVATEKEY_Base64_Encode(char *resultData, PRIVATEKEY *privateKey);

IW_RETURN IW_EPRIVATEKEY_Read(EPRIVATEKEY *epki, const char *pszEncodedPrivateKey);

IW_RETURN IW_MakeSignatureWithoutContent(char *pszEncodedSignature, int *nBufferSize, const void *pszMessage,
        int nMessageLen, PRIVATEKEY *private_key, CERTIFICATE *certificate, time_t sign_time);

IW_RETURN IW_MakeSignatureWithoutContentWithHashAlg(char *pszEncodedSignature, int *nBufferSize, const void *pszMessage,
        int nMessageLen, PRIVATEKEY *private_key, CERTIFICATE *certificate, time_t sign_time,
        enum IW_SUPPORTED_HASH_ALGORITHM hashAlg);

IW_RETURN IW_VerifySignatureWithContent(const char *pszEncodedSignedData, const void *contentMessage,
                                        const int contentMessageLen, CERTIFICATE *cert, time_t sign_time);

IW_RETURN IW_VerifySignatureWithContentWithHashAlg(const char *pszEncodedSignedData, const void *contentMessage,
        const int contentMessageLen, CERTIFICATE *cert, time_t sign_time, enum IW_SUPPORTED_HASH_ALGORITHM hashAlg);

IW_RETURN IW_EncryptExBin(unsigned char *output, unsigned int *outputLen, const unsigned char *pszSecretKey,
                          const int nSecretKeyLen, const int nAlgorithm, const unsigned char *pszPlainMsg,
                          const int nPlainMsgLen, const int mode, const unsigned char *iv, const int padFlag);

IW_RETURN IW_EncryptEx(char *pszEncodedEncryptedMsg, const unsigned int nBufferSize, const unsigned char *pszSecretKey,
                       const int nSecretKeyLen, const int nAlgorithm, const unsigned char *pszPlainMsg,
                       const int nPlainMsgLen, const int mode, const unsigned char *iv, const int padFlag);

IW_RETURN IW_DecryptEx(unsigned char *pszPlainMsg, unsigned int *nPlainMsgLen, const unsigned char *pszSecretKey,
                       const int nSecretKeyLen, const int nAlgorithm, const char *pszEncodedEncryptedMsg,
                       const int mode, const unsigned char *iv, const int padFlag);

IW_RETURN IW_DecryptExBin(unsigned char *pszPlainMsg, unsigned int *nPlainMsgLen, const unsigned char *pszSecretKey,
                          const int nSecretKeyLen, const int nAlgorithm, const unsigned char *encryptedMsg,
                          const int nEncryptedMsgLen, const int mode, const unsigned char *iv, const int padFlag);

IW_RETURN IW_HybridStdEncrypt(char *pszEncodedEncData, const int nBufferSize, const void *pKey, const int key_len,
                              const void *pPlainData, const int nPlainLen, const char *pszPubKey, const int nCipher_id,
                              const int nHashAlgorithm, const int nOaepVersion);

IW_RETURN IW_HybridStdDecrypt(void *pDecryptedData, const int nBufferSize, int *decryptedSize, const char *pEncryptedB64,
                              const char *pszPriKey, const int nCipher_id, const int nHashAlgorithm,
                              const int nOaepVersion);

IW_RETURN IW_CERTIFICATE_Write_To_RSAPublicKey(char *pszEncodedPublicKey, const int nBufferAllocLen, CERTIFICATE *cert);

//  ver. 1.3.0.x
//  2011.08.30 added by Lee.Y.S.
IW_RETURN IW_CERTIFICATE_Write_To_PublicKeyInfo(OUT char *pszEncodedPublicKey, IN const int nBufferAllocLen,
        IN CERTIFICATE *cert);

// RSA 공개키 암호화
// outbuf : 암호화 된 메시지
// outbuf_len : 암호화 된 메시지의 길이
// inbuf : 암호화 할 메시지
// inbuf_len : 암호화 할 메시지의 길이
// publickey : 공개키
// oaep_ver : rsa oaep version (2.1 : 0, 1.5 : 1, 1.1 : 2)
IW_RETURN IW_RSA_Encrypt(void *outbuf, unsigned int *outbuf_len, const void *inbuf, int inbuf_len,
                         const char *publickey, int oaep_ver);

// RSA 공개키 암호화
// outbuf : 암호화 된 메시지 (Base64)
// outbuf_len : 암호화 된 메시지의 길이
// inbuf : 암호화 할 메시지
// inbuf_len : 암호화 할 메시지의 길이
// publickey : 공개키
// oaep_ver : rsa oaep version (2.1 : 0, 1.5 : 1, 1.1 : 2)
IW_RETURN IW_RSA_Encrypt_Base64(void *outbuf, unsigned int *outbuf_len, const void *inbuf, int inbuf_len,
                                const char *publickey, int oaep_ver);

// RSA 공개키 복호화
// outbuf : 복호화 된 메시지
// outbuf_len : 복호화 된 메시지의 길이
// inbuf : 복호화 할 메시지
// inbuf_len : 복호화 할 메시지의 길이
// privatekey : 비공개키
// oaep_ver : rsa oaep version (2.1 : 0, 1.5 : 1, 1.1 : 2)
IW_RETURN IW_RSA_Decrypt(void *outbuf, unsigned int *outbuf_len, const void *inbuf, int inbuf_len,
                         const char *privatekey, int oaep_ver);

// RSA 공개키 복호화
// outbuf : 복호화 된 메시지
// outbuf_len : 복호화 된 메시지의 길이
// inbuf : 복호화 할 메시지 (Base64)
// inbuf_len : 복호화 할 메시지의 길이
// privatekey : 비공개키
// oaep_ver : rsa oaep version (2.1 : 0, 1.5 : 1, 1.1 : 2)
IW_RETURN IW_RSA_Decrypt_Base64(void *outbuf, unsigned int *outbuf_len, const void *inbuf, int inbuf_len,
                                const char *privatekey, int oaep_ver);

// java와 호환되는 RSA 공개키 암호화
// outbuf : 암호화 된 메시지 (Base64)
// outbuf_len : 암호화 된 메시지의 길이
// inbuf : 암호화 할 메시지
// inbuf_len : 암호화 할 메시지의 길이
// publickey : 공개키
IW_RETURN IW_RSA_Encrypt_native(void *outbuf, unsigned int *outbuf_len, const void *inbuf, int inbuf_len,
                                const char *publickey);


// JAVA 에서 지원하는 RSA 에서 생성한 공개키를 issacweb 키 형식으로 바꿔준다.
// szPublickey :  JAVA에서 생성한 공개키
// szIWPublickey : issacweb 공개키를 가져온다.
// buffer_len : szIWPublickey 버퍼 크기
IW_RETURN IW_CHANGE_ISSACWEB_Publickey(IN const char *szPublickey, OUT char *szIWPublickey, IN int buffer_len);

IW_RETURN IW_PBKDF_PKCS12_genkey(void *derivedKey, int dkLen, const char *passwd);
IW_RETURN IW_PBKDF_PKCS12_genkey_Advanced(void *derivedKey, int dkLen, int idByte, const char *passwd, char *salt,
                                   int saltLen, int iterations, int hashAlg);

IW_RETURN IW_MakePkcs7(char *pszEncodedSignature, int *nBufferSize, const void *pszMessage, int nMessageLen,
                       PRIVATEKEY *private_key, CERTIFICATE *certificate, time_t sign_time, int nSigVer,
                       int contentType);

#ifdef __cplusplus
}
#endif

#endif  // _ISSACWEB_H_
