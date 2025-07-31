# Zettle SDK Integration Guide

This guide provides step-by-step instructions for integrating the actual Zettle iOS SDK with this Flutter plugin.

## Prerequisites

1. **Zettle Developer Account**: Sign up at [Zettle Developer Portal](https://developer.zettle.com/)
2. **iOS SDK Download**: Download the latest Zettle iOS SDK from the developer portal
3. **API Credentials**: Obtain your Client ID and other necessary credentials

## Step 1: Add Zettle SDK to iOS Project

### Option 1: Manual Integration (Recommended)

1. Download the Zettle iOS SDK package from the developer portal
2. Extract the following frameworks:
   - `iZettleSDK.xcframework`
   - `iZettlePayments.xcframework`
   - `PPRiskMagnes.xcframework`

3. Add these frameworks to your iOS project:
   ```
   ios/
   ├── Frameworks/
   │   ├── iZettleSDK.xcframework
   │   ├── iZettlePayments.xcframework
   │   └── PPRiskMagnes.xcframework
   ```

4. Update the `ios/zettle_paypal_flutter.podspec` file:
   ```ruby
   s.vendored_frameworks = 'Frameworks/iZettleSDK.xcframework', 'Frameworks/iZettlePayments.xcframework', 'Frameworks/PPRiskMagnes.xcframework'
   ```

### Option 2: Swift Package Manager

Add the Zettle SDK as a dependency in your `Package.swift` or through Xcode:

```swift
dependencies: [
    .package(url: "https://github.com/iZettle/sdk-ios", from: "3.0.0")
]
```

## Step 2: Update iOS Implementation

Replace the mock implementation in `ios/Classes/ZettlePaypalFlutterPlugin.swift`:

### 1. Import the SDK

```swift
import Flutter
import UIKit
import iZettleSDK // Add this import
```

### 2. Initialize the SDK

Replace the `initialize` method:

```swift
private func initialize(result: @escaping FlutterResult) {
    // Replace with your actual Client ID
    let clientID = "YOUR_CLIENT_ID_HERE"
    
    iZettleSDK.shared().start(with: iZettleSDKAuthorizationProviderPublicKey(clientID: clientID))
    result(nil)
}
```

### 3. Implement Authentication

```swift
private func isAuthenticated(result: @escaping FlutterResult) {
    let authenticated = iZettleSDK.shared().isAuthorized()
    result(authenticated)
}

private func authenticate(result: @escaping FlutterResult) {
    guard let viewController = UIApplication.shared.windows.first?.rootViewController else {
        result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "Could not find root view controller", details: nil))
        return
    }
    
    iZettleSDK.shared().authorizeAccount(from: viewController) { (account, error) in
        DispatchQueue.main.async {
            if let error = error {
                result(FlutterError(code: "AUTHENTICATION_FAILED", message: error.localizedDescription, details: nil))
            } else {
                result(nil)
            }
        }
    }
}

private func logout(result: @escaping FlutterResult) {
    iZettleSDK.shared().logout()
    result(nil)
}
```

### 4. Implement Payment Processing

```swift
private func chargeCard(arguments: [String: Any], result: @escaping FlutterResult) {
    guard let amountData = arguments["amount"] as? [String: Any],
          let amount = amountData["amount"] as? Double,
          let currencyCode = amountData["currencyCode"] as? String,
          let currencyID = iZettleSDKCurrencyID(rawValue: currencyCode) else {
        result(FlutterError(code: "INVALID_PARAMETER", message: "Invalid amount or currency", details: nil))
        return
    }
    
    let reference = arguments["reference"] as? String
    let enableTipping = arguments["enableTipping"] as? Bool ?? false
    
    let iZettleAmount = iZettleSDKAmount(amount: NSDecimalNumber(value: amount), currencyID: currencyID)
    
    guard let viewController = UIApplication.shared.windows.first?.rootViewController else {
        result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "Could not find root view controller", details: nil))
        return
    }
    
    iZettleSDK.shared().charge(
        amount: iZettleAmount,
        enableTipping: enableTipping,
        reference: reference ?? UUID().uuidString,
        presentFrom: viewController
    ) { (paymentInfo, error) in
        DispatchQueue.main.async {
            if let error = error {
                if error.code == iZettleSDKErrorCode.userCancel.rawValue {
                    result(FlutterError(code: "PAYMENT_CANCELLED", message: "Payment was cancelled", details: nil))
                } else {
                    result(FlutterError(code: "PAYMENT_FAILED", message: error.localizedDescription, details: nil))
                }
            } else if let paymentInfo = paymentInfo {
                let paymentResult = self.createPaymentResultDictionary(from: paymentInfo)
                result(paymentResult)
            }
        }
    }
}
```

### 5. Add Helper Methods

```swift
private func createPaymentResultDictionary(from paymentInfo: iZettleSDKPaymentInfo) -> [String: Any] {
    var result: [String: Any] = [
        "amount": [
            "amount": paymentInfo.amount.amount.doubleValue,
            "currencyCode": paymentInfo.amount.currencyID.rawValue
        ],
        "reference": paymentInfo.reference
    ]
    
    if let gratuityAmount = paymentInfo.gratuityAmount {
        result["gratuityAmount"] = [
            "amount": gratuityAmount.amount.doubleValue,
            "currencyCode": gratuityAmount.currencyID.rawValue
        ]
    }
    
    if let entryMode = paymentInfo.entryMode {
        result["entryMode"] = entryMode.rawValue
    }
    
    if let authCode = paymentInfo.authorizationCode {
        result["authorizationCode"] = authCode
    }
    
    if let pan = paymentInfo.obfuscatedPan {
        result["obfuscatedPan"] = pan
    }
    
    if let panHash = paymentInfo.panHash {
        result["panHash"] = panHash
    }
    
    if let cardBrand = paymentInfo.cardBrand {
        result["cardBrand"] = cardBrand
    }
    
    if let aidName = paymentInfo.aidName {
        result["aidName"] = aidName
    }
    
    if let appId = paymentInfo.applicationIdentifier {
        result["applicationIdentifier"] = appId
    }
    
    return result
}
```

## Step 3: Configure Info.plist

Ensure your `example/ios/Runner/Info.plist` includes all required permissions and settings:

```xml
<!-- Bluetooth permissions -->
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app uses bluetooth to connect with Zettle card readers for payment processing.</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app uses bluetooth to connect with Zettle card readers for payment processing.</string>

<!-- Location permissions -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location access is required for payment processing compliance.</string>

<!-- Background modes -->
<key>UIBackgroundModes</key>
<array>
    <string>bluetooth-central</string>
    <string>external-accessory</string>
</array>

<!-- External accessory protocol -->
<key>UISupportedExternalAccessoryProtocols</key>
<array>
    <string>com.izettle.cardreader-one</string>
</array>

<!-- URL scheme for OAuth -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.yourcompany.yourapp</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>your-app-scheme</string>
        </array>
    </dict>
</array>
```

## Step 4: Environment Configuration

### Development Environment
- Use sandbox credentials for testing
- Test with Zettle test card readers or simulated readers
- Use test merchant accounts

### Production Environment
- Use live credentials from Zettle
- Test with actual Zettle card readers
- Ensure compliance with payment regulations

## Step 5: Testing

1. **Unit Tests**: Ensure all Dart tests pass
2. **Integration Tests**: Test with actual Zettle SDK
3. **Device Testing**: Test on physical iOS devices with card readers
4. **Payment Flow Testing**: Test complete payment workflows

## Common Issues and Solutions

### Issue: SDK Not Found
**Solution**: Ensure frameworks are properly linked and imported

### Issue: Authentication Fails
**Solution**: Verify Client ID and OAuth configuration

### Issue: Card Reader Not Connecting
**Solution**: Check Bluetooth permissions and external accessory protocols

### Issue: Payment Fails
**Solution**: Verify merchant account status and payment limits

## Additional Resources

- [Zettle iOS SDK Documentation](https://developer.zettle.com/docs/payment-integrations/ios-sdk)
- [Zettle Developer Portal](https://developer.zettle.com/)
- [iOS Integration Guide](https://developer.zettle.com/docs/payment-integrations/ios-sdk/ios-sdk-integration)
- [API Reference](https://developer.zettle.com/docs/api-reference)

## Support

For technical support:
- [Zettle Developer Support](https://ext-izettle.atlassian.net/servicedesk/customer/portal/3)
- [Plugin Issues](https://github.com/libertytechstacks/zettle-paypal-flutter/issues)
