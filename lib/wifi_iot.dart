import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

enum WIFI_AP_STATE { WIFI_AP_STATE_DISABLING, WIFI_AP_STATE_DISABLED, WIFI_AP_STATE_ENABLING, WIFI_AP_STATE_ENABLED, WIFI_AP_STATE_FAILED }

class WiFiForIoTPlugin {
  static const MethodChannel _channel = const MethodChannel('wifi_iot');

  static Future<bool> isWiFiAPEnabled() async {
    Map<String, String> htArguments = new Map();
    final bool bResult = await _channel.invokeMethod('isWiFiAPEnabled', htArguments);
    return (bResult != null && bResult);
  }

  static void setWiFiAPEnabled(bool enabled) async {
    Map<String, bool> htArguments = new Map();
    htArguments["enabled"] = enabled;
    await _channel.invokeMethod('setWiFiAPEnabled', htArguments);
  }

  static Future<bool> isWiFiAPSSIDHidden() async {
    Map<String, String> htArguments = new Map();
    final bool bResult = await _channel.invokeMethod('isSSIDHidden', htArguments);
    return (bResult != null && bResult);
  }

  static setWiFiAPSSIDHidden(bool hidden) async {
    Map<String, bool> htArguments = new Map();
    htArguments["hidden"] = hidden;
    await _channel.invokeMethod('setSSIDHidden', htArguments);
  }

  static Future<int> getWiFiAPState() async {
    Map<String, String> htArguments = new Map();
    final int iResult = await _channel.invokeMethod('getWiFiAPState', htArguments);
    return iResult;
  }

  static Future<List<APClient>> getClientList(bool onlyReachables, int reachableTimeout) async {
    Map<String, Object> htArguments = new Map();
    htArguments["onlyReachables"] = onlyReachables;
    htArguments["reachableTimeout"] = reachableTimeout;
    final String sResult = await _channel.invokeMethod('getClientList', htArguments);
    List<APClient> htResult = APClient.parse(sResult);
    return htResult;
  }

  static void setWiFiAPConfiguration(Object poWiFiConfig) async {
    Map<String, bool> htArguments = new Map();
    htArguments["wifi_config"] = poWiFiConfig;
    await _channel.invokeMethod('setWiFiAPConfiguration', htArguments);
  }

  static Future<String> getWiFiAPSSID() async {
    Map<String, String> htArguments = new Map();
    final String sResult = await _channel.invokeMethod('getWiFiAPSSID', htArguments);
    return sResult;
  }

  static setWiFiAPSSID(String psSSID) async {
    Map<String, String> htArguments = new Map();
    htArguments["ssid"] = psSSID;
    await _channel.invokeMethod('setWiFiAPSSID', htArguments);
  }

  static Future<String> getWiFiAPPreSharedKey() async {
    Map<String, String> htArguments = new Map();
    final String sResult = await _channel.invokeMethod('getWiFiAPPreSharedKey', htArguments);
    return sResult;
  }

  static setWiFiAPPreSharedKey(String psPreSharedKey) async {
    Map<String, String> htArguments = new Map();
    htArguments["preSharedKey"] = psPreSharedKey;
    await _channel.invokeMethod('setWiFiAPPreSharedKey', htArguments);
  }

  static Future<List<WifiNetwork>> loadWifiList() async {
    Map<String, String> htArguments = new Map();
    final String sResult = await _channel.invokeMethod('loadWifiList', htArguments);
    List<WifiNetwork> htResult = WifiNetwork.parse(sResult);
    return htResult;
  }

  static void forceWifiUsage(bool useWifi) async {
    Map<String, bool> htArguments = new Map();
    htArguments["useWifi"] = useWifi;
    await _channel.invokeMethod('forceWifiUsage', htArguments);
  }

  static Future<bool> isEnabled() async {
    Map<String, String> htArguments = new Map();
    final bool bResult = await _channel.invokeMethod('isEnabled', htArguments);
    return (bResult != null && bResult);
  }

  static setEnabled(bool enabled) async {
    Map<String, bool> htArguments = new Map();
    htArguments["enabled"] = enabled;
    await _channel.invokeMethod('setEnabled', htArguments);
  }

  static Future<bool> findAndConnect(String ssid, String password) async {
    if (!await isEnabled()) {
      await setEnabled(true);
    }
    Map<String, String> htArguments = new Map();
    htArguments["ssid"] = ssid;
    htArguments["password"] = password;
    final bool bResult = await _channel.invokeMethod('findAndConnect', htArguments);
    return (bResult != null && bResult);
  }

  static Future<bool> connectionStatus() async {
    Map<String, String> htArguments = new Map();
    final bool bResult = await _channel.invokeMethod('connectionStatus', htArguments);
    return (bResult != null && bResult);
  }

  static disconnect() async {
    Map<String, bool> htArguments = new Map();
    await _channel.invokeMethod('disconnect', htArguments);
  }

