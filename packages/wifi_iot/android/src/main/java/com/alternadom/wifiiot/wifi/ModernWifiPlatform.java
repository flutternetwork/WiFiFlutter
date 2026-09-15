package com.alternadom.wifiiot.wifi;

import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.LinkAddress;
import android.net.LinkProperties;
import android.net.MacAddress;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.NetworkRequest;
import android.net.TransportInfo;
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
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import java.net.Inet4Address;
import java.net.InetAddress;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

/** Modern STA backend for API 29+. */
@RequiresApi(api = Build.VERSION_CODES.Q) // API 29+
@SuppressWarnings("deprecation") // API < 31
public final class ModernWifiPlatform implements WifiPlatform {
  private static final String TAG = "ModernWifiPlatform";
  private static final int DEFAULT_TIMEOUT_MS = 30000;

  private final Context context;
  private final WifiManager wifiManager;
  private final ConnectivityManager connectivityManager;
  private final Handler handler = new Handler(Looper.getMainLooper());

  private ConnectivityManager.NetworkCallback networkCallback;
  private List<WifiNetworkSuggestion> networkSuggestions;
  @Nullable private Network joinedNetwork;
  private final List<WifiNetworkSuggestion> suggestionsToRemoveOnClose = new ArrayList<>();

  public ModernWifiPlatform(
      Context context, WifiManager wifiManager, ConnectivityManager connectivityManager) {
    this.context = context;
    this.wifiManager = wifiManager;
    this.connectivityManager = connectivityManager;
  }

  @Override
  public void connect(WifiConnectRequest request, WifiConnectCallback callback) {
    if (request.security != null && request.security.toUpperCase().equals("WEP")) {
      handler.post(
          () ->
              callback.onError(
                  "Error", "WEP is not supported for Android SDK " + Build.VERSION.SDK_INT, ""));
      return;
    }

    if (request.withInternet != null && request.withInternet) {
      connectWithSuggestion(request, callback);
    } else {
      connectWithSpecifier(request, callback);
    }
  }

  private void connectWithSuggestion(WifiConnectRequest request, WifiConnectCallback callback) {
    final WifiNetworkSuggestion.Builder builder = new WifiNetworkSuggestion.Builder();
    builder.setSsid(request.ssid);
    builder.setIsHiddenSsid(request.isHidden != null ? request.isHidden : false);
    if (!applyBssid(builder, request.bssid, callback)) {
      return;
    }
    if (request.security != null && request.security.toUpperCase().equals("WPA")) {
      builder.setWpa2Passphrase(request.password);
    }

    if (networkSuggestions != null) {
      wifiManager.removeNetworkSuggestions(networkSuggestions);
    }

    final WifiNetworkSuggestion suggestion = builder.build();
    networkSuggestions = new ArrayList<>();
    networkSuggestions.add(suggestion);
    if (request.joinOnce != null && request.joinOnce) {
      suggestionsToRemoveOnClose.add(suggestion);
    }

    int status = wifiManager.addNetworkSuggestions(networkSuggestions);
    if (status == WifiManager.STATUS_NETWORK_SUGGESTIONS_ERROR_ADD_DUPLICATE) {
      wifiManager.removeNetworkSuggestions(networkSuggestions);
      status = wifiManager.addNetworkSuggestions(networkSuggestions);
    }
    Log.d(TAG, "addNetworkSuggestions status: " + status + " (suggestion_added_async if SUCCESS)");
    final boolean added = status == WifiManager.STATUS_NETWORK_SUGGESTIONS_SUCCESS;
    handler.post(() -> callback.onSuccess(added));
  }

  private void connectWithSpecifier(WifiConnectRequest request, WifiConnectCallback callback) {
    final WifiNetworkSpecifier.Builder builder = new WifiNetworkSpecifier.Builder();
    builder.setSsid(request.ssid);
    builder.setIsHiddenSsid(request.isHidden != null ? request.isHidden : false);
    if (!applyBssid(builder, request.bssid, callback)) {
      return;
    }
    if (request.security != null && request.security.toUpperCase().equals("WPA")) {
      builder.setWpa2Passphrase(request.password);
    }

    final NetworkRequest networkRequest =
        new NetworkRequest.Builder()
            .addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
            .removeCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            .setNetworkSpecifier(builder.build())
            .build();

    unregisterNetwork(networkCallback);
    networkCallback = null;

    Integer timeoutInSeconds = request.timeoutInSeconds;
    int timeoutMs = timeoutInSeconds != null ? timeoutInSeconds * 1000 : DEFAULT_TIMEOUT_MS;

    final AtomicBoolean done = new AtomicBoolean(false);

    networkCallback =
        new ConnectivityManager.NetworkCallback() {
          @Override
          public void onAvailable(@NonNull Network network) {
            super.onAvailable(network);
            if (!done.compareAndSet(false, true)) {
              return;
            }
            joinedNetwork = network;
            connectivityManager.bindProcessToNetwork(network);
            handler.post(() -> callback.onSuccess(true));
          }

          @Override
          public void onUnavailable() {
            super.onUnavailable();
            if (!done.compareAndSet(false, true)) {
              return;
            }
            // Keep callback registered on API 30+ so a later user approval can still deliver
            // onAvailable; on API 29, unregister to avoid leaks after terminal failure.
            if (Build.VERSION.SDK_INT == Build.VERSION_CODES.Q) {
              unregisterNetwork(this);
              if (networkCallback == this) {
                networkCallback = null;
              }
            }
            handler.post(() -> callback.onSuccess(false));
          }

          @Override
          public void onLost(Network network) {
            super.onLost(network);
            if (joinedNetwork != null && joinedNetwork.equals(network)) {
              connectivityManager.bindProcessToNetwork(null);
              joinedNetwork = null;
            }
            if (Build.VERSION.SDK_INT == Build.VERSION_CODES.Q) {
              unregisterNetwork(this);
              if (networkCallback == this) {
                networkCallback = null;
              }
            }
          }
        };

    connectivityManager.requestNetwork(networkRequest, networkCallback, handler, timeoutMs);
  }

