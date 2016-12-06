use_frameworks!

target 'GroupFinance' do
    pod 'Sync', '~> 1'
    pod 'FBSDKCoreKit', '~> 4'
    pod 'FBSDKLoginKit', '~> 4'
    pod 'AFNetworking', '~> 3.1'
    pod 'MJRefresh', '~> 3.1'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '2.3'
        end
    end
end
