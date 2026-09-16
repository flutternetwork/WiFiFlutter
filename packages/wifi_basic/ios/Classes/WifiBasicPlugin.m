#import "WifiBasicPlugin.h"
#if __has_include(<wifi_basic/wifi_basic-Swift.h>)
#import <wifi_basic/wifi_basic-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "wifi_basic-Swift.h"
#endif

@implementation WifiBasicPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftWifiBasicPlugin registerWithRegistrar:registrar];
}
@end
