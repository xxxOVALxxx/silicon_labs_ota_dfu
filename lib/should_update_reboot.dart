import 'package:collection/collection.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:silicon_labs_ota_dfu/consts.dart';
import 'package:silicon_labs_ota_dfu/ota_characteristics.dart';

bool shouldReboot(OtaCharacteristics characteristics) {
  if (characteristics.controlCharacteristic != null &&
      characteristics.dataCharacteristic == null) {
    return true;
  }

  return false;
}

OtaCharacteristics findCharacteristics(List<BluetoothService> services) {
  final dfuService = services
      .firstWhereOrNull((s) => s.serviceUuid == SiliconLabsConsts.dfuService);

  if (dfuService == null) {
    throw Exception("OTA DFU service missing");
  }

  final controlCharacteristic = dfuService.characteristics.firstWhereOrNull(
      (c) => c.characteristicUuid == SiliconLabsConsts.controlCharacteristic);
  final dataCharacteristic = dfuService.characteristics.firstWhereOrNull(
      (c) => c.characteristicUuid == SiliconLabsConsts.dataCharacteristic);

  return OtaCharacteristics(dataCharacteristic, controlCharacteristic);
}
