import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

import '../ble/ble_device_connector.dart';
import '../ble/light.dart';

class DeviceDetailScreen extends StatelessWidget {
  const DeviceDetailScreen({
    super.key,
    required this.device,
  });

  final DiscoveredDevice device;

  @override
  Widget build(BuildContext context) =>
      Consumer2<BleDeviceConnector, ConnectionStateUpdate>(
        builder: (_, deviceConnector, connectionStateUpdate, __) =>
            _DeviceDetail(
          device: device,
          connectionUpdate: connectionStateUpdate.deviceId == device.id
              ? connectionStateUpdate
              : ConnectionStateUpdate(
                  deviceId: device.id,
                  connectionState: DeviceConnectionState.disconnected,
                  failure: null,
                ),
          connect: deviceConnector.connect,
          disconnect: deviceConnector.disconnect,
          readCharacteristic: deviceConnector.readCharacteristic,
          setLightMode: deviceConnector.setLightMode,
          setLightTime: deviceConnector.setLightTime,
        ),
      );
}

class _DeviceDetail extends StatelessWidget {
  const _DeviceDetail({
    required this.device,
    required this.connectionUpdate,
    required this.connect,
    required this.disconnect,
    required this.readCharacteristic,
    required this.setLightMode,
    required this.setLightTime,
  });

  final DiscoveredDevice device;
  final ConnectionStateUpdate connectionUpdate;
  final void Function(String deviceId) connect;
  final void Function(String deviceId) disconnect;
  final void Function(
          String deviceId, Uuid serviceUuid, Uuid lightCharacteristicUuid)
      readCharacteristic;
  final void Function(String deviceId, Uuid serviceUuid,
      Uuid lightCharacteristicUuid, Light light) setLightMode;
  final void Function(String deviceId, Uuid serviceId, Uuid characteristicId,
      TimeOfDay startLightTime, TimeOfDay endLightTime) setLightTime;

  static const liloServiceUuid = '53e11631b8404b2193ce081726ddc739';
  static const liloTimeCharacteristicUuid = '53e11633b8404b2193ce081726ddc739';
  static const liloLightCharacteristicUuid = '53e11632b8404b2193ce081726ddc739';

  bool _deviceConnected() =>
      connectionUpdate.connectionState == DeviceConnectionState.connected;

  @override
  Widget build(BuildContext context) => PopScope(
        onPopInvokedWithResult: (didPop, result) {
          disconnect(device.id);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(device.name),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'ID: ${connectionUpdate.deviceId}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Status: ${connectionUpdate.connectionState}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed:
                          !_deviceConnected() ? () => connect(device.id) : null,
                      child: const Text('Connect'),
                    ),
                    ElevatedButton(
                      onPressed: _deviceConnected()
                          ? () => disconnect(device.id)
                          : null,
                      child: const Text('Disconnect'),
                    ),
                    ElevatedButton(
                      onPressed: _deviceConnected()
                          ? () => readCharacteristic(
                              device.id,
                              Uuid.parse(liloServiceUuid),
                              Uuid.parse(liloLightCharacteristicUuid))
                          : null,
                      child: const Text('Read Light'),
                    ),
                    ElevatedButton(
                      onPressed: _deviceConnected()
                          ? () => readCharacteristic(
                              device.id,
                              Uuid.parse(liloServiceUuid),
                              Uuid.parse(liloTimeCharacteristicUuid))
                          : null,
                      child: const Text('Read Time'),
                    ),
                    ElevatedButton(
                      onPressed: _deviceConnected()
                          ? () => setLightMode(
                              device.id,
                              Uuid.parse(liloServiceUuid),
                              Uuid.parse(liloLightCharacteristicUuid),
                              Light.off)
                          : null,
                      child: const Text('Off'),
                    ),
                    ElevatedButton(
                      onPressed: _deviceConnected()
                          ? () => setLightMode(
                              device.id,
                              Uuid.parse(liloServiceUuid),
                              Uuid.parse(liloLightCharacteristicUuid),
                              Light.photoMode)
                          : null,
                      child: const Text('Photo Mode'),
                    ),
                    ElevatedButton(
                      onPressed: _deviceConnected()
                          ? () => setLightMode(
                              device.id,
                              Uuid.parse(liloServiceUuid),
                              Uuid.parse(liloLightCharacteristicUuid),
                              Light.spring)
                          : null,
                      child: const Text('Spring'),
                    ),
                    ElevatedButton(
                      onPressed: _deviceConnected()
                          ? () => setLightMode(
                              device.id,
                              Uuid.parse(liloServiceUuid),
                              Uuid.parse(liloLightCharacteristicUuid),
                              Light.summer)
                          : null,
                      child: const Text('Summer'),
                    ),
                    ElevatedButton(
                      onPressed: _deviceConnected()
                          ? () => setLightTime(
                                device.id,
                                Uuid.parse(liloServiceUuid),
                                Uuid.parse(liloLightCharacteristicUuid),
                                const TimeOfDay(hour: 7, minute: 0),
                                const TimeOfDay(hour: 22, minute: 44),
                              )
                          : null,
                      child: const Text('7h00 to 22h44'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
