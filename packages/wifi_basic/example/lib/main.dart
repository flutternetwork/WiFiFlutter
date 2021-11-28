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
  void showSnackBar(BuildContext context, String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              TextButton(
                child: const Text("WiFiBasic.hasCapability"),
                onPressed: () async => showSnackBar(context,
                    "hasCapability: ${await WiFiBasic.hasCapability()}"),
              ),
              TextButton(
                child: const Text("WiFiBasic.isEnabled"),
                onPressed: () async => showSnackBar(
                    context, "isEnabled: ${await WiFiBasic.isEnabled()}"),
              ),
              Row(
                children: [
                  const Text("WiFiBasic.setEnabled: "),
                  TextButton(
                    child: const Text("enable"),
                    onPressed: () async => await WiFiBasic.setEnabled(true,
                        shouldOpenSettings: true),
                  ),
                  TextButton(
                    child: const Text("disable"),
                    onPressed: () async => await WiFiBasic.setEnabled(false,
                        shouldOpenSettings: true),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
