import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi_iot/wifi_iot.dart';

const String STA_DEFAULT_SSID = "STA_SSID";
const String STA_DEFAULT_PASSWORD = "STA_PASSWORD";
const NetworkSecurity STA_DEFAULT_SECURITY = NetworkSecurity.WPA;

const String AP_DEFAULT_SSID = "AP_SSID";
const String AP_DEFAULT_PASSWORD = "AP_PASSWORD";

void main() => runApp(MyApp());

enum ClientDialogAction {
  cancel,
  ok,
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isWiFiAPEnabled = false;
  WIFI_AP_STATE _iWiFiState = WIFI_AP_STATE.WIFI_AP_STATE_DISABLED;
  List<APClient> _htResultClient;
  bool _isWiFiAPSSIDHidden = false;
  String _sAPSSID = "";
  String _sPreSharedKey = "";
  String _sPreviousAPSSID = "";
  String _sPreviousPreSharedKey = "";

  List<WifiNetwork> _htResultNetwork;
  bool _isEnabled = false;
  bool _isConnected = false;
  Map<String, bool> _htIsNetworkRegistered = Map();
  String _sSSID = "";
  String _sBSSID = "";
  int _iCurrentSignalStrength = 0;
  int _iFrequency = 0;
  String _sIP = "";

  @override
  initState() {
    super.initState();
  }

  storeAndConnect(String psSSID, String psKey) async {
    await storeAPInfos();
    await WiFiForIoTPlugin.setWiFiAPSSID(psSSID);
    await WiFiForIoTPlugin.setWiFiAPPreSharedKey(psKey);
  }

