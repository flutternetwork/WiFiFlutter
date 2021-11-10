/*
 * Copyright 2013 WhiteByte (Nick Russler, Ahmet Yueksektepe).
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package info.whitebyte.hotspotmanager;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.net.wifi.WifiConfiguration;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.Handler;
import android.provider.Settings;
import android.util.Log;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.lang.reflect.Method;
import java.net.InetAddress;
import java.util.ArrayList;

public class WifiApManager {
  private final WifiManager mWifiManager;
  private Context context;

  public WifiApManager(Context context) {
    this.context = context;
    mWifiManager = (WifiManager) this.context.getSystemService(Context.WIFI_SERVICE);
  }

  /**
   * Show write permission settings page to user if necessary or forced
   *
   * @param force show settings page even when rights are already granted
   */
  public void showWritePermissionSettings(boolean force) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      if (force || !Settings.System.canWrite(this.context)) {
        Intent intent = new Intent(android.provider.Settings.ACTION_MANAGE_WRITE_SETTINGS);
        intent.setData(Uri.parse("package:" + this.context.getPackageName()));
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        this.context.startActivity(intent);
      }
    }
  }

  /**
   * Start AccessPoint mode with the specified configuration. If the radio is already running in AP
   * mode, update the new configuration Note that starting in access point mode disables station
   * mode operation
   *
   * @param wifiConfig SSID, security and channel details as part of WifiConfiguration
   * @return {@code true} if the operation succeeds, {@code false} otherwise
   */
  public boolean setWifiApEnabled(WifiConfiguration wifiConfig, boolean enabled) {
    try {
      // Calling setWifiApEnabled requires MANAGE_WRITE_SETTINGS permissions, so check and request if needed
      showWritePermissionSettings(false);

      if (enabled) { // disable WiFi in any case
        mWifiManager.setWifiEnabled(false);
      }

      Method method =
          mWifiManager
              .getClass()
              .getMethod("setWifiApEnabled", WifiConfiguration.class, boolean.class);
      return (Boolean) method.invoke(mWifiManager, wifiConfig, enabled);
    } catch (Exception e) {
      Log.e(this.getClass().toString(), "", e);
      return false;
    }
  }

  /**
   * Gets the Wi-Fi enabled state.
   *
   * @return {@link WIFI_AP_STATE}
   * @see #isWifiApEnabled()
   */
  public WIFI_AP_STATE getWifiApState() {
    try {
      Method method = mWifiManager.getClass().getMethod("getWifiApState");

      int tmp = ((Integer) method.invoke(mWifiManager));

      // Fix for Android 4
      if (tmp >= 10) {
        tmp = tmp - 10;
      }

      return WIFI_AP_STATE.class.getEnumConstants()[tmp];
    } catch (Exception e) {
      Log.e(this.getClass().toString(), "", e);
      return WIFI_AP_STATE.WIFI_AP_STATE_FAILED;
    }
  }

  /**
   * Return whether Wi-Fi AP is enabled or disabled.
   *
   * @return {@code true} if Wi-Fi AP is enabled
   * @hide Dont open yet
   * @see #getWifiApState()
   */
  public boolean isWifiApEnabled() {
    return getWifiApState() == WIFI_AP_STATE.WIFI_AP_STATE_ENABLED;
  }

  /**
   * Gets the Wi-Fi AP Configuration.
   *
   * @return AP details in {@link WifiConfiguration}
   */
  public WifiConfiguration getWifiApConfiguration() {
    try {
      Method method = mWifiManager.getClass().getMethod("getWifiApConfiguration");
      return (WifiConfiguration) method.invoke(mWifiManager);
    } catch (Exception e) {
      Log.e(this.getClass().toString(), "", e);
      return null;
    }
  }

  /**
   * Sets the Wi-Fi AP Configuration.
   *
   * @return {@code true} if the operation succeeded, {@code false} otherwise
   */
  public boolean setWifiApConfiguration(WifiConfiguration wifiConfig) {
    try {
      Method method =
          mWifiManager.getClass().getMethod("setWifiApConfiguration", WifiConfiguration.class);
      return (Boolean) method.invoke(mWifiManager, wifiConfig);
    } catch (Exception e) {
      Log.e(this.getClass().toString(), "", e);
      return false;
    }
  }

  /**
   * Gets a list of the clients connected to the Hotspot, reachable timeout is 300
   *
   * @param onlyReachables {@code false} if the list should contain unreachable (probably
   *     disconnected) clients, {@code true} otherwise
   * @param finishListener, Interface called when the scan method finishes
   */
  public void getClientList(boolean onlyReachables, FinishScanListener finishListener) {
    getClientList(onlyReachables, 300, finishListener);
  }

  /**
   * Gets a list of the clients connected to the Hotspot
   *
   * @param onlyReachables {@code false} if the list should contain unreachable (probably
   *     disconnected) clients, {@code true} otherwise
   * @param reachableTimeout Reachable Timout in miliseconds
   * @param finishListener, Interface called when the scan method finishes
   */
  public void getClientList(
      final boolean onlyReachables,
      final int reachableTimeout,
      final FinishScanListener finishListener) {
    Runnable runnable =
        new Runnable() {
          public void run() {

            BufferedReader br = null;
            final ArrayList<ClientScanResult> result = new ArrayList<ClientScanResult>();

            try {
              br = new BufferedReader(new FileReader("/proc/net/arp"));
              String line;
              while ((line = br.readLine()) != null) {
                String[] splitted = line.split(" +");

                if ((splitted != null) && (splitted.length >= 4)) {
                  // Basic sanity check
                  String mac = splitted[3];

                  if (mac.matches("..:..:..:..:..:..")) {
                    boolean isReachable =
                        InetAddress.getByName(splitted[0]).isReachable(reachableTimeout);

                    if (!onlyReachables || isReachable) {
                      result.add(
                          new ClientScanResult(splitted[0], splitted[3], splitted[5], isReachable));
                    }
                  }
                }
              }
            } catch (Exception e) {
              Log.e(this.getClass().toString(), e.toString());
            } finally {
              try {
                br.close();
              } catch (IOException e) {
                Log.e(this.getClass().toString(), e.getMessage());
              }
            }

            // Get a handler that can be used to post to the main thread
            Handler mainHandler = new Handler(context.getMainLooper());
            Runnable myRunnable =
                new Runnable() {
                  @Override
                  public void run() {
                    finishListener.onFinishScan(result);
                  }
                };
            mainHandler.post(myRunnable);
          }
        };

    Thread mythread = new Thread(runnable);
    mythread.start();
  }
}
