import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Isıtma PDF verisi
class HeatingPdfData {
  final String customerName;
  final String customerPhone;
  final String city;
  final String district;
  final String areaM2;
  final String facadeStatus;
  final String insulationStatus;
  final String floorStatus;
  final String windowStatus;
  final String notes;
  final List<String> summaryLines;
  final DateTime? reportDate;

  HeatingPdfData({
    required this.customerName,
    required this.customerPhone,
    required this.city,
    required this.district,
    required this.areaM2,
    required this.facadeStatus,
    required this.insulationStatus,
    required this.floorStatus,
    required this.windowStatus,
    required this.notes,
    required this.summaryLines,
    this.reportDate,
  });
}

class HeatingPdfService {
  static Future<Uint8List> generateHeatingPdf(HeatingPdfData data) async {
    final pdf = pw.Document();

    final now = data.reportDate ?? DateTime.now();
    final formattedDate = DateFormat('dd.MM.yyyy').format(now);

    const primary = PdfColor.fromInt(0xFF00917E);
    const accent = PdfColor.fromInt(0xFFFF9900);
    const dark = PdfColor.fromInt(0xFF1F2937);
    const textGrey = PdfColor.fromInt(0xFF6B7280);
    const border = PdfColor.fromInt(0xFFD9DDE3);
    const softBg = PdfColor.fromInt(0xFFF7F8FA);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(24, 24, 24, 24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              /// HEADER
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 10),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: border, width: 1),
                  ),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 8,
                      height: 42,
                      decoration: pw.BoxDecoration(
                        color: accent,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'TermoPlan PDF Raporu',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: dark,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Isıtma Hesabı',
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Tarih',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: textGrey,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          formattedDate,
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: dark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 12),

              /// ÖZET / SONUÇ
              _sectionTitle('Özet / Sonuç', primary),
              pw.SizedBox(height: 6),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: softBg,
                  border: pw.Border.all(color: border, width: 0.8),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (data.summaryLines.isEmpty)
                      pw.Text(
                        '-',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: dark,
                        ),
                      ),
                    ...data.summaryLines.map(
                      (line) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 4),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              width: 4,
                              height: 4,
                              margin: const pw.EdgeInsets.only(top: 4),
                              decoration: const pw.BoxDecoration(
                                color: accent,
                                shape: pw.BoxShape.circle,
                              ),
                            ),
                            pw.SizedBox(width: 6),
                            pw.Expanded(
                              child: pw.Text(
                                line,
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  color: dark,
                                  lineSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

              /// MÜŞTERİ BİLGİLERİ
              _sectionTitle('Müşteri Bilgileri', primary),
              pw.SizedBox(height: 6),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  border: pw.Border.all(color: border, width: 0.8),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: _infoCell(
                        label: 'Müşteri Adı',
                        value: data.customerName,
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      child: _infoCell(
                        label: 'Telefon',
                        value: data.customerPhone,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

              /// GİRİŞ BİLGİLERİ
              _sectionTitle('Isıtma Hesabı Giriş Bilgileri', primary),
              pw.SizedBox(height: 6),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  border: pw.Border.all(color: border, width: 0.8),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: _infoCell(
                            label: 'İl',
                            value: data.city,
                          ),
                        ),
                        pw.SizedBox(width: 8),
                        pw.Expanded(
                          child: _infoCell(
                            label: 'İlçe',
                            value: data.district,
                          ),
                        ),
                        pw.SizedBox(width: 8),
                        pw.Expanded(
                          child: _infoCell(
                            label: 'm²',
                            value: data.areaM2,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: _infoCell(
                            label: 'Cephe Durumu',
                            value: data.facadeStatus,
                          ),
                        ),
                        pw.SizedBox(width: 8),
                        pw.Expanded(
                          child: _infoCell(
                            label: 'İzolasyon Durumu',
                            value: data.insulationStatus,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: _infoCell(
                            label: 'Kat Durumu',
                            value: data.floorStatus,
                          ),
                        ),
                        pw.SizedBox(width: 8),
                        pw.Expanded(
                          child: _infoCell(
                            label: 'Cam Durumu',
                            value: data.windowStatus,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

              /// NOTLAR
              _sectionTitle('Notlar', primary),
              pw.SizedBox(height: 6),
              pw.Container(
                width: double.infinity,
                constraints: const pw.BoxConstraints(minHeight: 72),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  border: pw.Border.all(color: border, width: 0.8),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text(
                  data.notes.trim().isEmpty ? '-' : data.notes.trim(),
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: dark,
                    lineSpacing: 1.3,
                  ),
                ),
              ),

              pw.Spacer(),

              /// FOOTER
              pw.Container(
                padding: const pw.EdgeInsets.only(top: 8),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(color: border, width: 0.8),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TermoPlan',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    pw.Text(
                      'Bu rapor bilgilendirme amaçlıdır.',
                      style: const pw.TextStyle(
                        fontSize: 8,
                        color: textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _sectionTitle(String title, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  static pw.Widget _infoCell({
    required String label,
    required String value,
  }) {
    const dark = PdfColor.fromInt(0xFF1F2937);
    const textGrey = PdfColor.fromInt(0xFF6B7280);
    const softBg = PdfColor.fromInt(0xFFF7F8FA);
    const border = PdfColor.fromInt(0xFFD9DDE3);

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: pw.BoxDecoration(
        color: softBg,
        border: pw.Border.all(color: border, width: 0.6),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
              color: textGrey,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            value.trim().isEmpty ? '-' : value.trim(),
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: dark,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}