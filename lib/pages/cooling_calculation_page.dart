import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/pdf/engine/termo_pdf_engine_impl.dart';
import '../core/pdf/models/pdf_document_data.dart';
import '../data/turkey_cooling_data.dart';
import '../core/constants/termo_location_data.dart';

class CoolingCalculationPage extends StatefulWidget {
  const CoolingCalculationPage({super.key});

  @override
  State<CoolingCalculationPage> createState() => _CoolingCalculationPageState();
}

class _CoolingCalculationPageState extends State<CoolingCalculationPage> {
  final TextEditingController _areaController = TextEditingController();

  String? _selectedProvince;
  CoolingZoneType? _selectedZone;
  CoolingRoomType? _selectedRoom;
  CoolingDistrictData? _selectedDistrict;

  int _extraPeopleCount = 0;
  CoolingCalculationResult? _result;

  static const Color _sunOrange = Color(0xFFF2A257);
  static const Color _softOrange = Color(0xFFFFF4E8);
  static const Color _brandTeal = Color(0xFF2F8FE8);
  static const Color _dividerDark = Color(0xFF23404D);
  static const Color _lightText = Color(0xFF728391);
  static const Color _borderColor = Color(0xFFDCE7EE);
  static const Color _iceBlue = Color(0xFF8CCEF0);
  static const Color _warnBg = Color(0xFFFFF4E8);

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  List<CoolingProvinceData> get _sortedProvinces {
    final provinces = List<CoolingProvinceData>.from(CoolingData.sortedProvinces);
    final order = {
      for (int i = 0; i < TermoLocationData.allCities.length; i++)
        TermoLocationData.allCities[i]: i,
    };
    provinces.sort((a, b) => (order[a.name] ?? 999).compareTo(order[b.name] ?? 999));
    return provinces;
  }

  

  void _onProvinceChanged(String? value) {
    if (value == null) return;

    final isMetro = CoolingData.isMetropolitan(value);

    setState(() {
      _selectedProvince = value;
      _selectedDistrict = null;
      _selectedRoom = null;
      _result = null;

      if (isMetro) {
        _selectedZone = null;
      } else {
        final zones = CoolingData.zonesOf(value);
        _selectedZone = zones.isNotEmpty ? zones.first : null;
      }
    });
  }

  void _onDistrictChanged(CoolingDistrictData? district) {
    setState(() {
      _selectedDistrict = district;
      _selectedZone = district?.zone;
      _result = null;
    });
  }

