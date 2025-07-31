# Adding Zettle SDK Files

This guide explains how to add the actual Zettle iOS SDK files to the plugin.

## Download the Zettle SDK

1. Sign up for a [Zettle Developer Account](https://developer.zettle.com/)
2. Download the latest Zettle iOS SDK from the developer portal
3. Extract the SDK package

## SDK Structure

The downloaded SDK should contain these files:
```
iZettleSDK-iOS/
├── iZettleSDK.xcframework/
├── iZettlePayments.xcframework/
├── PPRiskMagnes.xcframework/
├── iZettleSDK.xcframework.dSYM/
├── iZettlePayments.xcframework.dSYM/
└── PPRiskMagnes.xcframework.dSYM/
```

## Installation Steps

1. **Copy Framework Files:**
   Copy all `.xcframework` files to:
   ```
   ios/iZettleSDK/Frameworks/
   ```

2. **Copy Debug Symbol Files:**
   Copy all `.xcframework.dSYM` files to:
   ```
   ios/iZettleSDK/Frameworks/
   ```

3. **Verify Structure:**
   Your directory should look like:
   ```
   ios/iZettleSDK/Frameworks/
   ├── iZettleSDK.xcframework/
   ├── iZettlePayments.xcframework/
   ├── PPRiskMagnes.xcframework/
   ├── iZettleSDK.xcframework.dSYM/
   ├── iZettlePayments.xcframework.dSYM/
   └── PPRiskMagnes.xcframework.dSYM/
   ```

## Update iOS Implementation

After adding the SDK files:

1. **Update the Swift plugin file** (`ios/Classes/ZettlePaypalFlutterPlugin.swift`):
   - Uncomment the `import iZettleSDK` line
   - Replace mock implementations with actual SDK calls

2. **Test the integration**:
   ```bash
   cd example
   flutter clean
   flutter pub get
   cd ios
   pod install
   cd ..
   flutter run
   ```

## Framework Integration

The frameworks are automatically included in the plugin via the main podspec file (`zettle_paypal_flutter.podspec`) using `vendored_frameworks`. No additional CocoaPods configuration is required once the framework files are in place.

## Important Notes

- **File Size**: The SDK frameworks are large files (100+ MB total)
- **Git LFS**: Consider using Git LFS for the framework files
- **Licensing**: Ensure you comply with Zettle's licensing terms
- **Updates**: Keep track of SDK version updates from Zettle
- **Direct Integration**: Frameworks are included directly in the plugin podspec for simplicity

## Troubleshooting

### CocoaPods Issues
```bash
cd example/ios
pod deintegrate
pod install
```

### Build Issues
- Ensure all framework files are copied correctly
- Check that deployment target is iOS 12.0+
- Verify code signing settings

### Framework Not Found
- Check file paths in the podspec
- Ensure framework files aren't corrupted
- Verify framework architecture compatibility
