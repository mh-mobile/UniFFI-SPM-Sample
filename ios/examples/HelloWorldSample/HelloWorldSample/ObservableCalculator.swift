import SwiftUI
import Mobile

class ObservableCalculator: ObservableObject {
    private var calculator: Calculator
    @Published var value: Int32
    
    init(initialValue: Int32) {
        calculator = Calculator(initialValue: initialValue)
        value = initialValue
    }
    
    func increment() {
        calculator.add(x: 1)
        value = calculator.getValue()
    }
    
    func decrement() {
        calculator.add(x: -1)
        value = calculator.getValue()
    }
}
