#import "WifiIotPlugin.h"
#import <wifi_iot/wifi_iot-Swift.h>

@implementation WifiIotPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftWifiIotPlugin registerWithRegistrar:registrar];
}
@end
