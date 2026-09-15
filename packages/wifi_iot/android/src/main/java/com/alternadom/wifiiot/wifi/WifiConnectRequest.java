package com.alternadom.wifiiot.wifi;

import androidx.annotation.Nullable;

/** Parameters for a STA connect attempt. */
public final class WifiConnectRequest {
  public final String ssid;
  @Nullable public final String bssid;
  @Nullable public final String password;
  @Nullable public final String security;
  @Nullable public final Boolean joinOnce;
  @Nullable public final Boolean withInternet;
  @Nullable public final Boolean isHidden;
  @Nullable public final Integer timeoutInSeconds;

  public WifiConnectRequest(
      String ssid,
      @Nullable String bssid,
      @Nullable String password,
      @Nullable String security,
      @Nullable Boolean joinOnce,
      @Nullable Boolean withInternet,
      @Nullable Boolean isHidden,
      @Nullable Integer timeoutInSeconds) {
    this.ssid = ssid;
    this.bssid = bssid;
    this.password = password;
    this.security = security;
    this.joinOnce = joinOnce;
    this.withInternet = withInternet;
    this.isHidden = isHidden;
    this.timeoutInSeconds = timeoutInSeconds;
  }
}
