Pod::Spec.new do |s|

  s.name         = "XList"
  s.version      = "1.0.0"
  s.summary      = "A List component based on IGListKit."
  s.description  = <<-DESC
                    A List component based on IGListKit.
                   DESC
  s.homepage     = "https://github.com/xueqooy/XUI"
  s.license      = "MIT"
  s.author       = { "xueqooy" => "xue_qooy@163.com" }
  s.platform     = :ios, "13.0"
  s.source       = { :git => "git@github.com:xueqooy/XList.git", :tag => "#{s.version}" }
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
