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
  void showSnackBar(BuildContext context, String message) {
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
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  child: const Text("isSupported();"),
                  onPressed: () async => showSnackBar(context,
                      "isSupported: ${await WiFiBasic.instance.isSupported()}"),
                ),
                ElevatedButton(
                  child: const Text("getGeneration();"),
                  onPressed: () async => showSnackBar(context,
                      "getGeneration: ${await WiFiBasic.instance.getGeneration()}"),
                ),
                ElevatedButton(
                  child: const Text("isEnabled();"),
                  onPressed: () async => showSnackBar(context,
                      "isEnabled: ${await WiFiBasic.instance.isEnabled()}"),
                ),
                ElevatedButton(
                  child: const Text("setEnabled(true);"),
                  onPressed: () async => showSnackBar(context,
                      "setEnabled(true): success? ${await WiFiBasic.instance.setEnabled(true)}"),
                ),
                ElevatedButton(
                  child: const Text("setEnabled(false);"),
                  onPressed: () async => showSnackBar(context,
                      "setEnabled(false): success? ${await WiFiBasic.instance.setEnabled(false)}"),
                ),
                ElevatedButton(
                  child: const Text("openSettings();"),
                  onPressed: () async =>
                      await WiFiBasic.instance.openSettings(),
                ),
                ElevatedButton(
                  child: const Text("getCurrentInfo();"),
                  onPressed: () async => showSnackBar(context,
                      "getCurrentInfo: ${await WiFiBasic.instance.getCurrentInfo()}"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
