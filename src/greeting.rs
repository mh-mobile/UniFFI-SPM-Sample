#[uniffi::export]
pub fn say_hi() -> String {
    "Hello mh from Rust!".to_string()
}