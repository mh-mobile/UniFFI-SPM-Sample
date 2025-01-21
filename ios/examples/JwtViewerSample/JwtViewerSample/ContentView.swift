//
//  ContentView.swift
//  JwtViewerSample
//
//  Created by mh on 2025/01/21.
//

import SwiftUI
import Mobile

struct ContentView: View {
    @State private var jwtInput: String = ""
    @State private var decodedHeader: String = ""
    @State private var decodedPayload: String = ""
    @State private var errorMessage: String = ""
    
    private func decodeJWT() {
        errorMessage = ""
        decodedHeader = ""
        decodedPayload = ""
        
        guard !jwtInput.isEmpty else { return }
        
        do {
            let parts = try decodeJwt(jwt: jwtInput)
            if let headerData = parts.header.data(using: .utf8),
               let payloadData = parts.payload.data(using: .utf8),
               let headerJson = try? JSONSerialization.jsonObject(with: headerData),
               let payloadJson = try? JSONSerialization.jsonObject(with: payloadData) {
                let headerFormatted = try JSONSerialization.data(withJSONObject: headerJson, options: .prettyPrinted)
                let payloadFormatted = try JSONSerialization.data(withJSONObject: payloadJson, options: .prettyPrinted)
                decodedHeader = String(data: headerFormatted, encoding: .utf8) ?? parts.header
                decodedPayload = String(data: payloadFormatted, encoding: .utf8) ?? parts.payload
            } else {
                decodedHeader = parts.header
                decodedPayload = parts.payload
            }
        } catch JwtError.InvalidFormat {
            errorMessage = "無効なJWTフォーマットです"
        } catch JwtError.Base64Error(let message) {
            errorMessage = "Base64デコードエラー: \(message)"
        } catch JwtError.JsonError(let message) {
            errorMessage = "JSONパースエラー: \(message)"
        } catch {
            errorMessage = "予期せぬエラー: \(error.localizedDescription)"
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                VStack(alignment: .leading) {
                    Text("JWTを入力")
                        .font(.headline)
                    TextEditor(text: $jwtInput)
                        .font(.system(.body, design: .monospaced))
                        .frame(height: 150)
                        .padding(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .onChange(of: jwtInput) { _ in
                            decodeJWT()
                        }
                }
                
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.red.opacity(0.1))
                        )
                }
                
                if !decodedHeader.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Header")
                            .font(.headline)
                        Text(decodedHeader)
                            .font(.system(.body, design: .monospaced))
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue.opacity(0.1))
                                )
                    }
                     .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if !decodedPayload.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Payload")
                            .font(.headline)
                        Text(decodedPayload)
                            .font(.system(.body, design: .monospaced))
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.green.opacity(0.1))
                            )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                   
            }
        }
        .padding()
            
    }
}

#Preview {
    ContentView()
}
