#ifndef _ISSACWEB_H_
#define _ISSACWEB_H_

#include <time.h>

#ifdef __cplusplus
extern "C"
{
#endif

#ifndef IN
	#define IN
#endif		//	IN

#ifndef	OUT 
	#define OUT
#endif		//	OUT	

//	2011.08.19 added by Lee.Y.S.
//	for managing the version, define the version of this core module.
//	The most least version should be defined in the wrapping code(XCODE, Java Class).
//	RULE
//		type : 1.2.3.4
//			- 1 : serious change(core)
//			- 2 : just add / remove / modify APIs(core)
//			- 3 : bug fix or add comments, log(core)
//			- 4 : OS specific change(wrap)
//		1, 2, 3	
//			- must define newly after the agreement should be reached between android & iOS.
//		4
//			- it can be done as the person in charge thinks best.

//	version(core)
#define IW_VERSION_1		(1)
#define IW_VERSION_2		(4)
#define IW_VERSION_3		(0)

//	accessor - get
//	RULE
//		int(bit) : 12345678 90123456 78901234 56789012
//				   -------- -------- -------- --------
//		arrange  : ver_1    ver_2    ver_3	  reserved
//		ex) version = 1.2.3
//			((1 << 24) | (2 << 16) | (3 << 8)) & FFF0
int IW_GetVersion() ;

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

IW_RETURN IW_CERTIFICATE_Create(CERTIFICATE *cert);

IW_RETURN IW_CERTIFICATE_Delete(CERTIFICATE *cert);

IW_RETURN IW_CERTIFICATE_Read(CERTIFICATE *cert, const char *pszEncodedCertificate);

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
IW_RETURN IW_CERTIFICATE_GetInfo(CERTIFICATE *cert, int nInfo, char *pszBuf, int nBufLen);

IW_RETURN IW_CERTIFICATE_Write(char *pszEncodedCert, const int buffer_alloc_len, CERTIFICATE *cert);


IW_RETURN IW_PRIVATEKEY_Create(PRIVATEKEY *privKey);

IW_RETURN IW_PRIVATEKEY_Delete(PRIVATEKEY *privKey);

IW_RETURN IW_PRIVATEKEY_Read(PRIVATEKEY *privKey, const char *pszEncodedPrivateKey, const char *pszPin);

IW_RETURN IW_PRIVATEKEY_Write(char *pszEncodedPrivKey, int buffer_alloc_len, PRIVATEKEY *privatekey, const char *pin, const int nCipher_id);

IW_RETURN IW_PRIVATEKEY_CheckPair(PRIVATEKEY *privKey, CERTIFICATE *cert);

IW_RETURN IW_CheckVID(CERTIFICATE *cert, PRIVATEKEY *privKey, const char *pszVid);

IW_RETURN IW_Encrypt(char *pszEncodedEncryptedMsg, const unsigned int nBufferSize, const unsigned char *pszSecretKey, const int nSecretKeyLen, const int nAlgorithm, const unsigned char *pszPlainMsg, const int nPlainMsgLen);

IW_RETURN IW_Decrypt( unsigned char *pszPlainMsg, unsigned int *nPlainMsgLen, const unsigned int nBufferSize, const unsigned char *pszSecretKey, const int nSecretKeyLen, const int nAlgorithm, const char *pszEncodedEncryptedMsg);

IW_RETURN IW_MakeResponse(char *pszEncodedResponse, int *nBufferSize, const void *pszEncodedChallenge, int nChallnegeLen, PRIVATEKEY *private_key, CERTIFICATE *certificate);

IW_RETURN IW_MakeSignature(char *pszEncodedSignature, int *nBufferSize, const void *pszMessage, int nMessageLen, PRIVATEKEY *private_key, CERTIFICATE *certificate, time_t sign_time);

IW_RETURN IW_MakeSignatureEx(char *pszEncodedSignature, int *nBufferSize, const void *pszMessage, int nMessageLen, PRIVATEKEY *private_key, CERTIFICATE *certificate, time_t sign_time, int nSigVer);

IW_RETURN IW_VerifySignature(const char *pszEncodedSignedData);

IW_RETURN IW_HybridEncrypt(char *pszEncodedEncData, const int nBufferSize, void *pKey, const void *pPlainData, const int nPlainLen, const char *pszPubKey, int nCipher_id);
IW_RETURN IW_HybridEncryptEx(char *pszEncodedEncData, const int nBufferSize, void *pKey, int key_len, const void *pPlainData, const int nPlainLen, const char *pszPubKey, int nCipher_id);


IW_RETURN IW_CERTIFICATE_Read_From_PKCS12(CERTIFICATE *cert, PRIVATEKEY *privKey, const char *pszEncodedPfx, const char *pszPin);
IW_RETURN IW_CERTIFICATE_Read_From_PKCS12_WithoutKey(OUT CERTIFICATE *cert, OUT PRIVATEKEY *privKey, IN const char *pszEncodedPfx, IN const char *pszPin);

IW_RETURN IW_CERTIFICATE_Write_To_PKCS12(char *pszEncodedPfx, const int nBufferSize, const char *pszPin, CERTIFICATE *cert, PRIVATEKEY *privKey);

IW_RETURN IW_CERTIFICATE_GetSubjectName(char *pszSubjectDN, const int nSubjectNameSize, CERTIFICATE *cert);
IW_RETURN IW_CERTIFICATE_GetIssuerName(char *pszIssuerName, const int nIssuerNameSize, CERTIFICATE *cert);
IW_RETURN IW_CERTIFICATE_MakeCertReadable(IN CERTIFICATE* cert, OUT char* psz_outbuf, IN int outbuf_len) ;

IW_RETURN IW_PRIVATEKEY_GetRandomNum(char *pszEncodedRandomNum, const unsigned int nBufferSize, PRIVATEKEY *privKey);
IW_RETURN IW_PRIVATEKEY_MakePrvkeyReadable(IN PRIVATEKEY* prvkey, OUT char* psz_outbuf, IN int outbuf_len) ;

IW_RETURN IW_Hash(IN char* pszData, IN OUT int* len, OUT char* pszHash, IN int alg) ;

IW_RETURN IW_GenerateRandom(OUT char* pszRand, IN int len);


IW_RETURN IW_EPRIVATEKEY_Create(EPRIVATEKEY *epki);

IW_RETURN IW_EPRIVATEKEY_Delete(EPRIVATEKEY *epki);

IW_RETURN IW_EPRIVATEKEY_Write(char *pszEncodedPrivKey, int buffer_alloc_len, EPRIVATEKEY *epki);

IW_RETURN IW_CERTIFICATE_Read_From_PKCS12_EPKI(OUT CERTIFICATE *cert, OUT EPRIVATEKEY *epki, IN const char *pszEncodedPfx, IN const char *pszPin);

IW_RETURN IW_PRIVATEKEY_Read_From_EPRIVATEKEY(PRIVATEKEY *privKey, EPRIVATEKEY *epki, const char *pszPin);

IW_RETURN IW_EPRIVATEKEY_Read(EPRIVATEKEY *epki, const char *pszEncodedPrivateKey);

IW_RETURN IW_MakeSignatureWithoutContent(char *pszEncodedSignature, int *nBufferSize, const void *pszMessage, int nMessageLen, PRIVATEKEY *private_key, CERTIFICATE *certificate, time_t sign_time);

IW_RETURN IW_VerifySignatureWithContent(const char *pszEncodedSignedData, const void *contentMessage, const int contentMessageLen, CERTIFICATE *cert, time_t sign_time);

IW_RETURN IW_EncryptExBin(unsigned char *output, unsigned int *outputLen, const unsigned char *pszSecretKey, const int nSecretKeyLen, const int nAlgorithm, const unsigned char *pszPlainMsg, const int nPlainMsgLen, const int mode, const unsigned char *iv, const int padFlag);

IW_RETURN IW_EncryptEx(char *pszEncodedEncryptedMsg, const unsigned int nBufferSize, const unsigned char *pszSecretKey, const int nSecretKeyLen, const int nAlgorithm, const unsigned char *pszPlainMsg, const int nPlainMsgLen, const int mode, const unsigned char *iv, const int padFlag);

IW_RETURN IW_DecryptEx( unsigned char *pszPlainMsg, unsigned int *nPlainMsgLen, const unsigned char *pszSecretKey, const int nSecretKeyLen, const int nAlgorithm, const char *pszEncodedEncryptedMsg, const int mode, const unsigned char *iv, const int padFlag);

IW_RETURN IW_DecryptExBin( unsigned char *pszPlainMsg, unsigned int *nPlainMsgLen, const unsigned char *pszSecretKey, const int nSecretKeyLen, const int nAlgorithm, const char *encryptedMsg, const int nEncryptedMsgLen, const int mode, const unsigned char *iv, const int padFlag);

IW_RETURN IW_HybridStdEncrypt(char *pszEncodedEncData, const int nBufferSize, const void *pKey, const int key_len, const void *pPlainData, const int nPlainLen, const char *pszPubKey, const int nCipher_id, const int nHashAlgorithm, const int nOaepVersion);

IW_RETURN IW_CERTIFICATE_Write_To_RSAPublicKey(char *pszEncodedPublicKey, const int nBufferAllocLen, CERTIFICATE *cert);

//	ver. 1.3.0.x
//	2011.08.30 added by Lee.Y.S.
IW_RETURN IW_CERTIFICATE_Write_To_PublicKeyInfo(OUT char *pszEncodedPublicKey, IN const int nBufferAllocLen, IN CERTIFICATE *cert);

//	2011.08.09 added by Lee.Y.S.
//	because this defined value is referenced by not only iOS but also android,
//	just moved from .c.
enum
{
	RSA_SHA1 = 0
} ;

enum IW_SUPPORTED_BCIPHER_ALGORITHM
{
	ALG_SEED,
	ALG_ARIA,
	ALG_AES
};

enum
{
  IW_NPAD = 0,
	IW_PAD = 1
};

enum IW_SUPPORTED_HASH_ALGORITHM
{
	ALG_SHA1 = 0,
	ALG_SHA256,
	ALG_HAS160
};

enum IW_SUPPORTED_OAEP_VER
{
	RSA_OAEP21 = 0,
	RSA_OAEP15
};

enum IW_SUPPORTED_SIGNEDDATA_VER
{
	SIGDATA_VER0 = 0,
	SIGDATA_VER1
};

enum IW_SUPPORTED_BCIPHER_MODE
{
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

enum IW_ERR_LIST
{
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
	IW_ERR_LICENSE_CANNOT_LOAD_CERT, // 3030
	IW_ERR_LICENSE_CANNOT_LOAD_CACERT,
	IW_ERR_WRONG_PIN_PFX,
	IW_ERR_CANNOT_CREATE_PFX,
	IW_ERR_CANNOT_MAKE_RESPONSE,
	IW_ERR_MEMORY_ALLOCATION
};

#ifdef __cplusplus
}
#endif


#endif // _ISSACWEB_H_
