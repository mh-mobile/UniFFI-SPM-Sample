use std::sync::{Arc, Mutex};

uniffi::setup_scaffolding!();

#[derive(uniffi::Object)]
pub struct Calculator {
    value: Mutex<i32>,
}

#[uniffi::export]
fn say_hi() -> String {
    "Hello mh from Rust!".to_string()
}

#[uniffi::export]
impl Calculator {
    #[uniffi::constructor]
    pub fn new(initial_value: i32) -> Arc<Self> {
        Arc::new(Self {
            value: Mutex::new(initial_value),
        })
    }

    pub fn add(&self, x: i32) {
        let mut value = self.value.lock().unwrap();
        *value += x;
    }

    pub fn get_value(&self) -> i32 {
        let value = self.value.lock().unwrap();
        *value
    }
}
