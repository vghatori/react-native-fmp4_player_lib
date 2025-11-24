require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "NativeFmp4PlayerLib"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => min_ios_version_supported }
  s.source       = { :git => "https://github.com/vghatori/react-native-fmp4_player_lib.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm,swift,cpp}"
  s.private_header_files = "ios/**/*.h"
  s.swift_version = "5.0"
  s.dependency 'Swifter', '~> 1.5.0'
  s.pod_target_xcconfig = {
  'ENABLE_USER_SCRIPT_SANDBOXING' => 'NO'
  }
  
  
  install_modules_dependencies(s)
end
