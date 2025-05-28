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
        do {
            try calculator.add(x: 1)
            value = try calculator.getValue()
        } catch {
            print("Error incrementing: \(error)")
        }
    }
    
    func decrement() {
        do {
            try calculator.add(x: -1)
            value = try calculator.getValue()
        } catch {
            print("Error decrementing: \(error)")
        }
    }
}
