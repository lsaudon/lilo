import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'light.dart';
import 'reactive_state.dart';

class BleDeviceConnector extends ReactiveState<ConnectionStateUpdate> {
  BleDeviceConnector(this._ble);

  final FlutterReactiveBle _ble;

  @override
  Stream<ConnectionStateUpdate> get state => _deviceConnectionController.stream;

  final _deviceConnectionController = StreamController<ConnectionStateUpdate>();

  StreamSubscription<ConnectionStateUpdate> _connection;

  Future<void> connect(String deviceId) async {
    if (_connection != null) {
      await _connection.cancel();
    }
    _connection = _ble.connectToDevice(id: deviceId).listen(
          _deviceConnectionController.add,
        );
  }

  Future<void> disconnect(String deviceId) async {
    if (_connection == null) {
      return;
    }

    try {
      await _connection.cancel();
    } on Exception catch (e, _) {
      debugPrint('Error disconnecting from a device: $e');
    } finally {
      _deviceConnectionController.add(
        ConnectionStateUpdate(
          deviceId: deviceId,
          connectionState: DeviceConnectionState.disconnected,
          failure: null,
        ),
      );
    }
  }

  Future<void> readCharacteristic(
      String deviceId, Uuid serviceId, Uuid characteristicId) async {
    await _ble
        .readCharacteristic(
          QualifiedCharacteristic(
            deviceId: deviceId,
            serviceId: serviceId,
            characteristicId: characteristicId,
          ),
        )
        .then((value) => debugPrint('readCharacteristic: $value'));
  }

  Future<void> setLightMode(String deviceId, Uuid serviceId,
      Uuid characteristicId, Light light) async {
    await _ble.writeCharacteristicWithResponse(
      QualifiedCharacteristic(
        deviceId: deviceId,
        serviceId: serviceId,
        characteristicId: characteristicId,
      ),
      value: <int>[light.index],
    );
  }

  Future<void> setLightTime(
      String deviceId,
      Uuid serviceId,
      Uuid characteristicId,
      TimeOfDay startLightTime,
      TimeOfDay endLightTime) async {
    await _ble.writeCharacteristicWithResponse(
      QualifiedCharacteristic(
        deviceId: deviceId,
        serviceId: serviceId,
        characteristicId: characteristicId,
      ),
      value: <int>[
        startLightTime.hour,
        startLightTime.minute,
        endLightTime.hour,
        endLightTime.minute,
      ],
    );
  }

  Future<void> dispose() async {
    await _deviceConnectionController.close();
  }
}