  private boolean applyBssid(
      WifiNetworkSuggestion.Builder builder, @Nullable String bssid, WifiConnectCallback callback) {
    if (bssid == null) {
      return true;
    }
    MacAddress mac = parseMacAddress(bssid);
    if (mac == null) {
      handler.post(() -> callback.onError("Error", "Invalid BSSID representation", ""));
      return false;
    }
    builder.setBssid(mac);
    return true;
  }

  private boolean applyBssid(
      WifiNetworkSpecifier.Builder builder, @Nullable String bssid, WifiConnectCallback callback) {
    if (bssid == null) {
      return true;
    }
    MacAddress mac = parseMacAddress(bssid);
    if (mac == null) {
      handler.post(() -> callback.onError("Error", "Invalid BSSID representation", ""));
      return false;
    }
    builder.setBssid(mac);
    return true;
  }

  @Override
  public boolean disconnect() {
    connectivityManager.bindProcessToNetwork(null);
    joinedNetwork = null;

    boolean hasCallback = networkCallback != null;
    unregisterNetwork(networkCallback);
    networkCallback = null;

    boolean hasSuggestions = networkSuggestions != null;
    boolean removed = true;
    if (networkSuggestions != null) {
      removed =
          wifiManager.removeNetworkSuggestions(networkSuggestions)
              == WifiManager.STATUS_NETWORK_SUGGESTIONS_SUCCESS;
      networkSuggestions = null;
    }
    if (!suggestionsToRemoveOnClose.isEmpty()) {
      wifiManager.removeNetworkSuggestions(suggestionsToRemoveOnClose);
      suggestionsToRemoveOnClose.clear();
    }

    if (!hasCallback && !hasSuggestions) {
      Log.e(TAG, "Can't disconnect from WiFi, no active callback/suggestions.");
      return false;
    }
    return hasCallback || removed;
  }

