import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.bluetoothAdapterState}) : super(key: key);

  final BluetoothAdapterState? bluetoothAdapterState;

  @override
  Widget build(BuildContext context) {
    String? state = bluetoothAdapterState?.toString().split(".").last;

    return ScaffoldMessenger(
      child: Scaffold(
        backgroundColor: Colors.lightBlueAccent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bluetooth_disabled,
                size: 50,
                color: Colors.blueAccent,
              ),
              Text(
                'Bluetooth ${state != null ? state : 'Недоступно'}',
                style: Theme.of(context).primaryTextTheme.titleSmall?.copyWith(color: Colors.white),
              ),
              if (Platform.isAndroid)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    child: const Text('Включить'),
                    onPressed: () async {
                      if (Platform.isAndroid) await FlutterBluePlus.turnOn();
                    },
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
