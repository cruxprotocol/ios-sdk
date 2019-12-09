#
# Be sure to run `pod lib lint CruxPay.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CruxPay'
  s.version          = '0.0.1'
  s.summary          = 'CruxPay iOS SDK'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'CruxPay is a protocol which aims to link any blockchain address to a human-readable name, and let users interact with each other and dApps with ease.'

  s.homepage         = 'https://github.com/cruxprotocol/ios-sdk'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'GPL-3.0', :file => 'LICENSE' }
  s.author           = { 'CoinSwitch' => 'dev@coinswitch.co' }
  s.source           = { :git => 'https://github.com/cruxprotocol/ios-sdk.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/cruxpay'

  s.ios.deployment_target = '10.0'

  s.source_files = 'CruxPay/Classes/**/*'
  
  s.resource_bundles = {
    'CruxPay' => ['CruxPay/Assets/*.js']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'CryptoSwift', '0.15.0'
end
