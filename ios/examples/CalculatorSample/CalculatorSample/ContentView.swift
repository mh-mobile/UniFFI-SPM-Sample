//
//  ContentView.swift
//  CalculatorSample
//
//  Created by mh on 2025/01/15.
//

import SwiftUI
import Mobile

struct ContentView: View {
    @StateObject private var calculator = ObservableCalculator()
    
    var body: some View {
        VStack(spacing: 1) {
            // ディスプレイエリア
            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    Text("Rust Calculator")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                // メインディスプレイ
                HStack {
                    Spacer()
                    Text(calculator.displayValue)
                        .font(.system(size: 64, weight: .light, design: .default))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .frame(height: 100)
                .padding(.horizontal)
                .background(Color(.systemBackground))
                
                // エラーメッセージ
                if !calculator.errorMessage.isEmpty {
                    Text(calculator.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 30)
            .background(Color(.systemBackground))
            
            // ボタンエリア
            VStack(spacing: 1) {
                // 1行目: C, ±, ÷
                HStack(spacing: 1) {
                    CalculatorButtonView(
                        title: "C",
                        backgroundColor: .secondary,
                        foregroundColor: .black
                    ) {
                        calculator.clear()
                    }
                    
                    CalculatorButtonView(
                        title: "±",
                        backgroundColor: .secondary,
                        foregroundColor: .black
                    ) {
                        calculator.plusMinus()
                    }
                    
                    CalculatorButtonView(
                        title: " ",
                        backgroundColor: .secondary,
                        foregroundColor: .black
                    ) {
                        // 空のボタン
                    }
                    
                    CalculatorButtonView(
                        title: "÷",
                        backgroundColor: .orange,
                        foregroundColor: .white
                    ) {
                        calculator.operationPressed(.divide)
                    }
                }
                
                // 2行目: 7, 8, 9, ×
                HStack(spacing: 1) {
                    CalculatorButtonView(title: "7") {
                        calculator.digitPressed(7)
                    }
                    CalculatorButtonView(title: "8") {
                        calculator.digitPressed(8)
                    }
                    CalculatorButtonView(title: "9") {
                        calculator.digitPressed(9)
                    }
                    CalculatorButtonView(
                        title: "×",
                        backgroundColor: .orange,
                        foregroundColor: .white
                    ) {
                        calculator.operationPressed(.multiply)
                    }
                }
                
                // 3行目: 4, 5, 6, −
                HStack(spacing: 1) {
                    CalculatorButtonView(title: "4") {
                        calculator.digitPressed(4)
                    }
                    CalculatorButtonView(title: "5") {
                        calculator.digitPressed(5)
                    }
                    CalculatorButtonView(title: "6") {
                        calculator.digitPressed(6)
                    }
                    CalculatorButtonView(
                        title: "−",
                        backgroundColor: .orange,
                        foregroundColor: .white
                    ) {
                        calculator.operationPressed(.subtract)
                    }
                }
                
                // 4行目: 1, 2, 3, +
                HStack(spacing: 1) {
                    CalculatorButtonView(title: "1") {
                        calculator.digitPressed(1)
                    }
                    CalculatorButtonView(title: "2") {
                        calculator.digitPressed(2)
                    }
                    CalculatorButtonView(title: "3") {
                        calculator.digitPressed(3)
                    }
                    CalculatorButtonView(
                        title: "+",
                        backgroundColor: .orange,
                        foregroundColor: .white
                    ) {
                        calculator.operationPressed(.add)
                    }
                }
                
                // 5行目: 0, =
                HStack(spacing: 1) {
                    CalculatorButtonView(
                        title: "0",
                        width: 2
                    ) {
                        calculator.digitPressed(0)
                    }
                    
                    CalculatorButtonView(
                        title: " ",
                        backgroundColor: .primary,
                        foregroundColor: .white
                    ) {
                        // 空のボタン
                    }
                    
                    CalculatorButtonView(
                        title: "=",
                        backgroundColor: .orange,
                        foregroundColor: .white
                    ) {
                        calculator.equalsPressed()
                    }
                }
            }
            .background(Color.black)
        }
        .background(Color(.systemBackground))
    }
}

struct CalculatorButtonView: View {
    let title: String
    let backgroundColor: Color
    let foregroundColor: Color
    let width: Int
    let action: () -> Void
    
    init(
        title: String,
        backgroundColor: Color = .primary,
        foregroundColor: Color = .white,
        width: Int = 1,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.width = width
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(backgroundColor)
        }
        .frame(height: 80)
        .gridCellColumns(width)
    }
}

#Preview {
    ContentView()
}