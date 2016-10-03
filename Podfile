use_frameworks!

pod 'Sync', '~> 1'
pod 'FBSDKCoreKit', '~> 4.13'
pod 'FBSDKLoginKit', '~> 4.13'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '2.3'
        end
    end
end
