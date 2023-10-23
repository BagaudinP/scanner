import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  ServiceStatus? serviceStatus;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;
  late StreamSubscription<ServiceStatus> _serviceSubscription;

  @override
  void initState() {
    super.initState();
    GeolocatorPlatform.instance.isLocationServiceEnabled().then((enabled) {
      setState(() {
        serviceStatus = enabled ? ServiceStatus.enabled : ServiceStatus.disabled;
      });
    });

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      setState(() {});
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      setState(() {});
    });

    _serviceSubscription = Geolocator.getServiceStatusStream().listen((status) {
      setState(() {
        serviceStatus = status;
      });

      if (status == ServiceStatus.disabled && _isScanning) {
        FlutterBluePlus.stopScan();
        setState(() {
          _isScanning = false;
          _scanResults = [];
        });
      }
    });
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    _serviceSubscription.cancel();
    super.dispose();
  }

  Future onRefresh() {
    if (_isScanning == false) {
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 30));
    }
    setState(() {});
    return Future.delayed(Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Scaffold(
        appBar: AppBar(title: const Text('Найденные устройства')),
        body: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            children: _scanResults
                .map(
                  (scanResult) => ListTile(
                      leading: Text(scanResult.rssi.toString()),
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            scanResult.device.platformName.isNotEmpty ? scanResult.device.platformName : 'No name',
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            scanResult.device.remoteId.toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        ],
                      )),
                )
                .toList(),
          ),
        ),
        floatingActionButton: FlutterBluePlus.isScanningNow
            ? IconButton(
                onPressed: () => FlutterBluePlus.stopScan(),
                icon: Icon(
                  Icons.close,
                  color: Colors.red,
                ))
            : TextButton(
                onPressed: () async {
                  if (serviceStatus == ServiceStatus.disabled) {
                    await Geolocator.openLocationSettings();
                  } else {
                    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 30));
                    setState(() {});
                  }
                },
                child: Text(serviceStatus == ServiceStatus.enabled ? 'Скан' : 'Включить локацию'),
              ),
      ),
    );
  }
}
