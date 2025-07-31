#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint zettle_paypal_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'zettle_paypal_flutter'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for Zettle (PayPal) iOS SDK integration.'
  s.description      = <<-DESC
Flutter plugin for Zettle (PayPal) iOS SDK integration, enabling payment processing and card reader functionality.
This plugin provides a Dart API wrapper around the native Zettle iOS SDK.
                       DESC
  s.homepage         = 'https://github.com/nneuberger1/zettle-paypal-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Liberty Tech Stacks' => 'nick.neuberger@libertytechstacks.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # Add Zettle SDK as local dependency
  # Note: You'll need to add the Zettle SDK frameworks to your iOS project
  # or include them as a dependency. For now, we'll prepare for local integration.
  
  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'zettle_paypal_flutter_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
