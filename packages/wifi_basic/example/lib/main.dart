import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wifi_basic/wifi_basic.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
          builder: (context) => Scaffold(
                appBar: AppBar(
                  title: const Text('Plugin example app'),
                ),
                body: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const Text("WiFiBasic.hasCapability:"),
                          TextButton(
                            child: const Text("call"),
                            onPressed: () async => showSnackbar(context,
                                "hasCapability: ${await WiFiBasic.hasCapability()}"),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text("WiFiBasic.isEnabled:"),
                          TextButton(
                            child: const Text("call"),
                            onPressed: () async => showSnackbar(context,
                                "isEnabled: ${await WiFiBasic.isEnabled()}"),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text("WiFiBasic.setEnabled:"),
                          TextButton(
                            child: const Text("enable"),
                            onPressed: () async => showSnackbar(context,
                                "setEnabled(true): ${await WiFiBasic.setEnabled(true, shouldOpenSettings: true)}"),
                          ),
                          TextButton(
                            child: const Text("disable"),
                            onPressed: () async => showSnackbar(context,
                                "setEnabled(false): ${await WiFiBasic.setEnabled(false, shouldOpenSettings: true)}"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
    );
  }
}
