Pod::Spec.new do |s|
  s.name     = 'ReactiveNetworking'
  s.version  = '1.0.0'
  s.license  = 'MIT'
  s.summary  = 'Mixes the great AFNetworking with ReactiveCocoa.'
  s.homepage = 'https://github.com/plu/ReactiveNetworking'
  s.authors  = { 'Johannes Plunien' => 'plu@pqpq.de' }
  s.source   = { :git => 'https://github.com/plu/ReactiveNetworking.git', :tag => s.version.to_s, :submodules => true }
  s.requires_arc = true

  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.8'

  s.source_files = 'ReactiveNetworking/*.{h,m}'

  s.dependency 'AFNetworking', '~> 1.0'
  s.dependency 'Mantle', '~> 1.0'
  s.dependency 'ReactiveCocoa', '~> 2.0'
  s.dependency 'ReactiveCocoa/UI', '~> 2.0'
end
