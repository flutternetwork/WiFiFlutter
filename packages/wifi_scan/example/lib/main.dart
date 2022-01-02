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
  // TODO: integrate streamed results
  bool shouldStream = false;
  List<WiFiNetwork> networks = <WiFiNetwork>[];

  void showSnackBar(BuildContext context, String message) {
    if (kDebugMode) print(message);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _startScan(BuildContext context) async {
    // check if can-startScan
    final can = await WiFiScan.instance.canStartScan();
    // if can-not, then show error
    if (can != CanStartScan.yes) {
      showSnackBar(context, "Cannot start scan: $can");
      return;
    }
    showSnackBar(context, "startScan: ${await WiFiScan.instance.startScan()}");
  }

  Future<void> _fetchScannedResults(BuildContext context) async {
    // check if can-getScannedResults
    final can = await WiFiScan.instance.canGetScannedNetworks();
    // if can-not, then show error
    if (can != CanGetScannedNetworks.yes) {
      showSnackBar(context, "Cannot get scanned results: $can");
      networks = <WiFiNetwork>[];
      return;
    }
    networks = await WiFiScan.instance.scannedNetworks;
  }

  Widget _buildWifiNetworkList(BuildContext context) => networks.isEmpty
      ? const Text("NO SCANNED RESULTS")
      : ListView.builder(
          itemCount: networks.length,
          itemBuilder: (context, i) => ListTile(
            title: Text(networks[i].ssid),
            onTap: () => showDialog(
              context: context,
              builder: (context) => Text(networks[i].ssid),
            ),
          ),
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
                      icon: const Icon(Icons.perm_scan_wifi),
                      label: const Text('SCAN'),
                      onPressed: () => _startScan(context),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('GET'),
                      onPressed: () async {
                        await _fetchScannedResults(context);
                        setState(() {});
                      },
                    ),
                    Row(
                      children: [
                        const Text("STREAM"),
                        Switch(
                          value: shouldStream,
                          onChanged: (v) => setState(() => shouldStream = v),
                        ),
                      ],
                    )
                  ],
                ),
                const Divider(),
                Flexible(
                  child: Center(
                    child: FutureBuilder(
                      future: _fetchScannedResults(context),
                      builder: (context, snapshot) =>
                          snapshot.connectionState == ConnectionState.done
                              ? _buildWifiNetworkList(context)
                              : const CircularProgressIndicator(),
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
