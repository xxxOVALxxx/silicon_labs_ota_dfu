import 'dart:typed_data';

List<Uint8List> splitIntoChunks(List<int> bytes, int chunkSize) {
  List<Uint8List> chunks = [];

  for (int i = 0; i < bytes.length; i += chunkSize) {
    int end = i + chunkSize;
    if (end > bytes.length) {
      end = bytes.length;
    }
    Uint8List chunk = Uint8List.fromList(bytes.sublist(i, end));
    chunks.add(chunk);
  }

  return chunks;
}
