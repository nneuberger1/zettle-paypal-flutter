<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Zettle PayPal Flutter Plugin

This is a Flutter plugin that wraps the Zettle (PayPal) iOS SDK for payment processing. 

## Project Structure
- This is a federated Flutter plugin with iOS platform implementation only
- The plugin wraps the native Zettle iOS SDK (iZettleSDK.xcframework)
- Dart API should mirror the native iOS SDK functionality
- Focus on payment processing, card reader connectivity, and transaction management

## Key Guidelines
- Use proper Flutter plugin architecture with MethodChannel for iOS communication
- Implement comprehensive error handling for payment scenarios
- Follow Dart/Flutter naming conventions (snake_case for files, camelCase for variables)
- Include proper documentation for all public APIs
- Write unit tests for Dart code and integration tests for platform functionality
- Handle iOS-specific permissions (Bluetooth, Location) required for card readers

## Payment Flow Considerations
- Authentication with Zettle services
- Card reader pairing and connectivity
- Payment processing with proper callbacks
- Receipt handling and transaction records
- Error scenarios and user feedback

## Dependencies
- The iOS implementation depends on iZettleSDK, iZettlePayments, and PPRiskMagnes frameworks
- Example app should demonstrate real payment scenarios
