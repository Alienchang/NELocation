#
# Be sure to run `pod lib lint NELocation.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NELocation'
  s.version          = '1.0.0'
  s.summary          = '获取地理位置信息.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
定时获取，权限提示操作等等.
                       DESC

  s.homepage         = 'https://github.com/Alienchang/NELocation.git'
  s.license          = 'MIT'
  s.author           = { 'liuchang' => '1217493217@qq.com' }
  s.source           = { :git => 'https://github.com/Alienchang/NELocation.git', :tag => s.version.to_s }

  s.module_name = 'NELocation'
  s.requires_arc          = true
  s.ios.deployment_target = '9.0'
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.frameworks = 'CoreLocation'
  s.dependency 'MSWeakTimer'
end
