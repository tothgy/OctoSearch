platform :ios, '12.0'
use_frameworks!
inhibit_all_warnings!

target 'OctoSearch' do
  pod 'RxSwift'
  pod 'RxSwiftExt'
  pod 'Moya/RxSwift'
  pod 'RxFlow'
  pod 'SwiftLint'
  pod 'SwiftGen'
  pod 'Swinject', '2.6.0'
  pod 'SwinjectStoryboard', '2.2.0'
  pod 'CocoaLumberjack/Swift'
end

target 'OctoSearchTests' do
  inherit! :search_paths
  pod 'RxFlow'
  pod 'Swinject', '2.6.0'
  pod 'SwinjectStoryboard', '2.2.0'
  pod 'Moya/RxSwift'
  pod 'Nimble'
  pod 'Quick'
  pod 'RxTest'
  pod 'ViewControllerPresentationSpy', '~> 5.0'
end

# Disable Code Coverage for Pods projects
post_install do |installer_representation|
  installer_representation.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
      config.build_settings['EXCLUDED_ARCHS[sdk=watchsimulator*]'] = 'arm64'
      config.build_settings['EXCLUDED_ARCHS[sdk=appletvsimulator*]'] = 'arm64'

      config.build_settings['CLANG_ENABLE_CODE_COVERAGE'] = 'NO'
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 12.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
      if config.name == 'Debug'
        config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Onone']
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
      end
    end
  end
end
