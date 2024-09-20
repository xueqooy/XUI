#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|

  s.name         = "LLPUI"
  s.version      = "1.0.0"
  s.summary      = "LLPUI的一个简单示范工程."

  s.description  = <<-DESC
                   LLPUI的一个简单示范工程示范工程的长描述.
                   DESC

  s.homepage     = "http://git.sdp.nd/component-ios/LLPUI"

  s.license      = "MIT"

  s.author       = { "xueqooy" => "xueqooy@nd.com.cn" }

  s.platform     = :ios, "13.0"

  s.source       = { :git => "git@cocoapods.sdp.nd:cocoapods/llp_ui_ios.git", :tag => "#{s.version}" }

  s.preserve_paths = ['Demos', '.cocoapods.yml', "#{s.name}.podspec.json"]

  s.ios.deployment_target = '13.0'

  s.swift_versions = ['5.0']

  s.source_files = "#{s.name}/src/CombineCocoa/**/*.{h,m}", "#{s.name}/src/**/*.{swift}"
  s.public_header_files = "#{s.name}/src/CombineCocoa/*.h"

  s.resource_bundles = {
    'LLPUI_RESOURCE' => ["#{s.name}/resources/*"]
  }
  
  # https://stackoverflow.com/questions/32609776/uiapplication-sharedapplication-is-unavailable
  s.xcconfig = { "APPLICATION_EXTENSION_API_ONLY" => 'NO' }
  
  s.dependency 'LLPUtils'
  s.dependency 'SnapKit'
  s.dependency 'IGListKit', '5.0.0'
  s.dependency 'IGListSwiftKit', '5.0.0'
  s.dependency 'IGListDiffKit', '5.0.0'
  # s.dependency 'SDWebImage'

  
end
