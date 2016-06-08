use_frameworks!
pod 'JGProgressHUD', '~> 1.3'
pod 'Alamofire', '~> 3.4'
pod 'DynamicBlurView', '~> 1.1'

post_install do |installer|
    installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
        configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
    end
end