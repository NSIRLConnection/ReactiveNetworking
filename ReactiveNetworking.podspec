Pod::Spec.new do |s|
  s.name     = 'ReactiveNetworking'
  s.version  = '1.3.4'
  s.license  = 'MIT'
  s.summary  = 'Mixes the great AFNetworking with ReactiveCocoa.'
  s.homepage = 'https://github.com/plu/ReactiveNetworking'
  s.authors  = { 'Johannes Plunien' => 'plu@pqpq.de' }
  s.social_media_url = 'https://twitter.com/plutooth'
  s.source   = { :git => 'https://github.com/plu/ReactiveNetworking.git', :tag => s.version.to_s, :submodules => true }
  s.requires_arc = true

  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.8'

  s.default_subspec = 'Core'

  s.subspec 'Core' do |cs|
    cs.source_files = 'ReactiveNetworking/*.{h,m}'
    cs.dependency "#{s.name}/Dependencies"
  end

  s.subspec 'Dependencies' do |ds|
    ds.dependency 'AFNetworking', '~> 1.0'
    ds.dependency 'Mantle', '~> 1.0'
    ds.dependency 'ReactiveCocoa', '~> 2.0'
    ds.dependency 'ReactiveCocoa/UI', '~> 2.0'
  end

  s.subspec 'Testing' do |ts|
    ts.dependency 'Expecta', '~> 0.3'
    ts.dependency 'OHHTTPStubs', '~> 3.1'
    ts.dependency 'Specta', '~> 0.2'
  end

  s.prefix_header_contents = <<-EOS
#if __IPHONE_OS_VERSION_MIN_REQUIRED
  #import <SystemConfiguration/SystemConfiguration.h>
  #import <MobileCoreServices/MobileCoreServices.h>
  #import <Security/Security.h>
#else
  #import <SystemConfiguration/SystemConfiguration.h>
  #import <CoreServices/CoreServices.h>
  #import <Security/Security.h>
#endif
EOS

end
