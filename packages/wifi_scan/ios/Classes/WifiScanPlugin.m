#import "WifiScanPlugin.h"
#if __has_include(<wifi_scan/wifi_scan-Swift.h>)
#import <wifi_scan/wifi_scan-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "wifi_scan-Swift.h"
#endif

@implementation WifiScanPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [SwiftWifiScanPlugin registerWithRegistrar:registrar];
}
@end
