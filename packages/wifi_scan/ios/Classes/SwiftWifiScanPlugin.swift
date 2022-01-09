import Flutter
import UIKit

public class SwiftWifiScanPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "wifi_scan", binaryMessenger: registrar.messenger())
    let instance = SwiftWifiScanPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    // TODO: handle wifi_scan/onScannedResultsAvailable eventChannel
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch(call.method){
      case "canStartScan":
          return result(0) // not supported
      case "startScan":
          return result(false) // always fails
      case "canGetScannedResults":
          return result(0) // not supported
      case "getScannedResults":
          return result([]) // empty results
      default:
          return result(FlutterMethodNotImplemented)
    }
  }
}
