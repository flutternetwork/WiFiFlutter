<img src="https://flutter.io/images/flutter-mark-square-100.png" alt="Flutter" width="40" height="40" /> 

# WiFi Flutter

Plugin Flutter which can handle WiFi connections (AP, STA)

Becareful, some commands as no effect on iOS because Apple don't let us to do whatever we want...

## WiFi connections :
|                      Description                      |      Android       |         iOS          |
| :---------------------------------------------------- | :----------------: | :------------------: |
| Enabling / Disabling WiFi module                      | :white_check_mark: |  :x:  |
| Getting WiFi status                                   | :white_check_mark: |  :x:  |
| Scanning for networks, with "already-associated" flag | :white_check_mark: |  :x:  |
| Connecting / Disconnecting on a network in WPA / WEP  | :white_check_mark: |  :white_check_mark:  |
| Registering / Unregistering a WiFi network            | :white_check_mark: |  :x:  |
| Getting informations like :                           | :white_check_mark: |  :warning:  |
|      - SSID                                                | :white_check_mark: |  :white_check_mark:  |
|      - BSSID                                               | :white_check_mark: |  :x:  |
|      - Current signal strength                             | :white_check_mark: |  :x:  |
|      - Frequency                                           | :white_check_mark: |  :x:  |
|      - IP                                                  | :white_check_mark: |  :x:  |

## Access Point :
|                                       Description                                     |      Android       |         iOS          |
| :------------------------------------------------------------------------------------ | :----------------: | :------------------: |
| Getting the status of the Access Point (Disable, disabling, enable, enabling, failed) | :white_check_mark: |  :x:  |
| Enabling / Disabling Access Point                                                     | :white_check_mark: |  :x:  |
| Getting / Setting new credentials (SSID / Password)                                   | :white_check_mark: |  :x:  |
| Enabling / Disabling the visibility of the SSID Access Point                          | :white_check_mark: |  :x:  |
| Getting the clients list (IP, BSSID, Device, Reachable)                               | :white_check_mark: |  :x:  |
| Handling the MAC filtering                                                            | :sos: |  :x:  |