  storeAPInfos() async {
    String sAPSSID;
    String sPreSharedKey;
    try {
      sAPSSID = await WiFiForIoTPlugin.getWiFiAPSSID();
    } on PlatformException {
      sAPSSID = "";
    }

    try {
      sPreSharedKey = await WiFiForIoTPlugin.getWiFiAPPreSharedKey();
    } on PlatformException {
      sPreSharedKey = "";
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _sPreviousAPSSID = sAPSSID;
      _sPreviousPreSharedKey = sPreSharedKey;
    });
  }

  restoreAPInfos() async {
    WiFiForIoTPlugin.setWiFiAPSSID(_sPreviousAPSSID);
    WiFiForIoTPlugin.setWiFiAPPreSharedKey(_sPreviousPreSharedKey);
  }

  getWiFiAPInfos() async {
    String sAPSSID;
    String sPreSharedKey;
    try {
      sAPSSID = await WiFiForIoTPlugin.getWiFiAPSSID();
    } on PlatformException {
      sAPSSID = "";
    }

    try {
      sPreSharedKey = await WiFiForIoTPlugin.getWiFiAPPreSharedKey();
    } on PlatformException {
      sPreSharedKey = "";
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _sAPSSID = sAPSSID;
      _sPreSharedKey = sPreSharedKey;
    });
  }

  isWiFiAPSSIDHidden() async {
    bool isWiFiAPSSIDHidden;
    try {
      isWiFiAPSSIDHidden = await WiFiForIoTPlugin.isWiFiAPSSIDHidden();
    } on PlatformException {
      isWiFiAPSSIDHidden = false;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _isWiFiAPSSIDHidden = isWiFiAPSSIDHidden;
    });
  }

  isWiFiAPEnabled() async {
    bool isWiFiAPEnabled;
    try {
      isWiFiAPEnabled = await WiFiForIoTPlugin.isWiFiAPEnabled();
    } on PlatformException {
      isWiFiAPEnabled = false;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _isWiFiAPEnabled = isWiFiAPEnabled;
    });
  }

  getWiFiAPState() async {
    int iWiFiState;
    try {
      iWiFiState = await WiFiForIoTPlugin.getWiFiAPState();
    } on PlatformException {
      iWiFiState = WIFI_AP_STATE.WIFI_AP_STATE_FAILED.index;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      if (iWiFiState == WIFI_AP_STATE.WIFI_AP_STATE_DISABLING.index) {
        _iWiFiState = WIFI_AP_STATE.WIFI_AP_STATE_DISABLING;
      } else if (iWiFiState == WIFI_AP_STATE.WIFI_AP_STATE_DISABLED.index) {
        _iWiFiState = WIFI_AP_STATE.WIFI_AP_STATE_DISABLED;
      } else if (iWiFiState == WIFI_AP_STATE.WIFI_AP_STATE_ENABLING.index) {
        _iWiFiState = WIFI_AP_STATE.WIFI_AP_STATE_ENABLING;
      } else if (iWiFiState == WIFI_AP_STATE.WIFI_AP_STATE_ENABLED.index) {
        _iWiFiState = WIFI_AP_STATE.WIFI_AP_STATE_ENABLED;
      } else if (iWiFiState == WIFI_AP_STATE.WIFI_AP_STATE_FAILED.index) {
        _iWiFiState = WIFI_AP_STATE.WIFI_AP_STATE_FAILED;
      }
    });
  }

  getClientList(bool onlyReachables, int reachableTimeout) async {
    List<APClient> htResultClient;
    try {
      htResultClient = await WiFiForIoTPlugin.getClientList(onlyReachables, reachableTimeout);
    } on PlatformException {
      htResultClient = List<APClient>();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _htResultClient = htResultClient;
    });
  }

  loadWifiList() async {
    List<WifiNetwork> htResultNetwork;
    try {
      htResultNetwork = await WiFiForIoTPlugin.loadWifiList();
    } on PlatformException {
      htResultNetwork = List<WifiNetwork>();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _htResultNetwork = htResultNetwork;
    });
  }

  isEnabled() async {
    bool isEnabled;
    try {
      isEnabled = await WiFiForIoTPlugin.isEnabled();
    } on PlatformException {
      isEnabled = false;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _isEnabled = isEnabled;
    });
  }

  isConnected() async {
    bool isConnected;
    try {
      isConnected = await WiFiForIoTPlugin.isConnected();
    } on PlatformException {
      isConnected = false;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _isConnected = isConnected;
    });
  }

  getSSID() async {
    String ssid;
    try {
      ssid = await WiFiForIoTPlugin.getSSID();
    } on PlatformException {
      ssid = "";
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _sSSID = ssid;
    });
  }

  getBSSID() async {
    String bssid;
    try {
      bssid = await WiFiForIoTPlugin.getBSSID();
    } on PlatformException {
      bssid = "";
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _sBSSID = bssid;
    });
  }

  getCurrentSignalStrength() async {
    int iCurrentSignalStrength;
    try {
      iCurrentSignalStrength = await WiFiForIoTPlugin.getCurrentSignalStrength();
    } on PlatformException {
      iCurrentSignalStrength = 0;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _iCurrentSignalStrength = iCurrentSignalStrength;
    });
  }

  getFrequency() async {
    int iFrequency;
    try {
      iFrequency = await WiFiForIoTPlugin.getFrequency();
    } on PlatformException {
      iFrequency = 0;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _iFrequency = iFrequency;
    });
  }

  getIP() async {
    String sIP;
    try {
      sIP = await WiFiForIoTPlugin.getIP();
    } on PlatformException {
      sIP = "";
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _sIP = sIP;
    });
  }

  isRegisteredWifiNetwork(String ssid) async {
    bool bIsRegistered;
    try {
      bIsRegistered = await WiFiForIoTPlugin.isRegisteredWifiNetwork(ssid);
    } on PlatformException {
      bIsRegistered = false;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _htIsNetworkRegistered[ssid] = bIsRegistered;
    });
  }

  void showClientList() async {
    /// Refresh the list
    await getClientList(false, 300);

    /// Show in console
    if (_htResultClient != null && _htResultClient.length > 0) {
      _htResultClient.forEach((oClient) {
        print("************************");
        print("Client :");
        print("ipAddr = '${oClient.ipAddr}'");
        print("hwAddr = '${oClient.hwAddr}'");
        print("device = '${oClient.device}'");
        print("isReachable = '${oClient.isReachable}'");
      });
      print("************************");
    }
  }

  List<Widget> getActionsForAndroid() {
    List<Widget> htActions = List();
    if (_isConnected) {
      PopupCommand oCmdDisconnect = PopupCommand("Disconnect", "");
      PopupCommand oCmdRemove = PopupCommand("Remove", _sSSID);

      htActions.add(
        PopupMenuButton<PopupCommand>(
          onSelected: (PopupCommand poCommand) {
            switch (poCommand.command) {
              case "Disconnect":
                WiFiForIoTPlugin.disconnect();
                break;
              case "Remove":
                WiFiForIoTPlugin.removeWifiNetwork(_sSSID);
                break;
              default:
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuItem<PopupCommand>>[
                PopupMenuItem<PopupCommand>(
                  value: oCmdDisconnect,
                  child: const Text('Disconnect'),
                ),
                PopupMenuItem<PopupCommand>(
                  value: oCmdRemove,
                  child: const Text('Dissocier'),
                ),
                PopupMenuItem<PopupCommand>(
                  enabled: false,
                  child: Text(_sIP),
                ),
              ],
        ),
      );
    }
    return htActions;
  }

  Widget getWidgetsForAndroid() {
    isConnected();
    if (_isConnected != null && _isConnected) {
      _htResultNetwork = null;
    }

    if (_htResultNetwork != null && _htResultNetwork.length > 0) {
      List<ListTile> htNetworks = List();

      _htResultNetwork.forEach((oNetwork) {
        PopupCommand oCmdConnect = PopupCommand("Connect", oNetwork.ssid);
        PopupCommand oCmdRemove = PopupCommand("Remove", oNetwork.ssid);

        List<PopupMenuItem<PopupCommand>> htPopupMenuItems = List();

        htPopupMenuItems.add(
          PopupMenuItem<PopupCommand>(
            value: oCmdConnect,
            child: const Text('Connecter'),
          ),
        );

        setState(() {
          isRegisteredWifiNetwork(oNetwork.ssid);
          if (_htIsNetworkRegistered.containsKey(oNetwork.ssid) && _htIsNetworkRegistered[oNetwork.ssid]) {
            htPopupMenuItems.add(
              PopupMenuItem<PopupCommand>(
                value: oCmdRemove,
                child: const Text('Dissocier'),
              ),
            );
          }

          htNetworks.add(
            ListTile(
              title: Text("" + oNetwork.ssid + ((_htIsNetworkRegistered.containsKey(oNetwork.ssid) && _htIsNetworkRegistered[oNetwork.ssid]) ? " *" : "")),
              trailing: PopupMenuButton<PopupCommand>(
                padding: EdgeInsets.zero,
                onSelected: (PopupCommand poCommand) {
                  switch (poCommand.command) {
                    case "Connect":
                      WiFiForIoTPlugin.connect(STA_DEFAULT_SSID, password: STA_DEFAULT_PASSWORD, joinOnce: true, security: STA_DEFAULT_SECURITY);
                      break;
                    case "Remove":
                      WiFiForIoTPlugin.removeWifiNetwork(poCommand.argument);
                      break;
                    default:
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => htPopupMenuItems,
              ),
            ),
          );
        });
      });

      return ListView(
        padding: kMaterialListPadding,
        children: htNetworks,
      );
    } else {
      return SingleChildScrollView(
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children: getButtonWidgetsForAndroid(),
          ),
        ),
      );
    }
  }

  List<Widget> getButtonWidgetsForAndroid() {
    List<Widget> htPrimaryWidgets = List();

    ///
    isEnabled();
    if (_isEnabled != null && _isEnabled) {
      htPrimaryWidgets.add(Text("Wifi Enabled"));
      htPrimaryWidgets.add(
        RaisedButton(
          child: Text("Disable"),
          onPressed: () {
            WiFiForIoTPlugin.setEnabled(false);
          },
        ),
      );

      ///
      isConnected();
      if (_isConnected != null && _isConnected) {
        getSSID();
        getBSSID();
        getCurrentSignalStrength();
        getFrequency();
        getIP();

        htPrimaryWidgets.addAll(<Widget>[
          Text("Connected"),
          Text("SSID : $_sSSID"),
          Text("BSSID : $_sBSSID"),
          Text("Signal : $_iCurrentSignalStrength"),
          Text("Frequency : $_iFrequency"),
          Text("IP : $_sIP"),
          RaisedButton(
            child: Text("Disconnect"),
            onPressed: () {
              WiFiForIoTPlugin.disconnect();
            },
          ),
        ]);
      } else {
        htPrimaryWidgets.addAll(<Widget>[
          Text("Disconnected"),
          RaisedButton(
            child: Text("SCAN"),
            onPressed: () {
              loadWifiList();
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text("Use WiFi"),
                onPressed: () {
                  WiFiForIoTPlugin.forceWifiUsage(true);
                },
              ),
              RaisedButton(
                child: Text("Use 3G/4G"),
                onPressed: () {
                  WiFiForIoTPlugin.forceWifiUsage(false);
                },
              ),
            ],
          )
        ]);
      }
    } else {
      htPrimaryWidgets.addAll(<Widget>[
        Text("Wifi Disabled"),
        RaisedButton(
          child: Text("Enable"),
          onPressed: () {
            WiFiForIoTPlugin.setEnabled(true);
          },
        ),
      ]);
    }

    ///
    htPrimaryWidgets.add(Divider(
      height: 32.0,
    ));

    ///
    getWiFiAPState();
    htPrimaryWidgets.addAll(<Widget>[
      Text("WiFi AP State"),
      Text("$_iWiFiState"),
    ]);

    ///
    isWiFiAPEnabled();
    if (_isWiFiAPEnabled != null && _isWiFiAPEnabled) {
      htPrimaryWidgets.addAll(<Widget>[
        Text("Wifi AP Enabled"),
        RaisedButton(
          child: Text("Disable"),
          onPressed: () {
            WiFiForIoTPlugin.setWiFiAPEnabled(false);
          },
        ),
      ]);

      isWiFiAPSSIDHidden();
      if (_isWiFiAPSSIDHidden != null && _isWiFiAPSSIDHidden) {
        htPrimaryWidgets.add(Text("SSID is hidden"));
      } else {
        htPrimaryWidgets.add(Text("SSID is visible"));
      }

      ///
      getWiFiAPInfos();
      htPrimaryWidgets.addAll(<Widget>[
        Text("SSID : $_sAPSSID"),
        Text("KEY  : $_sPreSharedKey"),
      ]);
    } else {
      htPrimaryWidgets.addAll(<Widget>[
        Text("Wifi AP Disabled"),
        RaisedButton(
          child: Text("Enable"),
          onPressed: () {
            WiFiForIoTPlugin.setWiFiAPEnabled(true);
          },
        ),
      ]);

      isWiFiAPSSIDHidden();
      if (_isWiFiAPSSIDHidden != null && _isWiFiAPSSIDHidden) {
        htPrimaryWidgets.addAll(<Widget>[
          Text("SSID is hidden"),
          RaisedButton(
            child: Text("Show"),
            onPressed: () {
              WiFiForIoTPlugin.setWiFiAPSSIDHidden(false);
            },
          ),
        ]);
      } else {
        htPrimaryWidgets.addAll(<Widget>[
          Text("SSID is visible"),
          RaisedButton(
            child: Text("Hide"),
            onPressed: () {
              WiFiForIoTPlugin.setWiFiAPSSIDHidden(true);
            },
          ),
        ]);
      }

      ///
      getWiFiAPInfos();
      htPrimaryWidgets.addAll(<Widget>[
        Text("SSID : $_sAPSSID"),
        Text("KEY  : $_sPreSharedKey"),
        RaisedButton(
          child: Text("Set AP info ($AP_DEFAULT_SSID/$AP_DEFAULT_PASSWORD)"),
          onPressed: () {
            storeAndConnect(AP_DEFAULT_SSID, AP_DEFAULT_PASSWORD);
          },
        ),
        Text("AP SSID stored : $_sPreviousAPSSID"),
        Text("KEY stored : $_sPreviousPreSharedKey"),
        RaisedButton(
          child: Text("Store AP infos"),
          onPressed: () {
            storeAPInfos();
          },
        ),
        RaisedButton(
          child: Text("Restore AP infos"),
          onPressed: () {
            restoreAPInfos();
          },
        ),
      ]);
    }

    if (_iWiFiState == WIFI_AP_STATE.WIFI_AP_STATE_ENABLED) {
      htPrimaryWidgets.add(
        RaisedButton(
          child: Text("Get Client List"),
          onPressed: () {
            showClientList();
          },
        ),
      );
    }

    return htPrimaryWidgets;
  }

  List<Widget> getActionsForiOS() {
    List<Widget> htActions = List();
    if (_isConnected) {
//      PopupCommand oCmdDisconnect = PopupCommand("Disconnect", "");
//      PopupCommand oCmdRemove = PopupCommand("Remove", _sSSID);
//
//      htActions.add(
//        PopupMenuButton<PopupCommand>(
//          onSelected: (PopupCommand poCommand) {
//            switch (poCommand.command) {
//              case "Disconnect":
//                WiFiForIoTPlugin.disconnect();
//                break;
//              case "Remove":
//                WiFiForIoTPlugin.removeWifiNetwork(_sSSID);
//                break;
//              default:
//                break;
//            }
//          },
//          itemBuilder: (BuildContext context) => <PopupMenuItem<PopupCommand>>[
//            PopupMenuItem<PopupCommand>(
//              value: oCmdDisconnect,
//              child: const Text('Disconnect'),
//            ),
//            PopupMenuItem<PopupCommand>(
//              value: oCmdRemove,
//              child: const Text('Dissocier'),
//            ),
//            PopupMenuItem<PopupCommand>(
//              enabled: false,
//              child: Text(_sIP),
//            ),
//          ],
//        ),
//      );
    }
    return htActions;
  }

  Widget getWidgetsForiOS() {
    isConnected();

    return SingleChildScrollView(
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: getButtonWidgetsForiOS(),
        ),
      ),
    );
  }

  List<Widget> getButtonWidgetsForiOS() {
    List<Widget> htPrimaryWidgets = List();

    ///
    isEnabled();
    if (_isEnabled != null && _isEnabled) {
      htPrimaryWidgets.add(Text("Wifi Enabled"));
//      htPrimaryWidgets.add(
//        RaisedButton(
//          child: Text("Disable"),
//          onPressed: () {
//            WiFiForIoTPlugin.setEnabled(false);
//          },
//        ),
//      );

//      ///
//      htPrimaryWidgets.add(
//        RaisedButton(
//          child: Text("SCAN"),
//          onPressed: () {
//            loadWifiList();
//          },
//        ),
//      );

//      ///
//      htPrimaryWidgets.addAll(<Widget>[
//        Row(
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
//            RaisedButton(
//              child: Text("Use WiFi"),
//              onPressed: () {
//                WiFiForIoTPlugin.forceWifiUsage(true);
//              },
//            ),
//            RaisedButton(
//              child: Text("Use 3G/4G"),
//              onPressed: () {
//                WiFiForIoTPlugin.forceWifiUsage(false);
//              },
//            ),
//          ],
//        )
//      ]);
      ///
      isConnected();
      if (_isConnected != null && _isConnected) {
        getSSID();
//      getBSSID();
//      getCurrentSignalStrength();
//      getFrequency();
//      getIP();

        htPrimaryWidgets.addAll(<Widget>[
          Text("Connected"),
          Text("SSID : $_sSSID"),
//        Text("BSSID : $_sBSSID"),
//        Text("Signal : $_iCurrentSignalStrength"),
//        Text("Frequency : $_iFrequency"),
//        Text("IP : $_sIP"),
        ]);

        if (_sSSID == STA_DEFAULT_SSID) {
          htPrimaryWidgets.addAll(<Widget>[
            RaisedButton(
              child: Text("Disconnect"),
              onPressed: () {
                WiFiForIoTPlugin.disconnect();
              },
            ),
          ]);
        } else {
          htPrimaryWidgets.addAll(<Widget>[
            RaisedButton(
              child: Text("Connect to '$AP_DEFAULT_SSID'"),
              onPressed: () {
                WiFiForIoTPlugin.connect(STA_DEFAULT_SSID, password: STA_DEFAULT_PASSWORD, joinOnce: true, security: NetworkSecurity.WPA);
              },
            ),
          ]);
        }
      } else {
        htPrimaryWidgets.addAll(<Widget>[
          Text("Disconnected"),
          RaisedButton(
            child: Text("Connect to '$AP_DEFAULT_SSID'"),
            onPressed: () {
              WiFiForIoTPlugin.connect(STA_DEFAULT_SSID, password: STA_DEFAULT_PASSWORD, joinOnce: true, security: NetworkSecurity.WPA);
            },
          ),
        ]);
      }
    } else {
      htPrimaryWidgets.addAll(<Widget>[
        Text("Wifi Disabled ?"),
//        RaisedButton(
//          child: Text("Enable"),
//          onPressed: () {
//            WiFiForIoTPlugin.setEnabled(true);
//          },
//        ),
        RaisedButton(
          child: Text("Connect to '$AP_DEFAULT_SSID'"),
          onPressed: () {
            WiFiForIoTPlugin.connect(STA_DEFAULT_SSID, password: STA_DEFAULT_PASSWORD, joinOnce: true, security: NetworkSecurity.WPA);
          },
        ),
      ]);
    }

    ///
    htPrimaryWidgets.add(Divider(
      height: 32.0,
    ));

//    ///
//    getWiFiAPState();
//    htPrimaryWidgets.addAll(<Widget>[
//      Text("WiFi AP State"),
//      Text("$_iWiFiState"),
//    ]);
//
//    ///
//    isWiFiAPEnabled();
//    if (_isWiFiAPEnabled != null && _isWiFiAPEnabled) {
//      htPrimaryWidgets.addAll(<Widget>[
//        Text("Wifi AP Enabled"),
//        RaisedButton(
//          child: Text("Disable"),
//          onPressed: () {
//            WiFiForIoTPlugin.setWiFiAPEnabled(false);
//          },
//        ),
//      ]);
//
//      isWiFiAPSSIDHidden();
//      if (_isWiFiAPSSIDHidden != null && _isWiFiAPSSIDHidden) {
//        htPrimaryWidgets.add(Text("SSID is hidden"));
//      } else {
//        htPrimaryWidgets.add(Text("SSID is visible"));
//      }
//
//      ///
//      getWiFiAPInfos();
//      htPrimaryWidgets.addAll(<Widget>[
//        Text("SSID : $_sAPSSID"),
//        Text("KEY  : $_sPreSharedKey"),
//      ]);
//    } else {
//      htPrimaryWidgets.addAll(<Widget>[
//        Text("Wifi AP Disabled"),
//        RaisedButton(
//          child: Text("Enable"),
//          onPressed: () {
//            WiFiForIoTPlugin.setWiFiAPEnabled(true);
//          },
//        ),
//      ]);
//
//      isWiFiAPSSIDHidden();
//      if (_isWiFiAPSSIDHidden != null && _isWiFiAPSSIDHidden) {
//        htPrimaryWidgets.addAll(<Widget>[
//          Text("SSID is hidden"),
//          RaisedButton(
//            child: Text("Show"),
//            onPressed: () {
//              WiFiForIoTPlugin.setWiFiAPSSIDHidden(false);
//            },
//          ),
//        ]);
//      } else {
//        htPrimaryWidgets.addAll(<Widget>[
//          Text("SSID is visible"),
//          RaisedButton(
//            child: Text("Hide"),
//            onPressed: () {
//              WiFiForIoTPlugin.setWiFiAPSSIDHidden(true);
//            },
//          ),
//        ]);
//      }
//
//      ///
//      getWiFiAPInfos();
//      htPrimaryWidgets.addAll(<Widget>[
//        Text("SSID : $_sAPSSID"),
//        Text("KEY  : $_sPreSharedKey"),
//        RaisedButton(
//          child: Text("Set AP info ($AP_DEFAULT_SSID/$AP_DEFAULT_PASSWORD)"),
//          onPressed: () {
//            storeAndConnect(AP_DEFAULT_SSID, AP_DEFAULT_PASSWORD);
//          },
//        ),
//        Text("AP SSID stored : $_sPreviousAPSSID"),
//        Text("KEY stored : $_sPreviousPreSharedKey"),
//        RaisedButton(
//          child: Text("Store AP infos"),
//          onPressed: () {
//            storeAPInfos();
//          },
//        ),
//        RaisedButton(
//          child: Text("Restore AP infos"),
//          onPressed: () {
//            restoreAPInfos();
//          },
//        ),
//      ]);
//    }
//
//    if (_iWiFiState == WIFI_AP_STATE.WIFI_AP_STATE_ENABLED) {
//      htPrimaryWidgets.add(
//        RaisedButton(
//          child: Text("Get Client List"),
//          onPressed: () {
//            showClientList();
//          },
//        ),
//      );
//    }

    return htPrimaryWidgets;
  }

  @override
  Widget build(BuildContext poContext) {
    final defaultTheme = Theme.of(context);
    if (defaultTheme.platform == TargetPlatform.iOS) {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text('Plugin IoT Wifi app for iOS'),
            actions: getActionsForiOS(),
          ),
          body: getWidgetsForiOS(),
        ),
      );
    } else if (defaultTheme.platform == TargetPlatform.android) {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text('Plugin IoT Wifi app for Android'),
            actions: getActionsForAndroid(),
          ),
          body: getWidgetsForAndroid(),
        ),
      );
    }
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Plugin IoT Wifi app for ???'),
        ),
      ),
    );
  }
}

class PopupCommand {
  String command;
  String argument;

  PopupCommand(this.command, this.argument) {
    ///
  }
}