  static Future<String> getSSID() async {
    Map<String, String> htArguments = new Map();
    final String sResult = await _channel.invokeMethod('getSSID', htArguments);
    return sResult;
  }

  static Future<String> getBSSID() async {
    Map<String, String> htArguments = new Map();
    final String sResult = await _channel.invokeMethod('getBSSID', htArguments);
    return sResult;
  }

  static Future<int> getCurrentSignalStrength() async {
    Map<String, String> htArguments = new Map();
    final int iResult = await _channel.invokeMethod('getCurrentSignalStrength', htArguments);
    return iResult;
  }

  static Future<int> getFrequency() async {
    Map<String, String> htArguments = new Map();
    final int iResult = await _channel.invokeMethod('getFrequency', htArguments);
    return iResult;
  }

  static Future<String> getIP() async {
    Map<String, String> htArguments = new Map();
    final String sResult = await _channel.invokeMethod('getIP', htArguments);
    return sResult;
  }

  static Future<bool> removeWifiNetwork(String ssid) async {
    Map<String, String> htArguments = new Map();
    htArguments["ssid"] = ssid;
    final bool bResult = await _channel.invokeMethod('removeWifiNetwork', htArguments);
    return (bResult != null && bResult);
  }

  static Future<bool> isRegisteredWifiNetwork(String ssid) async {
    Map<String, String> htArguments = new Map();
    htArguments["ssid"] = ssid;
    final bool bResult = await _channel.invokeMethod('isRegisteredWifiNetwork', htArguments);
    return (bResult != null && bResult);
  }
}

class APClient {
  String ipAddr;
  String hwAddr;
  String device;
  bool isReachable;

  APClient.fromJson(Map<String, dynamic> json)
      : ipAddr = json['IPAddr'],
        hwAddr = json['HWAddr'],
        device = json['Device'],
        isReachable = json['isReachable'];

  Map<String, dynamic> toJson() => {
        'IPAddr': ipAddr,
        'HWAddr': hwAddr,
        'Device': device,
        'isReachable': isReachable,
      };

  static List<APClient> parse(String psString) {
    /// []

    List<APClient> htList = new List();

    List<dynamic> htMapClients = json.decode(psString);
//    List<Map<String, dynamic>> htMapClients = json.decode(psString);

    htMapClients.forEach((htMapClient) {
//    htMapClients.forEach((Map<String, dynamic> htMapClient) {
      htList.add(new APClient.fromJson(htMapClient));
    });

    return htList;
  }
}

class WifiNetwork {
  /// NOTE Parsing JSON :
  /// http://cogitas.net/parse-json-dart-flutter/

  String ssid;
  String bssid;
  String capabilities;
  int frequency;
  int level;
  int timestamp;
  String password;

  WifiNetwork.fromJson(Map<String, dynamic> json)
      : ssid = json['SSID'],
        bssid = json['BSSID'],
        capabilities = json['capabilities'],
        frequency = json['frequency'],
        level = json['level'],
        timestamp = json['timestamp'];

  Map<String, dynamic> toJson() => {
        'SSID': ssid,
        'BSSID': bssid,
        'capabilities': capabilities,
        'frequency': frequency,
        'level': level,
        'timestamp': timestamp,
      };

  static List<WifiNetwork> parse(String psString) {
    /// [{"SSID":"Florian","BSSID":"30:7e:cb:8c:48:e4","capabilities":"[WPA-PSK-CCMP+TKIP][ESS]","frequency":2462,"level":-64,"timestamp":201307720907},{"SSID":"Pi3-AP","BSSID":"b8:27:eb:b1:fa:e1","capabilities":"[WPA2-PSK-CCMP][ESS]","frequency":2437,"level":-66,"timestamp":201307720892},{"SSID":"AlternaDom-SonOff","BSSID":"b8:27:eb:98:b4:81","capabilities":"[WPA2-PSK-CCMP][ESS]","frequency":2437,"level":-86,"timestamp":201307720897},{"SSID":"SFR_1CF0_2GEXT","BSSID":"9c:3d:cf:58:98:07","capabilities":"[WPA-PSK-CCMP+TKIP][WPA2-PSK-CCMP+TKIP][WPS][ESS]","frequency":2412,"level":-87,"timestamp":201307720887},{"SSID":"Freebox-5CC952","BSSID":"f4:ca:e5:96:71:c4","capabilities":"[WPA-PSK-CCMP][ESS]","frequency":2442,"level":-90,"timestamp":201307720902}]

    List<WifiNetwork> htList = new List();

    List<dynamic> htMapNetworks = json.decode(psString);
//    List<Map<String, dynamic>> htMapNetworks = json.decode(psString);

    htMapNetworks.forEach((htMapNetwork) {
//    htMapNetworks.forEach((Map<String, dynamic> htMapNetwork) {
      htList.add(new WifiNetwork.fromJson(htMapNetwork));
    });

    return htList;
  }
}
