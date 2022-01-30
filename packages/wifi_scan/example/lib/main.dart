import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';

void main() {
  runApp(const MyApp());
}

/// Example app for wifi_scan plugin.
class MyApp extends StatefulWidget {
  /// Default constructor for [MyApp] widget.
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool shouldCheck = true;
  List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];
  StreamSubscription<List<WiFiAccessPoint>>? subscription;

  bool get isStreaming => subscription != null;

  Future<void> _startScan(BuildContext context) async {
    if (shouldCheck) {
      // check if can-startScan
      final can = await WiFiScan.instance.canStartScan();
      // if can-not, then show error
      if (can != CanStartScan.yes) {
        return kShowSnackBar(context, "Cannot start scan: $can");
      }
    }
    kShowSnackBar(context, "startScan: ${await WiFiScan.instance.startScan()}");
    // reset access points.
    setState(() => accessPoints = <WiFiAccessPoint>[]);
  }

  Future<bool> _canGetScannedResults(BuildContext context) async {
    if (shouldCheck) {
      // check if can-getScannedResults
      final can = await WiFiScan.instance.canGetScannedResults();
      // if can-not, then show error
      if (can != CanGetScannedResults.yes) {
        kShowSnackBar(context, "Cannot get scanned results: $can");
        accessPoints = <WiFiAccessPoint>[];
        return false;
      }
    }
    return true;
  }

  Future<void> _getScannedResults(BuildContext context) async {
    if (await _canGetScannedResults(context)) {
      // get scanned results
      final results = await WiFiScan.instance.getScannedResults();
      setState(() => accessPoints = results);
    }
  }

  Future<void> _startListeningToScanResults(BuildContext context) async {
    if (await _canGetScannedResults(context)) {
      // start listening - when notified - update accessPoints list
      subscription = WiFiScan.instance.onScannedResultsAvailable
          .listen((event) => setState(() => accessPoints = event));
    }
  }

  void _stopListteningToScanResults() {
    subscription?.cancel();
    setState(() => subscription = null);
  }

  // build toggle switch
  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged) =>
      Row(
        children: [
          Text(label),
          Switch(value: value, onChanged: onChanged),
        ],
      );

  // build row that can display info, based on label: value pair.
  Widget _buildInfo(String label, dynamic value) => Container(
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey))),
        child: Row(
          children: [
            Text("$label: ",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Expanded(child: Text(value.toString()))
          ],
        ),
      );

  @override
  void initState() {
    super.initState();
    // fetch getScannedResults post first build
    WidgetsBinding.instance
        ?.addPostFrameCallback((_) => _getScannedResults(context));
  }

  @override
  void dispose() {
    super.dispose();
    // stop subscription for scanned results
    _stopListteningToScanResults();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('GET'),
                      onPressed: () => _getScannedResults(context),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.perm_scan_wifi),
                      label: const Text('SCAN'),
                      onPressed: () => _startScan(context),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSwitch("SHOULD CHECK", shouldCheck,
                        (v) => setState(() => shouldCheck = v)),
                    _buildSwitch(
                        "STREAM",
                        isStreaming,
                        (shouldStream) => shouldStream
                            ? _startListeningToScanResults(context)
                            : _stopListteningToScanResults()),
                  ],
                ),
                const Divider(),
                Flexible(
                  child: Center(
                    child: accessPoints.isEmpty
                        ? const Text("NO SCANNED RESULTS")
                        : ListView.builder(
                            itemCount: accessPoints.length,
                            itemBuilder: (context, i) {
                              final ap = accessPoints[i];
                              final title =
                                  ap.ssid.isNotEmpty ? ap.ssid : "**EMPTY**";
                              final signalIcon = ap.level >= -80
                                  ? Icons.signal_wifi_4_bar
                                  : Icons.signal_wifi_0_bar;
                              return ListTile(
                                visualDensity: VisualDensity.compact,
                                leading: Icon(signalIcon),
                                title: Text(title),
                                subtitle: Text(ap.capabilities),
                                onTap: () => showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(title),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildInfo("BSSDI", ap.bssid),
                                        _buildInfo(
                                            "Capability", ap.capabilities),
                                        _buildInfo(
                                            "frequency", "${ap.frequency}MHz"),
                                        _buildInfo("level", ap.level),
                                        _buildInfo("standard", ap.standard),
                                        _buildInfo("centerFrequency0",
                                            "${ap.centerFrequency0}MHz"),
                                        _buildInfo("centerFrequency1",
                                            "${ap.centerFrequency1}MHz"),
                                        _buildInfo(
                                            "channelWidth", ap.channelWidth),
                                        _buildInfo(
                                            "isPasspoint", ap.isPasspoint),
                                        _buildInfo("operatorFriendlyName",
                                            ap.operatorFriendlyName),
                                        _buildInfo("venueName", ap.venueName),
                                        _buildInfo("is80211mcResponder",
                                            ap.is80211mcResponder),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Show snackbar.
void kShowSnackBar(BuildContext context, String message) {
  if (kDebugMode) print(message);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
