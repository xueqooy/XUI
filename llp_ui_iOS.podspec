#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|

  s.name         = "llp_ui_iOS"
  s.version      = "1.0.0"
  s.summary      = "llp_ui_iOS的一个简单示范工程."

  s.description  = <<-DESC
                   llp_ui_iOS的一个简单示范工程示范工程的长描述.
                   DESC

  s.homepage     = "http://git.sdp.nd/component-ios/llp_ui_iOS"

  s.license      = "MIT"

  s.author       = { "颜志炜" => "yanzhiwei147@gmail.com" }

  s.platform     = :ios, "12.0"

  s.source       = { :git => "git@cocoapods.sdp.nd:cocoapods/llp_ui_ios.git", :tag => "#{s.version}" }

  s.preserve_paths = ['Demos', '.cocoapods.yml', "#{s.name}.podspec.json"]

  s.dependency 'SDWebImage'

  if `echo $RUN_ON_JENKINS`.strip.length > 0
    s.vendored_frameworks = "#{s.name}.xcframework"
  else
    s.public_header_files = "#{s.name}/*.h", "#{s.name}/include/**/*.h"
    s.source_files = "#{s.name}/**/*.{h,m}"
  end

  s.resource_bundles = {
    "#{s.name}" => ["Resources/**/*"]
  }

end
