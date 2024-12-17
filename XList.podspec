#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|

  s.name         = "XList"
  s.version      = "1.0.0"
  s.summary      = "XList的一个简单示范工程."

  s.description  = <<-DESC
                   XList的一个简单示范工程示范工程的长描述.
                   DESC

  s.homepage     = "https://github.com/xueqooy/XKit"

  s.license      = "MIT"

  s.author       = { "xueqooy" => "xueqooy@nd.com.cn" }

  s.platform     = :ios, "13.0"

  s.source       = { :git => "git@github.com:xueqooy/XList.git", :tag => "#{s.version}" }

  s.preserve_paths = ['Demos', '.cocoapods.yml', "#{s.name}.podspec.json"]

  s.ios.deployment_target = '13.0'

  s.swift_versions = ['5.0']

  s.source_files = "Source/XList/**/*.{h,m,swift}"
  
  s.dependency 'XKit'
  s.dependency 'XUI'
  s.dependency 'SnapKit'
  s.dependency 'IGListKit', '5.0.0'
  s.dependency 'IGListSwiftKit', '5.0.0'
  s.dependency 'IGListDiffKit', '5.0.0'

  
end
