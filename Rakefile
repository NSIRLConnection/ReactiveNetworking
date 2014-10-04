require 'rubygems'
require 'bundler/setup'
Bundler.setup
require 'rake'

task default: 'test'

desc 'Execute iOS and Mac tests'
task :test do
  sh "xcodebuild -workspace ReactiveNetworking.xcworkspace -scheme 'ReactiveNetworking Mac' -sdk macosx -configuration Debug test | xcpretty -c"
  destination = system("xcodebuild -version | grep -q 'Xcode 5'") ? 'platform=iOS Simulator,OS=7.0' : 'name=iPhone 5'
  sh "xcodebuild -workspace ReactiveNetworking.xcworkspace -scheme 'ReactiveNetworking iOS' -sdk iphonesimulator -destination '#{destination}' -configuration Debug test | xcpretty -c"
end
