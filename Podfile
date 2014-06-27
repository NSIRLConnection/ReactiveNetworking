def import_pods
  pod 'ReactiveNetworking/Dependencies', :path => '.'
  pod 'ReactiveNetworking/Testing', :path => '.'
end

target 'ReactiveNetworking iOS' do
  platform :ios, '6.0'
  #link_with 'ReactiveNetworking iOS Tests'
  import_pods
end

target 'ReactiveNetworking Mac' do
  platform :osx, '10.8'
  #link_with 'ReactiveNetworking Mac Tests'
  import_pods
end
