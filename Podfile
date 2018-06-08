source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '11.0'

use_frameworks!
inhibit_all_warnings!

project 'Heartbeat.xcodeproj'

target 'Heartbeat' do
  pod 'AlamofireImage', '~> 3.3'
  pod 'Crashlytics', '~> 3.9'
  pod 'Fabric', '~> 1.7'

  # pod 'Fritz', '~> 1.0.0-beta.13'
  pod 'Fritz', :git => "https://github.com/fritzlabs/swift-sdk.git", :branch => 'new-xcode-sdks'
  pod 'FritzSDK', :path => '../swift-sdk'
  pod 'FritzSDK/FritzVisionModel', :path => '../swift-sdk'
  pod 'R.swift', '~> 4.0'
  pod 'Firebase/Core'
  pod 'Firebase/MLVision'
  pod 'Firebase/MLVisionLabelModel'
end
