package com.alternadom.wifiiot.wifi;

import androidx.annotation.Nullable;

public interface WifiConnectCallback {
  void onSuccess(boolean connected);

  void onError(String code, String message, @Nullable Object details);
}
