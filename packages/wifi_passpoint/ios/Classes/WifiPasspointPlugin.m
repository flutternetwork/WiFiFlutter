#import "WifiPasspointPlugin.h"
#if __has_include(<wifi_passpoint/wifi_passpoint-Swift.h>)
#import <wifi_passpoint/wifi_passpoint-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "wifi_passpoint-Swift.h"
#endif

@implementation WifiPasspointPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [SwiftWifiPasspointPlugin registerWithRegistrar:registrar];
}
@end
