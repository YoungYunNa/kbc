# Uncomment the next line to define a global platform for your project

platform :ios, '11.0'
install! 'cocoapods', :deterministic_uuids => false

target 'LiivMate' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for LiivMate
  pod 'Firebase/Analytics'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/RemoteConfig'
  pod 'GoogleIDFASupport'
  pod 'Firebase/Crashlytics', '=6.34.0'

# GoogleAnalytics
  pod 'GoogleAnalytics', '=3.17.0'

# Buzzvil
  pod 'BuzzAdBenefit', '=2.1.12'

# touchad
  pod 'Alamofire', '~> 4.8.2'
  pod 'JWTDecode', '~> 2.4'
  pod 'SnapKit', '~> 4.0.0'
  pod 'ObjectMapper'
    
# Pod Build install 9.0 Target
post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
        config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
        config.build_settings['ARCHS'] = '$(ARCHS_STANDARD)'
      end
    end
  end

end
