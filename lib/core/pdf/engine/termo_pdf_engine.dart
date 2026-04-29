import '../models/pdf_document_data.dart';

abstract class TermoPdfEngine {
  Future<List<int>> generate(PdfDocumentData data);
}