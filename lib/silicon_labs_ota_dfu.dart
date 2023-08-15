/*
TODO: 
Add custom exceptions
*/

/*
TODO: 
Replace "magic numbers" with constants
*/

/*
TODO: 
Write tests
*/

/*
TODO: 
Create README
*/

library silicon_labs_ota_dfu;

export 'other.dart';
export 'firmware_source.dart';

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'firmware_source.dart';

abstract class OtaPackage {
  Future<void> updateFirmware(
    BluetoothDevice device,
    FirmwareSource source,
    // TODO: Encapsulate FlutterBluePlus entities
    BluetoothCharacteristic dataUUID,
    BluetoothCharacteristic controlUUID,
  );

  // Stream to provide progress percentage
  //TODO: Replace with callback or state object
  Stream<int> get percentageStream;
}

class BleRepository {
  Future<void> writeDataCharacteristic(
      BluetoothCharacteristic characteristic, Uint8List data) async {
    await characteristic.write(data);
  }

  Future<List<int>> readCharacteristic(
      BluetoothCharacteristic characteristic) async {
    return await characteristic.read();
  }

  Future<void> requestMtu(BluetoothDevice device, int mtuSize) async {
    await device.requestMtu(mtuSize);
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
    BluetoothCharacteristic dataCharacteristic,
    BluetoothCharacteristic controlCharacteristic,
  ) async {
    final bleRepo = BleRepository();

    // Get MTU size from the device
    int mtuSize = await device.mtu.first;

    // Prepare a byte list to write MTU size to controlCharacteristic
    Uint8List byteList = Uint8List(2);
    byteList[0] = mtuSize & 0xFF;
    byteList[1] = (mtuSize >> 8) & 0xFF;

    // Fetch chunks from firmware source
    List<Uint8List> binaryChunks = await source.getFirmwareChunks(mtuSize);

    // Write x00 to the controlCharacteristic
    await bleRepo.writeDataCharacteristic(
        controlCharacteristic, Uint8List.fromList([0]));

    int packageNumber = 0;
    for (Uint8List chunk in binaryChunks) {
      // Write firmware chunks to dataCharacteristic
      await bleRepo.writeDataCharacteristic(dataCharacteristic, chunk);
      packageNumber++;

      double progress = (packageNumber / binaryChunks.length) * 100;
      int roundedProgress = progress.round(); // Rounded off progress value
      debugPrint(
          'Writing package number $packageNumber of ${binaryChunks.length}');
      debugPrint('Progress: $roundedProgress%');
      _percentageController.add(roundedProgress);
    }

    // Write x03 to the controlCharacteristic to finish the update process
    await bleRepo.writeDataCharacteristic(
        controlCharacteristic, Uint8List.fromList([3]));
  }
}
