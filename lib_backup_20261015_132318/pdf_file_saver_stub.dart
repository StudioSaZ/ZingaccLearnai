// Android/iOS/desktop PDF share/save fallback.

import 'dart:typed_data';

import 'package:printing/printing.dart';

Future<void> savePdfBytes({
  required Uint8List bytes,
  required String filename,
  required String subject,
}) async {
  await Printing.sharePdf(
    bytes: bytes,
    filename: filename,
    subject: subject,
  );
}
