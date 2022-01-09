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
  bool shouldStream = true;
  List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];

  void showSnackBar(BuildContext context, String message) {
    if (kDebugMode) print(message);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _startScan(BuildContext context) async {
    if (shouldCheck) {
      // check if can-startScan
      final can = await WiFiScan.instance.canStartScan();
      // if can-not, then show error
      if (can != CanStartScan.yes) {
        showSnackBar(context, "Cannot start scan: $can");
        return;
      }
    }
    showSnackBar(context, "startScan: ${await WiFiScan.instance.startScan()}");
  }

  Future<bool> _canGetScannedResults(BuildContext context) async {
    if (shouldCheck) {
      // check if can-getScannedResults
      final can = await WiFiScan.instance.canGetScannedResults();
      // if can-not, then show error
      if (can != CanGetScannedResults.yes) {
        showSnackBar(context, "Cannot get scanned results: $can");
        accessPoints = <WiFiAccessPoint>[];
        return false;
      }
    }
    return true;
  }

  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged) =>
      Row(
        children: [
          Text(label),
          Switch(value: value, onChanged: onChanged),
        ],
      );

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

  Widget _buildWifiApList(BuildContext context) => accessPoints.isEmpty
      ? const Text("NO SCANNED RESULTS")
      : ListView.builder(
          itemCount: accessPoints.length,
          itemBuilder: (context, i) {
            final ap = accessPoints[i];
            final title = ap.ssid.isNotEmpty ? ap.ssid : "**EMPTY**";
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
                      _buildInfo("Capability", ap.capabilities),
                      _buildInfo("frequency", "${ap.frequency}MHz"),
                      _buildInfo("level", ap.level),
                      _buildInfo("standard", ap.standard),
                      _buildInfo(
                          "centerFrequency0", "${ap.centerFrequency0}MHz"),
                      _buildInfo(
                          "centerFrequency1", "${ap.centerFrequency1}MHz"),
                      _buildInfo("channelWidth", ap.channelWidth),
                      _buildInfo("isPasspoint", ap.isPasspoint),
                      _buildInfo(
                          "operatorFriendlyName", ap.operatorFriendlyName),
                      _buildInfo("venueName", ap.venueName),
                      _buildInfo("is80211mcResponder", ap.is80211mcResponder),
                    ],
                  ),
                ),
              ),
            );
          },
        );

  Widget _buildWifiAPStreamable(BuildContext context) => !shouldStream
      ? _buildWifiApList(context)
      : FutureBuilder<bool>(
          future: _canGetScannedResults(context),
          builder: (context, snapshotCan) {
            if (snapshotCan.connectionState != ConnectionState.done) {
              return const CircularProgressIndicator();
            }
            // return without stream - if can't
            if (!(snapshotCan.data ?? false)) return _buildWifiApList(context);
            return StreamBuilder<List<WiFiAccessPoint>>(
              stream: WiFiScan.instance.onScannedResultsAvailable,
              builder: (context, snapshot) {
                // update accesspoint if available
                accessPoints = snapshot.data ?? accessPoints;
                return _buildWifiApList(context);
              },
            );
          },
        );

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
                      onPressed: () async {
                        if (await _canGetScannedResults(context)) {
                          accessPoints =
                              await WiFiScan.instance.getScannedResults();
                          setState(() {});
                        }
                      },
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
                    _buildSwitch("STREAM", shouldStream,
                        (v) => setState(() => shouldStream = v)),
                  ],
                ),
                const Divider(),
                Flexible(
                  child: Center(
                    child: _buildWifiAPStreamable(context),
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
