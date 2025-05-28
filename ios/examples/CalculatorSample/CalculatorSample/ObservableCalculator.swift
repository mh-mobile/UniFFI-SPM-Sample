import SwiftUI
import Mobile

enum Operation {
    case add, subtract, multiply, divide
}

class ObservableCalculator: ObservableObject {
    private var calculator: Calculator
    @Published var displayValue: String = "0"
    @Published var errorMessage: String = ""
    @Published var isEnteringNumber: Bool = false
    
    private var pendingOperation: Operation?
    private var operandValue: Int32?
    
    init() {
        calculator = Calculator(initialValue: 0)
    }
    
    private func updateDisplay() {
        do {
            let value = try calculator.getValue()
            displayValue = "\(value)"
            errorMessage = ""
        } catch {
            errorMessage = "エラー: \(error.localizedDescription)"
        }
    }
    
    func digitPressed(_ digit: Int) {
        if isEnteringNumber {
            if displayValue == "0" {
                displayValue = "\(digit)"
            } else {
                displayValue += "\(digit)"
            }
        } else {
            displayValue = "\(digit)"
            isEnteringNumber = true
        }
    }
    
    func operationPressed(_ operation: Operation) {
        if isEnteringNumber {
            let currentValue = Int32(displayValue) ?? 0
            if pendingOperation == nil {
                // 最初のオペランド
                do {
                    try calculator.reset(newValue: currentValue)
                    updateDisplay()
                } catch {
                    errorMessage = "エラー: \(error.localizedDescription)"
                    return
                }
            } else {
                // 計算実行
                executeCalculation()
            }
        }
        
        pendingOperation = operation
        operandValue = Int32(displayValue)
        isEnteringNumber = false
    }
    
    func equalsPressed() {
        executeCalculation()
        pendingOperation = nil
        operandValue = nil
        isEnteringNumber = false
    }
    
    private func executeCalculation() {
        guard let operation = pendingOperation,
              let currentValue = Int32(displayValue) else { return }
        
        do {
            switch operation {
            case .add:
                try calculator.add(x: currentValue)
            case .subtract:
                try calculator.subtract(x: currentValue)
            case .multiply:
                try calculator.multiply(x: currentValue)
            case .divide:
                try calculator.divide(x: currentValue)
            }
            updateDisplay()
        } catch {
            errorMessage = "計算エラー: \(error.localizedDescription)"
        }
    }
    
    func clear() {
        do {
            try calculator.reset(newValue: 0)
            displayValue = "0"
            errorMessage = ""
            isEnteringNumber = false
            pendingOperation = nil
            operandValue = nil
        } catch {
            errorMessage = "リセットエラー: \(error.localizedDescription)"
        }
    }
    
    func plusMinus() {
        if let value = Int32(displayValue) {
            if isEnteringNumber {
                displayValue = "\(-value)"
            } else {
                do {
                    try calculator.reset(newValue: -value)
                    updateDisplay()
                } catch {
                    errorMessage = "エラー: \(error.localizedDescription)"
                }
            }
        }
    }
}