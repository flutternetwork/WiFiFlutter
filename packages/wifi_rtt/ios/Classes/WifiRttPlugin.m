#import "WifiRttPlugin.h"
#if __has_include(<wifi_rtt/wifi_rtt-Swift.h>)
#import <wifi_rtt/wifi_rtt-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "wifi_rtt-Swift.h"
#endif

@implementation WifiRttPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [SwiftWifiRttPlugin registerWithRegistrar:registrar];
}
@end
