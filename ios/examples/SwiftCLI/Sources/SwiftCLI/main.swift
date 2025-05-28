import Mobile

// say_hiメソッドを呼び出し
let message = sayHi()
print(message)

// calculatorを使って計算
let calculator = Calculator(initialValue: 0)
do {
    try calculator.add(x: 7)
    let value = try calculator.getValue()
    print(value)
} catch {
    print("Calculator error: \(error)")
}
