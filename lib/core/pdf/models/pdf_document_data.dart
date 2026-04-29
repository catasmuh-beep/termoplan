enum PdfReportType {
  heating,
  cooling,
  underfloor,
  radiator,
}

class PdfDocumentData {
  final PdfReportType type;
  final String title;
  final String subtitle;
  final PdfCustomerData? customer;
  final PdfProjectMeta meta;
  final PdfSummaryData summary;
  final List<PdfSectionData> sections;
  final List<String> notes;

  const PdfDocumentData({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.summary,
    required this.sections,
    this.customer,
    this.notes = const [],
  });
}

class PdfCustomerData {
  final String? name;
  final String? phone;
  final String? city;
  final String? district;
  final String? projectName;

  const PdfCustomerData({
    this.name,
    this.phone,
    this.city,
    this.district,
    this.projectName,
  });
}

class PdfProjectMeta {
  final DateTime createdAt;
  final bool isPremium;
  final String appName;
  final String reportCode;

  const PdfProjectMeta({
    required this.createdAt,
    required this.isPremium,
    required this.appName,
    required this.reportCode,
  });
}

class PdfSummaryData {
  final String mainResult;
  final String? recommendedDevice;
  final String? recommendedCapacity;
  final List<PdfResultItem> highlights;

  const PdfSummaryData({
    required this.mainResult,
    this.recommendedDevice,
    this.recommendedCapacity,
    this.highlights = const [],
  });
}

class PdfSectionData {
  final String title;
  final List<PdfResultItem> items;

  const PdfSectionData({
    required this.title,
    this.items = const [],
  });
}

class PdfResultItem {
  final String label;
  final String value;
  final String? unit;
  final String? hint;

  const PdfResultItem({
    required this.label,
    required this.value,
    this.unit,
    this.hint,
  });
}