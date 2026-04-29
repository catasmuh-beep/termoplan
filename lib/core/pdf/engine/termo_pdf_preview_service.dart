import 'dart:typed_data';

import 'package:printing/printing.dart';

import '../models/pdf_document_data.dart';
import 'termo_pdf_engine.dart';

class TermoPdfPreviewService {
  final TermoPdfEngine engine;

  const TermoPdfPreviewService(this.engine);

  Future<Uint8List> buildPreviewBytes(PdfDocumentData data) async {
    final bytes = await engine.generate(data);
    return Uint8List.fromList(bytes);
  }

  Future<void> printPdf(PdfDocumentData data) async {
    await Printing.layoutPdf(
      onLayout: (format) async => Uint8List.fromList(
        await engine.generate(data),
      ),
    );
  }

  Future<void> sharePdf(PdfDocumentData data, {String? fileName}) async {
    await Printing.sharePdf(
      bytes: Uint8List.fromList(await engine.generate(data)),
      filename: fileName ?? 'termoplan_rapor.pdf',
    );
  }
}