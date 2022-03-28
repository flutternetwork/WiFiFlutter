#import "WifiEasyConnectPlugin.h"
#if __has_include(<wifi_easy_connect/wifi_easy_connect-Swift.h>)
#import <wifi_easy_connect/wifi_easy_connect-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "wifi_easy_connect-Swift.h"
#endif

@implementation WifiEasyConnectPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [SwiftWifiEasyConnectPlugin registerWithRegistrar:registrar];
}
@end
