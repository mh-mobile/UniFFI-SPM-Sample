//! JWT (JSON Web Token) デコードモジュール
//! 
//! このモジュールは、JWT文字列をデコードしてヘッダーとペイロードを
//! 抽出する機能を提供します。署名の検証は行いません。

use base64::{engine::general_purpose::URL_SAFE_NO_PAD, Engine};
use serde_json::Value;
use thiserror::Error;

/// JWTデコード時に発生する可能性のあるエラー
#[derive(Debug, Error, uniffi::Error)]
#[uniffi(flat_error)]
pub enum JwtError {
    /// JWTの形式が不正な場合（3つのパートに分割できない）
    #[error("Invalid JWT format: expected 3 parts separated by dots")]
    InvalidFormat,
    /// ヘッダーのBase64デコードに失敗した場合
    #[error("Failed to decode JWT header: {0}")]
    HeaderDecodeError(String),
    /// ペイロードのBase64デコードに失敗した場合
    #[error("Failed to decode JWT payload: {0}")]
    PayloadDecodeError(String),
    /// ヘッダーのJSONパースに失敗した場合
    #[error("Failed to parse JWT header as JSON: {0}")]
    HeaderParseError(String),
    /// ペイロードのJSONパースに失敗した場合
    #[error("Failed to parse JWT payload as JSON: {0}")]
    PayloadParseError(String),
    /// 空のJWTが渡された場合
    #[error("JWT string is empty")]
    EmptyJwt,
}

/// デコードされたJWTのヘッダーとペイロード
#[derive(Debug, uniffi::Record)]
pub struct JwtParts {
    /// JWTヘッダー（JSON文字列）
    pub header: String,
    /// JWTペイロード（JSON文字列）
    pub payload: String,
}

/// Base64 URLセーフエンコーディングをデコードします
fn decode_base64_url_safe(input: &str) -> Result<Vec<u8>, String> {
    URL_SAFE_NO_PAD
        .decode(input)
        .map_err(|e| e.to_string())
}

/// JWT文字列をデコードしてヘッダーとペイロードを抽出します
/// 
/// この関数は署名の検証を行いません。JWTの構造を解析して
/// ヘッダーとペイロードのJSON文字列を返すだけです。
/// 
/// # Arguments
/// * `jwt` - デコードするJWT文字列
/// 
/// # Returns
/// * `Ok(JwtParts)` - デコードに成功した場合、ヘッダーとペイロードを含む構造体
/// * `Err(JwtError)` - デコードに失敗した場合のエラー
/// 
/// # Example
/// ```
/// let jwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...";
/// match decode_jwt(jwt) {
///     Ok(parts) => {
///         println!("Header: {}", parts.header);
///         println!("Payload: {}", parts.payload);
///     }
///     Err(e) => println!("Error: {}", e),
/// }
/// ```
#[uniffi::export]
pub fn decode_jwt(jwt: &str) -> Result<JwtParts, JwtError> {
    // 空文字列チェック
    if jwt.is_empty() {
        return Err(JwtError::EmptyJwt);
    }

    // JWTを3つのパートに分割
    let parts: Vec<&str> = jwt.split('.').collect();
    if parts.len() != 3 {
        return Err(JwtError::InvalidFormat);
    }

    // ヘッダーとペイロードをデコード
    let header = decode_base64_url_safe(parts[0])
        .map_err(|e| JwtError::HeaderDecodeError(e))?;
    let payload = decode_base64_url_safe(parts[1])
        .map_err(|e| JwtError::PayloadDecodeError(e))?;

    // JSONとしてパース
    let header_json: Value =
        serde_json::from_slice(&header)
            .map_err(|e| JwtError::HeaderParseError(e.to_string()))?;
    let payload_json: Value =
        serde_json::from_slice(&payload)
            .map_err(|e| JwtError::PayloadParseError(e.to_string()))?;

    Ok(JwtParts {
        header: header_json.to_string(),
        payload: payload_json.to_string(),
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_decode_valid_jwt() {
        let jwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c";
        let result = decode_jwt(jwt);
        assert!(result.is_ok());
        
        let parts = result.unwrap();
        assert!(parts.header.contains("\"alg\":\"HS256\""));
        assert!(parts.header.contains("\"typ\":\"JWT\""));
        assert!(parts.payload.contains("\"sub\":\"1234567890\""));
        assert!(parts.payload.contains("\"name\":\"John Doe\""));
    }

    #[test]
    fn test_decode_invalid_jwt_format() {
        let jwt = "invalid.jwt.token";
        let result = decode_jwt(jwt);
        assert!(result.is_err());
        match result {
            Err(JwtError::HeaderDecodeError(_)) => (),
            _ => panic!("Expected HeaderDecodeError"),
        }
    }

    #[test]
    fn test_decode_jwt_missing_parts() {
        let jwt = "header.payload";  // 署名部分が欠けている
        let result = decode_jwt(jwt);
        assert!(result.is_err());
        match result {
            Err(JwtError::InvalidFormat) => (),
            _ => panic!("Expected InvalidFormat error"),
        }
    }

    #[test]
    fn test_decode_jwt_invalid_json() {
        // 有効なBase64だが無効なJSON
        let jwt = "aW52YWxpZA.aW52YWxpZA.signature";
        let result = decode_jwt(jwt);
        assert!(result.is_err());
        match result {
            Err(JwtError::HeaderParseError(_)) => (),
            _ => panic!("Expected HeaderParseError"),
        }
    }

    #[test]
    fn test_decode_empty_jwt() {
        let jwt = "";
        let result = decode_jwt(jwt);
        assert!(result.is_err());
        match result {
            Err(JwtError::EmptyJwt) => (),
            _ => panic!("Expected EmptyJwt error"),
        }
    }

    #[test]
    fn test_decode_jwt_with_extra_dots() {
        let jwt = "header.payload.signature.extra";
        let result = decode_jwt(jwt);
        assert!(result.is_err());
        match result {
            Err(JwtError::InvalidFormat) => (),
            _ => panic!("Expected InvalidFormat error"),
        }
    }
}