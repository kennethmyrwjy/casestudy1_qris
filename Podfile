platform :ios, '15.0'
use_frameworks!
inhibit_all_warnings!

target 'casestudy1_qris' do
  pod 'Alamofire', '~> 5.9'
  pod 'SnapKit', '~> 5.7'

  target 'casestudy1_qrisTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
