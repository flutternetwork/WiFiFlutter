# WiFiFlutter
Plugin Flutter which can handle WiFi connections (AP, STA)

For now, we have the Android part which is working :
 * For WiFi connection :
   - Enabling / Disabling WiFi module,
   - Getting WiFi status,
   - Scanning for networks with "already-associated" flag,
   - Connecting / Disconnecting on a network in WPA / WEP,
   - Getting informations like : SSID, BSSID, current signal strength, frequency, IP,
   - Registering / Unregistering a WiFi network,

 * For Access Point :
   - Getting the status of the Access Point (Disable, disabling, enable, enabling, failed),
   - Enabling / Disabling Access Point,
   - Getting / Setting new credentials (SSID / Password),
   - Enabling / Disabling the visibility of the SSID Access Point,
   - Getting the clients list (IP, BSSID, Device, Reachable),

There is one thing we want to add but don't know how : handling the MAC filtering!

We will work soon on the iOS part, we just receive an iPhone for test :)
