import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class OtaCharacteristics {
  OtaCharacteristics(this.dataCharacteristic, this.controlCharacteristic);
  final BluetoothCharacteristic? dataCharacteristic;
  final BluetoothCharacteristic? controlCharacteristic;
}
