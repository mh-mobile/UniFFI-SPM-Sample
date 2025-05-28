//! スレッドセーフな計算機モジュール
//! 
//! このモジュールは、内部状態を保持し、基本的な算術演算を提供する
//! `Calculator`構造体をエクスポートします。

use std::sync::{Arc, Mutex};
use thiserror::Error;

/// 計算機で発生する可能性のあるエラー
#[derive(Debug, Error, uniffi::Error)]
#[uniffi(flat_error)]
pub enum CalculatorError {
    /// Mutexがポイズン状態になった場合
    #[error("Mutex was poisoned")]
    MutexPoisoned,
    /// 整数オーバーフローが発生した場合
    #[error("Integer overflow occurred")]
    Overflow,
    /// 整数アンダーフローが発生した場合
    #[error("Integer underflow occurred")]
    Underflow,
    /// ゼロで除算しようとした場合
    #[error("Division by zero")]
    DivisionByZero,
}

/// スレッドセーフな計算機
/// 
/// 内部で整数値を保持し、複数のスレッドから安全にアクセスできます。
/// 
/// # Example
/// ```
/// let calc = Calculator::new(0);
/// calc.add(5)?;
/// assert_eq!(calc.get_value()?, 5);
/// ```
#[derive(uniffi::Object)]
pub struct Calculator {
    value: Mutex<i32>,
}

#[uniffi::export]
impl Calculator {
    /// 指定された初期値で新しい計算機を作成します
    /// 
    /// # Arguments
    /// * `initial_value` - 計算機の初期値
    #[uniffi::constructor]
    pub fn new(initial_value: i32) -> Arc<Self> {
        Arc::new(Self {
            value: Mutex::new(initial_value),
        })
    }

    /// 現在の値に指定された値を加算します
    /// 
    /// # Arguments
    /// * `x` - 加算する値（負の値で減算も可能）
    /// 
    /// # Errors
    /// * `CalculatorError::Overflow` - 結果が`i32`の最大値を超える場合
    /// * `CalculatorError::MutexPoisoned` - 内部Mutexが破損している場合
    pub fn add(&self, x: i32) -> Result<(), CalculatorError> {
        let mut value = self.value.lock()
            .map_err(|_| CalculatorError::MutexPoisoned)?;
        *value = value.checked_add(x)
            .ok_or(CalculatorError::Overflow)?;
        Ok(())
    }

    /// 現在の値から指定された値を減算します
    /// 
    /// # Arguments
    /// * `x` - 減算する値
    /// 
    /// # Errors
    /// * `CalculatorError::Underflow` - 結果が`i32`の最小値を下回る場合
    /// * `CalculatorError::MutexPoisoned` - 内部Mutexが破損している場合
    pub fn subtract(&self, x: i32) -> Result<(), CalculatorError> {
        let mut value = self.value.lock()
            .map_err(|_| CalculatorError::MutexPoisoned)?;
        *value = value.checked_sub(x)
            .ok_or(CalculatorError::Underflow)?;
        Ok(())
    }

    /// 現在の値に指定された値を乗算します
    /// 
    /// # Arguments
    /// * `x` - 乗算する値
    /// 
    /// # Errors
    /// * `CalculatorError::Overflow` - 結果が`i32`の範囲を超える場合
    /// * `CalculatorError::MutexPoisoned` - 内部Mutexが破損している場合
    pub fn multiply(&self, x: i32) -> Result<(), CalculatorError> {
        let mut value = self.value.lock()
            .map_err(|_| CalculatorError::MutexPoisoned)?;
        *value = value.checked_mul(x)
            .ok_or(CalculatorError::Overflow)?;
        Ok(())
    }

    /// 現在の値を指定された値で除算します
    /// 
    /// # Arguments
    /// * `x` - 除算する値
    /// 
    /// # Errors
    /// * `CalculatorError::DivisionByZero` - ゼロで除算しようとした場合
    /// * `CalculatorError::MutexPoisoned` - 内部Mutexが破損している場合
    pub fn divide(&self, x: i32) -> Result<(), CalculatorError> {
        if x == 0 {
            return Err(CalculatorError::DivisionByZero);
        }
        let mut value = self.value.lock()
            .map_err(|_| CalculatorError::MutexPoisoned)?;
        *value = value.checked_div(x)
            .ok_or(CalculatorError::Overflow)?;
        Ok(())
    }

