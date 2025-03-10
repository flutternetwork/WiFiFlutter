// ignore_for_file: sdk_version_since

import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:win32/win32.dart';

/// 连接到指定的 Wi-Fi 网络
/// Connect to the specified Wi-Fi network
Future<bool> windowsConnectToNetwork(
    {required String ssid,
    required String password,
    required String security}) async {
  // 初始化 COM 库
  // Initialize the COM library
  if (FAILED(CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED))) {
    debugPrint('Failed to initialize COM library.');
    return false;
  }

  // 打开 WLAN 句柄
  // Open the WLAN handle
  final phClientHandle = calloc<HANDLE>();
  final pNegotiatedVersion = calloc<DWORD>();
  final result = WlanOpenHandle(2, nullptr, pNegotiatedVersion, phClientHandle);

  if (result != ERROR_SUCCESS) {
    print('Failed to open WLAN handle. Error code: $result');
    free(phClientHandle);
    free(pNegotiatedVersion);
    CoUninitialize();
    return false;
  }

  // 枚举 WLAN 接口
  // Enumerate WLAN interfaces
  final ppInterfaceList = calloc<Pointer<WLAN_INTERFACE_INFO_LIST>>();
  final enumResult = WlanEnumInterfaces(
    phClientHandle.value,
    nullptr,
    ppInterfaceList,
  );

  if (enumResult != ERROR_SUCCESS) {
    print('Failed to enumerate WLAN interfaces. Error code: $enumResult');
    WlanCloseHandle(phClientHandle.value, nullptr);
    free(phClientHandle);
    free(pNegotiatedVersion);
    free(ppInterfaceList);
    CoUninitialize();
    return false;
  }

  // 获取第一个 WLAN 接口的 GUID
  // Get the GUID of the first WLAN interface
  final interfaceGuid =
      ppInterfaceList.value.ref.InterfaceInfo[0].InterfaceGuid;
  final pInterfaceGuid = calloc<GUID>();
  pInterfaceGuid.ref = interfaceGuid;

  // 断开当前连接
  // Disconnect the current connection
  final disconnectResult = WlanDisconnect(
    phClientHandle.value,
    pInterfaceGuid,
    nullptr,
  );

  if (disconnectResult != ERROR_SUCCESS) {
    free(pInterfaceGuid);
    WlanFreeMemory(ppInterfaceList.value);
    free(ppInterfaceList);
    WlanCloseHandle(phClientHandle.value, nullptr);
    free(phClientHandle);
    free(pNegotiatedVersion);
    CoUninitialize();
    return false;
  }

  // 创建 WLAN 配置文件 XML 字符串
  // Create the WLAN profile XML string
  final profileXml = '''<?xml version="1.0" encoding="UTF-8"?>
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
  <name>$ssid</name>
  <SSIDConfig>
    <SSID>
      <name>$ssid</name>
    </SSID>
  </SSIDConfig>
  <connectionType>ESS</connectionType>
  <connectionMode>auto</connectionMode>
  <MSM>
    <security>
      <authEncryption>
        <authentication>$security</authentication>
        <encryption>AES</encryption>
        <useOneX>false</useOneX>
      </authEncryption>
      <sharedKey>
        <keyType>passPhrase</keyType>
        <protected>false</protected>
        <keyMaterial>$password</keyMaterial>
      </sharedKey>
    </security>
  </MSM>
</WLANProfile>''';

  // 设置 WLAN 配置文件
  // Set the WLAN profile
  final pProfileXml = profileXml.toNativeUtf16();
  final pNegFailure = calloc<DWORD>();
  final setProfileResult = WlanSetProfile(
    phClientHandle.value,
    pInterfaceGuid,
    0,
    pProfileXml,
    nullptr,
    1,
    nullptr,
    pNegFailure,
  );

  if (setProfileResult != ERROR_SUCCESS) {
    print('Failed to set profile. Error code: $setProfileResult');
    free(pNegFailure);
    free(pProfileXml);
    free(pInterfaceGuid);
    WlanFreeMemory(ppInterfaceList.value);
    free(ppInterfaceList);
    WlanCloseHandle(phClientHandle.value, nullptr);
    free(phClientHandle);
    free(pNegotiatedVersion);
    CoUninitialize();
    return false;
  }

  free(pNegFailure);
  free(pProfileXml);

  // 设置连接参数并连接
  // Set connection parameters and connect
  final pConnectionParams = calloc<WLAN_CONNECTION_PARAMETERS>();
  pConnectionParams.ref.wlanConnectionMode = wlan_connection_mode_profile;
  final pProfileName = ssid.toNativeUtf16();
  pConnectionParams.ref.strProfile = pProfileName.cast<Utf16>();
  pConnectionParams.ref.pDot11Ssid = nullptr;
  pConnectionParams.ref.pDesiredBssidList = nullptr;
  pConnectionParams.ref.dot11BssType = dot11_BSS_type_infrastructure;
  pConnectionParams.ref.dwFlags = 0;

  final connectResult = WlanConnect(
    phClientHandle.value,
    pInterfaceGuid,
    pConnectionParams,
    nullptr,
  );
  print('WlanConnect result: $connectResult');

  free(pProfileName);
  free(pConnectionParams);
  free(pInterfaceGuid);
  WlanFreeMemory(ppInterfaceList.value);
  free(ppInterfaceList);
  WlanCloseHandle(phClientHandle.value, nullptr);
  free(phClientHandle);
  free(pNegotiatedVersion);
  CoUninitialize();

  return connectResult == ERROR_SUCCESS;
}
