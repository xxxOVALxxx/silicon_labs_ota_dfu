// import 'dart:typed_data';

// import 'package:flutter_test/flutter_test.dart';
// import 'package:silicon_labs_ota_dfu/other.dart';

// void main() {
//   test('splits empty list', () {
//     expect(splitIntoChunks([], 100), []);
//   });

//   test('splits list into one chunk', () {
//     final data = [1, 2, 3];
//     expect(splitIntoChunks(data, 3), [Uint8List.fromList(data)]);
//   });

//   test('splits list into multiple chunks', () {
//     final data = [1, 2, 3, 4, 5, 6];
//     expect(splitIntoChunks(data, 2), [
//       Uint8List.fromList([1, 2]),
//       Uint8List.fromList([3, 4]),
//       Uint8List.fromList([5, 6])
//     ]);
//   });

//   test('last chunk can be smaller than chunk size', () {
//     final data = [1, 2, 3, 4, 5];
//     expect(splitIntoChunks(data, 2), [
//       Uint8List.fromList([1, 2]),
//       Uint8List.fromList([3, 4]),
//       Uint8List.fromList([5])
//     ]);
//   });
// }
