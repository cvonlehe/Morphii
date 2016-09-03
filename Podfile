use_frameworks!

target 'Morphii' do
    pod 'AOTutorial', '~> 1.7'
    pod 'TPKeyboardAvoiding', '~> 1.3'
    pod 'EZYGradientView', :git => 'https://github.com/shashankpali/EZYGradientView'
end

link_with 'Morphii', 'Morphii Mobile Keyboard'

pod 'JGProgressHUD', '~> 1.3'
pod 'Alamofire', '~> 3.4'
pod 'AWSMobileAnalytics', '~> 2.4'
pod 'DeviceKit', '~> 0.3.2'
pod 'Parse'
pod 'APTimeZones', '~> 1.1'

post_install do |installer|
    installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
        configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
    end
end