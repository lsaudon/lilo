import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ble/ble_scanner.dart';
import 'device_detail_screen.dart';

class DeviceListScreen extends StatelessWidget {
  const DeviceListScreen({super.key});

  @override
  Widget build(BuildContext context) => Consumer2<BleScanner, BleScannerState>(
        builder: (_, bleScanner, bleScannerState, __) => _DeviceList(
          scannerState: bleScannerState,
          startScan: bleScanner.startScan,
          stopScan: bleScanner.stopScan,
        ),
      );
}

class _DeviceList extends StatefulWidget {
  const _DeviceList({
    required this.scannerState,
    required this.startScan,
    required this.stopScan,
  });

  final BleScannerState scannerState;
  final void Function() startScan;
  final VoidCallback stopScan;

  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<_DeviceList> {
  @override
  void initState() {
    super.initState();
    widget.startScan();
  }

  @override
  void dispose() {
    widget.stopScan();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Flexible(
              child: ListView(
                children: widget.scannerState.discoveredDevices
                    .map(
                      (device) => ListTile(
                        title: Text(device.name),
                        subtitle: Text(device.id),
                        onTap: () async {
                          widget.stopScan();
                          await Navigator.push<void>(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DeviceDetailScreen(device: device),
                            ),
                          );
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      );
}
