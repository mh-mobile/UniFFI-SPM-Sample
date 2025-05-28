//! 挨拶機能を提供するモジュール

/// 挨拶メッセージを返します
/// 
/// # Returns
/// * 固定の挨拶メッセージ文字列
/// 
/// # Example
/// ```
/// let message = say_hi();
/// assert_eq!(message, "Hello mh from Rust!");
/// ```
#[uniffi::export]
pub fn say_hi() -> String {
    "Hello mh from Rust!".to_string()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_say_hi() {
        let message = say_hi();
        assert_eq!(message, "Hello mh from Rust!");
    }

    #[test]
    fn test_say_hi_not_empty() {
        let message = say_hi();
        assert!(!message.is_empty());
    }
}