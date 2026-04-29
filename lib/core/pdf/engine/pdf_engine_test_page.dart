import 'package:flutter/material.dart';
import '../mappers/underfloor_pdf_mapper.dart';
import '../models/pdf_document_data.dart';
import 'termo_pdf_engine_impl.dart';
import 'termo_pdf_preview_service.dart';

class PdfEngineTestPage extends StatefulWidget {
  const PdfEngineTestPage({super.key});

  @override
  State<PdfEngineTestPage> createState() => _PdfEngineTestPageState();
}

class _PdfEngineTestPageState extends State<PdfEngineTestPage> {
  bool _loading = false;

  Future<void> _createSamplePdf() async {
    setState(() => _loading = true);

    try {
      final engine = TermoPdfEngineImpl();
      final previewService = TermoPdfPreviewService(engine);

      final sampleData = PdfDocumentData(
        type: PdfReportType.heating,
        title: 'TermoPlan PDF Raporu',
subtitle: 'Isıtma hesaplama sonuçlarına göre oluşturulmuş rapor.',
meta: PdfProjectMeta(
  createdAt: DateTime.now(),
  isPremium: false,
  appName: 'TermoPlan',
  reportCode: 'TP-${DateTime.now().millisecondsSinceEpoch}',
),
        customer: const PdfCustomerData(
          name: 'Serdar Çatak',
          city: 'İstanbul',
          district: 'Bağcılar',
          projectName: 'Örnek Daire Hesabı',
        ),
        summary: const PdfSummaryData(
          mainResult: 'Hesaplamalara göre 24 kW kombi uygun görülmüştür.',
          recommendedDevice: 'Premix Yoğuşmalı Kombi',
          recommendedCapacity: '24 kW',
          highlights: [
            PdfResultItem(
              label: 'Toplam Isı İhtiyacı',
              value: '17.3',
              unit: 'kW',
            ),
            PdfResultItem(
              label: 'Tavsiye',
              value: '28 kW üst segment tercih edilebilir',
              hint: 'Kullanım konforu ve sıcak su ihtiyacına göre değerlendirilir.',
            ),
          ],
        ),
        sections: const [
          PdfSectionData(
title: 'Isıtma Hesabı Giriş Bilgileri',
items: [
PdfResultItem(label: 'Net Alan', value: '120', unit: 'm²'),
PdfResultItem(label: 'İl', value: 'İstanbul'),
PdfResultItem(label: 'İlçe', value: 'Bağcılar'),
PdfResultItem(label: 'Cephe Durumu', value: '2 Cephe'),
PdfResultItem(label: 'İzolasyon Durumu', value: 'Orta'),
PdfResultItem(label: 'Cam Durumu', value: 'Çift Cam'),
PdfResultItem(label: 'Kat Durumu', value: 'Ara Kat'),
],
),
          PdfSectionData(
            title: 'Sonuç ve Değerlendirme',
            items: [
              PdfResultItem(label: 'Hesaplanan Güç', value: '17.3', unit: 'kW'),
              PdfResultItem(label: 'Uygun Kapasite', value: '24', unit: 'kW'),
              PdfResultItem(
                label: 'Üst Tavsiye',
                value: '28',
                unit: 'kW',
                hint: 'Kullanıcı tercihi ve sıcak su konforuna göre düşünülebilir.',
              ),
            ],
          ),
        ],
        notes: [
          'Bu rapor TermoPlan Premium PDF modülü ile oluşturulmuştur.',
          'Sonuçlar kullanıcı tarafından girilen verilere göre hesaplanır.',
          'Nihai cihaz seçimi uygulama koşullarına göre uzman değerlendirmesi ile netleştirilmelidir.',
        ],
      );

      await previewService.sharePdf(
        sampleData,
        fileName: 'termoplan_ornek_rapor.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF oluşturulamadı: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Engine Test'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _loading ? null : _createSamplePdf,
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Örnek PDF Oluştur'),
        ),
      ),
    );
  }
}