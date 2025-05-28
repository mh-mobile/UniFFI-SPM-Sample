# UniFFI Mobile Library

iOS/macOS向けのRustライブラリで、UniFFIを使用してSwiftバインディングを生成します。

## 機能

- **Calculator**: スレッドセーフな計算機能（Arc<Mutex>パターン）
- **JWT Decoder**: エラーハンドリング付きのJWTデコード機能
- **Cross-platform**: iOS、iOS Simulator、macOS対応

## 必要環境

- Rust (cargo)
- Xcode
- Swift 5.9以上

## ビルド方法

```bash
./build-ios.sh
```

このスクリプトは以下を実行します：
1. Rustライブラリをリリースモードでビルド
2. UniFFIを使用してSwiftバインディングを生成
3. 全Appleプラットフォーム向けにビルド
4. XCFrameworkを作成

## プロジェクト構造

```
├── src/                    # Rustソースコード
│   └── lib.rs             # メインライブラリ
├── ios/                   # iOS固有のファイル
│   ├── src/Mobile/        # Swift wrapper (自動生成)
│   ├── build/             # XCFramework出力
│   └── examples/          # 使用例
│       ├── HelloWorldSample/    # SwiftUI + ObservableObject
│       ├── JwtViewerSample/     # エラーハンドリング例
│       └── SwiftCLI/            # CLIツール例
└── build-ios.sh           # ビルドスクリプト
```

## 使用例

### Swift
```swift
import Mobile

// Calculator
let calc = Calculator()
let result = try calc.add(a: 10, b: 20)

// JWT Decoder
let jwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
let decoded = try decodeJwt(jwt: jwt)
```

## 開発者向け

詳細な開発ガイドラインは[CLAUDE.md](CLAUDE.md)を参照してください。