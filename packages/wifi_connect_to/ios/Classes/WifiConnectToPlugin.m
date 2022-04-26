#import "WifiConnectToPlugin.h"
#if __has_include(<wifi_connect_to/wifi_connect_to-Swift.h>)
#import <wifi_connect_to/wifi_connect_to-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "wifi_connect_to-Swift.h"
#endif

@implementation WifiConnectToPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [SwiftWifiConnectToPlugin registerWithRegistrar:registrar];
}
@end
