import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'termo_pdf_file_service.dart';

class TermoPdfFileServiceImpl implements TermoPdfFileService {
  @override
  Future<String> savePdf({
    required List<int> bytes,
    required String fileName,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final safeFileName = fileName.endsWith('.pdf') ? fileName : '$fileName.pdf';
    final file = File('${directory.path}/$safeFileName');

    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}