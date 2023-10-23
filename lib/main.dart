import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/bluetooth_screen.dart';
import 'screens/scan_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BluetoothAdapterState _bluetoothAdapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> _bluetoothAdapterStateSubscription;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _bluetoothAdapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      _bluetoothAdapterState = state;
      setState(() {});
    });
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.status;

    if (status.isDenied) {
      await Permission.location.request();
    }
  }

  @override
  void dispose() {
    _bluetoothAdapterStateSubscription.cancel();
    super.dispose();
  }

  Widget _buildScreen() {
    if (_bluetoothAdapterState == BluetoothAdapterState.off) {
      return BluetoothOffScreen(bluetoothAdapterState: _bluetoothAdapterState);
    } else {
      return ScanScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.lightBlueAccent,
      home: _buildScreen(),
    );
  }
}