  @Override
  public void registerNetwork(
      String ssid,
      @Nullable String bssid,
      @Nullable String password,
      @Nullable String security,
      @Nullable Boolean isHidden,
      RegisterCallback callback) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) { // API < 30
      new LegacyWifiPlatform(wifiManager)
          .registerNetwork(ssid, bssid, password, security, isHidden, callback);
      return;
    }
    createNetworkViaSettings(ssid, bssid, password, security, isHidden, callback);
  }

  @RequiresApi(api = Build.VERSION_CODES.R) // API 30+
  private void createNetworkViaSettings(
      String ssid,
      @Nullable String bssid,
      @Nullable String password,
      @Nullable String security,
      @Nullable Boolean isHidden,
      RegisterCallback callback) {
    final WifiNetworkSuggestion.Builder suggestedNet = new WifiNetworkSuggestion.Builder();
    suggestedNet.setSsid(ssid);
    suggestedNet.setIsHiddenSsid(isHidden != null ? isHidden : false);
    if (bssid != null) {
      MacAddress macAddress = parseMacAddress(bssid);
      if (macAddress == null) {
        callback.onError("Error", "Invalid BSSID representation", "");
        return;
      }
      suggestedNet.setBssid(macAddress);
    }

    if (security != null && security.toUpperCase().equals("WPA")) {
      suggestedNet.setWpa2Passphrase(password);
    } else if (security != null && security.toUpperCase().equals("WEP")) {
      callback.onError(
          "Error", "WEP is not supported for Android SDK " + Build.VERSION.SDK_INT, "");
      return;
    }

    final ArrayList<WifiNetworkSuggestion> suggestionsList = new ArrayList<>();
    suggestionsList.add(suggestedNet.build());

    Bundle bundle = new Bundle();
    bundle.putParcelableArrayList(Settings.EXTRA_WIFI_NETWORK_LIST, suggestionsList);
    Intent intent = new Intent(Settings.ACTION_WIFI_ADD_NETWORKS);
    intent.putExtras(bundle);
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    context.startActivity(intent);
    callback.onSuccess();
  }

  @Override
  @NonNull
  public WifiInfo getWifiInfo() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) { // API 31+
      WifiInfo wifiInfo = fetchWifiInfoFromConnectivityManager();
      if (wifiInfo != null) {
        return wifiInfo;
      }
    }
    return wifiManager.getConnectionInfo();
  }

  @Override
  @Nullable
  public String getSsid() {
    return LegacyWifiPlatform.normalizeSsid(getWifiInfo().getSSID());
  }

  @Override
  @Nullable
  public String getIpv4() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) { // API 31+
      String ipv4 = fetchIpv4FromLinkProperties();
      if (ipv4 != null) {
        return ipv4;
      }
    }
    return LegacyWifiPlatform.formatIpv4(getWifiInfo().getIpAddress());
  }

  @Override
  @Nullable
  public Network getJoinedNetwork() {
    return joinedNetwork;
  }

  @Override
  public void close() {
    connectivityManager.bindProcessToNetwork(null);
    joinedNetwork = null;

    unregisterNetwork(networkCallback);
    networkCallback = null;

    if (networkSuggestions != null) {
      wifiManager.removeNetworkSuggestions(networkSuggestions);
      networkSuggestions = null;
    }

    if (!suggestionsToRemoveOnClose.isEmpty()) {
      wifiManager.removeNetworkSuggestions(suggestionsToRemoveOnClose);
      suggestionsToRemoveOnClose.clear();
    }
  }

  private void unregisterNetwork(@Nullable ConnectivityManager.NetworkCallback callback) {
    if (callback == null) {
      return;
    }
    try {
      connectivityManager.unregisterNetworkCallback(callback);
    } catch (IllegalArgumentException ignored) {
      // already unregistered
    }
  }

  @Nullable
  private static MacAddress parseMacAddress(@Nullable String bssid) {
    if (bssid == null) {
      return null;
    }
    try {
      return MacAddress.fromString(bssid);
    } catch (IllegalArgumentException e) {
      Log.e(TAG, "Mac address parsing failed for bssid: " + bssid, e);
      return null;
    }
  }

  @Nullable
  @RequiresApi(api = Build.VERSION_CODES.S) // API 31+
  private WifiInfo fetchWifiInfoFromConnectivityManager() {
    for (Network network : orderedWifiNetworks()) {
      WifiInfo wifiInfo = fetchWifiInfoFromNetwork(network);
      if (wifiInfo != null && LegacyWifiPlatform.normalizeSsid(wifiInfo.getSSID()) != null) {
        return wifiInfo;
      }
    }
    return null;
  }

  @RequiresApi(api = Build.VERSION_CODES.M) // API 23+
  private List<Network> orderedWifiNetworks() {
    List<Network> ordered = new ArrayList<>();
    if (joinedNetwork != null) {
      ordered.add(joinedNetwork);
    }

    List<Network> activeWifi = new ArrayList<>();
    List<Network> rest = new ArrayList<>();
    Network activeNetwork = connectivityManager.getActiveNetwork();

    for (Network network : connectivityManager.getAllNetworks()) {
      if (joinedNetwork != null && network.equals(joinedNetwork)) {
        continue;
      }
      NetworkCapabilities capabilities = connectivityManager.getNetworkCapabilities(network);
      if (capabilities == null || !capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)) {
        continue;
      }
      if (activeNetwork != null && network.equals(activeNetwork)) {
        activeWifi.add(network);
      } else {
        rest.add(network);
      }
    }
    ordered.addAll(activeWifi);
    ordered.addAll(rest);
    return ordered;
  }

  @Nullable
  @RequiresApi(api = Build.VERSION_CODES.Q) // API 29+
  private WifiInfo fetchWifiInfoFromNetwork(Network network) {
    NetworkCapabilities capabilities = connectivityManager.getNetworkCapabilities(network);
    if (capabilities == null) {
      return null;
    }
    TransportInfo transportInfo = capabilities.getTransportInfo();
    return transportInfo instanceof WifiInfo ? (WifiInfo) transportInfo : null;
  }

  @Nullable
  @RequiresApi(api = Build.VERSION_CODES.S) // API 31+
  private String fetchIpv4FromLinkProperties() {
    for (Network wifiNetwork : orderedWifiNetworks()) {
      LinkProperties linkProperties = connectivityManager.getLinkProperties(wifiNetwork);
      if (linkProperties == null) {
        continue;
      }
      for (LinkAddress linkAddress : linkProperties.getLinkAddresses()) {
        InetAddress address = linkAddress.getAddress();
        if (address instanceof Inet4Address) {
          return address.getHostAddress();
        }
      }
    }
    return null;
  }
}
