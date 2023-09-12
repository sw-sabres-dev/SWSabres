platform :ios, '15.0'
use_frameworks!

target 'SWSabres' do
	pod 'Alamofire', '~> 4.9.0'
	pod 'SwiftyJSON', '~> 4.3.0'
	pod 'PINRemoteImage', '~> 3.0.3'
	pod 'THLabel', '~> 1.4'
	pod 'ReachabilitySwift', '~> 4.3.0'
	pod 'RSDayFlow', '~> 1.2'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "15"
    end
  end
end
