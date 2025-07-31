# iZettleSDK Frameworks

This directory should contain the following Zettle SDK frameworks:

## Required Frameworks
- `iZettleSDK.xcframework/`
- `iZettlePayments.xcframework/`
- `PPRiskMagnes.xcframework/`

## Required Debug Symbols (dSYM files)
- `iZettleSDK.xcframework.dSYM/`
- `iZettlePayments.xcframework.dSYM/`
- `PPRiskMagnes.xcframework.dSYM/`

## To Add the SDK Files

1. Download the Zettle iOS SDK from the [Zettle Developer Portal](https://developer.zettle.com/)
2. Extract the SDK package
3. Copy the `.xcframework` files to this directory
4. Copy the `.xcframework.dSYM` files to this directory
5. Run `flutter clean && flutter pub get` from the project root
6. Run `cd example/ios && pod install` to update CocoaPods dependencies

## Directory Structure
```
Frameworks/
├── iZettleSDK.xcframework/
├── iZettlePayments.xcframework/
├── PPRiskMagnes.xcframework/
├── iZettleSDK.xcframework.dSYM/
├── iZettlePayments.xcframework.dSYM/
└── PPRiskMagnes.xcframework.dSYM/
```

Once these files are added, the plugin will automatically include them via `vendored_frameworks` in the main podspec.
