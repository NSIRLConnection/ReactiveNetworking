require 'rubygems'
require 'bundler/setup'
Bundler.setup
require 'rake'

task default: 'test'

desc 'Execute iOS and Mac tests'
task :test do
  sh "set -o pipefail; xcodebuild -workspace ReactiveNetworking.xcworkspace -scheme 'ReactiveNetworking Mac' -sdk macosx -configuration Debug test | xcpretty -c"

  # This is randomly failing with different errors on Xcode6 on Travis
  #destination = system("xcodebuild -version | grep -q 'Xcode 5'") ? 'platform=iOS Simulator,OS=7.0' : 'platform=iOS Simulator,name=iPhone 5,OS=8.0'
  #sh "set -o pipefail; xcodebuild -workspace ReactiveNetworking.xcworkspace -scheme 'ReactiveNetworking iOS' -sdk iphonesimulator -destination '#{destination}' -configuration Debug test | xcpretty -c"
end
