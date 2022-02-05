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
  List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];
  StreamSubscription<Result<List<WiFiAccessPoint>, GetScannedResultsErrors>>?
      subscription;

  bool get isStreaming => subscription != null;

  void _handleScannedResults(BuildContext context,
      Result<List<WiFiAccessPoint>, GetScannedResultsErrors> result) {
    if (result.hasError) {
      kShowSnackBar(context, "Cannot get scanned results: ${result.error}");
      setState(() => accessPoints = <WiFiAccessPoint>[]);
    } else {
      setState(() => accessPoints = result.value!);
    }
  }

  void _startListeningToScanResults(BuildContext context) {
    subscription = WiFiScan.instance.onScannedResultsAvailable
        .listen((result) => _handleScannedResults(context, result));
  }

  void _stopListteningToScanResults() {
    subscription?.cancel();
    setState(() => subscription = null);
  }

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

  // build access point tile.
  Widget _buildAccessPointTile(BuildContext context, WiFiAccessPoint ap) {
    final title = ap.ssid.isNotEmpty ? ap.ssid : "**EMPTY**";
    final signalIcon =
        ap.level >= -80 ? Icons.signal_wifi_4_bar : Icons.signal_wifi_0_bar;
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
              _buildInfo("Capability", ap.capabilities),
              _buildInfo("frequency", "${ap.frequency}MHz"),
              _buildInfo("level", ap.level),
              _buildInfo("standard", ap.standard),
              _buildInfo("centerFrequency0", "${ap.centerFrequency0}MHz"),
              _buildInfo("centerFrequency1", "${ap.centerFrequency1}MHz"),
              _buildInfo("channelWidth", ap.channelWidth),
              _buildInfo("isPasspoint", ap.isPasspoint),
              _buildInfo("operatorFriendlyName", ap.operatorFriendlyName),
              _buildInfo("venueName", ap.venueName),
              _buildInfo("is80211mcResponder", ap.is80211mcResponder),
            ],
          ),
        ),
      ),
    );
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
                      icon: const Icon(Icons.perm_scan_wifi),
                      label: const Text('SCAN'),
                      // call startScan and reset the ap list
                      onPressed: () async {
                        final error = await WiFiScan.instance.startScan();
                        kShowSnackBar(context, "startScan: ${error ?? 'done'}");
                        setState(() => accessPoints = <WiFiAccessPoint>[]);
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('GET'),
                      // call getScannedResults and handle the result
                      onPressed: () async => _handleScannedResults(
                          context, await WiFiScan.instance.getScannedResults()),
                    ),
                    Row(
                      children: [
                        const Text("STREAM"),
                        Switch(
                            value: isStreaming,
                            onChanged: (shouldStream) => shouldStream
                                ? _startListeningToScanResults(context)
                                : _stopListteningToScanResults()),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                Flexible(
                  child: Center(
                    child: accessPoints.isEmpty
                        ? const Text("NO SCANNED RESULTS")
                        : ListView.builder(
                            itemCount: accessPoints.length,
                            itemBuilder: (context, i) => _buildAccessPointTile(
                                context, accessPoints[i])),
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