    /// 計算機の値をリセットします
    /// 
    /// # Arguments
    /// * `new_value` - 新しい値
    /// 
    /// # Errors
    /// * `CalculatorError::MutexPoisoned` - 内部Mutexが破損している場合
    pub fn reset(&self, new_value: i32) -> Result<(), CalculatorError> {
        let mut value = self.value.lock()
            .map_err(|_| CalculatorError::MutexPoisoned)?;
        *value = new_value;
        Ok(())
    }

    /// 現在の値を取得します
    /// 
    /// # Errors
    /// * `CalculatorError::MutexPoisoned` - 内部Mutexが破損している場合
    pub fn get_value(&self) -> Result<i32, CalculatorError> {
        let value = self.value.lock()
            .map_err(|_| CalculatorError::MutexPoisoned)?;
        Ok(*value)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_calculator_new() {
        let calc = Calculator::new(42);
        assert_eq!(calc.get_value().unwrap(), 42);
    }

    #[test]
    fn test_calculator_add() {
        let calc = Calculator::new(10);
        assert!(calc.add(5).is_ok());
        assert_eq!(calc.get_value().unwrap(), 15);
    }

    #[test]
    fn test_calculator_add_negative() {
        let calc = Calculator::new(10);
        assert!(calc.add(-5).is_ok());
        assert_eq!(calc.get_value().unwrap(), 5);
    }

    #[test]
    fn test_calculator_overflow() {
        let calc = Calculator::new(i32::MAX);
        let result = calc.add(1);
        assert!(result.is_err());
        match result {
            Err(CalculatorError::Overflow) => (),
            _ => panic!("Expected Overflow error"),
        }
    }

    #[test]
    fn test_calculator_underflow() {
        let calc = Calculator::new(i32::MIN);
        let result = calc.add(-1);
        assert!(result.is_err());
        match result {
            Err(CalculatorError::Overflow) => (), // checked_addはアンダーフローもOverflowとして扱う
            _ => panic!("Expected Overflow error"),
        }
    }

    #[test]
    fn test_calculator_thread_safety() {
        use std::thread;
        let calc = Calculator::new(0);
        let mut handles = vec![];

        for _ in 0..10 {
            let calc_clone = Arc::clone(&calc);
            let handle = thread::spawn(move || {
                for _ in 0..100 {
                    let _ = calc_clone.add(1);
                }
            });
            handles.push(handle);
        }

        for handle in handles {
            handle.join().unwrap();
        }

        assert_eq!(calc.get_value().unwrap(), 1000);
    }

    #[test]
    fn test_calculator_subtract() {
        let calc = Calculator::new(10);
        assert!(calc.subtract(3).is_ok());
        assert_eq!(calc.get_value().unwrap(), 7);
    }

    #[test]
    fn test_calculator_subtract_underflow() {
        let calc = Calculator::new(i32::MIN);
        let result = calc.subtract(1);
        assert!(result.is_err());
        match result {
            Err(CalculatorError::Underflow) => (),
            _ => panic!("Expected Underflow error"),
        }
    }

    #[test]
    fn test_calculator_multiply() {
        let calc = Calculator::new(5);
        assert!(calc.multiply(3).is_ok());
        assert_eq!(calc.get_value().unwrap(), 15);
    }

    #[test]
    fn test_calculator_multiply_overflow() {
        let calc = Calculator::new(i32::MAX);
        let result = calc.multiply(2);
        assert!(result.is_err());
        match result {
            Err(CalculatorError::Overflow) => (),
            _ => panic!("Expected Overflow error"),
        }
    }

    #[test]
    fn test_calculator_divide() {
        let calc = Calculator::new(20);
        assert!(calc.divide(4).is_ok());
        assert_eq!(calc.get_value().unwrap(), 5);
    }

    #[test]
    fn test_calculator_divide_by_zero() {
        let calc = Calculator::new(10);
        let result = calc.divide(0);
        assert!(result.is_err());
        match result {
            Err(CalculatorError::DivisionByZero) => (),
            _ => panic!("Expected DivisionByZero error"),
        }
    }

    #[test]
    fn test_calculator_reset() {
        let calc = Calculator::new(100);
        assert!(calc.reset(42).is_ok());
        assert_eq!(calc.get_value().unwrap(), 42);
    }

    #[test]
    fn test_calculator_complex_operations() {
        let calc = Calculator::new(10);
        assert!(calc.add(5).is_ok());      // 15
        assert!(calc.multiply(2).is_ok());  // 30
        assert!(calc.subtract(10).is_ok()); // 20
        assert!(calc.divide(4).is_ok());    // 5
        assert_eq!(calc.get_value().unwrap(), 5);
    }
}