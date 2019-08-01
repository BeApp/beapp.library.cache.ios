#
# Be sure to run `pod lib lint BeappCache.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BeappCache'
  s.version          = '0.4.0'
  s.summary          = 'This library provides a cache mechanism relying on RxSwift'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  This library provides a cache mechanism relying on RxSwift. There are currently one storage implementation: Cache
  DESC

  s.homepage         = 'https://github.com/BeApp/beapp.library.cache.ios.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'beapp' => 'dev@beapp.fr' }
  s.source           = { :git => 'https://github.com/BeApp/beapp.library.cache.ios.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'
  s.source_files  = 'BeappCache/Classes/**/*'
  s.frameworks = 'Foundation'
  s.dependency 'Cache', '~> 5.2.0'
  s.dependency 'RxSwift', '~> 4.5' #for cache library
  s.dependency 'RxSwift', '~> 5.0.1'
end
