import Flutter

public class SwiftWifiScanPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = SwiftWifiScanPlugin()
    // set Flutter channels - 1 for method, 1 for event
    let channel = FlutterMethodChannel(
        name: "wifi_scan", binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(instance, channel: channel)
    let eventChannel = FlutterEventChannel(
        name: "wifi_scan/onScannedResultsAvailable",
        binaryMessenger: registrar.messenger()
    )
    eventChannel.setStreamHandler(DummyStreamHandler())
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


class DummyStreamHandler: NSObject, FlutterStreamHandler{
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        return nil
    }
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
}
