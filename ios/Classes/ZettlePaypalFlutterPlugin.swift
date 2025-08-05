import Flutter
import UIKit
import iZettleSDK

public class ZettlePaypalFlutterPlugin: NSObject, FlutterPlugin {

    // SDK initialization state
    private var isSDKInitialized = false
    private var sdkInitializationInProgress = false
    private var pendingOperations: [() -> Void] = []

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "zettle_paypal_flutter", binaryMessenger: registrar.messenger())
        let instance = ZettlePaypalFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)

        case "initialize":
            initialize(result: result)

        case "initializeSDK":
            guard let arguments = call.arguments as? [String: Any] else {
                result(
                    FlutterError(
                        code: "INVALID_PARAMETER", message: "Invalid arguments", details: nil))
                return
            }
            initializeSDK(arguments: arguments, result: result)

        case "isAuthenticated":
            isAuthenticated(result: result)

        case "authenticate":
            authenticate(result: result)

        case "logout":
            logout(result: result)

        case "chargeCard":
            guard let arguments = call.arguments as? [String: Any] else {
                result(
                    FlutterError(
                        code: "INVALID_PARAMETER", message: "Invalid arguments", details: nil))
                return
            }
            chargeCard(arguments: arguments, result: result)

        case "refund":
            guard let arguments = call.arguments as? [String: Any] else {
                result(
                    FlutterError(
                        code: "INVALID_PARAMETER", message: "Invalid arguments", details: nil))
                return
            }
            refund(arguments: arguments, result: result)

        case "isCardReaderConnected":
            isCardReaderConnected(result: result)

        case "showCardReaderSettings":
            showCardReaderSettings(result: result)

        case "getLastPayment":
            getLastPayment(result: result)

        case "showPaymentSettings":
            showPaymentSettings(result: result)

        case "showSettings":
            showSettings(result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - SDK Initialization

    private func initialize(result: @escaping FlutterResult) {
        print("ZettlePaypalFlutterPlugin: Initialize called - using lazy initialization approach")
        // With lazy initialization, we just acknowledge the initialize call
        // The actual SDK initialization will happen when authenticate() or other SDK operations are called
        result(nil)
    }

    private func initializeSDK(arguments: [String: Any], result: @escaping FlutterResult) {
        print("ZettlePaypalFlutterPlugin: Explicit SDK initialization called")

        // Extract parameters
        guard let clientId = arguments["clientId"] as? String,
            let callbackURL = arguments["callbackURL"] as? String
        else {
            result(
                FlutterError(
                    code: "INVALID_PARAMETER",
                    message: "Missing required parameters: clientId and callbackURL",
                    details: nil
                ))
            return
        }

        // If already initialized, return success
        if isSDKInitialized {
            print("ZettlePaypalFlutterPlugin: SDK already initialized")
            result(nil)
            return
        }

        // If initialization is already in progress, return error
        if sdkInitializationInProgress {
            print("ZettlePaypalFlutterPlugin: SDK initialization already in progress")
            result(
                FlutterError(
                    code: "INITIALIZATION_IN_PROGRESS",
                    message: "SDK initialization is already in progress",
                    details: nil
                ))
            return
        }

        print("ZettlePaypalFlutterPlugin: Starting explicit SDK initialization...")
        sdkInitializationInProgress = true

        do {
            print("ZettlePaypalFlutterPlugin: Creating authorization provider...")

            // Create authorization provider exactly like in AppDelegate.m
            print("ZettlePaypalFlutterPlugin: Using clientId: \(clientId)")
            print("ZettlePaypalFlutterPlugin: Using callbackURL: \(callbackURL)")

            // Try creating authorization provider with try-catch
            let authorizationProvider: iZettleSDKAuthorization
            do {
                authorizationProvider = try iZettleSDKAuthorization(
                    clientID: clientId,
                    callbackURL: URL(string: callbackURL)!,
                    enforcedUserAccount: nil
                )
            } catch {
                print(
                    "ZettlePaypalFlutterPlugin: Failed to create authorization provider: \(error)")
                sdkInitializationInProgress = false
                result(
                    FlutterError(
                        code: "AUTHORIZATION_PROVIDER_ERROR",
                        message:
                            "Failed to create authorization provider: \(error.localizedDescription)",
                        details: nil
                    ))
                return
            }

            print("ZettlePaypalFlutterPlugin: Authorization provider created successfully")

            // Start SDK exactly like in AppDelegate.m
            print("ZettlePaypalFlutterPlugin: Starting SDK...")
            iZettleSDK.shared().start(with: authorizationProvider)

            // Set enabled alternative payment methods like in AppDelegate.m
            iZettleSDK.shared().setEnabledAlternativePaymentMethods([
                NSNumber(value: IZSDKAlternativePaymentMethod.payPalQRC.rawValue),
                NSNumber(value: IZSDKAlternativePaymentMethod.manualCardEntry.rawValue),
            ])

            print("ZettlePaypalFlutterPlugin: SDK started successfully")

            isSDKInitialized = true
            sdkInitializationInProgress = false

            result(nil)

        } catch {
            print("ZettlePaypalFlutterPlugin: SDK initialization failed with error: \(error)")
            sdkInitializationInProgress = false
            result(
                FlutterError(
                    code: "SDK_INITIALIZATION_ERROR",
                    message: "Failed to initialize SDK: \(error.localizedDescription)",
                    details: nil
                ))
        }
    }

    private func ensureSDKInitialized(completion: @escaping (Bool, String?) -> Void) {
        // If already initialized, return immediately
        if isSDKInitialized {
            completion(true, nil)
            return
        }

        // If initialization is already in progress, add to pending operations
        if sdkInitializationInProgress {
            print(
                "ZettlePaypalFlutterPlugin: SDK initialization already in progress, queuing operation"
            )
            pendingOperations.append {
                completion(
                    self.isSDKInitialized, self.isSDKInitialized ? nil : "SDK initialization failed"
                )
            }
            return
        }

        print("ZettlePaypalFlutterPlugin: Starting lazy SDK initialization...")
        sdkInitializationInProgress = true

        // Try real SDK initialization with better error handling
        print("ZettlePaypalFlutterPlugin: Attempting real SDK initialization...")

        // Add a timeout to prevent hanging
        let timeoutTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            if self.sdkInitializationInProgress {
                print("ZettlePaypalFlutterPlugin: SDK initialization timed out after 5 seconds")
                DispatchQueue.main.async {
                    self.isSDKInitialized = false
                    self.sdkInitializationInProgress = false
                    completion(false, "SDK initialization timed out")

                    // Fail any pending operations
                    for pendingOperation in self.pendingOperations {
                        pendingOperation()
                    }
                    self.pendingOperations.removeAll()
                }
            }
        }

        // Perform initialization on a background queue
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                print("ZettlePaypalFlutterPlugin: Creating authorization provider...")

                // Initialize Zettle SDK with proper authorization provider
                // Note: Using default values for lazy initialization since parameters aren't available here
                // For explicit initialization, use initializeSDK() with custom parameters
                let authProvider = try iZettleSDKAuthorization(
                    clientID: "temp_add_client_id_from_portal",
                    callbackURL: URL(string: "myapp://oauth/callback")!,
                    enforcedUserAccount: { nil }()
                )

                print("ZettlePaypalFlutterPlugin: Authorization provider created successfully")

                // Switch back to main queue for SDK operations
                DispatchQueue.main.async {
                    timeoutTimer.invalidate()  // Cancel timeout

                    print("ZettlePaypalFlutterPlugin: Starting SDK with developer mode...")
                    // Start SDK with developer mode enabled for testing
                    iZettleSDK.shared().start(with: authProvider, enableDeveloperMode: true)
                    print("ZettlePaypalFlutterPlugin: SDK started successfully with developer mode")

                    self.isSDKInitialized = true
                    self.sdkInitializationInProgress = false

                    // Complete the current operation
                    completion(true, nil)

                    // Complete any pending operations
                    for pendingOperation in self.pendingOperations {
                        pendingOperation()
                    }
                    self.pendingOperations.removeAll()
                }

            } catch {
                print("ZettlePaypalFlutterPlugin: SDK initialization failed with error: \(error)")
                DispatchQueue.main.async {
                    timeoutTimer.invalidate()  // Cancel timeout

                    self.isSDKInitialized = false
                    self.sdkInitializationInProgress = false

                    let errorMessage =
                        "Failed to initialize Zettle SDK: \(error.localizedDescription)"
                    completion(false, errorMessage)

                    // Fail any pending operations
                    for pendingOperation in self.pendingOperations {
                        pendingOperation()
                    }
                    self.pendingOperations.removeAll()
                }
            }
        }

        // TODO: Re-enable actual SDK initialization when we solve the hanging issue
        /*
        // Add a timeout to prevent hanging
        let timeoutTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { _ in
            if self.sdkInitializationInProgress {
                print("ZettlePaypalFlutterPlugin: SDK initialization timed out")
                DispatchQueue.main.async {
                    self.isSDKInitialized = false
                    self.sdkInitializationInProgress = false
                    completion(false, "SDK initialization timed out")
        
                    // Fail any pending operations
                    for pendingOperation in self.pendingOperations {
                        pendingOperation()
                    }
                    self.pendingOperations.removeAll()
                }
            }
        }
        
        // Perform initialization on a background queue
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                print("ZettlePaypalFlutterPlugin: Creating authorization provider...")
        
                // Initialize Zettle SDK with proper authorization provider
                let authProvider = try iZettleSDKAuthorization(
                    clientID: "temp_add_client_id_from_portal",
                    callbackURL: URL(string: "myapp://oauth/callback")!,
                    enforcedUserAccount: { nil }()
                )
        
                print("ZettlePaypalFlutterPlugin: Authorization provider created successfully")
        
                // Switch back to main queue for SDK operations
                DispatchQueue.main.async {
                    timeoutTimer.invalidate()  // Cancel timeout
        
                    print("ZettlePaypalFlutterPlugin: Starting SDK with developer mode...")
                    // Start SDK with developer mode enabled for testing
                    iZettleSDK.shared().start(with: authProvider, enableDeveloperMode: true)
                    print("ZettlePaypalFlutterPlugin: SDK started successfully with developer mode")
        
                    self.isSDKInitialized = true
                    self.sdkInitializationInProgress = false
        
                    // Complete the current operation
                    completion(true, nil)
        
                    // Complete any pending operations
                    for pendingOperation in self.pendingOperations {
                        pendingOperation()
                    }
                    self.pendingOperations.removeAll()
                }
        
            } catch {
                print("ZettlePaypalFlutterPlugin: SDK initialization failed with error: \(error)")
                DispatchQueue.main.async {
                    timeoutTimer.invalidate()  // Cancel timeout
        
                    self.isSDKInitialized = false
                    self.sdkInitializationInProgress = false
        
                    let errorMessage =
                        "Failed to initialize Zettle SDK: \(error.localizedDescription)"
                    completion(false, errorMessage)
        
                    // Fail any pending operations
                    for pendingOperation in self.pendingOperations {
                        pendingOperation()
                    }
                    self.pendingOperations.removeAll()
                }
            }
        }
        */
    }  // MARK: - Authentication

    private func isAuthenticated(result: @escaping FlutterResult) {
        print("ZettlePaypalFlutterPlugin: isAuthenticated called")

        // If SDK is not initialized, we know the user is not authenticated
        if !isSDKInitialized {
            print("ZettlePaypalFlutterPlugin: SDK not initialized, returning false")
            result(false)
            return
        }

        // Check Zettle SDK authentication status using the correct property
        let authenticated = iZettleSDK.shared().isLoggedIn
        print("ZettlePaypalFlutterPlugin: SDK authentication status: \(authenticated)")
        result(authenticated)
    }

    private func authenticate(result: @escaping FlutterResult) {
        print("ZettlePaypalFlutterPlugin: authenticate called")

        // Ensure SDK is initialized before attempting authentication
        ensureSDKInitialized { [weak self] success, errorMessage in
            guard let self = self else { return }

            if !success {
                result(
                    FlutterError(
                        code: "INITIALIZATION_FAILED",
                        message: errorMessage ?? "Failed to initialize SDK",
                        details: nil
                    ))
                return
            }

            print("ZettlePaypalFlutterPlugin: SDK initialized, starting authentication")

            // Use the Zettle SDK authentication method from the actual SDK header
            print("ZettlePaypalFlutterPlugin: Calling performLoginWithCompletion...")

            var authCompleted = false

            // Add timeout for authentication
            let authTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { _ in
                if !authCompleted {
                    print("ZettlePaypalFlutterPlugin: Authentication timed out")
                    authCompleted = true
                    result(
                        FlutterError(
                            code: "AUTHENTICATION_TIMEOUT",
                            message: "Authentication timed out after 30 seconds",
                            details: nil
                        ))
                }
            }

            // Perform Zettle SDK authentication using the method that requires a view controller
            guard let viewController = UIApplication.shared.windows.first?.rootViewController else {
                authTimer.invalidate()
                authCompleted = true
                result(
                    FlutterError(
                        code: "NO_VIEW_CONTROLLER",
                        message: "Could not find root view controller",
                        details: nil
                    ))
                return
            }

            iZettleSDK.shared().performLogin(from: viewController) { error in
                authTimer.invalidate()  // Cancel timeout

                guard !authCompleted else { return }  // Prevent double completion
                authCompleted = true

                DispatchQueue.main.async {
                    if let error = error {
                        print(
                            "ZettlePaypalFlutterPlugin: Authentication failed: \(error.localizedDescription)"
                        )
                        result(
                            FlutterError(
                                code: "AUTHENTICATION_FAILED",
                                message: error.localizedDescription,
                                details: nil
                            ))
                    } else {
                        print("ZettlePaypalFlutterPlugin: Authentication successful")
                        result(nil)
                    }
                }
            }

        }
    }

    private func logout(result: @escaping FlutterResult) {
        print("ZettlePaypalFlutterPlugin: logout called")

        // If SDK is not initialized, there's nothing to logout from
        if !isSDKInitialized {
            print("ZettlePaypalFlutterPlugin: SDK not initialized, nothing to logout")
            result(nil)
            return
        }

        // Logout from Zettle SDK
        iZettleSDK.shared().logout()
        print("ZettlePaypalFlutterPlugin: Logout successful")
        result(nil)
    }

    // MARK: - Payment Processing

    private func chargeCard(arguments: [String: Any], result: @escaping FlutterResult) {
        guard let amountData = arguments["amount"] as? [String: Any],
            let amount = amountData["amount"] as? Double,
            let currencyCode = amountData["currencyCode"] as? String
        else {
            result(
                FlutterError(
                    code: "INVALID_PARAMETER", message: "Invalid amount or currency", details: nil))
            return
        }

        let reference = arguments["reference"] as? String
        let enableTipping = arguments["enableTipping"] as? Bool ?? false
        let iZettleAmount = NSDecimalNumber(value: amount)

        guard let viewController = UIApplication.shared.windows.first?.rootViewController else {
            result(
                FlutterError(
                    code: "NO_VIEW_CONTROLLER", message: "Could not find root view controller",
                    details: nil))
            return
        }

        iZettleSDK.shared().charge(
            amount: iZettleAmount, enableTipping: enableTipping, reference: reference,
            presentFrom: viewController
        ) { [weak self] (paymentInfo, error) in
            DispatchQueue.main.async {
                if let error = error {
                    if (error.localizedDescription == "Payment canceled / Canceled by user"){
                        result(FlutterError(code: "PAYMENT_CANCELLED", message: "Payment was cancelled", details: nil))
                    }
                    else {
                        print(
                            "ZettlePaypalFlutterPlugin: Payment failed: \(error.localizedDescription)")
                        result(
                            FlutterError(
                                code: "PAYMENT_FAILED", message: error.localizedDescription,
                                details: nil))
                    }
                } else if let paymentInfo = paymentInfo {
                    guard let self = self else {
                        result(
                            FlutterError(
                                code: "INTERNAL_ERROR", message: "Plugin instance was deallocated",
                                details: nil))
                        return
                    }

                    // print(
                    //     "ZettlePaypalFlutterPlugin: Payment successful - Payment info: \(paymentInfo)"
                    // )
                    let paymentResult = self.createPaymentResultDictionary(from: paymentInfo)
                    // print("ZettlePaypalFlutterPlugin: Payment result: \(paymentResult)")
                    result(paymentResult)
                } else {
                    result(
                        FlutterError(
                            code: "PAYMENT_FAILED", message: "No payment information received",
                            details: nil))
                }
            }
        }
    }

    private func refund(arguments: [String: Any], result: @escaping FlutterResult) {
        guard let amountData = arguments["amount"] as? [String: Any],
            let amount = amountData["amount"] as? Double,
            let currencyCode = amountData["currencyCode"] as? String
        else {
            result(
                FlutterError(
                    code: "INVALID_PARAMETER", message: "Invalid amount or currency", details: nil))
            return
        }

        let reference = arguments["reference"] as? String
        let receiptId = arguments["receiptId"] as? String

        // TODO: Integrate with actual Zettle SDK refund
        // Similar implementation to chargeCard but for refunds

        // For now, simulate a successful refund
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let mockRefundResult =
                [
                    "amount": [
                        "amount": amount,
                        "currencyCode": currencyCode,
                    ],
                    "reference": reference ?? "REFUND_REF_" + UUID().uuidString.prefix(8),
                    "receiptId": receiptId ?? "REFUND_RECEIPT_" + UUID().uuidString.prefix(8),
                ] as [String: Any]

            result(mockRefundResult)
        }
    }

    // MARK: - Card Reader Management

    private func isCardReaderConnected(result: @escaping FlutterResult) {
        // TODO: Check card reader connection status
        // let connected = iZettleSDK.shared().isCardReaderConnected()

        // For now, simulate connection status
        result(true)  // Change to actual check when SDK is integrated
    }

    private func showCardReaderSettings(result: @escaping FlutterResult) {
        // TODO: Show card reader settings
        // guard let viewController = UIApplication.shared.windows.first?.rootViewController else {
        //     result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "Could not find root view controller", details: nil))
        //     return
        // }

        // iZettleSDK.shared().presentCardReaderSettings(from: viewController)

        // For now, simulate showing settings
        result(nil)
    }

    // MARK: - Payment Information

    private func getLastPayment(result: @escaping FlutterResult) {
        // TODO: Get last payment from Zettle SDK
        // let lastPayment = iZettleSDK.shared().lastPayment()

        // For now, return nil (no last payment)
        result(nil)
    }

    private func showPaymentSettings(result: @escaping FlutterResult) {
        print("ZettlePaypalFlutterPlugin: showPaymentSettings called")

        DispatchQueue.main.async {
            guard let viewController = UIApplication.shared.windows.first?.rootViewController else {
                result(
                    FlutterError(
                        code: "NO_VIEW_CONTROLLER", message: "Could not find root view controller",
                        details: nil))
                return
            }

            do {
                print("ZettlePaypalFlutterPlugin: Presenting Zettle settings")
                iZettleSDK.shared().presentSettings(from: viewController)
                result(nil)
            } catch {
                print("ZettlePaypalFlutterPlugin: Error presenting settings: \(error)")
                result(
                    FlutterError(
                        code: "SETTINGS_ERROR",
                        message: "Failed to present settings: \(error.localizedDescription)",
                        details: nil
                    ))
            }
        }
    }

    private func showSettings(result: @escaping FlutterResult) {
        print("ZettlePaypalFlutterPlugin: showSettings called")

        DispatchQueue.main.async {
            guard let viewController = UIApplication.shared.windows.first?.rootViewController else {
                result(
                    FlutterError(
                        code: "NO_VIEW_CONTROLLER", message: "Could not find root view controller",
                        details: nil))
                return
            }

            do {
                print("ZettlePaypalFlutterPlugin: Presenting Zettle SDK settings")
                iZettleSDK.shared().presentSettings(from: viewController)
                result(nil)
            } catch {
                print("ZettlePaypalFlutterPlugin: Error presenting SDK settings: \(error)")
                result(
                    FlutterError(
                        code: "SETTINGS_ERROR",
                        message: "Failed to present SDK settings: \(error.localizedDescription)",
                        details: nil
                    ))
            }
        }
    }

    // MARK: - Helper Methods

    private func createPaymentResultDictionary(from paymentInfo: iZettleSDKPaymentInfo) -> [String:
        Any]
    {
        var result: [String: Any] = [:]

        // Required amount field with proper structure (separate from other fields)
        result["amount"] = [
            "amount": paymentInfo.amount.doubleValue,
            "currencyCode": "USD",  // TODO: Get actual currency from payment info when available
        ]

        // Map the payment fields correctly using the actual property names from iZettleSDKPaymentInfo
        result["authorizationCode"] = paymentInfo.authorizationCode
        result["obfuscatedPan"] = paymentInfo.obfuscatedPan
        result["panHash"] = paymentInfo.panHash
        result["cardBrand"] = paymentInfo.cardBrand
        result["entryMode"] = paymentInfo.entryMode
        result["reference"] = paymentInfo.referenceNumber
        result["receiptId"] = paymentInfo.transactionId

        // Optional fields - only include if not nil
        if let applicationName = paymentInfo.applicationName {
            result["aidName"] = applicationName
        }

        if let aid = paymentInfo.aid {
            result["applicationIdentifier"] = aid
        }

        // Add gratuity amount if available
        if let gratuityAmount = paymentInfo.gratuityAmount {
            result["gratuityAmount"] = [
                "amount": gratuityAmount.doubleValue,
                "currencyCode": "USD",  // TODO: Get actual currency
            ]
        }

        return result
    }
}
