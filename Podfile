target 'PBBReader' do
    platform :osx, '10.11'
    use_frameworks!
    project 'PBBReaderForMac.xcodeproj'
    pod 'EDStarRating'
    pod 'CocoaAsyncSocket'
    pod 'FMDB'
#     pod 'SnapKit', '~> 3.0.2'

    pod 'Fabric'
    pod 'Crashlytics'

    pod 'RNCryptor', '~> 5.0.1'  #https://github.com/RNCryptor/RNCryptor/releases/tag/RNCryptor-5.0.1
    
    target 'PBBLogSDK' do
        inherit! :search_paths
        pod 'RNCryptor', '~> 5.0.1'
    end
end

    
#pod update 'Crashlytics' #单独更新某一个依赖

#Found an unexpected Mach-O header code: 0x72613c21:http://stackoverflow.com/questions/33076819/found-an-unexpected-mach-o-header-code-0x72613c21-in-xcode-7
#  post_install do |installer|
#      installer.pods_project.targets.each do |target|
#          target.build_configurations.each do |config|
#              config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
#          end
#      end
#  end
