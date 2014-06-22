require 'rubygems'
require 'bundler/setup'
Bundler.setup
require 'rake'

task default: 'test'

desc 'Execute iOS and Mac tests'
task :test do
  sh "xcodebuild -workspace ReactiveNetworking.xcworkspace -scheme 'ReactiveNetworking iOS' -sdk iphonesimulator -configuration Debug test | xcpretty -c"
  sh "xcodebuild -workspace ReactiveNetworking.xcworkspace -scheme 'ReactiveNetworking Mac' -sdk macosx -configuration Debug test | xcpretty -c"
end
