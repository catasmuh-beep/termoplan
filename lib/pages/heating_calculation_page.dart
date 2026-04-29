import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/calculation/heat_loss_engine.dart';
import '../models/termo_models.dart';
import 'radiator_heating_page.dart';
import '../core/constants/termo_options.dart';
import '../core/constants/termo_location_data.dart';

class HeatingCalculationPage extends StatefulWidget {
  const HeatingCalculationPage({super.key});

  @override
  State<HeatingCalculationPage> createState() => _HeatingCalculationPageState();
}

class _HeatingCalculationPageState extends State<HeatingCalculationPage> {
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _kat1Controller = TextEditingController();
  final TextEditingController _kat2Controller = TextEditingController();

  final HeatLossEngine _heatLossEngine = const HeatLossEngine();
  final _theme = _TermoTheme();

  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedRegion;
  String? _selectedHousingType;
  String? _selectedFacadeCount;
  String? _selectedFloorType;
  String? _selectedGlassType;
  String? _selectedWindowArea;
  int? _selectedInsulation;

  HeatResult? _result;

  static const List<int> _capacitySteps = [24, 28, 30, 35, 42, 45];
  static const String _sharePromoText =
      'Marketten TermoPlan uygulamasını indirdim, bence sen de denemelisin. '
      'Artık ısıtma ve soğutma hesabında işim çok daha kolay.';
  static const String _androidStoreUrl = '';
  static const String _iosStoreUrl = '';

  bool get _isMetro =>
      _selectedCity != null && HeatLossEngine.isMetropolitan(_selectedCity!);

  bool get _isCoastal =>
      _selectedCity != null &&
      HeatLossEngine.coastalCities.contains(_selectedCity!);

  bool get _isDublex => _selectedHousingType == 'Dubleks';

  List<String> get _allCities => TermoLocationData.allCities;

  List<String> get _districts =>
      _selectedCity == null ? const [] : HeatLossEngine.locationOptionsForCity(_selectedCity!);

  List<String> get _regionOptions {
    if (_selectedCity == null) return const [];
    return HeatLossEngine.locationOptionsForCity(_selectedCity!);
  }

  @override
  void dispose() {
    _areaController.dispose();
    _kat1Controller.dispose();
    _kat2Controller.dispose();
    super.dispose();
  }

  void _syncLocationDefaults() {
    if (_selectedCity == null) {
      _selectedDistrict = null;
      _selectedRegion = null;
      return;
    }

    if (_isMetro) {
      _selectedRegion = null;
      if (_selectedDistrict != null && !_districts.contains(_selectedDistrict)) {
        _selectedDistrict = null;
      }
    } else {
      _selectedDistrict = null;
      if (_selectedRegion != null && !_regionOptions.contains(_selectedRegion)) {
        _selectedRegion = null;
      }
    }
  }

  String _insulationText(int? level) {
    switch (level) {
      case 0:
        return 'Zayıf';
      case 2:
        return 'İyi';
      case 1:
        return 'Orta';
      default:
        return 'Seçiniz';
    }
  }

  double _getTotalArea() {
    if (_isDublex) {
      final kat1 =
          double.tryParse(_kat1Controller.text.trim().replaceAll(',', '.')) ?? 0;
      final kat2 =
          double.tryParse(_kat2Controller.text.trim().replaceAll(',', '.')) ?? 0;
      return kat1 + kat2;
    }

    return double.tryParse(_areaController.text.trim().replaceAll(',', '.')) ?? 0;
  }

  int? _capacityCeilingKw(double kw) {
    for (final step in _capacitySteps) {
      if (kw <= step) return step;
    }
    return null;
  }

  int? _nextCapacityStep(int current) {
    final index = _capacitySteps.indexOf(current);
    if (index == -1 || index == _capacitySteps.length - 1) return null;
    return _capacitySteps[index + 1];
  }

  int? _advisoryCapacityKwFor(double kw, double area) {
    final recommended = _capacityCeilingKw(kw);
    if (recommended == null) return null;

    final ratio = kw / recommended;
    final isLargeHome24Band = recommended == 24 && area >= 200;

    if (ratio >= 0.70 || isLargeHome24Band) {
      return _nextCapacityStep(recommended);
    }

    return null;
  }

