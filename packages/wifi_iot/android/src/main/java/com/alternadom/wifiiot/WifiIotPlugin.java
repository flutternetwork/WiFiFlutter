package com.alternadom.wifiiot;

import android.Manifest;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.net.ConnectivityManager;
import android.net.MacAddress;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.NetworkRequest;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiConfiguration;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.net.wifi.WifiNetworkSpecifier;
import android.net.wifi.WifiNetworkSuggestion;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import info.whitebyte.hotspotmanager.ClientScanResult;
import info.whitebyte.hotspotmanager.FinishScanListener;
import info.whitebyte.hotspotmanager.WifiApManager;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener;
import io.flutter.plugin.common.PluginRegistry.ViewDestroyListener;
import io.flutter.view.FlutterNativeView;
import java.util.ArrayList;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/** WifiIotPlugin */
public class WifiIotPlugin
    implements FlutterPlugin,
        ActivityAware,
        MethodCallHandler,
        EventChannel.StreamHandler,
        RequestPermissionsResultListener {
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private EventChannel eventChannel;

  private WifiManager moWiFi;
  private Context moContext;
  private WifiApManager moWiFiAPManager;
  private Activity moActivity;
  private BroadcastReceiver receiver;
  private WifiManager.LocalOnlyHotspotReservation apReservation;
  private ConnectivityManager.NetworkCallback networkCallback;
  private List<WifiNetworkSuggestion> networkSuggestions;
  private List<String> ssidsToBeRemovedOnExit = new ArrayList<String>();
  private List<WifiNetworkSuggestion> suggestionsToBeRemovedOnExit = new ArrayList<>();

  // Permission request management
  private boolean requestingPermission = false;
  private Result permissionRequestResultCallback = null;
  private ArrayList<Object> permissionRequestCookie = new ArrayList<>();
  private static final int PERMISSIONS_REQUEST_CODE_ACCESS_FINE_LOCATION_LOAD_WIFI_LIST = 65655435;
  private static final int PERMISSIONS_REQUEST_CODE_ACCESS_FINE_LOCATION_ON_LISTEN = 65655436;
  private static final int PERMISSIONS_REQUEST_CODE_ACCESS_FINE_LOCATION_FIND_AND_CONNECT =
      65655437;
  private static final int PERMISSIONS_REQUEST_CODE_ACCESS_NETWORK_STATE_IS_CONNECTED = 65655438;

  // initialize members of this class with Context
  private void initWithContext(Context context) {
    moContext = context;
    moWiFi = (WifiManager) moContext.getApplicationContext().getSystemService(Context.WIFI_SERVICE);
    moWiFiAPManager = new WifiApManager(moContext.getApplicationContext());
  }

  // initialize members of this class with Activity
  private void initWithActivity(Activity activity) {
    moActivity = activity;
  }

  // cleanup
  private void cleanup() {
    if (!ssidsToBeRemovedOnExit.isEmpty()) {
      List<WifiConfiguration> wifiConfigList = moWiFi.getConfiguredNetworks();
      for (String ssid : ssidsToBeRemovedOnExit) {
        for (WifiConfiguration wifiConfig : wifiConfigList) {
          if (wifiConfig.SSID.equals(ssid)) {
            moWiFi.removeNetwork(wifiConfig.networkId);
          }
        }
      }
    }
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && !suggestionsToBeRemovedOnExit.isEmpty()) {
      moWiFi.removeNetworkSuggestions(suggestionsToBeRemovedOnExit);
    }
    // setting all members to null to avoid memory leaks
    channel = null;
    eventChannel = null;
    moActivity = null;
    moContext = null;
    moWiFi = null;
    moWiFiAPManager = null;
  }

  /** Plugin registration. This is used for registering with v1 Android embedding. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "wifi_iot");
    final EventChannel eventChannel =
        new EventChannel(registrar.messenger(), "plugins.wififlutter.io/wifi_scan");
    final WifiIotPlugin wifiIotPlugin = new WifiIotPlugin();
    wifiIotPlugin.initWithActivity(registrar.activity());
    wifiIotPlugin.initWithContext(registrar.activeContext());
    eventChannel.setStreamHandler(wifiIotPlugin);
    channel.setMethodCallHandler(wifiIotPlugin);

    registrar.addViewDestroyListener(
        new ViewDestroyListener() {
          @Override
          public boolean onViewDestroy(FlutterNativeView view) {
            wifiIotPlugin.cleanup();
            return false;
          }
        });
    registrar.addRequestPermissionsResultListener(wifiIotPlugin);
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    // initialize method and event channel and set handlers
    channel = new MethodChannel(binding.getBinaryMessenger(), "wifi_iot");
    eventChannel =
        new EventChannel(binding.getBinaryMessenger(), "plugins.wififlutter.io/wifi_scan");
    channel.setMethodCallHandler(this);
    eventChannel.setStreamHandler(this);

    // initializeWithContext
    initWithContext(binding.getApplicationContext());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    // set null as channel handlers
    channel.setMethodCallHandler(null);
    eventChannel.setStreamHandler(null);

    // set member to null
    cleanup();
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    // init with activity
    initWithActivity(binding.getActivity());
    binding.addRequestPermissionsResultListener(this);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    // set activity to null
    moActivity = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    // init with activity
    initWithActivity(binding.getActivity());
    binding.addRequestPermissionsResultListener(this);
  }

  @Override
  public void onDetachedFromActivity() {
    // set activity to null
    moActivity = null;
  }

  @Override
  public boolean onRequestPermissionsResult(
      int requestCode, String[] permissions, int[] grantResults) {
    final boolean wasPermissionGranted =
        grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED;
    switch (requestCode) {
      case PERMISSIONS_REQUEST_CODE_ACCESS_FINE_LOCATION_LOAD_WIFI_LIST:
        if (wasPermissionGranted) {
          _loadWifiList(permissionRequestResultCallback);
        } else {
          permissionRequestResultCallback.error(
              "WifiIotPlugin.Permission", "Fine location permission denied", null);
        }
        requestingPermission = false;
        return true;

      case PERMISSIONS_REQUEST_CODE_ACCESS_FINE_LOCATION_ON_LISTEN:
        if (wasPermissionGranted) {
          final EventChannel.EventSink eventSink =
              (EventChannel.EventSink) permissionRequestCookie.get(0);
          _onListen(eventSink);
        }
        requestingPermission = false;
        return true;

      case PERMISSIONS_REQUEST_CODE_ACCESS_FINE_LOCATION_FIND_AND_CONNECT:
        if (wasPermissionGranted) {
          final MethodCall poCall = (MethodCall) permissionRequestCookie.get(0);
          _findAndConnect(poCall, permissionRequestResultCallback);
        } else {
          permissionRequestResultCallback.error(
              "WifiIotPlugin.Permission", "Fine location permission denied", null);
        }
        requestingPermission = false;
        return true;

      case PERMISSIONS_REQUEST_CODE_ACCESS_NETWORK_STATE_IS_CONNECTED:
        if (wasPermissionGranted) {
          _isConnected(permissionRequestResultCallback);
        } else {
          permissionRequestResultCallback.error(
              "WifiIotPlugin.Permission", "Network state permission denied", null);
        }
        requestingPermission = false;
        return true;
    }
    requestingPermission = false;
    return false;
  }

  @Override
  public void onMethodCall(MethodCall poCall, Result poResult) {
    switch (poCall.method) {
      case "loadWifiList":
        loadWifiList(poResult);
        break;
      case "forceWifiUsage":
        forceWifiUsage(poCall, poResult);
        break;
      case "isEnabled":
        isEnabled(poResult);
        break;
      case "setEnabled":
        setEnabled(poCall, poResult);
        break;
      case "connect":
        connect(poCall, poResult);
        break;
      case "registerWifiNetwork":
        registerWifiNetwork(poCall, poResult);
        break;
      case "findAndConnect":
        findAndConnect(poCall, poResult);
        break;
      case "isConnected":
        isConnected(poResult);
        break;
      case "disconnect":
        disconnect(poResult);
        break;
      case "getSSID":
        getSSID(poResult);
        break;
      case "getBSSID":
        getBSSID(poResult);
        break;
      case "getCurrentSignalStrength":
        getCurrentSignalStrength(poResult);
        break;
      case "getFrequency":
        getFrequency(poResult);
        break;
      case "getIP":
        getIP(poResult);
        break;
      case "removeWifiNetwork":
        removeWifiNetwork(poCall, poResult);
        break;
      case "isRegisteredWifiNetwork":
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q)
          isRegisteredWifiNetwork(poCall, poResult);
        else
          poResult.error(
              "Error",
              "isRegisteredWifiNetwork not supported for Android SDK " + Build.VERSION.SDK_INT,
              null);
        break;
      case "isWiFiAPEnabled":
        isWiFiAPEnabled(poResult);
        break;
      case "setWiFiAPEnabled":
        setWiFiAPEnabled(poCall, poResult);
        break;
      case "getWiFiAPState":
        getWiFiAPState(poResult);
        break;
      case "getClientList":
        getClientList(poCall, poResult);
        break;
      case "getWiFiAPSSID":
        getWiFiAPSSID(poResult);
        break;
      case "setWiFiAPSSID":
        setWiFiAPSSID(poCall, poResult);
        break;
      case "isSSIDHidden":
        isSSIDHidden(poResult);
        break;
      case "setSSIDHidden":
        setSSIDHidden(poCall, poResult);
        break;
      case "getWiFiAPPreSharedKey":
        getWiFiAPPreSharedKey(poResult);
        break;
      case "setWiFiAPPreSharedKey":
        setWiFiAPPreSharedKey(poCall, poResult);
        break;
      case "showWritePermissionSettings":
        showWritePermissionSettings(poCall, poResult);
        break;
      default:
        poResult.notImplemented();
        break;
    }
  }

  /**
   * The network's SSID. Can either be an ASCII string, which must be enclosed in double quotation
   * marks (e.g., {@code "MyNetwork"}), or a string of hex digits, which are not enclosed in quotes
   * (e.g., {@code 01a243f405}).
   */
  private void getWiFiAPSSID(Result poResult) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
      android.net.wifi.WifiConfiguration oWiFiConfig = moWiFiAPManager.getWifiApConfiguration();

      if (oWiFiConfig != null && oWiFiConfig.SSID != null) {
        poResult.success(oWiFiConfig.SSID);
        return;
      }

      poResult.error("Exception", "SSID not found", null);
    } else {
      poResult.error(
          "Exception [getWiFiAPSSID]",
          "Getting SSID name is not supported on API level >= 26",
          null);
    }
  }

  private void setWiFiAPSSID(MethodCall poCall, Result poResult) {
    String sAPSSID = poCall.argument("ssid");

    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
      android.net.wifi.WifiConfiguration oWiFiConfig = moWiFiAPManager.getWifiApConfiguration();

      oWiFiConfig.SSID = sAPSSID;

      moWiFiAPManager.setWifiApConfiguration(oWiFiConfig);

      poResult.success(null);
    } else {
      poResult.error(
          "Exception [setWiFiAPSSID]",
          "Setting SSID name is not supported on API level >= 26",
          null);
    }
  }

  /**
   * This is a network that does not broadcast its SSID, so an SSID-specific probe request must be
   * used for scans.
   */
  private void isSSIDHidden(Result poResult) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
      android.net.wifi.WifiConfiguration oWiFiConfig = moWiFiAPManager.getWifiApConfiguration();

      if (oWiFiConfig != null && oWiFiConfig.hiddenSSID) {
        poResult.success(oWiFiConfig.hiddenSSID);
        return;
      }

      poResult.error("Exception [isSSIDHidden]", "Wifi AP not Supported", null);
    } else {
      poResult.error(
          "Exception [isSSIDHidden]",
          "Getting SSID visibility is not supported on API level >= 26",
          null);
    }
  }

  private void setSSIDHidden(MethodCall poCall, Result poResult) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
      boolean isSSIDHidden = poCall.argument("hidden");

      android.net.wifi.WifiConfiguration oWiFiConfig = moWiFiAPManager.getWifiApConfiguration();

      oWiFiConfig.hiddenSSID = isSSIDHidden;

      moWiFiAPManager.setWifiApConfiguration(oWiFiConfig);

      poResult.success(null);
    } else {
      poResult.error(
          "Exception [setSSIDHidden]",
          "Setting SSID visibility is not supported on API level >= 26",
          null);
    }
  }

  /**
   * Pre-shared key for use with WPA-PSK. Either an ASCII string enclosed in double quotation marks
   * (e.g., {@code "abcdefghij"} for PSK passphrase or a string of 64 hex digits for raw PSK.
   *
   * <p>When the value of this key is read, the actual key is not returned, just a "*" if the key
   * has a value, or the null string otherwise.
   */
  private void getWiFiAPPreSharedKey(Result poResult) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
      android.net.wifi.WifiConfiguration oWiFiConfig = moWiFiAPManager.getWifiApConfiguration();

      if (oWiFiConfig != null && oWiFiConfig.preSharedKey != null) {
        poResult.success(oWiFiConfig.preSharedKey);
        return;
      }

      poResult.error("Exception", "Wifi AP not Supported", null);
    } else {
      poResult.error(
          "Exception [getWiFIAPPreSharedKey]",
          "Getting WiFi AP password is not supported on API level >= 26",
          null);
    }
  }

  private void setWiFiAPPreSharedKey(MethodCall poCall, Result poResult) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
      String sPreSharedKey = poCall.argument("preSharedKey");

      android.net.wifi.WifiConfiguration oWiFiConfig = moWiFiAPManager.getWifiApConfiguration();

      oWiFiConfig.preSharedKey = sPreSharedKey;

      moWiFiAPManager.setWifiApConfiguration(oWiFiConfig);

      poResult.success(null);
    } else {
      poResult.error(
          "Exception [setWiFiAPPreSharedKey]",
          "Setting WiFi password is not supported on API level >= 26",
          null);
    }
  }

  /**
   * Gets a list of the clients connected to the Hotspot *** getClientList : param onlyReachables
   * {@code false} if the list should contain unreachable (probably disconnected) clients, {@code
   * true} otherwise param reachableTimeout Reachable Timout in miliseconds, 300 is default param
   * finishListener, Interface called when the scan method finishes
   */
  private void getClientList(MethodCall poCall, final Result poResult) {
    Boolean onlyReachables = false;
    if (poCall.argument("onlyReachables") != null) {
      onlyReachables = poCall.argument("onlyReachables");
    }

    Integer reachableTimeout = 300;
    if (poCall.argument("reachableTimeout") != null) {
      reachableTimeout = poCall.argument("reachableTimeout");
    }

    final Boolean finalOnlyReachables = onlyReachables;
    FinishScanListener oFinishScanListener =
        new FinishScanListener() {
          @Override
          public void onFinishScan(final ArrayList<ClientScanResult> clients) {
            try {
              JSONArray clientArray = new JSONArray();

              for (ClientScanResult client : clients) {
                JSONObject clientObject = new JSONObject();

                Boolean clientIsReachable = client.isReachable();
                Boolean shouldReturnCurrentClient = true;
                if (finalOnlyReachables.booleanValue()) {
                  if (!clientIsReachable.booleanValue()) {
                    shouldReturnCurrentClient = Boolean.valueOf(false);
                  }
                }
                if (shouldReturnCurrentClient.booleanValue()) {
                  try {
                    clientObject.put("IPAddr", client.getIpAddr());
                    clientObject.put("HWAddr", client.getHWAddr());
                    clientObject.put("Device", client.getDevice());
                    clientObject.put("isReachable", client.isReachable());
                  } catch (JSONException e) {
                    poResult.error("Exception", e.getMessage(), null);
                  }
                  clientArray.put(clientObject);
                }
              }
              poResult.success(clientArray.toString());
            } catch (Exception e) {
              poResult.error("Exception", e.getMessage(), null);
            }
          }
        };

    if (reachableTimeout != null) {
      moWiFiAPManager.getClientList(onlyReachables, reachableTimeout, oFinishScanListener);
    } else {
      moWiFiAPManager.getClientList(onlyReachables, oFinishScanListener);
    }
  }

  /**
   * Return whether Wi-Fi AP is enabled or disabled. *** isWifiApEnabled : return {@code true} if
   * Wi-Fi AP is enabled
   */
  private void isWiFiAPEnabled(Result poResult) {
    try {
      poResult.success(moWiFiAPManager.isWifiApEnabled());
    } catch (SecurityException e) {
      Log.e(WifiIotPlugin.class.getSimpleName(), e.getMessage(), null);
      poResult.error("Exception [isWiFiAPEnabled]", e.getMessage(), null);
    }
  }

  /**
   * Start AccessPoint mode with the specified configuration. If the radio is already running in AP
   * mode, update the new configuration Note that starting in access point mode disables station
   * mode operation *** setWifiApEnabled : param wifiConfig SSID, security and channel details as
   * part of WifiConfiguration return {@code true} if the operation succeeds, {@code false}
   * otherwise
   */
  private void setWiFiAPEnabled(MethodCall poCall, Result poResult) {
    boolean enabled = poCall.argument("state");

    /** Using LocalOnlyHotspotCallback when setting WiFi AP state on API level >= 29 */
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
      moWiFiAPManager.setWifiApEnabled(null, enabled);
    } else {
      if (enabled) {
        moWiFi.startLocalOnlyHotspot(
            new WifiManager.LocalOnlyHotspotCallback() {
              @Override
              public void onStarted(WifiManager.LocalOnlyHotspotReservation reservation) {
                super.onStarted(reservation);
                apReservation = reservation;
              }

              @Override
              public void onStopped() {
                super.onStopped();
                Log.d(WifiIotPlugin.class.getSimpleName(), "LocalHotspot Stopped.");
              }

              @Override
              public void onFailed(int reason) {
                super.onFailed(reason);
                Log.d(
                    WifiIotPlugin.class.getSimpleName(),
                    "LocalHotspot failed with code: " + String.valueOf(reason));
              }
            },
            new Handler());
      } else {
        if (apReservation != null) {
          apReservation.close();
        } else {
          Log.e(
              WifiIotPlugin.class.getSimpleName(), "Can't disable WiFi AP, apReservation is null.");
        }
      }
    }

    poResult.success(null);
  }

  /**
   * Show write permission settings page to user Depending on Android version and application these
   * may be needed to perform certain WiFi configurations that require WRITE_SETTINGS which require
   * a double opt-in, not just presence in manifest. *** showWritePermissionSettings : param boolean
   * force, if true shows always, if false only if permissions are not already granted
   */
  private void showWritePermissionSettings(MethodCall poCall, Result poResult) {
    boolean force = poCall.argument("force");
    moWiFiAPManager.showWritePermissionSettings(force);
    poResult.success(null);
  }

  /** Gets the Wi-Fi enabled state. *** getWifiApState : return {link WIFI_AP_STATE} */
  private void getWiFiAPState(Result poResult) {
    poResult.success(moWiFiAPManager.getWifiApState().ordinal());
  }

  @Override
  public void onListen(Object o, EventChannel.EventSink eventSink) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M
        && moContext.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION)
            != PackageManager.PERMISSION_GRANTED) {
      if (requestingPermission) {
        return;
      }
      requestingPermission = true;
      permissionRequestCookie.clear();
      permissionRequestCookie.add(eventSink);
      moActivity.requestPermissions(
          new String[] {Manifest.permission.ACCESS_FINE_LOCATION},
          PERMISSIONS_REQUEST_CODE_ACCESS_FINE_LOCATION_ON_LISTEN);
      // actual call will be handled in [onRequestPermissionsResult]
    } else {
      _onListen(eventSink);
    }
  }

  private void _onListen(EventChannel.EventSink eventSink) {
    receiver = createReceiver(eventSink);
    moContext.registerReceiver(
        receiver, new IntentFilter(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION));
  }

  @Override
  public void onCancel(Object o) {
    if (receiver != null) {
      moContext.unregisterReceiver(receiver);
      receiver = null;
    }
  }

  private BroadcastReceiver createReceiver(final EventChannel.EventSink eventSink) {
    return new BroadcastReceiver() {
      @Override
      public void onReceive(Context context, Intent intent) {
        eventSink.success(handleNetworkScanResult().toString());
      }
    };
  }

  JSONArray handleNetworkScanResult() {
    List<ScanResult> results = moWiFi.getScanResults();
    JSONArray wifiArray = new JSONArray();

    try {
      for (ScanResult result : results) {
        JSONObject wifiObject = new JSONObject();
        if (!result.SSID.equals("")) {

          wifiObject.put("SSID", result.SSID);
          wifiObject.put("BSSID", result.BSSID);
          wifiObject.put("capabilities", result.capabilities);
          wifiObject.put("frequency", result.frequency);
          wifiObject.put("level", result.level);
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            wifiObject.put("timestamp", result.timestamp);
          } else {
            wifiObject.put("timestamp", 0);
          }
          /// Other fields not added
          //wifiObject.put("operatorFriendlyName", result.operatorFriendlyName);
          //wifiObject.put("venueName", result.venueName);
          //wifiObject.put("centerFreq0", result.centerFreq0);
          //wifiObject.put("centerFreq1", result.centerFreq1);
          //wifiObject.put("channelWidth", result.channelWidth);

          wifiArray.put(wifiObject);
        }
      }
    } catch (JSONException e) {
      e.printStackTrace();
    } finally {
      return wifiArray;
    }
  }

  /// Method to load wifi list into string via Callback. Returns a stringified JSONArray
  private void loadWifiList(final Result poResult) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M
        && moContext.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION)
            != PackageManager.PERMISSION_GRANTED) {
      if (requestingPermission) {
        poResult.error(
            "WifiIotPlugin.Permission", "Only one permission can be requested at a time", null);
        return;
      }
      requestingPermission = true;
      permissionRequestResultCallback = poResult;
      moActivity.requestPermissions(
          new String[] {Manifest.permission.ACCESS_FINE_LOCATION},
          PERMISSIONS_REQUEST_CODE_ACCESS_FINE_LOCATION_LOAD_WIFI_LIST);
      // actual call will be handled in [onRequestPermissionsResult]
    } else {
      _loadWifiList(poResult);
    }
  }

  private void _loadWifiList(final Result poResult) {
    try {
      moWiFi.startScan();
      poResult.success(handleNetworkScanResult().toString());
    } catch (Exception e) {
      poResult.error("Exception", e.getMessage(), null);
    }
  }

  /// Method to force wifi usage if the user needs to send requests via wifi
  /// if it does not have internet connection. Useful for IoT applications, when
  /// the app needs to communicate and send requests to a device that have no
  /// internet connection via wifi.

  /// Receives a boolean to enable forceWifiUsage if true, and disable if false.
  /// Is important to enable only when communicating with the device via wifi
  /// and remember to disable it when disconnecting from device.
  private void forceWifiUsage(final MethodCall poCall, final Result poResult) {
    boolean useWifi = poCall.argument("useWifi");

    final ConnectivityManager manager =
        (ConnectivityManager) moContext.getSystemService(Context.CONNECTIVITY_SERVICE);

    boolean success = true;
    boolean shouldReply = true;
    if (Build.VERSION.SDK_INT > Build.VERSION_CODES.LOLLIPOP && manager != null) {
      if (useWifi) {
        NetworkRequest.Builder builder;
        builder = new NetworkRequest.Builder();
        /// set the transport type do WIFI
        builder.addTransportType(NetworkCapabilities.TRANSPORT_WIFI);
        shouldReply = false;
        manager.requestNetwork(
            builder.build(),
            new ConnectivityManager.NetworkCallback() {
              @Override
              public void onAvailable(Network network) {
                super.onAvailable(network);
                boolean success = false;
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                  success = manager.bindProcessToNetwork(network);

                } else {
                  success = ConnectivityManager.setProcessDefaultNetwork(network);
                }
                manager.unregisterNetworkCallback(this);
                final boolean result = success;
                final Handler handler = new Handler(Looper.getMainLooper());
                handler.post(
                    new Runnable() {
                      @Override
                      public void run() {
                        poResult.success(result);
                      }
                    });
              }
            });

      } else {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
          success = manager.bindProcessToNetwork(null);
        } else {
          success = ConnectivityManager.setProcessDefaultNetwork(null);
        }
      }
    }
    if (shouldReply) {
      poResult.success(success);
    }
  }

  /// Method to check if wifi is enabled
  private void isEnabled(Result poResult) {
    poResult.success(moWiFi.isWifiEnabled());
  }

  /// Method to connect/disconnect wifi service
  private void setEnabled(MethodCall poCall, Result poResult) {
    Boolean enabled = poCall.argument("state");
    Boolean shouldOpenSettings = poCall.argument("shouldOpenSettings");

    // Enable or Disable WiFi programmatically
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
      moWiFi.setWifiEnabled(enabled);
    }
    // Whether to open native WiFi settings or not
    else {
      if (shouldOpenSettings != null) {
        if (shouldOpenSettings) {
          Intent intent = new Intent(Settings.ACTION_WIFI_SETTINGS);
          intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
          this.moContext.startActivity(intent);
        } else {
          moWiFi.setWifiEnabled(enabled);
        }
      } else {
        Log.e(
            WifiIotPlugin.class.getSimpleName(), "Error `setEnabled`: shouldOpenSettings is null.");
      }
    }

    poResult.success(null);
  }

  private void connect(final MethodCall poCall, final Result poResult) {
    new Thread() {
      public void run() {
        String ssid = poCall.argument("ssid");
        String bssid = poCall.argument("bssid");
        String password = poCall.argument("password");
        String security = poCall.argument("security");
        Boolean joinOnce = poCall.argument("join_once");
        Boolean withInternet = poCall.argument("with_internet");
        Boolean isHidden = poCall.argument("is_hidden");

        connectTo(poResult, ssid, bssid, password, security, joinOnce, withInternet, isHidden);
      }
    }.start();
  }

  /// Transform a string based bssid into a MacAdress.
  /// Return null in case of error.
  @RequiresApi(Build.VERSION_CODES.P)
  private static MacAddress macAddressFromBssid(String bssid) {
    if (bssid == null) {
      return null;
    }

    try {
      return MacAddress.fromString(bssid);
    } catch (IllegalArgumentException invalidRepresentation) {
      Log.e(
          WifiIotPlugin.class.getSimpleName(),
          "Mac address parsing failed for bssid: " + bssid,
          invalidRepresentation);
      return null;
    }
  }

  /**
   * Registers a wifi network in the device wireless networks For API >= 30 uses intent to
   * permanently store such network in user configuration For API <= 29 uses deprecated functions
   * that manipulate directly *** registerWifiNetwork : param ssid, SSID to register param password,
   * passphrase to use param security, security mode (WPA or null) to use return {@code true} if the
   * operation succeeds, {@code false} otherwise
   */
  private void registerWifiNetwork(final MethodCall poCall, final Result poResult) {
    String ssid = poCall.argument("ssid");
    String bssid = poCall.argument("bssid");
    String password = poCall.argument("password");
    String security = poCall.argument("security");
    Boolean isHidden = poCall.argument("is_hidden");

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
      final WifiNetworkSuggestion.Builder suggestedNet = new WifiNetworkSuggestion.Builder();
      suggestedNet.setSsid(ssid);
      suggestedNet.setIsHiddenSsid(isHidden != null ? isHidden : false);
      if (bssid != null) {
        final MacAddress macAddress = macAddressFromBssid(bssid);
        if (macAddress == null) {
          poResult.error("Error", "Invalid BSSID representation", "");
          return;
        }
        suggestedNet.setBssid(macAddress);
      }

      if (security != null && security.toUpperCase().equals("WPA")) {
        suggestedNet.setWpa2Passphrase(password);
      } else if (security != null && security.toUpperCase().equals("WEP")) {
        // WEP is not supported
        poResult.error(
            "Error", "WEP is not supported for Android SDK " + Build.VERSION.SDK_INT, "");
        return;
      }

      final ArrayList<WifiNetworkSuggestion> suggestionsList =
          new ArrayList<WifiNetworkSuggestion>();
      suggestionsList.add(suggestedNet.build());

      Bundle bundle = new Bundle();
      bundle.putParcelableArrayList(
          android.provider.Settings.EXTRA_WIFI_NETWORK_LIST, suggestionsList);
      Intent intent = new Intent(android.provider.Settings.ACTION_WIFI_ADD_NETWORKS);
      intent.putExtras(bundle);
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      moContext.startActivity(intent);

      poResult.success(null);
    } else {
      // Deprecated version
      android.net.wifi.WifiConfiguration conf =
          generateConfiguration(ssid, bssid, password, security, isHidden);

      int updateNetwork = registerWifiNetworkDeprecated(conf);

      if (updateNetwork == -1) {
        poResult.error("Error", "Error updating network configuration", "");
      } else {
        poResult.success(null);
      }
    }
  }

  /// Send the ssid and password of a Wifi network into this to connect to the network.
  /// Example:  wifi.findAndConnect(ssid, password);
  /// After 10 seconds, a post telling you whether you are connected will pop up.
  /// Callback returns true if ssid is in the range
  private void findAndConnect(final MethodCall poCall, final Result poResult) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M
        && moContext.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION)
            != PackageManager.PERMISSION_GRANTED) {
      if (requestingPermission) {
        poResult.error(
            "WifiIotPlugin.Permission", "Only one permission can be requested at a time", null);
        return;
      }
      requestingPermission = true;
      permissionRequestResultCallback = poResult;
      permissionRequestCookie.clear();
      permissionRequestCookie.add(poCall);
      moActivity.requestPermissions(
          new String[] {Manifest.permission.ACCESS_FINE_LOCATION},
          PERMISSIONS_REQUEST_CODE_ACCESS_FINE_LOCATION_FIND_AND_CONNECT);
      // actual call will be handled in [onRequestPermissionsResult]
    } else {
      _findAndConnect(poCall, poResult);
    }
  }

  private void _findAndConnect(final MethodCall poCall, final Result poResult) {
    new Thread() {
      public void run() {
        String ssid = poCall.argument("ssid");
        String bssid = poCall.argument("bssid");
        String password = poCall.argument("password");
        Boolean joinOnce = poCall.argument("join_once");
        Boolean withInternet = poCall.argument("with_internet");

        String security = null;
        List<ScanResult> results = moWiFi.getScanResults();
        for (ScanResult result : results) {
          String resultString = "" + result.SSID;
          if (ssid.equals(resultString)
              && (result.BSSID == null || bssid == null || result.BSSID.equals(bssid))) {
            security = getSecurityType(result);
            if (bssid == null) {
              bssid = result.BSSID;
            }
          }
        }

        connectTo(poResult, ssid, bssid, password, security, joinOnce, withInternet, false);
      }
    }.start();
  }

  private static String getSecurityType(ScanResult scanResult) {
    String capabilities = scanResult.capabilities;

    if (capabilities.contains("WPA")
        || capabilities.contains("WPA2")
        || capabilities.contains("WPA/WPA2 PSK")) {
      return "WPA";
    } else if (capabilities.contains("WEP")) {
      return "WEP";
    } else {
      return null;
    }
  }

  /// Use this method to check if the device is currently connected to Wifi.
  private void isConnected(Result poResult) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
      isConnectedDeprecated(poResult);
    } else {
      if (moContext.checkSelfPermission(Manifest.permission.ACCESS_NETWORK_STATE)
          != PackageManager.PERMISSION_GRANTED) {
        if (requestingPermission) {
          poResult.error(
              "WifiIotPlugin.Permission", "Only one permission can be requested at a time", null);
          return;
        }
        requestingPermission = true;
        permissionRequestResultCallback = poResult;
        moActivity.requestPermissions(
            new String[] {Manifest.permission.ACCESS_NETWORK_STATE},
            PERMISSIONS_REQUEST_CODE_ACCESS_NETWORK_STATE_IS_CONNECTED);
        // actual call will be handled in [onRequestPermissionsResult]
      } else {
        _isConnected(poResult);
      }
    }
  }

  private void _isConnected(Result poResult) {
    ConnectivityManager connManager =
        (ConnectivityManager) moContext.getSystemService(Context.CONNECTIVITY_SERVICE);
    boolean result = false;
    if (connManager != null) {
      // `connManager.getActiveNetwork` only return if the network has internet
      // therefore using `connManager.getAllNetworks()` to check all networks
      for (final Network network : connManager.getAllNetworks()) {
        final NetworkCapabilities capabilities =
            network != null ? connManager.getNetworkCapabilities(network) : null;
        final boolean isConnected =
            capabilities != null && capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI);
        if (isConnected) {
          result = true;
          break;
        }
      }
    }

    poResult.success(result);
  }

  @SuppressWarnings("deprecation")
  private void isConnectedDeprecated(Result poResult) {
    ConnectivityManager connManager =
        (ConnectivityManager) moContext.getSystemService(Context.CONNECTIVITY_SERVICE);
    android.net.NetworkInfo mWifi =
        connManager != null ? connManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI) : null;

    poResult.success(mWifi != null && mWifi.isConnected());
  }

  /// Disconnect current Wifi.
  private void disconnect(Result poResult) {
    boolean disconnected = false;
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
      //noinspection deprecation
      disconnected = moWiFi.disconnect();
    } else {
      if (networkCallback != null) {
        final ConnectivityManager connectivityManager =
            (ConnectivityManager) moContext.getSystemService(Context.CONNECTIVITY_SERVICE);
        connectivityManager.unregisterNetworkCallback(networkCallback);
        networkCallback = null;
        disconnected = true;
      } else if (networkSuggestions != null) {
        final int networksRemoved = moWiFi.removeNetworkSuggestions(networkSuggestions);
        disconnected = networksRemoved == WifiManager.STATUS_NETWORK_SUGGESTIONS_SUCCESS;
      } else {
        Log.e(
            WifiIotPlugin.class.getSimpleName(),
            "Can't disconnect from WiFi, networkCallback and networkSuggestions is null.");
      }
    }
    poResult.success(disconnected);
  }

  /// This method will return current ssid
  private void getSSID(Result poResult) {
    WifiInfo info = moWiFi.getConnectionInfo();

    // This value should be wrapped in double quotes, so we need to unwrap it.
    String ssid = info.getSSID();
    if (ssid.startsWith("\"") && ssid.endsWith("\"")) {
      ssid = ssid.substring(1, ssid.length() - 1);
    }

    poResult.success(ssid);
  }

  /// This method will return the basic service set identifier (BSSID) of the current access point
  private void getBSSID(Result poResult) {
    WifiInfo info = moWiFi.getConnectionInfo();

    String bssid = info.getBSSID();

    try {
      poResult.success(bssid.toUpperCase());
    } catch (Exception e) {
      poResult.error("Exception", e.getMessage(), null);
    }
  }

  /// This method will return current WiFi signal strength
  private void getCurrentSignalStrength(Result poResult) {
    int linkSpeed = moWiFi.getConnectionInfo().getRssi();
    poResult.success(linkSpeed);
  }

  /// This method will return current WiFi frequency
  private void getFrequency(Result poResult) {
    WifiInfo info = moWiFi.getConnectionInfo();
    int frequency = 0;
    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
      frequency = info.getFrequency();
    }
    poResult.success(frequency);
  }

  /// This method will return current IP
  private void getIP(Result poResult) {
    WifiInfo info = moWiFi.getConnectionInfo();
    String stringip = longToIP(info.getIpAddress());
    poResult.success(stringip);
  }

  /// This method will remove the WiFi network as per the passed SSID from the device list
  private void removeWifiNetwork(MethodCall poCall, Result poResult) {
    String prefix_ssid = poCall.argument("ssid");
    if (prefix_ssid.equals("")) {
      poResult.error("Error", "No prefix SSID was given!", null);
    }
    boolean removed = false;

    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
      List<android.net.wifi.WifiConfiguration> mWifiConfigList = moWiFi.getConfiguredNetworks();
      for (android.net.wifi.WifiConfiguration wifiConfig : mWifiConfigList) {
        String comparableSSID = ('"' + prefix_ssid); //Add quotes because wifiConfig.SSID has them
        if (wifiConfig.SSID.startsWith(comparableSSID)) {
          moWiFi.removeNetwork(wifiConfig.networkId);
          moWiFi.saveConfiguration();
          removed = true;
          break;
        }
      }
    }

    // remove network suggestion
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
      List<WifiNetworkSuggestion> suggestions = moWiFi.getNetworkSuggestions();
      List<WifiNetworkSuggestion> removeSuggestions = new ArrayList();
      for (int i = 0, suggestionsSize = suggestions.size(); i < suggestionsSize; i++) {
        WifiNetworkSuggestion suggestion = suggestions.get(i);
        if (suggestion.getSsid().startsWith(prefix_ssid)) {
          removeSuggestions.add(suggestion);
        }
      }
      final int networksRemoved = moWiFi.removeNetworkSuggestions(removeSuggestions);
      removed = networksRemoved == WifiManager.STATUS_NETWORK_SUGGESTIONS_SUCCESS;
    }
    poResult.success(removed);
  }

  /// This method will remove the WiFi network as per the passed SSID from the device list
  private void isRegisteredWifiNetwork(MethodCall poCall, Result poResult) {

    String ssid = poCall.argument("ssid");

    List<android.net.wifi.WifiConfiguration> mWifiConfigList = moWiFi.getConfiguredNetworks();
    String comparableSSID = ('"' + ssid + '"'); //Add quotes because wifiConfig.SSID has them
    if (mWifiConfigList != null) {
      for (android.net.wifi.WifiConfiguration wifiConfig : mWifiConfigList) {
        if (wifiConfig.SSID.equals(comparableSSID)) {
          poResult.success(true);
          return;
        }
      }
    }
    poResult.success(false);
  }

  private static String longToIP(int longIp) {
    StringBuilder sb = new StringBuilder("");
    String[] strip = new String[4];
    strip[3] = String.valueOf((longIp >>> 24));
    strip[2] = String.valueOf((longIp & 0x00FFFFFF) >>> 16);
    strip[1] = String.valueOf((longIp & 0x0000FFFF) >>> 8);
    strip[0] = String.valueOf((longIp & 0x000000FF));
    sb.append(strip[0]);
    sb.append(".");
    sb.append(strip[1]);
    sb.append(".");
    sb.append(strip[2]);
    sb.append(".");
    sb.append(strip[3]);
    return sb.toString();
  }

  /// Method to connect to WIFI Network
  private void connectTo(
      final Result poResult,
      final String ssid,
      final String bssid,
      final String password,
      final String security,
      final Boolean joinOnce,
      final Boolean withInternet,
      final Boolean isHidden) {
    final Handler handler = new Handler(Looper.getMainLooper());
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
      final boolean connected =
          connectToDeprecated(ssid, bssid, password, security, joinOnce, isHidden);
      handler.post(
          new Runnable() {
            @Override
            public void run() {
              poResult.success(connected);
            }
          });
    } else {
      // error if WEP security, since not supported
      if (security != null && security.toUpperCase().equals("WEP")) {
        handler.post(
            new Runnable() {
              @Override
              public void run() {
                poResult.error(
                    "Error", "WEP is not supported for Android SDK " + Build.VERSION.SDK_INT, "");
              }
            });
        return;
      }

      if (withInternet != null && withInternet) {
        // create network suggestion
        final WifiNetworkSuggestion.Builder builder = new WifiNetworkSuggestion.Builder();
        // set ssid
        builder.setSsid(ssid);
        builder.setIsHiddenSsid(isHidden != null ? isHidden : false);
        if (bssid != null) {
          final MacAddress macAddress = macAddressFromBssid(bssid);
          if (macAddress == null) {
            handler.post(
                new Runnable() {
                  @Override
                  public void run() {
                    poResult.error("Error", "Invalid BSSID representation", "");
                  }
                });
            return;
          }
          builder.setBssid(macAddress);
        }

        // set password
        if (security != null && security.toUpperCase().equals("WPA")) {
          builder.setWpa2Passphrase(password);
        }

        // remove suggestions if already existing
        if (networkSuggestions != null) {
          moWiFi.removeNetworkSuggestions(networkSuggestions);
        }

        //builder.setIsAppInteractionRequired(true);
        final WifiNetworkSuggestion suggestion = builder.build();

        networkSuggestions = new ArrayList<>();
        networkSuggestions.add(suggestion);
        if (joinOnce != null && joinOnce) {
          suggestionsToBeRemovedOnExit.add(suggestion);
        }

        final int status = moWiFi.addNetworkSuggestions(networkSuggestions);
        Log.e(WifiIotPlugin.class.getSimpleName(), "status: " + status);

        handler.post(
            new Runnable() {
              @Override
              public void run() {
                poResult.success(status == WifiManager.STATUS_NETWORK_SUGGESTIONS_SUCCESS);
              }
            });
      } else {
        // Make new network specifier
        final WifiNetworkSpecifier.Builder builder = new WifiNetworkSpecifier.Builder();
        // set ssid
        builder.setSsid(ssid);
        builder.setIsHiddenSsid(isHidden != null ? isHidden : false);
        if (bssid != null) {
          final MacAddress macAddress = macAddressFromBssid(bssid);
          if (macAddress == null) {
            handler.post(
                new Runnable() {
                  @Override
                  public void run() {
                    poResult.error("Error", "Invalid BSSID representation", "");
                  }
                });
            return;
          }
          builder.setBssid(macAddress);
        }

        // set security
        if (security != null && security.toUpperCase().equals("WPA")) {
          builder.setWpa2Passphrase(password);
        }

        final NetworkRequest networkRequest =
            new NetworkRequest.Builder()
                .addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
                .removeCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
                .setNetworkSpecifier(builder.build())
                .build();

        final ConnectivityManager connectivityManager =
            (ConnectivityManager) moContext.getSystemService(Context.CONNECTIVITY_SERVICE);

        if (networkCallback != null) connectivityManager.unregisterNetworkCallback(networkCallback);

        networkCallback =
            new ConnectivityManager.NetworkCallback() {
              boolean resultSent = false;

              @Override
              public void onAvailable(@NonNull Network network) {
                super.onAvailable(network);
                if (!resultSent) {
                  poResult.success(true);
                  resultSent = true;
                }
              }

              @Override
              public void onUnavailable() {
                super.onUnavailable();
                if (!resultSent) {
                  poResult.success(false);
                  resultSent = true;
                }
              }
            };

        connectivityManager.requestNetwork(networkRequest, networkCallback, handler, 30 * 1000);
      }
    }
  }

  @SuppressWarnings("deprecation")
  private int registerWifiNetworkDeprecated(android.net.wifi.WifiConfiguration conf) {
    int updateNetwork = -1;

    /// Remove the existing configuration for this netwrok
    List<android.net.wifi.WifiConfiguration> mWifiConfigList = moWiFi.getConfiguredNetworks();

    if (mWifiConfigList != null) {
      for (android.net.wifi.WifiConfiguration wifiConfig : mWifiConfigList) {
        if (wifiConfig.SSID.equals(conf.SSID)
            && (wifiConfig.BSSID == null
                || conf.BSSID == null
                || wifiConfig.BSSID.equals(conf.BSSID))) {
          conf.networkId = wifiConfig.networkId;
          updateNetwork = moWiFi.updateNetwork(conf);
        }
      }
    }

    /// If network not already in configured networks add new network
    if (updateNetwork == -1) {
      updateNetwork = moWiFi.addNetwork(conf);
      moWiFi.saveConfiguration();
    }

    return updateNetwork;
  }

  private android.net.wifi.WifiConfiguration generateConfiguration(
      String ssid, String bssid, String password, String security, Boolean isHidden) {
    android.net.wifi.WifiConfiguration conf = new android.net.wifi.WifiConfiguration();
    conf.SSID = "\"" + ssid + "\"";
    conf.hiddenSSID = isHidden != null ? isHidden : false;
    if (bssid != null) {
      conf.BSSID = bssid;
    }

    if (security != null) security = security.toUpperCase();
    else security = "NONE";

    if (security.toUpperCase().equals("WPA")) {

      /// appropriate ciper is need to set according to security type used,
      /// ifcase of not added it will not be able to connect
      conf.preSharedKey = "\"" + password + "\"";

      conf.allowedProtocols.set(android.net.wifi.WifiConfiguration.Protocol.RSN);

      conf.allowedKeyManagement.set(android.net.wifi.WifiConfiguration.KeyMgmt.WPA_PSK);

      conf.status = android.net.wifi.WifiConfiguration.Status.ENABLED;

      conf.allowedGroupCiphers.set(android.net.wifi.WifiConfiguration.GroupCipher.TKIP);
      conf.allowedGroupCiphers.set(android.net.wifi.WifiConfiguration.GroupCipher.CCMP);

      conf.allowedKeyManagement.set(android.net.wifi.WifiConfiguration.KeyMgmt.WPA_PSK);

      conf.allowedPairwiseCiphers.set(android.net.wifi.WifiConfiguration.PairwiseCipher.TKIP);
      conf.allowedPairwiseCiphers.set(android.net.wifi.WifiConfiguration.PairwiseCipher.CCMP);

      conf.allowedProtocols.set(android.net.wifi.WifiConfiguration.Protocol.RSN);
      conf.allowedProtocols.set(android.net.wifi.WifiConfiguration.Protocol.WPA);
    } else if (security.equals("WEP")) {
      conf.wepKeys[0] = "\"" + password + "\"";
      conf.wepTxKeyIndex = 0;
      conf.allowedKeyManagement.set(android.net.wifi.WifiConfiguration.KeyMgmt.NONE);
      conf.allowedGroupCiphers.set(android.net.wifi.WifiConfiguration.GroupCipher.WEP40);
    } else {
      conf.allowedKeyManagement.set(android.net.wifi.WifiConfiguration.KeyMgmt.NONE);
    }

    return conf;
  }

  @SuppressWarnings("deprecation")
  private Boolean connectToDeprecated(
      String ssid,
      String bssid,
      String password,
      String security,
      Boolean joinOnce,
      Boolean isHidden) {
    /// Make new configuration
    android.net.wifi.WifiConfiguration conf =
        generateConfiguration(ssid, bssid, password, security, isHidden);

    int updateNetwork = registerWifiNetworkDeprecated(conf);

    if (updateNetwork == -1) {
      return false;
    }

    if (joinOnce != null && joinOnce.booleanValue()) {
      ssidsToBeRemovedOnExit.add(conf.SSID);
    }

    boolean disconnect = moWiFi.disconnect();
    if (!disconnect) {
      return false;
    }

    boolean enabled = moWiFi.enableNetwork(updateNetwork, true);
    if (!enabled) return false;

    boolean connected = false;
    for (int i = 0; i < 30; i++) {
      int networkId = moWiFi.getConnectionInfo().getNetworkId();
      if (networkId != -1) {
        connected = networkId == updateNetwork;
        break;
      }
      try {
        Thread.sleep(1000);
      } catch (InterruptedException ignored) {
        break;
      }
    }

    return connected;
  }
}
