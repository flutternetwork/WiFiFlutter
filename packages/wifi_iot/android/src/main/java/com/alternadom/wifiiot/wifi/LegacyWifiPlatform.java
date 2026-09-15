package com.alternadom.wifiiot.wifi;

import android.net.Network;
import android.net.wifi.SupplicantState;
import android.net.wifi.WifiConfiguration;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import java.util.ArrayList;
import java.util.List;

/** Legacy STA backend for API < 29. */
@SuppressWarnings("deprecation") // API < 29
public final class LegacyWifiPlatform implements WifiPlatform {
  private static final String UNKNOWN_SSID = "<unknown ssid>";
  private static final String HEX_EMPTY_SSID = "0x";

  private final WifiManager wifiManager;
  private final List<String> ssidsToRemoveOnClose = new ArrayList<>();

  public LegacyWifiPlatform(WifiManager wifiManager) {
    this.wifiManager = wifiManager;
  }

  @Override
  public void connect(WifiConnectRequest request, WifiConnectCallback callback) {
    callback.onSuccess(
        connectLegacy(
            request.ssid,
            request.bssid,
            request.password,
            request.security,
            request.joinOnce,
            request.isHidden));
  }

  @Override
  public boolean disconnect() {
    return wifiManager.disconnect();
  }

  @Override
  public void registerNetwork(
      String ssid,
      @Nullable String bssid,
      @Nullable String password,
      @Nullable String security,
      @Nullable Boolean isHidden,
      RegisterCallback callback) {
    WifiConfiguration conf = createConfiguration(ssid, bssid, password, security, isHidden);
    if (updateOrCreateNetwork(conf) == -1) {
      callback.onError("Error", "Error updating network configuration", "");
    } else {
      callback.onSuccess();
    }
  }

  @Override
  @NonNull
  public WifiInfo getWifiInfo() {
    return wifiManager.getConnectionInfo();
  }

  @Override
  @Nullable
  public String getSsid() {
    return normalizeSsid(getWifiInfo().getSSID());
  }

  @Override
  @Nullable
  public String getIpv4() {
    return formatIpv4(getWifiInfo().getIpAddress());
  }

  @Override
  @Nullable
  public Network getJoinedNetwork() {
    return null;
  }

  @Override
  public void close() {
    if (ssidsToRemoveOnClose.isEmpty()) {
      return;
    }
    List<WifiConfiguration> configs = wifiManager.getConfiguredNetworks();
    if (configs == null) {
      return;
    }
    for (String ssid : ssidsToRemoveOnClose) {
      for (WifiConfiguration config : configs) {
        if (config.SSID.equals(ssid)) {
          wifiManager.removeNetwork(config.networkId);
        }
      }
    }
    ssidsToRemoveOnClose.clear();
  }

  private boolean connectLegacy(
      String ssid,
      @Nullable String bssid,
      @Nullable String password,
      @Nullable String security,
      @Nullable Boolean joinOnce,
      @Nullable Boolean isHidden) {
    WifiConfiguration conf = createConfiguration(ssid, bssid, password, security, isHidden);
    int networkId = updateOrCreateNetwork(conf);
    if (networkId == -1) {
      return false;
    }

    if (joinOnce != null && joinOnce) {
      ssidsToRemoveOnClose.add(conf.SSID);
    }

    if (!wifiManager.disconnect()) {
      return false;
    }
    if (!wifiManager.enableNetwork(networkId, true)) {
      return false;
    }

    for (int i = 0; i < 20; i++) {
      WifiInfo info = getWifiInfo();
      if (info.getNetworkId() != -1 && info.getSupplicantState() == SupplicantState.COMPLETED) {
        return info.getNetworkId() == networkId;
      }
      try {
        Thread.sleep(500);
      } catch (InterruptedException ignored) {
        break;
      }
    }
    return false;
  }

  private WifiConfiguration createConfiguration(
      String ssid,
      @Nullable String bssid,
      @Nullable String password,
      @Nullable String security,
      @Nullable Boolean isHidden) {
    WifiConfiguration conf = new WifiConfiguration();
    conf.SSID = "\"" + ssid + "\"";
    conf.hiddenSSID = isHidden != null ? isHidden : false;
    if (bssid != null) {
      conf.BSSID = bssid;
    }

    if (security != null) {
      security = security.toUpperCase();
    } else {
      security = "NONE";
    }

    if (security.equals("WPA")) {
      conf.preSharedKey = "\"" + password + "\"";
      conf.allowedProtocols.set(WifiConfiguration.Protocol.RSN);
      conf.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.WPA_PSK);
      conf.status = WifiConfiguration.Status.ENABLED;
      conf.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.TKIP);
      conf.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.CCMP);
      conf.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.WPA_PSK);
      conf.allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.TKIP);
      conf.allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.CCMP);
      conf.allowedProtocols.set(WifiConfiguration.Protocol.RSN);
      conf.allowedProtocols.set(WifiConfiguration.Protocol.WPA);
    } else if (security.equals("WEP")) {
      conf.wepKeys[0] = "\"" + password + "\"";
      conf.wepTxKeyIndex = 0;
      conf.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE);
      conf.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.WEP40);
    } else {
      conf.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE);
    }
    return conf;
  }

  private int updateOrCreateNetwork(WifiConfiguration conf) {
    int updateNetwork = -1;
    int registeredNetwork = -1;
    List<WifiConfiguration> configs = wifiManager.getConfiguredNetworks();
    if (configs != null) {
      for (WifiConfiguration existing : configs) {
        if (existing.SSID.equals(conf.SSID)
            && (existing.BSSID == null
                || conf.BSSID == null
                || existing.BSSID.equals(conf.BSSID))) {
          conf.networkId = existing.networkId;
          registeredNetwork = existing.networkId;
          updateNetwork = wifiManager.updateNetwork(conf);
        }
      }
    }
    if (updateNetwork == -1) {
      updateNetwork = wifiManager.addNetwork(conf);
      wifiManager.saveConfiguration();
    }
    return updateNetwork == -1 ? registeredNetwork : updateNetwork;
  }

  @Nullable
  static String normalizeSsid(@Nullable String ssid) {
    if (ssid == null) {
      return null;
    }
    if (ssid.length() >= 2 && ssid.charAt(0) == '"' && ssid.charAt(ssid.length() - 1) == '"') {
      ssid = ssid.substring(1, ssid.length() - 1);
    }
    if (ssid.isEmpty() || UNKNOWN_SSID.equals(ssid) || HEX_EMPTY_SSID.equals(ssid)) {
      return null;
    }
    return ssid;
  }

  static String formatIpv4(int longIp) {
    return (longIp & 0xff)
        + "."
        + ((longIp >> 8) & 0xff)
        + "."
        + ((longIp >> 16) & 0xff)
        + "."
        + ((longIp >> 24) & 0xff);
  }
}
