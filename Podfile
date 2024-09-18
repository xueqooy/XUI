source 'ssh://git@cocoapods.sdp.nd:/cocoapods-precompiled/specs.git'
source 'ssh://git@cocoapods.sdp.nd:/cocoapods/specs.git'

platform :ios, '12.0'

project 'llp_ui_iOS'

# SDK/组件使用的依赖（最后应该在podspec中体现）
def dependency
  pod 'SDWebImage' # 换成各自的 Pod 依赖
end

# 仅在开发时使用的依赖（不应该加入到podspec），如单元测试框架等
def develop_dependency
    pod 'SDPSpaceCommander' # 自动格式化代码工具
    pod 'SDPMobileComponentBuilder', '~> 1.0.21-TEST' # 移动组件构建工具
end

target 'llp_ui_iOSTests' do
    dependency
    develop_dependency
end

# 注意：以下至结尾所有内容，请勿修改，以防后期发生问题
# 注意：首次 pod 安装后，请务必使用命令行提交改动，否则可能导致无法正常发布：`git add . && git commit -m '修改内容'`
pre_install do |installer|
    # check develop tools
    develop_tools = installer.podfile.dependencies.select { |dependency| dependency.name.strip == 'SDPSpaceCommander' || dependency.name.strip == 'SDPMobileComponentBuilder' } || []
    if develop_tools.length < 2
        puts "\033[31m组件开发必须在 develop_dependency 中同时添加 SDPSpaceCommander 与 SDPMobileComponentBuilder 依赖\033[0m"
        raise
    end

    # fix tool symbolic link
    build_scripts_map = {
        'build.sh' => 'Pods/SDPMobileComponentBuilder/Scripts/xcframework-build.sh',
        'build.rb' => 'Pods/SDPMobileComponentBuilder/Scripts/build.rb',
    }
    build_scripts_map.each do |entity, symbolic|
        File.delete entity if File.exist? entity
        File.symlink symbolic, entity
    end
end

post_integrate do |installer|
    project_name = "llp_ui_iOS"
    project = installer.aggregate_targets[0].user_project
    
    target = project.targets.select { |item| item.name.strip == project_name.strip }.first
    unless target
        puts "target(#{project_name})不存在"
        return
    end

    test_target = project.targets.select { |item| item.name.strip == "#{project_name}Tests".strip }.first
    unless test_target
        puts "target(#{project_name})不存在"
        return
    end

    # 将 llp_ui_iOS 的 xcconfig 文件指向 llp_ui_iOSTests 的 xcconfig 文件
    target.build_configurations.each do |configuration|
        test_configuration = test_target.build_configurations.select { |test_config|
            test_config.name.strip == configuration.name.strip
        }.first
        configuration.base_configuration_reference = test_configuration.base_configuration_reference
    end
    
    project.save
end

