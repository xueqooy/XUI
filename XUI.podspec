Pod::Spec.new do |s|

  s.name         = "XUI"
  s.version      = "1.0.0"
  s.summary      = "Powerful UI component library."

  s.description  = <<-DESC
                   Powerful UI component library.
                   DESC
  s.homepage     = "http://github/xueqooy/XUI"
  s.license      = "MIT"
  s.author       = { "xueqooy" => "xueqooy@nd.com.cn" }
  s.platform     = :ios, "13.0"
  s.source       = { :git => "git@github.com:xueqooy/XUI.git", :tag => "#{s.version}" }
  s.ios.deployment_target = '13.0'
  s.swift_versions = ['5.0']
  s.source_files = "Source/XUI/src/**/*.{h,m,swift}"
  s.private_header_files = "Source/_XUILoader/include/Loader.h"
  s.resource_bundles = {
    'XUI_RESOURCE' => ["Source/XUI/resources/*"]
  }
  s.xcconfig = { "APPLICATION_EXTENSION_API_ONLY" => 'NO' }
  s.dependency 'XKit'
  s.dependency 'SnapKit'
  s.dependency 'CombineCocoa'
  
end
