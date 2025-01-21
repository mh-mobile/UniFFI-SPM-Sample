//
//  ContentView.swift
//  HelloWorldSample
//
//  Created by mh on 2025/01/15.
//

import SwiftUI
import Mobile

struct ContentView: View {
    @StateObject private var calculator = ObservableCalculator(initialValue: 0)
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(sayHi())
                .padding()
            
            HStack {
                Button("-1") {
                    calculator.decrement()
                }
                Button("+1") {
                    calculator.increment()
                }
            }
            Text("Value: \(calculator.value)")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
