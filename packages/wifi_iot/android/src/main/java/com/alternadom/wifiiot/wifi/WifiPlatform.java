package com.alternadom.wifiiot.wifi;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * STA Wi‑Fi backend: {@link LegacyWifiPlatform} (API &lt; 29) or {@link ModernWifiPlatform} (API
 * 29+).
 */
public interface WifiPlatform {
  void connect(WifiConnectRequest request, WifiConnectCallback callback);

  boolean disconnect();

  void registerNetwork(
      String ssid,
      @Nullable String bssid,
      @Nullable String password,
      @Nullable String security,
      @Nullable Boolean isHidden,
      RegisterCallback callback);

  @NonNull
  WifiInfo getWifiInfo();

  @Nullable
  String getSsid();

  @Nullable
  String getIpv4();

  @Nullable
  Network getJoinedNetwork();

  void close();

  interface RegisterCallback {
    void onSuccess();

    void onError(String code, String message, @Nullable Object details);
  }

  static WifiPlatform create(
      Context context, WifiManager wifiManager, ConnectivityManager connectivityManager) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
      return new LegacyWifiPlatform(wifiManager);
    }
    return new ModernWifiPlatform(context, wifiManager, connectivityManager);
  }
}
