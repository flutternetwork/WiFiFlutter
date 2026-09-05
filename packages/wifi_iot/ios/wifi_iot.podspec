#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'wifi_iot'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin which can handle WiFi connections and hotspot (AP, STA).'
  s.description      = <<-DESC
Flutter plugin which can handle WiFi connections and hotspot (AP, STA).
                       DESC
  s.homepage         = 'https://github.com/flutternetwork/WiFiFlutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'WiFiFlutter' => 'harsh@bhikadia.com' }
  s.source           = { :path => '.' }
  s.source_files = 'wifi_iot/Sources/wifi_iot/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
