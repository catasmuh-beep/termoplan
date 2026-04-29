abstract class TermoPdfFileService {
  Future<String> savePdf({
    required List<int> bytes,
    required String fileName,
  });
}