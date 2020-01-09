import Flutter
import UIKit
import SystemConfiguration.CaptiveNetwork
import NetworkExtension

public class SwiftWifiIotPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "wifi_iot", binaryMessenger: registrar.messenger())
        let instance = SwiftWifiIotPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
            /// Stand Alone
            case "loadWifiList":
                loadWifiList(result: result)
                break;
            case "forceWifiUsage":
                forceWifiUsage(call: call, result: result)
                break;
            case "isEnabled":
                isEnabled(result: result)
                break;
            case "setEnabled":
                setEnabled(call: call, result: result)
                break;
            case "findAndConnect": // OK
                findAndConnect(call: call, result: result)
                break;
            case "connect": // OK
                connect(call: call, result: result)
                break;
            case "isConnected": // OK
                isConnected(result: result)
                break;
            case "disconnect": // OK
                disconnect(result: result)
                break;
            case "getSSID":
                result(getSSID())
                break;
            case "getBSSID":
                result(getBSSID())
                break;
            case "getCurrentSignalStrength":
                getCurrentSignalStrength(result: result)
                break;
            case "getFrequency":
                getFrequency(result: result)
                break;
            case "getIP":
                getIP(result: result)
                break;
            case "removeWifiNetwork": // OK
                removeWifiNetwork(call: call, result: result)
                break;
            case "isRegisteredWifiNetwork":
                isRegisteredWifiNetwork(call: call, result: result)
                break;
            /// Access Point
            case "isWiFiAPEnabled":
                isWiFiAPEnabled(result: result)
                break;
            case "setWiFiAPEnabled":
                setWiFiAPEnabled(call: call, result: result)
                break;
            case "getWiFiAPState":
                getWiFiAPState(result: result)
                break;
            case "getClientList":
                getClientList(result: result)
                break;
            case "getWiFiAPSSID":
                getWiFiAPSSID(result: result)
                break;
            case "setWiFiAPSSID":
                setWiFiAPSSID(call: call, result: result)
                break;
            case "isSSIDHidden":
                isSSIDHidden(result: result)
                break;
            case "setSSIDHidden":
                setSSIDHidden(call: call, result: result)
                break;
            case "getWiFiAPPreSharedKey":
                getWiFiAPPreSharedKey(result: result)
                break;
            case "setWiFiAPPreSharedKey":
                setWiFiAPPreSharedKey(call: call, result: result)
                break;
            case "setMACFiltering":
                setMACFiltering(call: call, result: result)
                break;
            default:
                result(FlutterMethodNotImplemented);
                break;
        }
    }

    private func loadWifiList(result: FlutterResult) {
        result(FlutterMethodNotImplemented)
    }

    private func forceWifiUsage(call: FlutterMethodCall, result: FlutterResult) {
        let arguments = call.arguments
        let useWifi = (arguments as! [String : Bool])["useWifi"]
        if (useWifi != nil) {
            print("Forcing WiFi usage : %s", ((useWifi ?? false) ? "Use WiFi" : "Use 3G/4G Data"))
            result(FlutterMethodNotImplemented)
        } else {
            result(nil)
        }
    }

    private func connect(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let sSSID = (call.arguments as? [String : AnyObject])?["ssid"] as! String
        let sPassword = (call.arguments as? [String : AnyObject])?["password"] as! String?
        let bJoinOnce = (call.arguments as? [String : AnyObject])?["join_once"] as! Bool?
        let sSecurity = (call.arguments as? [String : AnyObject])?["security"] as! String?
        
        //        print("SSID : '\(sSSID)'")
        //        print("PASSWORD : '\(sPassword)'")
        //        print("JOIN_ONCE : '\(bJoinOnce)'")
        //        if (bJoinOnce) {
        //            print("The network will be forgotten!")
        //        }
        //        print("SECURITY : '\(sSecurity)'")

        if #available(iOS 11.0, *) {
            let configuration = initHotspotConfiguration(ssid: sSSID, passphrase: sPassword, security: sSecurity)
            configuration.joinOnce = bJoinOnce ?? false

            NEHotspotConfigurationManager.shared.apply(configuration) { (error) in
                if (error != nil) {
                    if (error?.localizedDescription == "already associated.") {
                        print("Connected to " + self.getSSID()!)
                        result(true)
                        return
                    } else {
                        print("Not Connected")
                        result(false)
                        return
                    }
                } else {
                    if (self.getSSID() == nil) {
                        print("WiFi network not found")
                        result(false)
                    } else {
                        print("Connected to " + self.getSSID()!)
                        // ssid check is required because if wifi not found (could not connect) there seems to be no error given
                        result(self.getSSID()! == sSSID)
                    }
                    return
                }
            }
        } else {
            print("Not Connected")
            result(nil)
            return
        }
    }

    private func findAndConnect(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }

    @available(iOS 11.0, *)
    private func initHotspotConfiguration(ssid: String, passphrase: String?, security: String? = nil) -> NEHotspotConfiguration {
        switch security?.uppercased() {
            case "WPA":
                return NEHotspotConfiguration.init(ssid: ssid, passphrase: passphrase!, isWEP: false)
            case "WEP":
                return NEHotspotConfiguration.init(ssid: ssid, passphrase: passphrase!, isWEP: true)
            default:
                return NEHotspotConfiguration.init(ssid: ssid)
        }
    }

    private func isEnabled(result: FlutterResult) {
        // For now..
        let sSSID: String? = getSSID()
        if (sSSID != nil) {
            result(true)
        } else {
            result(nil)
        }
    }

    private func setEnabled(call: FlutterMethodCall, result: FlutterResult) {
        let arguments = call.arguments
        let state = (arguments as! [String : Bool])["state"]
        if (state != nil) {
            print("Setting WiFi Enable : \(((state ?? false) ? "enable" : "disable"))")
            result(FlutterMethodNotImplemented)
        } else {
            result(nil)
        }
    }

    private func isConnected(result: FlutterResult) {
        // For now..
        let sSSID: String? = getSSID()
        if (sSSID != nil) {
            result(true)
        } else {
            result(false)
        }
    }

    private func disconnect(result: FlutterResult) {
        if #available(iOS 11.0, *) {
            let sSSID: String? = getSSID()
            if (sSSID != nil) {
                print("trying to disconnect from '\(sSSID!)'")
                NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: sSSID ?? "")
                result(true)
            } else {
                print("SSID is null")
                result(false)
            }
        } else {
            print("Not disconnected")
            result(nil)
        }
    }

    private func getSSID() -> String? {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        return ssid
    }

    private func getBSSID() -> String? {
        var bssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    bssid = interfaceInfo[kCNNetworkInfoKeyBSSID as String] as? String
                    break
                }
            }
        }
        return bssid
    }

    private func getCurrentSignalStrength(result: FlutterResult) {
        result(FlutterMethodNotImplemented)
    }

    private func getFrequency(result: FlutterResult) {
        result(FlutterMethodNotImplemented)
    }

    private func getIP(result: FlutterResult) {
        result(FlutterMethodNotImplemented)
    }

    private func removeWifiNetwork(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments
        let sPrefixSSID = (arguments as! [String : String])["prefix_ssid"] ?? ""
        if (sPrefixSSID == "") {
            print("No prefix SSID was given!")
            result(nil)
        }
        
        if #available(iOS 11.0, *) {
            NEHotspotConfigurationManager.shared.getConfiguredSSIDs { (htSSID) in
                for sIncSSID in htSSID {
                    if (sPrefixSSID != "" && sIncSSID.hasPrefix(sPrefixSSID)) {
                        NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: sIncSSID)
                    }
                }
            }
            result(true)
        } else {
            print("Not removed")
            result(nil)
        }
    }

    private func isRegisteredWifiNetwork(call: FlutterMethodCall, result: FlutterResult) {
        result(FlutterMethodNotImplemented)
    }

    private func isWiFiAPEnabled(result: FlutterResult) {
        result(FlutterMethodNotImplemented)
    }

    private func setWiFiAPEnabled(call: FlutterMethodCall, result: FlutterResult) {
        let arguments = call.arguments
        let state = (arguments as! [String : Bool])["state"]
        if (state != nil) {
            print("Setting AP WiFi Enable : \(state ?? false ? "enable" : "disable")")
            result(FlutterMethodNotImplemented)
        } else {
            result(nil)
        }
    }

    private func getWiFiAPState(result: FlutterResult) {
        result(FlutterMethodNotImplemented)
    }

    private func getClientList(result: FlutterResult) {
        result(FlutterMethodNotImplemented)
    }

    private func getWiFiAPSSID(result: FlutterResult) {
        result(FlutterMethodNotImplemented)
    }

    private func setWiFiAPSSID(call: FlutterMethodCall, result: FlutterResult) {
        let arguments = call.arguments
        let ssid = (arguments as! [String : String])["ssid"]
        if (ssid != nil) {
            print("Setting AP WiFi SSID : '\(ssid ?? "")'")
            result(FlutterMethodNotImplemented)
        } else {
            result(nil)
        }
    }

    private func isSSIDHidden(result: FlutterResult) {
        result(FlutterMethodNotImplemented)
    }

    private func setSSIDHidden(call: FlutterMethodCall, result: FlutterResult) {
        let arguments = call.arguments
        let hidden = (arguments as! [String : Bool])["hidden"]
        if (hidden != nil) {
            print("Setting AP WiFi Visibility : \(((hidden ?? false) ? "hidden" : "visible"))")
            result(FlutterMethodNotImplemented)
        } else {
            result(nil)
        }
    }

    private func getWiFiAPPreSharedKey(result: FlutterResult) {
        result(FlutterMethodNotImplemented)
    }

    private func setWiFiAPPreSharedKey(call: FlutterMethodCall, result: FlutterResult) {
        let arguments = call.arguments
        let preSharedKey = (arguments as! [String : String])["preSharedKey"]
        if (preSharedKey != nil) {
            print("Setting AP WiFi PreSharedKey : '\(preSharedKey ?? "")'")
            result(FlutterMethodNotImplemented)
        } else {
            result(nil)
        }
    }

    private func setMACFiltering(call: FlutterMethodCall, result: FlutterResult) {
        result(FlutterMethodNotImplemented)
    }
}
