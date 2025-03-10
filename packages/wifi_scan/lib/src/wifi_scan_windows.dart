import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:win32/win32.dart';

/// 私有的公共列表，用于存储扫描结果 / Private list to store scan results
List<WiFiAccessPoint> _wifiList = [];

/// 启动 WLAN 扫描 / Initiate WLAN scan
/// waitScanDuration control time to wait result,must >500ms
/// mergeDuplicateNetworks control whether merge same name wifi
Future<bool> windowsStartScan({
  Duration waitScanDuration = const Duration(seconds: 2),
  bool mergeDuplicateNetworks = true,
}) async {
  _wifiList.clear(); // Clear previous scan results

  // Initialize COM library
  if (FAILED(CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED))) {
    debugPrint('Failed to initialize COM library.');
    return false;
  }

  // Open WLAN client handle
  final phClientHandle = calloc<HANDLE>();
  final pNegotiatedVersion = calloc<DWORD>();
  var result = WlanOpenHandle(2, nullptr, pNegotiatedVersion, phClientHandle);
  if (result != ERROR_SUCCESS) {
    debugPrint('Failed to open WLAN handle, error code: $result');
    free(phClientHandle);
    free(pNegotiatedVersion);
    CoUninitialize();
    return false;
  }

  // Enumerate WLAN interfaces
  final ppInterfaceList = calloc<Pointer<WLAN_INTERFACE_INFO_LIST>>();
  result = WlanEnumInterfaces(phClientHandle.value, nullptr, ppInterfaceList);
  if (result != ERROR_SUCCESS) {
    debugPrint('Failed to enumerate WLAN interfaces, error code: $result');
    WlanCloseHandle(phClientHandle.value, nullptr);
    free(phClientHandle);
    free(pNegotiatedVersion);
    free(ppInterfaceList);
    CoUninitialize();
    return false;
  }

  // Get the GUID of the first WLAN interface
  final interfaceGuid =
      ppInterfaceList.value.ref.InterfaceInfo[0].InterfaceGuid;
  final pInterfaceGuid = calloc<GUID>();
  pInterfaceGuid.ref = interfaceGuid;

  // Initiate scan
  result =
      WlanScan(phClientHandle.value, pInterfaceGuid, nullptr, nullptr, nullptr);
  if (result != ERROR_SUCCESS) {
    debugPrint('Failed to initiate WLAN scan, error code: $result');
    free(pInterfaceGuid);
    WlanFreeMemory(ppInterfaceList.value);
    free(ppInterfaceList);
    WlanCloseHandle(phClientHandle.value, nullptr);
    free(phClientHandle);
    free(pNegotiatedVersion);
    CoUninitialize();
    return false;
  }

  // Wait for the scan to complete
  await Future.delayed(waitScanDuration);

  // Get BSS list
  final ppBssList = calloc<Pointer<WLAN_BSS_LIST>>();
  result = WlanGetNetworkBssList(
    phClientHandle.value,
    pInterfaceGuid,
    nullptr, // Query all SSIDs
    dot11_BSS_type_any, // Query all BSS types
    0, // Do not restrict by security
    nullptr, // Reserved
    ppBssList,
  );
  if (result != ERROR_SUCCESS) {
    debugPrint('Failed to get BSS list, error code: $result');
    free(pInterfaceGuid);
    WlanFreeMemory(ppInterfaceList.value);
    free(ppInterfaceList);
    WlanCloseHandle(phClientHandle.value, nullptr);
    free(phClientHandle);
    free(pNegotiatedVersion);
    CoUninitialize();
    return false;
  }

  // Parse BSS list
  final bssList = ppBssList.value.ref;
  final Map<String, WiFiAccessPoint> mergedNetworks = {};

  for (var i = 0; i < bssList.dwNumberOfItems; i++) {
    final bssEntry = bssList.wlanBssEntries[i];

    // Get SSID
    final ssidBytes = List<int>.generate(
      bssEntry.dot11Ssid.uSSIDLength,
      (j) => bssEntry.dot11Ssid.ucSSID[j],
    );
    final ssid = String.fromCharCodes(ssidBytes);

    // Get BSSID
    final bssid = List.generate(
      6,
      (j) => bssEntry.dot11Bssid[j].toRadixString(16).padLeft(2, '0'),
    ).join(':');

    // Get frequency and channel width
    final frequency = bssEntry.ulChCenterFrequency;
    final channelWidth = _getChannelWidthFromFrequency(frequency);

    // Get WiFi standard
    final standard = _getWiFiStandard(bssEntry);

    // Create WiFiAccessPoint object
    final accessPoint = WiFiAccessPoint.fromMap({
      "ssid": ssid,
      "bssid": bssid,
      "capabilities": "", // TODO
      "frequency": frequency,
      "level": bssEntry.lRssi, // Signal strength
      "timestamp": bssEntry.ullTimestamp,
      "standard": standard,
      "centerFrequency0": -1, // TODO
      "centerFrequency1": -1, // TODO
      "channelWidth": channelWidth,
      "isPasspoint": false, // TODO
      "operatorFriendlyName": "", // TODO
      "venueName": "", // TODO
      "is80211mcResponder": false, // TODO
    });

    if (mergeDuplicateNetworks) {
      // If merging is enabled, check if this SSID already exists
      if (mergedNetworks.containsKey(ssid)) {
        // Compare signal strength and keep the one with the higher value
        if (accessPoint.level > mergedNetworks[ssid]!.level) {
          mergedNetworks[ssid] = accessPoint;
        }
      } else {
        // Add the network to the map
        mergedNetworks[ssid] = accessPoint;
      }
    } else {
      // If merging is not enabled, add all networks to the list
      _wifiList.add(accessPoint);
    }
  }

  // If merging is enabled, add the merged networks to the final list
  if (mergeDuplicateNetworks) {
    _wifiList.addAll(mergedNetworks.values);
  }

  // Clean up memory resources
  WlanFreeMemory(ppBssList.value);
  free(ppBssList);
  free(pInterfaceGuid);
  WlanFreeMemory(ppInterfaceList.value);
  free(ppInterfaceList);
  WlanCloseHandle(phClientHandle.value, nullptr);
  free(phClientHandle);
  free(pNegotiatedVersion);
  CoUninitialize();
  return true;
}

/// 获取扫描结果 / Get scan results
List<WiFiAccessPoint> windowsGetScanResults() {
  return _wifiList;
}

/// 获取信道宽度 / Get channel width
int _getChannelWidthFromFrequency(int frequency) {
  // 根据频率计算信道宽度 / Calculate channel width based on frequency
  if (frequency >= 2412 && frequency <= 2484) {
    return 0; // 2.4GHz 频段
  } else if (frequency >= 5170 && frequency <= 5825) {
    return 2; // 5GHz 频段
  }
  return -1;
}

/// 获取 WiFi 标准 / Get WiFi standard
int _getWiFiStandard(WLAN_BSS_ENTRY bssEntry) {
  // 根据 BSS 信息解析 WiFi 标准 / Parse WiFi standard based on BSS information
  switch (bssEntry.dot11BssPhyType) {
    case dot11_phy_type_hrdsss:
      return 1; // 802.11b
    case dot11_phy_type_ofdm:
      return 1; // 802.11a/g
    case dot11_phy_type_ht:
      return 4; // 802.11n
    case dot11_phy_type_vht:
      return 5; // 802.11ac
    case dot11_phy_type_he:
      return 6; // 802.11ax
    default:
      return -1;
  }
}
