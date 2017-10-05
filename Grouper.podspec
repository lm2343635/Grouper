#
# Be sure to run `pod lib lint Grouper.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
	s.name         = "Grouper"
	s.version      = "1.2.3"
	s.summary      = "A framework for Developing iOS app using Secret Sharing and untrusted servers."

	s.description  = <<-DESC
	# Features
	- Easy Group Management.
	- Protected Data Synchronization. 
	DESC

	s.homepage     = "https://github.com/lm2343635/Grouper"
	s.license      = { :type => "MIT", :file => "LICENSE" }
	s.author             = { "Meng Li" => "lm2343635@126.com" }
	s.social_media_url   = "http://fczm.pw"

	s.platform     = :ios
	s.ios.deployment_target = '9.0'
	s.source       = { :git => "https://github.com/lm2343635/Grouper.git", :tag => s.version.to_s }

	s.source_files  = "Core/**/*.{h,m,c,swift}"
	s.resource_bundles = {
		'Grouper' => ['Core/**/*.{storyboard,xib,xcassets}']
	}
	s.requires_arc = true

	s.dependency 'Sync', '~> 4'
	s.dependency 'AFNetworking', '~> 3'
end
