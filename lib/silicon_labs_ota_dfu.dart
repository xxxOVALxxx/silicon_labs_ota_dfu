library silicon_labs_ota_dfu;

export 'other.dart';
export 'firmware_source.dart';

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:silicon_labs_ota_dfu/ota_characteristics.dart';
import 'package:silicon_labs_ota_dfu/should_update_reboot.dart';

import 'firmware_source.dart';

abstract class OtaPackage {
  Future<void> updateFirmware(
    BluetoothDevice device,
    FirmwareSource source,
  );

  // Stream to provide progress percentage
  Stream<int> get percentageStream;
}

class BleRepository {
  static Future<void> writeDataCharacteristic(
      BluetoothCharacteristic characteristic, Uint8List data) async {
    await characteristic.write(data, withoutResponse: false);
  }

  static Future<List<int>> readCharacteristic(
      BluetoothCharacteristic characteristic) async {
    return await characteristic.read();
  }

  static Future<int> requestMtu(BluetoothDevice device, int mtuSize) async {
    return await device.requestMtu(mtuSize);
  }
}

// Implementation of OTA package for Silicon Labs
class SiliconLabsOtaPackage implements OtaPackage {
  final StreamController<int> _percentageController =
      StreamController<int>.broadcast();
  @override
  Stream<int> get percentageStream => _percentageController.stream;

  SiliconLabsOtaPackage();

  @override
  Future<void> updateFirmware(
    BluetoothDevice device,
    FirmwareSource source,
  ) async {
    final services = device.servicesList;

    OtaCharacteristics characteristics = findCharacteristics(services);

    if (shouldReboot(characteristics)) {
      try {
        await _rebootToDfuMode(device, characteristics.controlCharacteristic!);
      } catch (e) {
        debugPrint(e.toString());
        throw Exception('Error rebooting to DFU mode');
      }

      final discoveredServices = await device.discoverServices(subscribeToServicesChanged: false);
      characteristics = findCharacteristics(discoveredServices);
      if (characteristics.controlCharacteristic == null ||
          characteristics.dataCharacteristic == null) {
        throw Exception('Error rebooting to DFU mode');
      }
    }

    final BluetoothCharacteristic controlCharacteristic =
        characteristics.controlCharacteristic!;
    final BluetoothCharacteristic dataCharacteristic =
        characteristics.dataCharacteristic!;

    // Get MTU size from the device
    int mtuSize = await BleRepository.requestMtu(device, 250) - 3;

    // Fetch chunks from firmware source
    List<Uint8List> binaryChunks = await source.getFirmwareChunks(mtuSize);

    // Write x00 to the controlCharacteristic
    await BleRepository.writeDataCharacteristic(
        controlCharacteristic, Uint8List.fromList([0]));

    int packageNumber = 0;
    for (Uint8List chunk in binaryChunks) {
      // Write firmware chunks to dataCharacteristic
      debugPrint(
          'Writing package number $packageNumber of ${binaryChunks.length}. Packet length ${chunk.length} bytes');

      await BleRepository.writeDataCharacteristic(dataCharacteristic, chunk);
      packageNumber++;

      double progress = (packageNumber / binaryChunks.length) * 100;
      int roundedProgress = progress.round();

      debugPrint('Progress: $roundedProgress%');
      _percentageController.add(roundedProgress);
    }

    // Write x03 to the controlCharacteristic to finish the update process
    await BleRepository.writeDataCharacteristic(
        controlCharacteristic, Uint8List.fromList([3]));

    device.disconnect();
  }

  Future<void> _rebootToDfuMode(
    BluetoothDevice device,
    BluetoothCharacteristic controlCharacteristic,
  ) async {
    await BleRepository.writeDataCharacteristic(
        controlCharacteristic, Uint8List.fromList([0]));
    await device.disconnect();
    await Future.delayed(const Duration(seconds: 5));
    await device.connect();
  }
}