  DeviceRecommendation _recommendDevice(double kw, double area) {
    final recommended = _capacityCeilingKw(kw);

    if (recommended == null) {
      return const DeviceRecommendation(
        title: '45 kW üzeri - Kazan / Kaskad Çözümü',
        subtitle:
            '45 kW üzeri ihtiyaçlarda detaylı mühendislik değerlendirmesi önerilir.',
        isWarning: true,
      );
    }

    final advisory = _advisoryCapacityKwFor(kw, area);
    final effective = advisory ?? recommended;

    if (advisory != null && recommended == 24 && area >= 200) {
      return DeviceRecommendation(
        title: '$effective kW Kombi',
        subtitle:
            '${recommended} kW kapasite hesap olarak yeterli görünse de ${area.toStringAsFixed(area % 1 == 0 ? 0 : 1)} m² gibi büyük alanlarda pompa ve eşanjör avantajı nedeniyle ${effective} kW kombi tavsiye edilir.',
        isWarning: false,
      );
    }

    if (advisory != null) {
      return DeviceRecommendation(
        title: '$effective kW Kombi',
        subtitle:
            '${recommended} kW hesaplanan ihtiyaca yakın olduğu için bir üst kapasite olarak ${effective} kW tavsiye edilir.',
        isWarning: false,
      );
    }

    return DeviceRecommendation(
      title: '$recommended kW Kombi',
      subtitle:
          'Girilen verilere göre ${recommended} kW sınıfı yoğuşmalı kombi uygundur.',
      isWarning: false,
    );
  }

  String _recommendedCapacityText(double kw) {
    final recommended = _capacityCeilingKw(kw);
    if (recommended == null) return '45 kW üzeri';
    return '$recommended kW';
  }

  String _advisoryCapacityText(double kw, double area) {
    final advisory = _advisoryCapacityKwFor(kw, area);
    if (advisory == null) {
      return _recommendedCapacityText(kw);
    }
    return '$advisory kW';
  }

  Future<void> _shareResult() async {
    final result = _result;
    if (result == null) return;

    final lines = <String>[
      'TermoPlan Isıtma Hesabı Sonucu',
      '',
      'Alan: ${result.area.toStringAsFixed(result.area % 1 == 0 ? 0 : 1)} m²',
      'İl: ${result.city}',
      'Konum: ${result.locationSelectionLabel}',
      'Yaklaşık ısı ihtiyacı: ${result.rawKw.toStringAsFixed(1)} kW',
      'Önerilen kapasite: ${_recommendedCapacityText(result.rawKw)}',
      'Tavsiye edilen kapasite: ${_advisoryCapacityText(result.rawKw, result.area)}',
      '',
      _sharePromoText,
      if (_androidStoreUrl.isNotEmpty) 'Android: $_androidStoreUrl',
      if (_iosStoreUrl.isNotEmpty) 'iOS: $_iosStoreUrl',
    ];

    await Share.share(lines.join('\n'));
  }

  String _locationSelectionLabel() {
    if (_isMetro) {
      return _selectedDistrict ?? '-';
    }
    return _selectedRegion ?? '-';
  }

  void _calculate() {
    if (_selectedHousingType == null) {
      _showSnack('Lütfen yapı tipini seçin.');
      return;
    }

    if (_selectedFacadeCount == null) {
      _showSnack('Lütfen cephe sayısını seçin.');
      return;
    }

    if (_selectedFloorType == null) {
      _showSnack('Lütfen kat durumunu seçin.');
      return;
    }

    if (_selectedCity == null) {
      _showSnack('Lütfen il seçin.');
      return;
    }

    if (_isMetro && _selectedDistrict == null) {
      _showSnack('Lütfen ilçe seçin.');
      return;
    }

    if (!_isMetro && _selectedRegion == null) {
      _showSnack('Lütfen bölge seçin.');
      return;
    }

    if (_selectedGlassType == null) {
      _showSnack('Lütfen cam tipini seçin.');
      return;
    }

    if (_selectedWindowArea == null) {
      _showSnack('Lütfen cam alanını seçin.');
      return;
    }

    if (_selectedInsulation == null) {
      _showSnack('Lütfen izolasyon durumunu seçin.');
      return;
    }

    final area = _getTotalArea();

    if (area <= 0) {
      _showSnack(
        _isDublex
            ? 'Lütfen Kat 1 ve Kat 2 için geçerli alan girin.'
            : 'Lütfen geçerli bir alan (m²) girin.',
      );
      return;
    }

    final selectedCity = _selectedCity!;
    final selectedHousingType = _selectedHousingType!;
    final selectedFacadeCount = _selectedFacadeCount!;
    final selectedFloorType = _selectedFloorType!;
    final selectedGlassType = _selectedGlassType!;
    final selectedWindowArea = _selectedWindowArea!;
    final selectedInsulation = _selectedInsulation!;

    final heatLoss = _heatLossEngine.calculate(
      HeatLossRequest(
        city: selectedCity,
        location: _locationSelectionLabel(),
        buildingType: selectedHousingType,
        floorStatus: selectedFloorType,
        facadeCount: selectedFacadeCount,
        windowType: selectedGlassType,
        windowArea: selectedWindowArea,
        insulationLevel: _insulationText(selectedInsulation),
        areaM2: area,
      ),
    );

    final rawKw = heatLoss.totalKw;
    final device = _recommendDevice(rawKw, area);

    setState(() {
      _result = HeatResult(
        area: area,
        city: selectedCity,
        locationLabel: _isMetro ? _selectedDistrict : null,
        locationSelectionLabel: _locationSelectionLabel(),
        housingType: selectedHousingType,
        facadeCount: selectedFacadeCount,
        floorType: selectedFloorType,
        insulationLevel: selectedInsulation,
        glassType: selectedGlassType,
        windowArea: selectedWindowArea,
        rawKw: rawKw,
        device: device,
      );
    });
  }

