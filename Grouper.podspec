Pod::Spec.new do |s|
	s.name         = "Grouper"
	s.version      = "0.1"
	s.summary      = "A framework for Developing iOS app using Secret Sharing and untrusted servers."

	s.description  = <<-DESC
	# Features
    - A framework for Developing iOS app using Secret Sharing and untrusted servers.
	DESC

	s.homepage     = "https://github.com/lm2343635/Grouper"
	s.license      = { :type => "MIT", :file => "LICENSE" }
	s.author             = { "Meng Li" => "lm2343635@126.com" }
	s.social_media_url   = "http://fczm.pw"

	s.platform     = :ios
	s.source       = { :git => "", :tag => "0.1" }

	s.source_files  = "Core/*.{h,m,swift}"

	s.requires_arc = true

    s.dependency 'Sync', '~> 3'
    s.dependency 'BRYXBanner', '~> 0.7'
    s.dependency 'AFNetworking', '~> 3.1'

end
