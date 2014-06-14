inhibit_all_warnings!

def import_pods
  pod 'ReactiveNetworking', :path => '.'

  pod 'Expecta'
  pod 'OHHTTPStubs'
  pod 'Specta'
end

target :ios do
  platform :ios, '6.0'
  link_with 'ReactiveNetworking iOS Tests'
  import_pods
end

target :osx do
  platform :osx, '10.8'
  link_with 'ReactiveNetworking Mac Tests'
  import_pods
end