  Future<void> _openExpertSupport() async {
    final uri = Uri.parse('https://wa.me/905307847260');

    try {
      final launched = await launchUrl(uri);
      if (!launched && mounted) {
        _showSnack('WhatsApp bağlantısı açılamadı.');
      }
    } catch (_) {
      if (!mounted) return;
      _showSnack('WhatsApp bağlantısı açılamadı.');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _theme.orange,
        content: Text(message),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _theme.turquoise),
      filled: true,
      fillColor: Colors.white,
      labelStyle: TextStyle(
        color: _theme.textSoft,
        fontWeight: FontWeight.w600,
        fontSize: 14.5,
      ),
      hintStyle: TextStyle(
        color: _theme.textSoft.withOpacity(0.85),
        fontWeight: FontWeight.w500,
        fontSize: 14.5,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _theme.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _theme.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _theme.turquoise, width: 1.4),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _theme.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _theme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: _theme.shadow,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _theme.softTurquoise,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: _theme.turquoise),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: _theme.textDark,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: _theme.textSoft,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: AspectRatio(
        aspectRatio: 6.30,
        child: Image.asset(
          'assets/header/heating_header_clean.png',
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      menuMaxHeight: 320,
      value: value,
      decoration: _inputDecoration(label: label, icon: icon),
      hint: const Text(
        'Seçiniz',
        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500),
      ),
      style: TextStyle(
        color: _theme.textDark,
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
      ),
      borderRadius: BorderRadius.circular(16),
      dropdownColor: Colors.white,
      items: items
          .map(
            (e) => DropdownMenuItem<String>(
              value: e,
              child: Text(
                e,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _theme.textDark,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (v) {
        onChanged(v);
      },
    );
  }

  Widget _premiumBridgeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EDFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD9CCFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.workspace_premium, color: Color(0xFF7C4DFF), size: 22),
              SizedBox(width: 8),
              Text(
                'Premium Teyit Önerisi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF23404D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Isı kaybına göre kombi kapasitesi hesaplanmıştır. Ancak evinizdeki mevcut radyatör uzunluğu kombi seçimini etkileyebilir. Radyatör Bazlı Hesap modülü ile sonucu teyit etmeniz faydalı olur.',
            style: TextStyle(
              fontSize: 13.5,
              height: 1.4,
              color: Color(0xFF728391),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RadiatorHeatingPage(),
                  ),
                );
              },
              icon: const Icon(Icons.waterfall_chart_rounded),
              label: const Text(
                'RADYATÖR BAZLI HESABA GEÇ',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF7C4DFF),
                side: const BorderSide(color: Color(0xFF7C4DFF)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultBox({
    required String title,
    required String value,
    required Color bgColor,
    bool fullWidth = false,
  }) {
    final box = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.2,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
        ],
      ),
    );

    if (fullWidth) return box;
    return Expanded(child: box);
  }

  Widget _buildResultCard(HeatResult result) {
    final advisoryText = _advisoryCapacityText(result.rawKw, result.area);

    return _sectionCard(
      title: '4. Sonuç',
      subtitle: 'Yaklaşık ısı ihtiyacı ve kombi kapasite önerisi',
      icon: Icons.analytics_rounded,
      child: Column(
        children: [
          Row(
            children: [
              _resultBox(
                title: 'Yaklaşık Isı İhtiyacı',
                value: '${result.rawKw.toStringAsFixed(1)} kW',
                bgColor: _theme.turquoise,
              ),
              const SizedBox(width: 12),
              _resultBox(
                title: 'Önerilen Kapasite',
                value: _recommendedCapacityText(result.rawKw),
                bgColor: _theme.orange,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _resultBox(
            title: 'Tavsiye Edilen Kapasite',
            value: advisoryText,
            bgColor: _theme.textDark,
            fullWidth: true,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: result.device.isWarning
                  ? const Color(0xFFFFF2F0)
                  : const Color(0xFFF8FAFB),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: result.device.isWarning
                    ? const Color(0xFFFFCCC7)
                    : _theme.cardBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.device.title,
                  style: TextStyle(
                    color: result.device.isWarning
                        ? const Color(0xFFD4380D)
                        : _theme.textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  result.device.subtitle,
                  style: TextStyle(
                    color: _theme.textSoft,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _premiumBridgeCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard(HeatResult result) {
    final areaText =
        result.area.toStringAsFixed(result.area % 1 == 0 ? 0 : 1);

    return _sectionCard(
      title: '5. Giriş Bilgileri',
      subtitle: 'Hesapta kullanılan bilgiler',
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          _infoRow('Toplam Alan', '$areaText m²'),
          _infoRow('İl', result.city),
          _infoRow('Konum', result.locationSelectionLabel),
          _infoRow('Yapı Tipi', result.housingType),
          _infoRow('Cephe Sayısı', result.facadeCount),
          _infoRow('Kat Durumu', result.floorType),
          _infoRow('Cam Tipi', result.glassType),
          _infoRow('Cam Alanı', result.windowArea),
          _infoRow('İzolasyon', _insulationText(result.insulationLevel)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: _theme.textSoft,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: TextStyle(
              color: _theme.textDark,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _shareResult,
            icon: const Icon(Icons.share_rounded),
            label: const Text(
              'PAYLAŞ',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: _theme.turquoise,
              side: BorderSide(color: _theme.turquoise, width: 1.4),
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
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildPersistentExpertSupportButton() {
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
          backgroundColor: const Color(0xFF25D366),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _theme.softNote,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _theme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: _theme.textDark),
              const SizedBox(width: 8),
              Text(
                'Not',
                style: TextStyle(
                  color: _theme.textDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Hesaplama bölgesel veriler dikkate alınarak yaklaşık sonuç üretir. Nihai cihaz seçimi için yerinde keşif yapılması tavsiye edilir.',
            style: TextStyle(
              color: _theme.textSoft,
              fontSize: 13.2,
              height: 1.55,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String locationLabel = _isMetro ? 'İlçe' : 'Bölgesel Seçim';

    return Scaffold(
      backgroundColor: _theme.pageBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _theme.pageBg,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const SizedBox(),
        iconTheme: IconThemeData(color: _theme.textDark),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          children: [
            _buildHeroCard(),
            const SizedBox(height: 16),
            _sectionCard(
              title: '1. Alan ve Konut Bilgisi',
              subtitle: 'm², yapı tipi, cephe ve kat durumunu seçin',
              icon: Icons.home_work_rounded,
              child: Column(
                children: [
                  _dropdownField(
                    label: 'Yapı Tipi',
                    icon: Icons.apartment_rounded,
                    value: _selectedHousingType,
                    items: TermoOptions.housingTypes,
                    onChanged: (v) {
                      setState(() {
                        _selectedHousingType = v;
                        _areaController.clear();
                        _kat1Controller.clear();
                        _kat2Controller.clear();
                        _result = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  if (_isDublex) ...[
                    TextField(
                      controller: _kat1Controller,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDecoration(
                        label: 'Kat 1 Alanı (m²)',
                        icon: Icons.looks_one_rounded,
                      ),
                      onChanged: (_) => setState(() => _result = null),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _kat2Controller,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDecoration(
                        label: 'Kat 2 Alanı (m²)',
                        icon: Icons.looks_two_rounded,
                      ),
                      onChanged: (_) => setState(() => _result = null),
                    ),
                  ] else ...[
                    TextField(
                      controller: _areaController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDecoration(
                        label: 'Alan (m²)',
                        icon: Icons.square_foot_rounded,
                      ),
                      onChanged: (_) => setState(() => _result = null),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _dropdownField(
                    label: 'Cephe Sayısı',
                    icon: Icons.crop_16_9_rounded,
                    value: _selectedFacadeCount,
                    items: TermoOptions.generalFacadeOptions,
                    onChanged: (v) {
                      setState(() {
                        _selectedFacadeCount = v;
                        _result = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _dropdownField(
                    label: 'Kat Durumu',
                    icon: Icons.layers_rounded,
                    value: _selectedFloorType,
                    items: const ['Zemin Kat', 'Ara Kat', 'Çatı Katı'],
                    onChanged: (v) {
                      setState(() {
                        _selectedFloorType = v;
                        _result = null;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _sectionCard(
              title: '2. Konum Bilgisi',
              subtitle: 'Büyükşehirlerde ilçe, diğer illerde bölgesel seçim yapılır',
              icon: Icons.location_on_rounded,
              child: Column(
                children: [
                  _dropdownField(
                    label: 'İl',
                    icon: Icons.location_city_rounded,
                    value: _selectedCity,
                    items: _allCities,
                    onChanged: (v) {
                      setState(() {
                        _selectedCity = v;
                        _syncLocationDefaults();
                        _result = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _dropdownField(
                    label: locationLabel,
                    icon: _isMetro ? Icons.map_rounded : Icons.landscape_rounded,
                    value: _isMetro ? _selectedDistrict : _selectedRegion,
                    items: _selectedCity == null
                        ? const []
                        : (_isMetro ? _districts : _regionOptions),
                    onChanged: (v) {
                      setState(() {
                        if (_isMetro) {
                          _selectedDistrict = v;
                        } else {
                          _selectedRegion = v;
                        }
                        _result = null;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _sectionCard(
              title: '3. Cam ve İzolasyon',
              subtitle: 'Cam tipi, cam alanı ve izolasyon kalitesini seçin',
              icon: Icons.window_rounded,
              child: Column(
                children: [
                  _dropdownField(
                    label: 'Cam Tipi',
                    icon: Icons.window_rounded,
                    value: _selectedGlassType,
                    items: TermoOptions.windowTypes,
                    onChanged: (v) {
                      setState(() {
                        _selectedGlassType = v;
                        _result = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _dropdownField(
                    label: 'Cam Alanı',
                    icon: Icons.crop_landscape_rounded,
                    value: _selectedWindowArea,
                    items: const ['Az', 'Orta', 'Çok'],
                    onChanged: (v) {
                      setState(() {
                        _selectedWindowArea = v;
                        _result = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
      menuMaxHeight: 320,
                    value: _selectedInsulation,
                    decoration: _inputDecoration(
                      label: 'İzolasyon Durumu',
                      icon: Icons.shield_moon_rounded,
                    ),
                    hint: const Text(
                      'Seçiniz',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500),
                    ),
                    style: TextStyle(
                      color: _theme.textDark,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    dropdownColor: Colors.white,
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Zayıf')),
                      DropdownMenuItem(value: 1, child: Text('Orta')),
                      DropdownMenuItem(value: 2, child: Text('İyi')),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _selectedInsulation = v;
                        _result = null;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: _theme.turquoise,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'HESAPLA',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 14),
              _buildResultCard(_result!),
              const SizedBox(height: 14),
              _buildInfoCard(_result!),
              const SizedBox(height: 14),
              _buildActionButtons(),
            ] else ...[
              const SizedBox(height: 14),
              _buildPersistentExpertSupportButton(),
            ],
            const SizedBox(height: 14),
            _buildNoteCard(),
          ],
        ),
      ),
    );
  }
}

class _TermoTheme {
  final Color pageBg = const Color(0xffF3F7FA);
  final Color cardBg = const Color(0xffFFFFFF);
  final Color softTurquoise = const Color(0xffFFF1E7);
  final Color softNote = const Color(0xffFFF8F0);
  final Color cardBorder = const Color(0xffDCE7EE);
  final Color shadow = const Color(0xffB7CAD6).withOpacity(0.16);

  final Color turquoise = const Color(0xffFF7A1A);
  final Color orange = const Color(0xffF2A257);
  final Color lightOrange = const Color(0xffFFA24A);
  final Color textDark = const Color(0xff23404D);
  final Color textSoft = const Color(0xff728391);
}
