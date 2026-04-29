import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/pdf_document_data.dart';
import 'termo_pdf_engine.dart';

class TermoPdfEngineImpl implements TermoPdfEngine {
  TermoPdfEngineImpl();

  Future<pw.ThemeData> _loadTheme() async {
    final fontRegular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );

    final fontBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    );

    return pw.ThemeData.withFont(
      base: fontRegular,
      bold: fontBold,
    );
  }

  @override
  Future<List<int>> generate(PdfDocumentData data) async {
    final theme = await _loadTheme();
    final pdf = pw.Document(theme: theme);

    final firstPageSections = _firstPageSections(data.sections, data.type);
    final secondPageSections = _secondPageSections(data.sections, data.type);
    final hasSecondPageContent =
        secondPageSections.isNotEmpty || data.notes.isNotEmpty;

    pdf.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(22, 22, 22, 26),
        header: (context) => _buildHeader(data),
        footer: (context) => _buildFooter(context, data),
        build: (context) => [
          _buildCoverCard(data),
          pw.SizedBox(height: 10),
          _buildSummaryCard(data.summary, data.type),
          if (data.customer != null) ...[
            pw.SizedBox(height: 8),
            _buildCustomerCard(data.customer!, data.type),
          ],
          if (firstPageSections.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            ...firstPageSections.map((section) => _buildSectionCard(section, data.type)),
          ],
          if (hasSecondPageContent) pw.NewPage(),
          if (secondPageSections.isNotEmpty) ...[
            ...secondPageSections.map((section) => _buildSectionCard(section, data.type)),
          ],
          if (data.notes.isNotEmpty) ...[
            if (secondPageSections.isNotEmpty) pw.SizedBox(height: 8),
            _buildNotesCard(data.notes),
          ],
        ],
      ),
    );

    return pdf.save();
  }

  List<PdfSectionData> _firstPageSections(
    List<PdfSectionData> sections,
    PdfReportType type,
  ) {
    final prepared = _prepareSections(sections, type);
    return prepared.where((section) {
      final title = _mapSectionTitle(section.title, type).toLowerCase().trim();

      switch (type) {
        case PdfReportType.heating:
          return title.contains('giriş bilgileri');
        case PdfReportType.cooling:
          return title == 'mahal bilgileri' || title.contains('giriş bilgileri');
        case PdfReportType.underfloor:
          return title.contains('giriş bilgileri');
        case PdfReportType.radiator:
          return title.contains('giriş bilgileri');
      }
    }).toList();
  }

  List<PdfSectionData> _secondPageSections(
    List<PdfSectionData> sections,
    PdfReportType type,
  ) {
    final prepared = _prepareSections(sections, type);
    final firstTitles = _firstPageSections(sections, type)
        .map((e) => _mapSectionTitle(e.title, type).toLowerCase().trim())
        .toSet();

    return prepared.where((section) {
      final title = _mapSectionTitle(section.title, type).toLowerCase().trim();
      return !firstTitles.contains(title);
    }).toList();
  }

  List<PdfSectionData> _prepareSections(
    List<PdfSectionData> sections,
    PdfReportType type,
  ) {
    final filteredSections = type == PdfReportType.heating
        ? sections.where((section) {
            final lower = section.title.toLowerCase().trim();
            return lower != 'sonuç ve değerlendirme' &&
                lower != 'sonuç' &&
                lower != 'değerlendirme';
          }).toList()
        : sections;

    return filteredSections.map((section) {
      final sectionItems = type == PdfReportType.heating
          ? section.items.where((item) {
              final lower = item.label.toLowerCase().trim();
              if (lower == 'yön') return false;
              return true;
            }).toList()
          : section.items;

      return PdfSectionData(
        title: section.title,
        items: sectionItems,
      );
    }).toList();
  }

  pw.Widget _buildHeader(PdfDocumentData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.grey300,
            width: 0.8,
          ),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 7,
                height: 34,
                decoration: pw.BoxDecoration(
                  color: PdfColors.orange400,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    data.meta.appName,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.orange700,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    data.title,
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              _reportTypeText(data.type),
              style: pw.TextStyle(
                fontSize: 8.5,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context, PdfDocumentData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(
            color: PdfColors.grey300,
            width: 0.8,
          ),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Rapor Kodu: ${data.meta.reportCode}',
            style: const pw.TextStyle(
              fontSize: 8.5,
              color: PdfColors.grey700,
            ),
          ),
          pw.Text(
            'Sayfa ${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(
              fontSize: 8.5,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCoverCard(PdfDocumentData data) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.orange50,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(
          color: PdfColors.orange200,
          width: 1,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            data.title,
            style: pw.TextStyle(
              fontSize: 17,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.orange800,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            data.subtitle,
            style: const pw.TextStyle(
              fontSize: 9.5,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metaChip(
                'Oluşturulma',
                DateFormat('dd.MM.yyyy HH:mm').format(data.meta.createdAt),
              ),
              _metaChip('Rapor Tipi', _reportTypeText(data.type)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryCard(PdfSummaryData summary, PdfReportType type) {
    final title = switch (type) {
      PdfReportType.heating => 'Özet / Sonuç',
      PdfReportType.cooling => 'Özet / Sonuç',
      PdfReportType.underfloor => 'Özet Sonuç',
      PdfReportType.radiator => 'Özet Sonuç',
    };

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(11),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(
          color: PdfColors.blue100,
          width: 1,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 13.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            summary.mainResult,
            style: pw.TextStyle(
              fontSize: 11.2,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          if ((summary.recommendedDevice ?? '').isNotEmpty ||
              (summary.recommendedCapacity ?? '').isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if ((summary.recommendedDevice ?? '').isNotEmpty)
                    pw.Text(
                      'Önerilen Cihaz: ${summary.recommendedDevice}',
                      style: const pw.TextStyle(fontSize: 9.8),
                    ),
                  if ((summary.recommendedCapacity ?? '').isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 3),
                      child: pw.Text(
                        'Önerilen Kapasite: ${summary.recommendedCapacity}',
                        style: const pw.TextStyle(fontSize: 9.8),
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (summary.highlights.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            ...summary.highlights.map(_buildResultRow),
          ],
          if (type == PdfReportType.heating) ...[
            pw.SizedBox(height: 8),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColors.amber50,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(
                  color: PdfColors.amber200,
                  width: 0.8,
                ),
              ),
              child: pw.Text(
                'Nihai cihaz seçimi uygulama koşullarına göre uzman değerlendirmesi ile netleştirilmelidir.',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.amber900,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildCustomerCard(PdfCustomerData customer, PdfReportType type) {
    final rows = <pw.Widget>[];

    void addField(String label, String? value) {
      if ((value ?? '').trim().isEmpty) return;
      rows.add(_buildLabelValueLine(label, value!.trim()));
    }

    addField('Ad Soyad', customer.name);
    addField('Telefon', customer.phone);
    addField('İl', customer.city);
    addField('İlçe', customer.district);

    if (type != PdfReportType.heating &&
        (customer.projectName ?? '').trim().isNotEmpty) {
      addField('Proje', customer.projectName);
    }

    if (rows.isEmpty) {
      return pw.SizedBox();
    }

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(11),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(
          color: PdfColors.grey300,
          width: 1,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            switch (type) {
              PdfReportType.heating => 'Müşteri Bilgileri',
              PdfReportType.cooling => 'Konum Bilgileri',
              PdfReportType.underfloor => 'Müşteri / Proje Bilgisi',
              PdfReportType.radiator => 'Müşteri / Proje Bilgisi',
            },
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey900,
            ),
          ),
          pw.SizedBox(height: 7),
          ...rows,
        ],
      ),
    );
  }

  pw.Widget _buildSectionCard(PdfSectionData section, PdfReportType type) {
    final sectionTitle = _mapSectionTitle(section.title, type);

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(11),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(
          color: PdfColors.grey300,
          width: 1,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            sectionTitle,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal800,
            ),
          ),
          pw.SizedBox(height: 7),
          if (section.items.isEmpty)
            pw.Text(
              'Bu bölüm için veri bulunamadı.',
              style: const pw.TextStyle(
                fontSize: 9.2,
                color: PdfColors.grey700,
              ),
            )
          else
            ...section.items.map(_buildResultRow),
        ],
      ),
    );
  }

  String _mapSectionTitle(String originalTitle, PdfReportType type) {
    final lower = originalTitle.toLowerCase().trim();

    if (type == PdfReportType.heating) {
      if (lower.contains('genel hesap')) {
        return 'Isıtma Hesabı Giriş Bilgileri';
      }
    }

    if (type == PdfReportType.underfloor) {
      if (lower.contains('genel hesap')) {
        return 'Yerden Isıtma Giriş Bilgileri';
      }
    }

    if (type == PdfReportType.radiator) {
      if (lower.contains('genel hesap')) {
        return 'Radyatör Hesabı Giriş Bilgileri';
      }
    }

    if (type == PdfReportType.cooling) {
      if (lower.contains('genel hesap')) {
        return 'Klima Hesabı Giriş Bilgileri';
      }
      if (lower == 'genel bilgiler' || lower == 'mahal bilgileri') {
        return 'Mahal Bilgileri';
      }
      if (lower == 'hesap sonuçları' || lower == 'klima sonuçları') {
        return 'Klima Sonuçları';
      }
    }

    return originalTitle;
  }

  pw.Widget _buildNotesCard(List<String> notes) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(11),
      decoration: pw.BoxDecoration(
        color: PdfColors.amber50,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(
          color: PdfColors.amber200,
          width: 1,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Notlar',
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.amber900,
            ),
          ),
          pw.SizedBox(height: 7),
          ...notes.map(
            (note) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('• ', style: const pw.TextStyle(fontSize: 9.5)),
                  pw.Expanded(
                    child: pw.Text(
                      note,
                      style: const pw.TextStyle(fontSize: 9.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildResultRow(PdfResultItem item) {
    final valueText = item.unit == null || item.unit!.trim().isEmpty
        ? item.value
        : '${item.value} ${item.unit}';

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 5),
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 4,
                child: pw.Text(
                  item.label,
                  style: pw.TextStyle(
                    fontSize: 9.4,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey900,
                  ),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                flex: 3,
                child: pw.Text(
                  valueText,
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    fontSize: 9.4,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
              ),
            ],
          ),
          if ((item.hint ?? '').trim().isNotEmpty) ...[
            pw.SizedBox(height: 3),
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(
                    item.hint!.trim(),
                    style: const pw.TextStyle(
                      fontSize: 8.2,
                      color: PdfColors.grey700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildLabelValueLine(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 68,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 9.4,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
            ),
          ),
          pw.Text(
            ': ',
            style: const pw.TextStyle(fontSize: 9.4),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 9.4),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _metaChip(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 7.3,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 9.2,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _reportTypeText(PdfReportType type) {
    switch (type) {
      case PdfReportType.heating:
        return 'Isıtma Hesabı';
      case PdfReportType.cooling:
        return 'Klima Hesabı';
      case PdfReportType.underfloor:
        return 'Yerden Isıtma';
      case PdfReportType.radiator:
        return 'Radyatör Hesabı';
    }
  }
}