  void _calculate() {
    final area = double.tryParse(_areaController.text.replaceAll(',', '.'));

    if (_selectedProvince == null ||
        _selectedRoom == null ||
        _selectedZone == null ||
        area == null ||
        area <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm alanları eksiksiz doldurun.'),
        ),
      );
      return;
    }

    final result = CoolingData.calculate(
      area: area,
      zone: _selectedZone!,
      room: _selectedRoom!,
      peopleCount: _extraPeopleCount,
    );

    setState(() {
      _result = result;
    });
  }

  bool get _isOver24kBtu =>
      _result != null && _result!.rawBtu > 24000;

  String _displayCapacityText() {
    if (_result == null) return '-';
    final value = _isOver24kBtu ? _result!.rawBtu : _result!.recommendedBtu;
    return '${_formatNumber(value)} BTU';
  }

  String _capacityCardTitle() {
    return _isOver24kBtu
        ? 'Hesaplanan Soğutma İhtiyacı'
        : 'Önerilen Klima Kapasitesi';
  }

  String _capacitySummaryLabel() {
    return _isOver24kBtu ? 'Hesaplanan Soğutma İhtiyacı' : 'Önerilen Kapasite';
  }

  String _coolingSystemRecommendation() {
    if (_result == null) return '-';

    if (_result!.rawBtu > 24000) {
      return '${_formatNumber(_result!.recommendedBtu)} BTU üzeri kapasite ihtiyacı';
    }

    return 'Duvar Tipi Split Klima';
  }

  String _highCapacityWarningText() {
    return '24.000 BTU üzeri güçler için bahse konu alana 2. bir klima, '
        'multi split sistem veya salon tipi klima önerilir. '
        'Nihai seçim için uzman desteği alınız.';
  }

  String _locationLabel() {
    if (_selectedDistrict != null) return _selectedDistrict!.name;
    if (_selectedZone != null) return CoolingData.zoneLabel(_selectedZone!);
    return '-';
  }

  String _roomLabel() {
    if (_selectedRoom == null) return '-';
    return CoolingData.roomLabel(_selectedRoom!);
  }

  Future<Uint8List> _generatePdfBytes() async {
    if (_result == null) {
      throw Exception('Sonuç bulunamadı');
    }

    final data = PdfDocumentData(
      type: PdfReportType.cooling,
      title: 'TermoPlan PDF Raporu',
      subtitle: 'Klima Hesabı',
      customer: PdfCustomerData(
        city: _selectedProvince,
        district: _locationLabel(),
      ),
      meta: PdfProjectMeta(
        createdAt: DateTime.now(),
        isPremium: true,
        appName: 'TermoPlan',
        reportCode: 'CLM-${DateTime.now().millisecondsSinceEpoch}',
      ),
      summary: PdfSummaryData(
        mainResult: _isOver24kBtu
            ? '${_formatNumber(_result!.rawBtu)} BTU soğutma ihtiyacı hesaplanmıştır.'
            : '${_formatNumber(_result!.recommendedBtu)} BTU kapasite önerilmektedir.',
        recommendedDevice:
            _result!.rawBtu > 24000 ? '' : 'Duvar Tipi Split Klima',
        recommendedCapacity: _isOver24kBtu
            ? ''
            : '${_formatNumber(_result!.recommendedBtu)} BTU',
        highlights: [
          PdfResultItem(
            label: 'Alan',
            value: _areaController.text.replaceAll(',', '.'),
            unit: 'm²',
          ),
          PdfResultItem(
            label: 'İl',
            value: _selectedProvince ?? '-',
          ),
          PdfResultItem(
            label: 'İlçe',
            value: _locationLabel(),
          ),
        ],
      ),
      sections: [
        PdfSectionData(
          title: 'Mahal Bilgileri',
          items: [
            PdfResultItem(label: 'İl', value: _selectedProvince ?? '-'),
            PdfResultItem(label: 'İlçe', value: _locationLabel()),
            PdfResultItem(label: 'Oda Türü', value: _roomLabel()),
            PdfResultItem(
              label: 'Alan',
              value: _areaController.text.replaceAll(',', '.'),
              unit: 'm²',
            ),
            PdfResultItem(
              label: 'Ekstra Kişi',
              value: '$_extraPeopleCount',
            ),
          ],
        ),
        PdfSectionData(
          title: 'Klima Sonuçları',
          items: [
            PdfResultItem(
              label: 'Bölge Katsayısı',
              value: _result!.zoneCoefficient.toStringAsFixed(0),
              hint: 'Seçilen il / ilçe / bölgeye göre belirlenmiştir.',
            ),
            PdfResultItem(
              label: 'Oda Çarpanı',
              value: _result!.roomMultiplier.toStringAsFixed(2),
              hint: 'Oda kullanım tipine göre uygulanmıştır.',
            ),
            PdfResultItem(
              label: 'Ek Kişi Yükü',
              value: _formatNumber(_result!.extraPeopleLoadBtu),
              unit: 'BTU',
            ),
            PdfResultItem(
              label: 'Hesaplanan İhtiyaç',
              value: _formatNumber(_result!.rawBtu),
              unit: 'BTU',
            ),
            PdfResultItem(
              label: _isOver24kBtu
                  ? 'Hesaplanan Soğutma İhtiyacı'
                  : 'Önerilen Kapasite',
              value: _formatNumber(
                _isOver24kBtu ? _result!.rawBtu : _result!.recommendedBtu,
              ),
              unit: 'BTU',
              hint: _isOver24kBtu
                  ? '24.000 BTU üzeri ihtiyaçlarda standart tekli duvar tipi split önerisi verilmez.'
                  : 'Standart kapasite basamağına yuvarlanmış öneri değeridir.',
            ),
            if (_result!.recommendedBtu <= 24000)
              PdfResultItem(
                label: 'Sistem Tipi',
                value: 'Duvar Tipi Split Klima',
              ),
          ],
        ),
      ],
      notes: [
        if (_result!.rawBtu > 24000) _highCapacityWarningText(),
        'Bu rapor yaklaşık kapasite tespiti amacıyla oluşturulmuştur.',
        'Mahal yapısı, cephe etkisi ve cam alanı gibi ilave şartlar sahada ayrıca değerlendirilmelidir.',
        'Kesin cihaz seçimi için yerinde keşif ve uzman görüşü önerilir.',
      ],
    );

    final engine = TermoPdfEngineImpl();
    final bytes = await engine.generate(data);
    return Uint8List.fromList(bytes);
  }

  Future<void> _openPdfPreview() async {
    try {
      final bytes = await _generatePdfBytes();
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF oluşturulurken bir hata oluştu.'),
        ),
      );
    }
  }

  Future<void> _sharePdf() async {
    try {
      final bytes = await _generatePdfBytes();
      final file = XFile.fromData(
        bytes,
        mimeType: 'application/pdf',
        name: 'termoplan_klima_raporu.pdf',
      );
      await Share.shareXFiles(
        [file],
        text:
            'TermoPlan ile hazırladığım klima hesabı raporunu paylaşıyorum.',
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF paylaşılırken bir hata oluştu.'),
        ),
      );
    }
  }

  Future<void> _openExpertSupport() async {
    final uri = Uri.parse('https://wa.me/905307847260');

    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WhatsApp bağlantısı açılamadı.'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('WhatsApp bağlantısı açılamadı.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provinces = _sortedProvinces;
    final isMetro = _selectedProvince != null
        ? CoolingData.isMetropolitan(_selectedProvince!)
        : false;
    final districts = _selectedProvince != null
        ? CoolingData.districtsOf(_selectedProvince!)
        : <CoolingDistrictData>[];
    final zones = _selectedProvince != null
        ? CoolingData.zonesOf(_selectedProvince!)
        : <CoolingZoneType>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FA),
      appBar: AppBar(
  elevation: 0,
  backgroundColor: const Color(0xFFF3F7FA),
  foregroundColor: _dividerDark,
  centerTitle: true,
  title: const SizedBox.shrink(),
),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopInfoCard(),
              const SizedBox(height: 16),
              _buildMainCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 18),
                    _buildProvinceDropdown(provinces),
                    const SizedBox(height: 14),
                    if (_selectedProvince != null && isMetro) ...[
                      _buildDistrictDropdown(districts),
                      const SizedBox(height: 14),
                    ],
                    if (_selectedProvince != null && !isMetro) ...[
                      _buildZoneDropdown(zones),
                      const SizedBox(height: 14),
                    ],
                    _buildRoomDropdown(),
                    const SizedBox(height: 14),
                    _buildAreaField(),
                    const SizedBox(height: 14),
                    _buildExtraPeopleSelector(),
                    const SizedBox(height: 18),
                    _buildWarningBox(),
                    const SizedBox(height: 18),
                    _buildCalculateButton(),
                    const SizedBox(height: 12),
                    _buildExpertSupportButton(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_result != null) _buildResultCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopInfoCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: AspectRatio(
        aspectRatio: 6.06,
        child: Image.asset(
          'assets/header/cooling_header_clean.png',
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildMainCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: _softOrange,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.wb_sunny_outlined,
            color: _sunOrange,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Oda Bazlı Soğutma Hesabı',
                style: TextStyle(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w800,
                  color: _dividerDark,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Isı kaybı ve yerden ısıtma modülleriyle uyumlu tasarım dili korunmuştur.',
                style: TextStyle(
                  fontSize: 13.2,
                  height: 1.45,
                  color: _lightText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProvinceDropdown(List<CoolingProvinceData> provinces) {
    return DropdownButtonFormField<String>(
      menuMaxHeight: 320,
      value: _selectedProvince,
      decoration: _inputDecoration(
        label: 'İl',
        prefixIcon: Icons.location_city_rounded,
      ),
      items: provinces
          .map(
            (p) => DropdownMenuItem<String>(
              value: p.name,
              child: Text(p.name),
            ),
          )
          .toList(),
      onChanged: _onProvinceChanged,
    );
  }

  Widget _buildDistrictDropdown(List<CoolingDistrictData> districts) {
    return DropdownButtonFormField<CoolingDistrictData>(
      menuMaxHeight: 320,
      value: _selectedDistrict,
      decoration: _inputDecoration(
        label: 'İlçe',
        prefixIcon: Icons.map_outlined,
      ),
      items: districts
          .map(
            (d) => DropdownMenuItem<CoolingDistrictData>(
              value: d,
              child: Text(d.name),
            ),
          )
          .toList(),
      onChanged: _onDistrictChanged,
    );
  }

  Widget _buildZoneDropdown(List<CoolingZoneType> zones) {
    return DropdownButtonFormField<CoolingZoneType>(
      menuMaxHeight: 320,
      value: _selectedZone,
      decoration: _inputDecoration(
        label: 'Bölge',
        prefixIcon: Icons.terrain_rounded,
      ),
      items: zones
          .map(
            (z) => DropdownMenuItem<CoolingZoneType>(
              value: z,
              child: Text(CoolingData.zoneLabel(z)),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedZone = value;
          _result = null;
        });
      },
    );
  }

  Widget _buildRoomDropdown() {
    return DropdownButtonFormField<CoolingRoomType>(
      menuMaxHeight: 320,
      value: _selectedRoom,
      decoration: _inputDecoration(
        label: 'Oda Türü',
        prefixIcon: Icons.weekend_rounded,
      ),
      items: CoolingRoomType.values
          .map(
            (room) => DropdownMenuItem<CoolingRoomType>(
              value: room,
              child: Text(CoolingData.roomLabel(room)),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedRoom = value;
          _result = null;
        });
      },
    );
  }

  Widget _buildAreaField() {
    return TextFormField(
      controller: _areaController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: _inputDecoration(
        label: 'Oda Alanı (m²)',
        prefixIcon: Icons.square_foot_rounded,
      ),
      onChanged: (_) {
        if (_result != null) {
          setState(() {
            _result = null;
          });
        }
      },
    );
  }

  Widget _buildExtraPeopleSelector() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.people_alt_rounded, color: _brandTeal, size: 20),
              SizedBox(width: 8),
              Text(
                'Ekstra Kişi / Misafir Sayısı',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _dividerDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Hesaplama bölgesel şartlar gözetilerek 4 kişilik standart aile baz alınarak yapılmıştır. Oda niteliğine göre ekstra kişi / misafir girişini aşağıdan yapınız.',
            style: TextStyle(
              fontSize: 12.8,
              color: _lightText,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildCounterButton(
                icon: Icons.remove_rounded,
                onTap: _extraPeopleCount > 0
                    ? () {
                        setState(() {
                          _extraPeopleCount--;
                          _result = null;
                        });
                      }
                    : null,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$_extraPeopleCount Ekstra Kişi',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _dividerDark,
                    ),
                  ),
                ),
              ),
              _buildCounterButton(
                icon: Icons.add_rounded,
                onTap: () {
                  setState(() {
                    _extraPeopleCount++;
                    _result = null;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey.shade200 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _borderColor),
        ),
        child: Icon(
          icon,
          color: onTap == null ? Colors.grey : _brandTeal,
        ),
      ),
    );
  }

  Widget _buildWarningBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _warnBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD9B0)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: _sunOrange,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Hesaplama bölgesel şartlar gözetilerek 4 kişilik standart aile göz önünde bulundurularak yapılmıştır. Oda niteliğine göre kişi arttırımını aşağıdan yapınız.',
              style: TextStyle(
                fontSize: 12.8,
                height: 1.45,
                color: _dividerDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertSupportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _openExpertSupport,
        icon: const Icon(Icons.support_agent_rounded),
        label: const Text(
          'UZMAN DESTEĞİ AL',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF25D366),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildCalculateButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _calculate,
        style: ElevatedButton.styleFrom(
          backgroundColor: _sunOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Klima Kapasitesini Hesapla',
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final selectedZoneText = _selectedZone != null
        ? CoolingData.zoneLabel(_selectedZone!)
        : '-';
    final selectedRoomText = _selectedRoom != null
        ? CoolingData.roomLabel(_selectedRoom!)
        : '-';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: _brandTeal, size: 22),
              SizedBox(width: 8),
              Text(
                'Sonuç',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _dividerDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF27B8B0), Color(0xFF55D1C5)],
              ),
            ),
            child: Column(
              children: [
                Text(
                  _capacityCardTitle(),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _displayCapacityText(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildMiniInfoGrid(
            province: _selectedProvince ?? '-',
            zone: selectedZoneText,
            room: selectedRoomText,
            people: '$_extraPeopleCount Ekstra',
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FBFD),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hesap Özeti',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: _dividerDark,
                  ),
                ),
                const SizedBox(height: 10),
                _buildSummaryRow(
                  'Bölge katsayısı',
                  _result!.zoneCoefficient.toStringAsFixed(0),
                ),
                _buildSummaryRow(
                  'Oda çarpanı',
                  _result!.roomMultiplier.toStringAsFixed(2),
                ),
                _buildSummaryRow(
                  'Ekstra kişi sayısı',
                  '$_extraPeopleCount',
                ),
                _buildSummaryRow(
                  'Ek kişi yükü',
                  '${_formatNumber(_result!.extraPeopleLoadBtu)} BTU',
                ),
                _buildSummaryRow(
                  'Hesaplanan ihtiyaç',
                  '${_formatNumber(_result!.rawBtu)} BTU',
                  isStrong: true,
                ),
                if (!_isOver24kBtu)
                  _buildSummaryRow(
                    'Yuvarlanan öneri',
                    '${_formatNumber(_result!.recommendedBtu)} BTU',
                    isStrong: true,
                    valueColor: _brandTeal,
                  ),
                _buildSummaryRow(
                  _capacitySummaryLabel(),
                  _displayCapacityText(),
                  isStrong: true,
                  valueColor: _brandTeal,
                ),
                if (!_isOver24kBtu)
                  _buildSummaryRow(
                    'Sistem tipi',
                    _coolingSystemRecommendation(),
                    isStrong: true,
                  ),
              ],
            ),
          ),
          if (_isOver24kBtu) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E8),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFD9B0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: _sunOrange,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _highCapacityWarningText(),
                      style: const TextStyle(
                        fontSize: 12.8,
                        height: 1.45,
                        color: _dividerDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7F8),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _borderColor),
            ),
            child: Text(
              _isOver24kBtu
                  ? 'Bu alan için hesaplanan soğutma ihtiyacı ${_formatNumber(_result!.rawBtu)} BTU düzeyindedir. 24.000 BTU üstü olduğu için standart tekli klima tavsiyesi verilmez. PDF RAPOR ile detaylı çıktı alabilir veya UZMAN DESTEĞİ AL ile destek isteyebilirsiniz.'
                  : 'Bu sonuç için ${_formatNumber(_result!.recommendedBtu)} BTU sınıfında klima önerilir. PDF RAPOR ile detaylı çıktı alabilir, PAYLAŞ ile PDF dosyasını gönderebilir veya UZMAN DESTEĞİ AL ile WhatsApp üzerinden destek isteyebilirsiniz.',
              style: const TextStyle(
                fontSize: 13.2,
                height: 1.5,
                color: _dividerDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openPdfPreview,
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: const Text(
                'PDF RAPOR',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _sunOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _sharePdf,
              icon: const Icon(Icons.share_rounded),
              label: const Text(
                'PAYLAŞ',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _brandTeal,
                side: const BorderSide(color: _brandTeal, width: 1.4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildExpertSupportButton(),
        ],
      ),
    );
  }

  Widget _buildMiniInfoGrid({
    required String province,
    required String zone,
    required String room,
    required String people,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildChip('İl', province),
        _buildChip('Bölge', zone),
        _buildChip('Oda', room),
        _buildChip('Ekstra', people),
      ],
    );
  }

  Widget _buildChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD9B0)),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 12.8,
            color: _dividerDark,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isStrong = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                color: isStrong ? _dividerDark : _lightText,
                fontWeight: isStrong ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.8,
              color: valueColor ?? _dividerDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: _lightText,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(prefixIcon, color: _brandTeal),
      filled: true,
      fillColor: const Color(0xFFF8FBFD),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _sunOrange, width: 1.4),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }

  String _formatNumber(int value) {
    final text = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final positionFromEnd = text.length - i;
      buffer.write(text[i]);
      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }
}
