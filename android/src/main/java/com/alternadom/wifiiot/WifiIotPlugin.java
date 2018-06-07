package com.alternadom.wifiiot;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.NetworkInfo;
import android.net.NetworkRequest;
import android.net.Uri;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiConfiguration;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.provider.Settings;
import android.util.Log;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.Closeable;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.DatagramSocket;
import java.net.Socket;
import java.util.ArrayList;
import java.util.List;

import info.whitebyte.hotspotmanager.ClientScanResult;
import info.whitebyte.hotspotmanager.FinishScanListener;
import info.whitebyte.hotspotmanager.WifiApManager;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * WifiIotPlugin
 */
public class WifiIotPlugin implements MethodCallHandler {
    private WifiManager moWiFi;
    private Context moContext;
    private WifiApManager moWiFiAPManager;

    private WifiIotPlugin(Activity poActivity) {
        this.moContext = poActivity.getApplicationContext();
        this.moWiFi = (WifiManager) moContext.getApplicationContext().getSystemService(Context.WIFI_SERVICE);
        this.moWiFiAPManager = new WifiApManager(moContext.getApplicationContext());
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "wifi_iot");
        channel.setMethodCallHandler(new WifiIotPlugin(registrar.activity()));

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
                isRegisteredWifiNetwork(poCall, poResult);
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
            case "setMACFiltering":
                setMACFiltering(poCall, poResult);
                break;
            default:
                poResult.notImplemented();
                break;
        }
    }

    /**
     *
     * @param poCall
     * @param poResult
     */
    private void setMACFiltering(MethodCall poCall, Result poResult) {
//        String sResult = sudoForResult("iptables --list");
//        Log.d(this.getClass().toString(), sResult);
        boolean bEnable = poCall.argument("state");


        /// cat /data/misc/wifi_hostapd/hostapd.accept

        Log.e(this.getClass().toString(), "TODO : Develop function to enable/disable MAC filtering...");

        poResult.error("TODO", "Develop function to enable/disable MAC filtering...", null);
    }


    /**
     * The network's SSID. Can either be an ASCII string,
     * which must be enclosed in double quotation marks
     * (e.g., {@code "MyNetwork"}), or a string of
     * hex digits, which are not enclosed in quotes
     * (e.g., {@code 01a243f405}).
     */
    private void getWiFiAPSSID(Result poResult) {
        WifiConfiguration oWiFiConfig = moWiFiAPManager.getWifiApConfiguration();
        String sAPSSID = oWiFiConfig.SSID;
        poResult.success(sAPSSID);
    }

    private void setWiFiAPSSID(MethodCall poCall, Result poResult) {
        String sAPSSID = poCall.argument("ssid");

        WifiConfiguration oWiFiConfig = moWiFiAPManager.getWifiApConfiguration();

        oWiFiConfig.SSID = sAPSSID;

        moWiFiAPManager.setWifiApConfiguration(oWiFiConfig);

        poResult.success(null);
    }

    /**
     * This is a network that does not broadcast its SSID, so an
     * SSID-specific probe request must be used for scans.
     */
    private void isSSIDHidden(Result poResult) {
        WifiConfiguration oWiFiConfig = moWiFiAPManager.getWifiApConfiguration();
        boolean isSSIDHidden = oWiFiConfig.hiddenSSID;
        poResult.success(isSSIDHidden);
    }

    private void setSSIDHidden(MethodCall poCall, Result poResult) {
        boolean isSSIDHidden = poCall.argument("hidden");

        WifiConfiguration oWiFiConfig = moWiFiAPManager.getWifiApConfiguration();

        Log.d(this.getClass().toString(), "isSSIDHidden : " + isSSIDHidden);
        oWiFiConfig.hiddenSSID = isSSIDHidden;

        moWiFiAPManager.setWifiApConfiguration(oWiFiConfig);

        poResult.success(null);
    }

    /**
     * Pre-shared key for use with WPA-PSK. Either an ASCII string enclosed in
     * double quotation marks (e.g., {@code "abcdefghij"} for PSK passphrase or
     * a string of 64 hex digits for raw PSK.
     * <p/>
     * When the value of this key is read, the actual key is
     * not returned, just a "*" if the key has a value, or the null
     * string otherwise.
     */
    private void getWiFiAPPreSharedKey(Result poResult) {
        WifiConfiguration oWiFiConfig = moWiFiAPManager.getWifiApConfiguration();
        String sPreSharedKey = oWiFiConfig.preSharedKey;
        poResult.success(sPreSharedKey);
    }

    private void setWiFiAPPreSharedKey(MethodCall poCall, Result poResult) {
        String sPreSharedKey = poCall.argument("preSharedKey");

        WifiConfiguration oWiFiConfig = moWiFiAPManager.getWifiApConfiguration();

        oWiFiConfig.preSharedKey = sPreSharedKey;

        moWiFiAPManager.setWifiApConfiguration(oWiFiConfig);

        poResult.success(null);
    }

    /**
     * Gets a list of the clients connected to the Hotspot
     * *** getClientList :
     * param onlyReachables   {@code false} if the list should contain unreachable (probably disconnected) clients, {@code true} otherwise
     * param reachableTimeout Reachable Timout in miliseconds, 300 is default
     * param finishListener,  Interface called when the scan method finishes
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
        FinishScanListener oFinishScanListener = new FinishScanListener() {
            @Override
            public void onFinishScan(final ArrayList<ClientScanResult> clients) {
                try {
                    JSONArray clientArray = new JSONArray();

                    for (ClientScanResult client : clients) {
                        JSONObject clientObject = new JSONObject();

                        if (client.isReachable() == finalOnlyReachables) {
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
     * Return whether Wi-Fi AP is enabled or disabled.
     * *** isWifiApEnabled :
     * return {@code true} if Wi-Fi AP is enabled
     */
    private void isWiFiAPEnabled(Result poResult) {
        poResult.success(moWiFiAPManager.isWifiApEnabled());
    }

    /**
     * Start AccessPoint mode with the specified
     * configuration. If the radio is already running in
     * AP mode, update the new configuration
     * Note that starting in access point mode disables station
     * mode operation
     * *** setWifiApEnabled :
     * param wifiConfig SSID, security and channel details as part of WifiConfiguration
     * return {@code true} if the operation succeeds, {@code false} otherwise
     */
    private void setWiFiAPEnabled(MethodCall poCall, Result poResult) {
        boolean enabled = poCall.argument("state");
        moWiFiAPManager.setWifiApEnabled(null, enabled);
        poResult.success(null);
    }

    /**
     * Gets the Wi-Fi enabled state.
     * *** getWifiApState :
     * return {link WIFI_AP_STATE}
     */
    private void getWiFiAPState(Result poResult) {
        poResult.success(moWiFiAPManager.getWifiApState().ordinal());
    }

    /// Method to load wifi list into string via Callback. Returns a stringified JSONArray
    private void loadWifiList(Result poResult) {
        try {
            List<ScanResult> results = moWiFi.getScanResults();
            JSONArray wifiArray = new JSONArray();

            for (ScanResult result : results) {
                JSONObject wifiObject = new JSONObject();
                if (!result.SSID.equals("")) {
                    try {
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
                    } catch (JSONException e) {
                        poResult.error("Exception", e.getMessage(), null);
                    }
                    wifiArray.put(wifiObject);
                }
            }
            poResult.success(wifiArray.toString());
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
    private void forceWifiUsage(MethodCall poCall, Result poResult) {
        boolean canWriteFlag = false;

        boolean useWifi = poCall.argument("useWifi");

        if (useWifi) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    canWriteFlag = Settings.System.canWrite(moContext);

                    if (!canWriteFlag) {
                        Intent intent = new Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS);
                        intent.setData(Uri.parse("package:" + moContext.getPackageName()));
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);

                        moContext.startActivity(intent);
                    }
                }


                if (((Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) && canWriteFlag) || ((Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) && !(Build.VERSION.SDK_INT >= Build.VERSION_CODES.M))) {
                    final ConnectivityManager manager = (ConnectivityManager) moContext
                            .getSystemService(Context.CONNECTIVITY_SERVICE);
                    NetworkRequest.Builder builder;
                    builder = new NetworkRequest.Builder();
                    /// set the transport type do WIFI
                    builder.addTransportType(NetworkCapabilities.TRANSPORT_WIFI);

                    if (manager != null) {
                        manager.requestNetwork(builder.build(), new ConnectivityManager.NetworkCallback() {
                            @Override
                            public void onAvailable(Network network) {
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                    manager.bindProcessToNetwork(network);
                                    manager.unregisterNetworkCallback(this);
                                } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                                    ConnectivityManager.setProcessDefaultNetwork(network);
                                    manager.unregisterNetworkCallback(this);
                                }
                            }
                        });
                    }
                }
            }
        } else {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                ConnectivityManager manager = (ConnectivityManager) moContext
                        .getSystemService(Context.CONNECTIVITY_SERVICE);
                assert manager != null;
                manager.bindProcessToNetwork(null);
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                ConnectivityManager.setProcessDefaultNetwork(null);
            }
        }
        poResult.success(null);
    }

    /// Method to check if wifi is enabled
    private void isEnabled(Result poResult) {
        poResult.success(moWiFi.isWifiEnabled());
    }

    /// Method to connect/disconnect wifi service
    private void setEnabled(MethodCall poCall, Result poResult) {
        Boolean enabled = poCall.argument("state");
        moWiFi.setWifiEnabled(enabled);
        poResult.success(null);
    }

    /// Send the ssid and password of a Wifi network into this to connect to the network.
    /// Example:  wifi.findAndConnect(ssid, password);
    /// After 10 seconds, a post telling you whether you are connected will pop up.
    /// Callback returns true if ssid is in the range
    private void findAndConnect(MethodCall poCall, Result poResult) {

        String ssid = poCall.argument("ssid");
        String password = poCall.argument("password");


        List<ScanResult> results = moWiFi.getScanResults();
        boolean connected = false;
        for (ScanResult result : results) {
            String resultString = "" + result.SSID;
            if (ssid.equals(resultString)) {
                connected = connectTo(result, password, ssid);
            }
        }
        poResult.success(connected);
    }

    /// Use this method to check if the device is currently connected to Wifi.
    private void isConnected(Result poResult) {
        ConnectivityManager connManager = (ConnectivityManager) moContext.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo mWifi = connManager != null ? connManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI) : null;
        if (mWifi != null && mWifi.isConnected()) {
            poResult.success(true);
        } else {
            poResult.success(false);
        }
    }

    /// Disconnect current Wifi.
    private void disconnect(Result poResult) {
        moWiFi.disconnect();
        poResult.success(null);
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
        String prefix_ssid = poCall.argument("prefix_ssid");
        if (prefix_ssid.equals("")) {
            poResult.error("Error", "No prefix SSID was given!", null);
        }

        List<WifiConfiguration> mWifiConfigList = moWiFi.getConfiguredNetworks();
        for (WifiConfiguration wifiConfig : mWifiConfigList) {
            String comparableSSID = ('"' + prefix_ssid); //Add quotes because wifiConfig.SSID has them
            if (wifiConfig.SSID.startsWith(comparableSSID)) {
                moWiFi.removeNetwork(wifiConfig.networkId);
                moWiFi.saveConfiguration();
                poResult.success(true);
                return;
            }
        }
        poResult.success(false);
    }

    /// This method will remove the WiFi network as per the passed SSID from the device list
    private void isRegisteredWifiNetwork(MethodCall poCall, Result poResult) {

        String ssid = poCall.argument("ssid");

        List<WifiConfiguration> mWifiConfigList = moWiFi.getConfiguredNetworks();
        String comparableSSID = ('"' + ssid + '"'); //Add quotes because wifiConfig.SSID has them
        if (mWifiConfigList != null) {
            for (WifiConfiguration wifiConfig : mWifiConfigList) {
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
    private Boolean connectTo(ScanResult result, String password, String ssid) {
        /// Make new configuration
        WifiConfiguration conf = new WifiConfiguration();

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            conf.SSID = ssid;
        } else {
            conf.SSID = "\"" + ssid + "\"";
        }

        String capabilities = result.capabilities;

        if (capabilities.contains("WPA") ||
                capabilities.contains("WPA2") ||
                capabilities.contains("WPA/WPA2 PSK")) {

            /// appropriate ciper is need to set according to security type used,
            /// ifcase of not added it will not be able to connect
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

        } else if (capabilities.contains("WEP")) {
            conf.wepKeys[0] = "\"" + password + "\"";
            conf.wepTxKeyIndex = 0;
            conf.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE);
            conf.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.WEP40);

        } else {
            conf.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE);
        }

        /// Remove the existing configuration for this netwrok
        List<WifiConfiguration> mWifiConfigList = moWiFi.getConfiguredNetworks();

        int updateNetwork = -1;

        if (mWifiConfigList != null) {
            for (WifiConfiguration wifiConfig : mWifiConfigList) {
                if (wifiConfig.SSID.equals(conf.SSID)) {
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

        if (updateNetwork == -1) {
            return false;
        }

        boolean disconnect = moWiFi.disconnect();
        if (!disconnect) {
            return false;
        }

        boolean enableNetwork = moWiFi.enableNetwork(updateNetwork, true);
        if (!enableNetwork) {
            return false;
        }

        return true;
    }

    public static String sudoForResult(String... strings) {
        String res = "";
        DataOutputStream outputStream = null;
        InputStream response = null;
        try {
            Process su = Runtime.getRuntime().exec("su");
            outputStream = new DataOutputStream(su.getOutputStream());
            response = su.getInputStream();

            for (String s : strings) {
                outputStream.writeBytes(s + "\n");
                outputStream.flush();
            }

            outputStream.writeBytes("exit\n");
            outputStream.flush();
            try {
                su.waitFor();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            res = readFully(response);
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            Closer.closeSilently(outputStream, response);
        }
        return res;
    }

    private static String readFully(InputStream is) throws IOException {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        byte[] buffer = new byte[1024];
        int length = 0;
        while ((length = is.read(buffer)) != -1) {
            baos.write(buffer, 0, length);
        }
        return baos.toString("UTF-8");
    }

    static class Closer {
        /// closeAll()
        public static void closeSilently(Object... xs) {
            /// Note: on Android API levels prior to 19 Socket does not implement Closeable
            for (Object x : xs) {
                if (x != null) {
                    try {
                        Log.d(Closer.class.toString(), "closing: " + x);
                        if (x instanceof Closeable) {
                            ((Closeable) x).close();
                        } else if (x instanceof Socket) {
                            ((Socket) x).close();
                        } else if (x instanceof DatagramSocket) {
                            ((DatagramSocket) x).close();
                        } else {
                            Log.d(Closer.class.toString(), "cannot close: " + x);
                            throw new RuntimeException("cannot close " + x);
                        }
                    } catch (Throwable e) {
                        Log.e(Closer.class.toString(), e.getMessage());
                    }
                }
            }
        }
    }
}

