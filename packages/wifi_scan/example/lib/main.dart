import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp._());
}

/// Example app for wifi_scan plugin.
class MyApp extends StatefulWidget {
  const MyApp._({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // TODO: proper example app
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: const Center(
          child: Text('TODO'),
        ),
      ),
    );
  }
}