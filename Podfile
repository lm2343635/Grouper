use_frameworks!

target 'GroupFinance' do
    pod 'Sync', '~> 3'
    pod 'FBSDKCoreKit', '~> 4'
    pod 'FBSDKLoginKit', '~> 4'
    pod 'AFNetworking', '~> 3.1'
    pod 'MJRefresh', '~> 3.1'
    pod 'UIImageView+Extension', '~> 0.2'
    pod 'M80AttributedLabel', '~> 1.6'
    pod 'UILabel+Copyable', '~> 1.0'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.1'
        end
    end
end
