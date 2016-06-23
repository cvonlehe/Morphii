use_frameworks!

target 'Morphii' do
    pod 'AOTutorial', '~> 1.7'
end

link_with 'Morphii', 'Morphii Mobile Keyboard'

pod 'JGProgressHUD', '~> 1.3'
pod 'Alamofire', '~> 3.4'
pod 'Parse'

post_install do |installer|
    installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
        configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
    end
end