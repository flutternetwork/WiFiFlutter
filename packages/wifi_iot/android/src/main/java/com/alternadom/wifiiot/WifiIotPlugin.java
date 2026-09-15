package com.alternadom.wifiiot;

import android.Manifest;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.NetworkRequest;
import android.net.wifi.ScanResult;
import android.net.wifi.SoftApConfiguration;
import android.net.wifi.WifiConfiguration;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.net.wifi.WifiNetworkSuggestion;
import android.net.wifi.WifiSsid;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.alternadom.wifiiot.wifi.WifiConnectCallback;
import com.alternadom.wifiiot.wifi.WifiConnectRequest;
import com.alternadom.wifiiot.wifi.WifiPlatform;
import info.whitebyte.hotspotmanager.ClientScanResult;
import info.whitebyte.hotspotmanager.FinishScanListener;
import info.whitebyte.hotspotmanager.WIFI_AP_STATE;
import info.whitebyte.hotspotmanager.WifiApManager;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import java.util.ArrayList;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/** WifiIotPlugin — Flutter binding; STA logic in {@link WifiPlatform} (legacy / modern). */
@SuppressWarnings("deprecation") // API < 29 SoftAp / WifiConfiguration
public class WifiIotPlugin
    implements FlutterPlugin,
        ActivityAware,
        MethodCallHandler,
        EventChannel.StreamHandler,
        PluginRegistry.RequestPermissionsResultListener {

  private MethodChannel channel;
  private EventChannel eventChannel;

  private WifiManager moWiFi;
  private Context moContext;
  private WifiApManager moWiFiAPManager;
  private Activity moActivity;
  private BroadcastReceiver receiver;
  private WifiManager.LocalOnlyHotspotReservation apReservation;
  private WIFI_AP_STATE localOnlyHotspotState = WIFI_AP_STATE.WIFI_AP_STATE_DISABLED;

  private WifiPlatform wifiPlatform;

  private boolean requestingPermission = false;
  private Result permissionRequestResultCallback = null;
  private ArrayList<Object> permissionRequestCookie = new ArrayList<>();
  private static final int PERMISSIONS_REQUEST_CODE_ACCESS_FINE_LOCATION_LOAD_WIFI_LIST = 65655435;
  private static final int PERMISSIONS_REQUEST_CODE_ACCESS_FINE_LOCATION_ON_LISTEN = 65655436;
  private static final int PERMISSIONS_REQUEST_CODE_ACCESS_FINE_LOCATION_FIND_AND_CONNECT =
      65655437;
  private static final int PERMISSIONS_REQUEST_CODE_ACCESS_NETWORK_STATE_IS_CONNECTED = 65655438;

  /** API ≤ 32: FINE_LOCATION; API ≥ 33: NEARBY_WIFI_DEVICES (SSID required). */
  private String[] wifiScanPermissions() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      return new String[] {Manifest.permission.NEARBY_WIFI_DEVICES};
    }
    return new String[] {Manifest.permission.ACCESS_FINE_LOCATION};
  }

  private boolean hasWifiScanPermission() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      return moContext.checkSelfPermission(Manifest.permission.NEARBY_WIFI_DEVICES)
          == PackageManager.PERMISSION_GRANTED;
    }
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      return moContext.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION)
          == PackageManager.PERMISSION_GRANTED;
    }
    return true;
  }

  private String wifiScanPermissionDeniedMessage() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      return "NEARBY_WIFI_DEVICES permission denied";
    }
    return "Fine location permission denied";
  }

  private void initWithContext(Context context) {
    moContext = context;
    moWiFi = (WifiManager) moContext.getApplicationContext().getSystemService(Context.WIFI_SERVICE);
    moWiFiAPManager = new WifiApManager(moContext.getApplicationContext());
    ConnectivityManager connectivityManager =
        (ConnectivityManager) moContext.getSystemService(Context.CONNECTIVITY_SERVICE);
    wifiPlatform = WifiPlatform.create(moContext, moWiFi, connectivityManager);
  }

  private void initWithActivity(Activity activity) {
    moActivity = activity;
  }

  private void cleanup() {
    unregisterScanReceiver();
    if (apReservation != null) {
      apReservation.close();
      apReservation = null;
    }
    if (wifiPlatform != null) {
      wifiPlatform.close();
    }
    permissionRequestResultCallback = null;
    permissionRequestCookie.clear();
    requestingPermission = false;
    channel = null;
    eventChannel = null;
    moActivity = null;
    moContext = null;
    moWiFi = null;
    moWiFiAPManager = null;
    wifiPlatform = null;
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    channel = new MethodChannel(binding.getBinaryMessenger(), "wifi_iot");
    eventChannel =
        new EventChannel(binding.getBinaryMessenger(), "plugins.wififlutter.io/wifi_scan");
    channel.setMethodCallHandler(this);
    eventChannel.setStreamHandler(this);
    initWithContext(binding.getApplicationContext());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    eventChannel.setStreamHandler(null);
    cleanup();
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    initWithActivity(binding.getActivity());
    binding.addRequestPermissionsResultListener(this);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    moActivity = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    initWithActivity(binding.getActivity());
    binding.addRequestPermissionsResultListener(this);
  }

  @Override
  public void onDetachedFromActivity() {
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
              "WifiIotPlugin.Permission", wifiScanPermissionDeniedMessage(), null);
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
              "WifiIotPlugin.Permission", wifiScanPermissionDeniedMessage(), null);
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
  public void onMethodCall(MethodCall poCall, Result result) {
    switch (poCall.method) {
      case "loadWifiList":
        loadWifiList(result);
        break;
      case "forceWifiUsage":
        forceWifiUsage(poCall, result);
        break;
      case "isEnabled":
        isEnabled(result);
        break;
      case "setEnabled":
        setEnabled(poCall, result);
        break;
      case "connect":
        connect(poCall, result);
        break;
      case "registerWifiNetwork":
        registerWifiNetwork(poCall, result);
        break;
      case "findAndConnect":
        findAndConnect(poCall, result);
        break;
      case "isConnected":
        isConnected(result);
        break;
      case "disconnect":
        disconnect(result);
        break;
      case "getSSID":
        getSSID(result);
        break;
      case "getBSSID":
        getBSSID(result);
        break;
      case "getCurrentSignalStrength":
        getCurrentSignalStrength(result);
        break;
      case "getFrequency":
        getFrequency(result);
        break;
      case "getIP":
        getIP(result);
        break;
      case "removeWifiNetwork":
        removeWifiNetwork(poCall, result);
        break;
      case "isRegisteredWifiNetwork":
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) isRegisteredWifiNetwork(poCall, result);
        else
          result.error(
              "Error",
              "isRegisteredWifiNetwork not supported for Android SDK " + Build.VERSION.SDK_INT,
              null);
        break;
      case "isWiFiAPEnabled":
        isWiFiAPEnabled(result);
        break;
      case "setWiFiAPEnabled":
        setWiFiAPEnabled(poCall, result);
        break;
      case "getWiFiAPState":
        getWiFiAPState(result);
        break;
      case "getClientList":
        getClientList(poCall, result);
        break;
      case "getWiFiAPSSID":
        getWiFiAPSSID(result);
        break;
      case "setWiFiAPSSID":
        setWiFiAPSSID(poCall, result);
        break;
      case "isSSIDHidden":
        isSSIDHidden(result);
        break;
      case "setSSIDHidden":
        setSSIDHidden(poCall, result);
        break;
      case "getWiFiAPPreSharedKey":
        getWiFiAPPreSharedKey(result);
        break;
      case "setWiFiAPPreSharedKey":
        setWiFiAPPreSharedKey(poCall, result);
        break;
      case "showWritePermissionSettings":
        showWritePermissionSettings(poCall, result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void getWiFiAPSSID(Result result) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
      android.net.wifi.WifiConfiguration oWiFiConfig = moWiFiAPManager.getWifiApConfiguration();

      if (oWiFiConfig != null && oWiFiConfig.SSID != null) {
        result.success(oWiFiConfig.SSID);
        return;
      }

      result.error("Exception [getWiFiAPSSID]", "SSID not found", null);
    } else {
      if (apReservation != null) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
          WifiConfiguration wifiConfiguration = apReservation.getWifiConfiguration();
          if (wifiConfiguration != null) {
            result.success(wifiConfiguration.SSID);
          } else {
            result.error(
                "Exception [getWiFiAPSSID]",
                "Security type is not WifiConfiguration.KeyMgmt.None or"
                    + " WifiConfiguration.KeyMgmt.WPA2_PSK",
                null);
          }
        } else {
          SoftApConfiguration softApConfiguration = apReservation.getSoftApConfiguration();
          result.success(softApConfiguration.getSsid());
        }
      } else {
        result.error("Exception [getWiFiAPSSID]", "Hotspot is not enabled.", null);
      }
    }
  }

  private void setWiFiAPSSID(MethodCall poCall, Result result) {
    String sAPSSID = poCall.argument("ssid");

    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
      android.net.wifi.WifiConfiguration oWiFiConfig = moWiFiAPManager.getWifiApConfiguration();
      oWiFiConfig.SSID = sAPSSID;
      moWiFiAPManager.setWifiApConfiguration(oWiFiConfig);
      result.success(null);
    } else {
      result.error(
          "Exception [setWiFiAPSSID]",
          "Setting SSID name is not supported on API level >= 26",
          null);
    }
  }

  private void isSSIDHidden(Result result) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
      android.net.wifi.WifiConfiguration oWiFiConfig = moWiFiAPManager.getWifiApConfiguration();

      if (oWiFiConfig != null && oWiFiConfig.hiddenSSID) {
        result.success(oWiFiConfig.hiddenSSID);
        return;
      }

      result.error("Exception [isSSIDHidden]", "Wifi AP not Supported", null);
    } else {
      if (apReservation != null) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
          SoftApConfiguration softApConfiguration = apReservation.getSoftApConfiguration();
          result.success(softApConfiguration.isHiddenSsid());
        } else {
          WifiConfiguration wifiConfiguration = apReservation.getWifiConfiguration();
          if (wifiConfiguration != null) {
            result.success(wifiConfiguration.hiddenSSID);
          } else {
            result.error(
                "Exception [isSSIDHidden]",
                "Security type is not WifiConfiguration.KeyMgmt.None or"
                    + " WifiConfiguration.KeyMgmt.WPA2_PSK",
                null);
          }
        }
      } else {
        result.error("Exception [isSSIDHidden]", "Hotspot is not enabled.", null);
      }
    }
  }

  private void setSSIDHidden(MethodCall poCall, Result result) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
      boolean isSSIDHidden = poCall.argument("hidden");
      android.net.wifi.WifiConfiguration oWiFiConfig = moWiFiAPManager.getWifiApConfiguration();
      oWiFiConfig.hiddenSSID = isSSIDHidden;
      moWiFiAPManager.setWifiApConfiguration(oWiFiConfig);
      result.success(null);
    } else {
      result.error(
          "Exception [setSSIDHidden]",
          "Setting SSID visibility is not supported on API level >= 26",
          null);
    }
  }

  private void getWiFiAPPreSharedKey(Result result) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
      android.net.wifi.WifiConfiguration oWiFiConfig = moWiFiAPManager.getWifiApConfiguration();

      if (oWiFiConfig != null && oWiFiConfig.preSharedKey != null) {
        result.success(oWiFiConfig.preSharedKey);
        return;
      }

      result.error("Exception", "Wifi AP not Supported", null);
    } else {
      if (apReservation != null) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
          WifiConfiguration wifiConfiguration = apReservation.getWifiConfiguration();
          if (wifiConfiguration != null) {
            result.success(wifiConfiguration.preSharedKey);
          } else {
            result.error(
                "Exception [getWiFiAPPreSharedKey]",
                "Security type is not WifiConfiguration.KeyMgmt.None or"
                    + " WifiConfiguration.KeyMgmt.WPA2_PSK",
                null);
          }
        } else {
          SoftApConfiguration softApConfiguration = apReservation.getSoftApConfiguration();
          result.success(softApConfiguration.getPassphrase());
        }
      } else {
        result.error("Exception [getWiFiAPPreSharedKey]", "Hotspot is not enabled.", null);
      }
    }
  }

  private void setWiFiAPPreSharedKey(MethodCall poCall, Result result) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
      String sPreSharedKey = poCall.argument("preSharedKey");
      android.net.wifi.WifiConfiguration oWiFiConfig = moWiFiAPManager.getWifiApConfiguration();
      oWiFiConfig.preSharedKey = sPreSharedKey;
      moWiFiAPManager.setWifiApConfiguration(oWiFiConfig);
      result.success(null);
    } else {
      result.error(
          "Exception [setWiFiAPPreSharedKey]",
          "Setting WiFi password is not supported on API level >= 26",
          null);
    }
  }

  private void getClientList(MethodCall poCall, final Result result) {
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
                    result.error("Exception", e.getMessage(), null);
                  }
                  clientArray.put(clientObject);
                }
              }
              result.success(clientArray.toString());
            } catch (Exception e) {
              result.error("Exception", e.getMessage(), null);
            }
          }
        };

    if (reachableTimeout != null) {
      moWiFiAPManager.getClientList(onlyReachables, reachableTimeout, oFinishScanListener);
    } else {
      moWiFiAPManager.getClientList(onlyReachables, oFinishScanListener);
    }
  }

  private void isWiFiAPEnabled(Result result) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
      try {
        result.success(moWiFiAPManager.isWifiApEnabled());
      } catch (SecurityException e) {
        Log.e(WifiIotPlugin.class.getSimpleName(), e.getMessage(), null);
        result.error("Exception [isWiFiAPEnabled]", e.getMessage(), null);
      }
    } else {
      result.success(apReservation != null);
    }
  }

  private void setWiFiAPEnabled(MethodCall poCall, final Result result) {
    boolean enabled = poCall.argument("state");

    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
      final boolean success = moWiFiAPManager.setWifiApEnabled(null, enabled);
      result.success(success);
    } else {
      if (enabled) {
        localOnlyHotspotState = WIFI_AP_STATE.WIFI_AP_STATE_ENABLING;
        moWiFi.startLocalOnlyHotspot(
            new WifiManager.LocalOnlyHotspotCallback() {
              @Override
              public void onStarted(WifiManager.LocalOnlyHotspotReservation reservation) {
                super.onStarted(reservation);
                apReservation = reservation;
                localOnlyHotspotState = WIFI_AP_STATE.WIFI_AP_STATE_ENABLED;
                result.success(true);
              }

              @Override
              public void onStopped() {
                super.onStopped();
                if (apReservation != null) {
                  apReservation.close();
                }
                apReservation = null;
                localOnlyHotspotState = WIFI_AP_STATE.WIFI_AP_STATE_DISABLED;
                Log.d(WifiIotPlugin.class.getSimpleName(), "LocalHotspot Stopped.");
              }

              @Override
              public void onFailed(int reason) {
                super.onFailed(reason);
                if (apReservation != null) {
                  apReservation.close();
                }
                apReservation = null;
                localOnlyHotspotState = WIFI_AP_STATE.WIFI_AP_STATE_FAILED;
                Log.d(
                    WifiIotPlugin.class.getSimpleName(),
                    "LocalHotspot failed with code: " + String.valueOf(reason));
                result.success(false);
              }
            },
            new Handler());
      } else {
        localOnlyHotspotState = WIFI_AP_STATE.WIFI_AP_STATE_DISABLING;
        if (apReservation != null) {
          apReservation.close();
          apReservation = null;
          result.success(true);
        } else {
          Log.e(
              WifiIotPlugin.class.getSimpleName(), "Can't disable WiFi AP, apReservation is null.");
          result.success(false);
        }
        localOnlyHotspotState = WIFI_AP_STATE.WIFI_AP_STATE_DISABLED;
      }
    }
  }

  private void showWritePermissionSettings(MethodCall poCall, Result result) {
    boolean force = poCall.argument("force");
    moWiFiAPManager.showWritePermissionSettings(force);
    result.success(null);
  }

  private void getWiFiAPState(Result result) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
      result.success(moWiFiAPManager.getWifiApState().ordinal());
    } else {
      result.success(localOnlyHotspotState);
    }
  }

  @Override
  public void onListen(Object o, EventChannel.EventSink eventSink) {
    if (!hasWifiScanPermission()) {
      if (requestingPermission) {
        return;
      }
      requestingPermission = true;
      permissionRequestCookie.clear();
      permissionRequestCookie.add(eventSink);
      moActivity.requestPermissions(
          wifiScanPermissions(), PERMISSIONS_REQUEST_CODE_ACCESS_FINE_LOCATION_ON_LISTEN);
    } else {
      _onListen(eventSink);
    }
  }

  private void _onListen(EventChannel.EventSink eventSink) {
    unregisterScanReceiver();
    receiver = createReceiver(eventSink);
    IntentFilter filter = new IntentFilter(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION);
    registerScanResultsReceiver(receiver, filter);
  }

  @SuppressWarnings("deprecation") // API < 33
  private void registerScanResultsReceiver(
      BroadcastReceiver broadcastReceiver, IntentFilter filter) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) { // API 33+
      moContext.registerReceiver(broadcastReceiver, filter, Context.RECEIVER_NOT_EXPORTED);
    } else {
      moContext.registerReceiver(broadcastReceiver, filter);
    }
  }

  private void unregisterScanReceiver() {
    if (receiver == null || moContext == null) {
      return;
    }
    try {
      moContext.unregisterReceiver(receiver);
    } catch (IllegalArgumentException ignored) {
      // already unregistered
    }
    receiver = null;
  }

  @Override
  public void onCancel(Object o) {
    unregisterScanReceiver();
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
        String ssid = ssidFromScanResult(result);
        if (ssid != null && !ssid.isEmpty()) {
          wifiObject.put("SSID", ssid);
          wifiObject.put("BSSID", result.BSSID);
          wifiObject.put("capabilities", result.capabilities);
          wifiObject.put("frequency", result.frequency);
          wifiObject.put("level", result.level);
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            wifiObject.put("timestamp", result.timestamp);
          } else {
            wifiObject.put("timestamp", 0);
          }
          wifiArray.put(wifiObject);
        }
      }
    } catch (JSONException e) {
      e.printStackTrace();
    } finally {
      return wifiArray;
    }
  }

  private void loadWifiList(final Result result) {
    if (!hasWifiScanPermission()) {
      if (requestingPermission) {
        result.error(
            "WifiIotPlugin.Permission", "Only one permission can be requested at a time", null);
        return;
      }
      requestingPermission = true;
      permissionRequestResultCallback = result;
      moActivity.requestPermissions(
          wifiScanPermissions(), PERMISSIONS_REQUEST_CODE_ACCESS_FINE_LOCATION_LOAD_WIFI_LIST);
    } else {
      _loadWifiList(result);
    }
  }

  private void _loadWifiList(final Result result) {
    try {
      moWiFi.startScan();
      result.success(handleNetworkScanResult().toString());
    } catch (Exception e) {
      result.error("Exception", e.getMessage(), null);
    }
  }

  @SuppressWarnings("deprecation") // API < 23
  private boolean selectNetwork(final Network network, final ConnectivityManager manager) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      return manager.bindProcessToNetwork(network);
    } else {
      return ConnectivityManager.setProcessDefaultNetwork(network);
    }
  }

  private void onAvailableNetwork(
      final ConnectivityManager manager, final Network network, final Result result) {
    final boolean success = selectNetwork(network, manager);
    final Handler handler = new Handler(Looper.getMainLooper());
    handler.post(
        new Runnable() {
          @Override
          public void run() {
            result.success(success);
          }
        });
  }

  private void forceWifiUsage(final MethodCall poCall, final Result result) {
    boolean useWifi = poCall.argument("useWifi");

    final ConnectivityManager manager =
        (ConnectivityManager) moContext.getSystemService(Context.CONNECTIVITY_SERVICE);

    boolean success = true;
    boolean shouldReply = true;
    if (Build.VERSION.SDK_INT > Build.VERSION_CODES.LOLLIPOP && manager != null) {
      if (useWifi) {
        Network joinedNetwork = wifiPlatform.getJoinedNetwork();
        if (joinedNetwork != null) {
          success = selectNetwork(joinedNetwork, manager);
        } else {
          NetworkRequest.Builder builder = new NetworkRequest.Builder();
          builder.addTransportType(NetworkCapabilities.TRANSPORT_WIFI);
          shouldReply = false;
          manager.requestNetwork(
              builder.build(),
              new ConnectivityManager.NetworkCallback() {
                @Override
                public void onAvailable(Network network) {
                  super.onAvailable(network);
                  manager.unregisterNetworkCallback(this);
                  onAvailableNetwork(manager, network, result);
                }
              });
        }
      } else {
        success = selectNetwork(null, manager);
      }
    }
    if (shouldReply) {
      result.success(success);
    }
  }

  private void isEnabled(Result result) {
    result.success(moWiFi.isWifiEnabled());
  }

  @SuppressWarnings("deprecation") // API < 29
  private void setEnabled(MethodCall poCall, Result result) {
    Boolean enabled = poCall.argument("state");
    Boolean shouldOpenSettings = poCall.argument("shouldOpenSettings");

    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
      moWiFi.setWifiEnabled(enabled);
    } else {
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

    result.success(null);
  }

  private void connect(final MethodCall poCall, final Result result) {
    new Thread() {
      public void run() {
        WifiConnectRequest request =
            new WifiConnectRequest(
                poCall.argument("ssid"),
                poCall.argument("bssid"),
                poCall.argument("password"),
                poCall.argument("security"),
                poCall.argument("join_once"),
                poCall.argument("with_internet"),
                poCall.argument("is_hidden"),
                poCall.argument("timeout_in_seconds"));
        connectWithResult(request, result);
      }
    }.start();
  }

  private void connectWithResult(WifiConnectRequest request, final Result result) {
    final Handler handler = new Handler(Looper.getMainLooper());
    wifiPlatform.connect(
        request,
        new WifiConnectCallback() {
          @Override
          public void onSuccess(final boolean connected) {
            if (Looper.myLooper() == Looper.getMainLooper()) {
              result.success(connected);
            } else {
              handler.post(() -> result.success(connected));
            }
          }

          @Override
          public void onError(final String code, final String message, final Object details) {
            if (Looper.myLooper() == Looper.getMainLooper()) {
              result.error(code, message, details);
            } else {
              handler.post(() -> result.error(code, message, details));
            }
          }
        });
  }

  private void registerWifiNetwork(final MethodCall poCall, final Result result) {
    wifiPlatform.registerNetwork(
        poCall.argument("ssid"),
        poCall.argument("bssid"),
        poCall.argument("password"),
        poCall.argument("security"),
        poCall.argument("is_hidden"),
        new WifiPlatform.RegisterCallback() {
          @Override
          public void onSuccess() {
            result.success(null);
          }

          @Override
          public void onError(String code, String message, Object details) {
            result.error(code, message, details);
          }
        });
  }

  private void findAndConnect(final MethodCall poCall, final Result result) {
    if (!hasWifiScanPermission()) {
      if (requestingPermission) {
        result.error(
            "WifiIotPlugin.Permission", "Only one permission can be requested at a time", null);
        return;
      }
      requestingPermission = true;
      permissionRequestResultCallback = result;
      permissionRequestCookie.clear();
      permissionRequestCookie.add(poCall);
      moActivity.requestPermissions(
          wifiScanPermissions(), PERMISSIONS_REQUEST_CODE_ACCESS_FINE_LOCATION_FIND_AND_CONNECT);
    } else {
      _findAndConnect(poCall, result);
    }
  }

  private void _findAndConnect(final MethodCall poCall, final Result result) {
    new Thread() {
      public void run() {
        String ssid = poCall.argument("ssid");
        String bssid = poCall.argument("bssid");
        String password = poCall.argument("password");
        Boolean joinOnce = poCall.argument("join_once");
        Boolean withInternet = poCall.argument("with_internet");
        Integer timeoutInSeconds = poCall.argument("timeout_in_seconds");

        String security = null;
        List<ScanResult> results = moWiFi.getScanResults();
        for (ScanResult result : results) {
          String resultString = ssidFromScanResult(result);
          if (ssid.equals(resultString)
              && (result.BSSID == null || bssid == null || result.BSSID.equals(bssid))) {
            security = securityTypeFromScanResult(result);
            if (bssid == null) {
              bssid = result.BSSID;
            }
          }
        }

        WifiConnectRequest request =
            new WifiConnectRequest(
                ssid, bssid, password, security, joinOnce, withInternet, false, timeoutInSeconds);
        connectWithResult(request, result);
      }
    }.start();
  }

  private void isConnected(Result result) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
      isConnectedDeprecated(result);
    } else {
      if (moContext.checkSelfPermission(Manifest.permission.ACCESS_NETWORK_STATE)
          != PackageManager.PERMISSION_GRANTED) {
        if (requestingPermission) {
          result.error(
              "WifiIotPlugin.Permission", "Only one permission can be requested at a time", null);
          return;
        }
        requestingPermission = true;
        permissionRequestResultCallback = result;
        moActivity.requestPermissions(
            new String[] {Manifest.permission.ACCESS_NETWORK_STATE},
            PERMISSIONS_REQUEST_CODE_ACCESS_NETWORK_STATE_IS_CONNECTED);
      } else {
        _isConnected(result);
      }
    }
  }

  private void _isConnected(Result result) {
    ConnectivityManager connManager =
        (ConnectivityManager) moContext.getSystemService(Context.CONNECTIVITY_SERVICE);
    boolean isConnected = false;
    if (connManager != null) {
      for (final Network network : connManager.getAllNetworks()) {
        final NetworkCapabilities capabilities =
            network != null ? connManager.getNetworkCapabilities(network) : null;
        final boolean hasWifi =
            capabilities != null && capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI);
        if (hasWifi) {
          isConnected = true;
          break;
        }
      }
    }

    result.success(isConnected);
  }

  @SuppressWarnings("deprecation") // API < 23
  private void isConnectedDeprecated(Result result) {
    ConnectivityManager connManager =
        (ConnectivityManager) moContext.getSystemService(Context.CONNECTIVITY_SERVICE);
    android.net.NetworkInfo mWifi =
        connManager != null ? connManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI) : null;

    result.success(mWifi != null && mWifi.isConnected());
  }

  private void disconnect(Result result) {
    result.success(wifiPlatform.disconnect());
  }

  private void getSSID(Result result) {
    if (!hasWifiScanPermission()) {
      result.error("WifiIotPlugin.Permission", wifiScanPermissionDeniedMessage(), null);
      return;
    }
    result.success(wifiPlatform.getSsid());
  }

  private void getBSSID(Result result) {
    if (!hasWifiScanPermission()) {
      result.error("WifiIotPlugin.Permission", wifiScanPermissionDeniedMessage(), null);
      return;
    }
    WifiInfo info = wifiPlatform.getWifiInfo();
    String bssid = info.getBSSID();
    try {
      result.success(bssid != null ? bssid.toUpperCase() : null);
    } catch (Exception e) {
      result.error("Exception", e.getMessage(), null);
    }
  }

  private void getCurrentSignalStrength(Result result) {
    result.success(wifiPlatform.getWifiInfo().getRssi());
  }

  private void getFrequency(Result result) {
    WifiInfo info = wifiPlatform.getWifiInfo();
    int frequency = 0;
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      frequency = info.getFrequency();
    }
    result.success(frequency);
  }

  private void getIP(Result result) {
    result.success(wifiPlatform.getIpv4());
  }

  @SuppressWarnings("deprecation") // API < 29
  private void removeWifiNetwork(MethodCall poCall, Result result) {
    String prefix_ssid = poCall.argument("ssid");
    if (prefix_ssid.equals("")) {
      result.error("Error", "No prefix SSID was given!", null);
    }
    boolean removed = false;

    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
      List<WifiConfiguration> mWifiConfigList = moWiFi.getConfiguredNetworks();
      for (WifiConfiguration wifiConfig : mWifiConfigList) {
        String comparableSSID = ('"' + prefix_ssid);
        if (wifiConfig.SSID.startsWith(comparableSSID)) {
          moWiFi.removeNetwork(wifiConfig.networkId);
          moWiFi.saveConfiguration();
          removed = true;
          break;
        }
      }
    }

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
      List<WifiNetworkSuggestion> suggestions = moWiFi.getNetworkSuggestions();
      List<WifiNetworkSuggestion> removeSuggestions = new ArrayList<>();
      for (int i = 0, suggestionsSize = suggestions.size(); i < suggestionsSize; i++) {
        WifiNetworkSuggestion suggestion = suggestions.get(i);
        if (suggestion.getSsid().startsWith(prefix_ssid)) {
          removeSuggestions.add(suggestion);
        }
      }
      final int networksRemoved = moWiFi.removeNetworkSuggestions(removeSuggestions);
      removed = networksRemoved == WifiManager.STATUS_NETWORK_SUGGESTIONS_SUCCESS;
    }
    result.success(removed);
  }

  @SuppressWarnings("deprecation") // API < 29
  private void isRegisteredWifiNetwork(MethodCall poCall, Result result) {
    String ssid = poCall.argument("ssid");
    List<WifiConfiguration> mWifiConfigList = moWiFi.getConfiguredNetworks();
    String comparableSSID = ('"' + ssid + '"');
    if (mWifiConfigList != null) {
      for (WifiConfiguration wifiConfig : mWifiConfigList) {
        if (wifiConfig.SSID.equals(comparableSSID)) {
          result.success(true);
          return;
        }
      }
    }
    result.success(false);
  }

  /** API 33+: WifiSsid; API < 33: SSID. */
  @Nullable
  @SuppressWarnings("deprecation") // API < 33
  private static String ssidFromScanResult(ScanResult result) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      WifiSsid wifiSsid = result.getWifiSsid();
      if (wifiSsid == null) {
        return null;
      }
      String ssid = wifiSsid.toString();
      if (ssid.startsWith("\"") && ssid.endsWith("\"") && ssid.length() >= 2) {
        return ssid.substring(1, ssid.length() - 1);
      }
      return ssid;
    }
    return result.SSID;
  }

  @Nullable
  private static String securityTypeFromScanResult(ScanResult scanResult) {
    String capabilities = scanResult.capabilities;
    if (capabilities.contains("WPA")
        || capabilities.contains("WPA2")
        || capabilities.contains("WPA/WPA2 PSK")) {
      return "WPA";
    } else if (capabilities.contains("WEP")) {
      return "WEP";
    }
    return null;
  }
}
