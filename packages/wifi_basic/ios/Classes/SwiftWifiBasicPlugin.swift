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
        case "hasCapability":
            // all iOS device is WiFi capable - except Simulator,
            // also no API to check it either
#if targetEnvironment(simulator)
            return result(false)
#else
            return result(true)
#endif
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
    
    // code from https://stackoverflow.com/a/41672571/2554745
    private func isEnabled()->Bool{
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
