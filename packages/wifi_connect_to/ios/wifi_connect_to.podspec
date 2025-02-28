#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint wifi_connect_to.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'wifi_connect_to'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin to connect (and disconnect) to a WiFi access point.'
  s.description      = <<-DESC
Flutter plugin to connect (and disconnect) to a WiFi access point.
                       DESC
  s.homepage         = 'https://wifi.flutternetwork.dev'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'WiFiFlutter' => 'contact@flutternetwork.dev' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
