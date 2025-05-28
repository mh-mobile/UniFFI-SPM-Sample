use base64::{engine::general_purpose::URL_SAFE_NO_PAD, Engine};
use serde_json::Value;
use thiserror::Error;

#[derive(Debug, Error, uniffi::Error)]
#[uniffi(flat_error)]
pub enum JwtError {
    #[error("Invalid JWT format")]
    InvalidFormat,
    #[error("Base64 decode error: {0}")]
    Base64Error(String),
    #[error("JSON parse error: {0}")]
    JsonError(String),
}

#[derive(Debug, uniffi::Record)]
pub struct JwtParts {
    pub header: String,
    pub payload: String,
}

fn decode(input: &str) -> Result<Vec<u8>, JwtError> {
    URL_SAFE_NO_PAD
        .decode(input)
        .map_err(|e| JwtError::Base64Error(e.to_string()))
}

#[uniffi::export]
pub fn decode_jwt(jwt: &str) -> Result<JwtParts, JwtError> {
    // divide jwt
    let parts: Vec<&str> = jwt.split('.').collect();
    if parts.len() != 3 {
        return Err(JwtError::InvalidFormat);
    }

    // decode header and payload
    let header = decode(parts[0])?;
    let payload = decode(parts[1])?;

    // parse JSON
    let header_json: Value =
        serde_json::from_slice(&header).map_err(|e| JwtError::JsonError(e.to_string()))?;
    let payload_json: Value =
        serde_json::from_slice(&payload).map_err(|e| JwtError::JsonError(e.to_string()))?;

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
    }

    #[test]
    fn test_decode_invalid_jwt() {
        let jwt = "invalid.jwt.token";
        let result = decode_jwt(jwt);
        assert!(result.is_err());
    }
}