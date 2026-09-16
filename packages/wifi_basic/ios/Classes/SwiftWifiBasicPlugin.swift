import Flutter
import UIKit

public class SwiftWifiBasicPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "wifi_basic", binaryMessenger: registrar.messenger())
        let instance = SwiftWifiBasicPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
        case "isSupported":
            // all iOS device is WiFi capable - except Simulator,
            // also no API to check it either
#if targetEnvironment(simulator)
            return result(false)
#else
            return result(true)
#endif
        case "getGeneration":
            return result(getGeneration())
        case "isEnabled":
            return result(isEnabled())
        case "setEnabled":
            // always fails - no API to do it
            return result(false)
        case "openSettings":
            return openSettings()
        default:
            return result(FlutterMethodNotImplemented)
        }
    }
    
    private func getGeneration() -> Int{
        // This info is curated from - https://en.wikipedia.org/wiki/List_of_iOS_and_iPadOS_devices
        //-- iPod
          // iPod 6,7 - Wi-Fi (802.11 a/b/g/n/ac)
          // iPod 5 - Wi-Fi (802.11 a/b/g/n)
          // iPod 4 - Wi-Fi (802.11 b/g/n)
          // iPod <3 - Wi-Fi (802.11 b/g)
        //-- iPhone
          // iPhone SE2,11x,12x,13x - Wi- (802.11 a/b/g/n/ac/ax)
          // iPhone 6x,SE,7x,8X,Xx - Wi-Fi (802.11 a/b/g/n/ac)
          // iPhone 5x - Wi-Fi (802.11 a/b/g/n)
          // iPhone 4x - Wi-Fi (802.11 b/g/n)
          // iPhone <3x - Wi-Fi (802.11 b/g)
        //-- iPad
          // iPad 5,6,7,8,9 - Wi-Fi (802.11a/b/g/n/ac)
          // iPad <4 - Wi-Fi (802.11 a/b/g/n)
          // iPad Mini 6 - Wi-Fi 6 (802.11a/b/g/n/ac/ax)
          // iPad Mini 4,5 - Wi-Fi (802.11 a/b/g/n/ac)
          // iPad Mini <3-  Wi-Fi (802.11 a/b/g/n)
          // iPad Air 4 - Wi-Fi 6 (802.11a/b/g/n/ac/ax)
          // iPad Air 2,3 - Wi-Fi 5 (802.11a/b/g/n/ac)
          // iPad Air 1 - Wi-Fi (802.11a/b/g/n)
          // iPad Pro - Wi-Fi 5 (802.11a/b/g/n/ac)
        return -1
    }
    
    // code from https://stackoverflow.com/a/41672571/2554745
    private func isEnabled() -> Bool{
        var addresses = [String]()
        
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return false }
        guard let firstAddr = ifaddr else { return false }
        
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            addresses.append(String(cString: ptr.pointee.ifa_name))
        }
        
        var counts:[String:Int] = [:]
        
        for item in addresses {
            counts[item] = (counts[item] ?? 0) + 1
        }
        
        freeifaddrs(ifaddr)
        guard let count = counts["awdl0"] else { return false }
        return count > 1
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
