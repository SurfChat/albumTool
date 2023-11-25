# Uncomment the next line to define a global platform for your project
# source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'

platform :ios, '14.0'

inhibit_all_warnings!
use_frameworks!
install!'cocoapods',:deterministic_uuids=>false  # 禁止重生成UUID
install! 'cocoapods', :warn_for_unused_master_specs_repo => false


target 'SurfTool' do

pod 'SnapKit'
pod 'IMProgressHUD'
pod 'ZLPhotoBrowser'
pod 'WCDB.swift'
pod 'JXPhotoBrowser'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      config.build_settings['SWIFT_VERSION'] = '5.0'
    end
  end
end