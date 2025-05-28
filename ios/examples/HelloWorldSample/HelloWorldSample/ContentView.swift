//
//  ContentView.swift
//  HelloWorldSample
//
//  Created by mh on 2025/01/29.
//

import SwiftUI
import Mobile

struct ContentView: View {
    @State private var greetingMessage: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Rustのgreeting機能のデモ
                VStack(spacing: 20) {
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .font(.system(size: 60))
                        .foregroundStyle(.tint)
                    
                    Text("Hello World Sample")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("This sample demonstrates the greeting module from Rust")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // メッセージ表示エリア
                VStack(spacing: 16) {
                    if !greetingMessage.isEmpty {
                        Text(greetingMessage)
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBlue).opacity(0.1))
                                    .stroke(Color(.systemBlue), lineWidth: 1)
                            )
                    }
                    
                    Button(action: {
                        greetingMessage = sayHi()
                    }) {
                        Label("Get Greeting from Rust", systemImage: "bubble.left.and.bubble.right")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    if !greetingMessage.isEmpty {
                        Button("Clear") {
                            greetingMessage = ""
                        }
                        .foregroundColor(.red)
                    }
                }
                
                Spacer()
                
                // 説明テキスト
                VStack(spacing: 8) {
                    Text("About this sample:")
                        .font(.headline)
                    
                    Text("This app calls the `sayHi()` function from Rust using UniFFI bindings. It demonstrates the simplest possible integration between Swift and Rust.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding()
            .navigationTitle("Hello World")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}