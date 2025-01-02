// Firmware source abstract class
import 'dart:io';
import 'dart:typed_data';

import 'other.dart';

abstract class FirmwareSource {
  const FirmwareSource();

  Future<List<Uint8List>> getFirmwareChunks(int mtuSize);
}

// Concrete firmware sources
class FileFirmwareSource extends FirmwareSource {
  final String filePath;

  const FileFirmwareSource(this.filePath);

  @override
  Future<List<Uint8List>> getFirmwareChunks(int mtuSize) async {
    // Read file and split into chunks
    final fileBytes = await File(filePath).readAsBytes();

    return splitIntoChunks(fileBytes, mtuSize);
  }
}
