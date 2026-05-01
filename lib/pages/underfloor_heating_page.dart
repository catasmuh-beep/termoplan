import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../core/pdf/engine/termo_pdf_engine_impl.dart';
import '../core/pdf/models/pdf_document_data.dart';
import '../core/constants/termo_location_data.dart';

class UnderfloorHeatingPage extends StatefulWidget {
  const UnderfloorHeatingPage({super.key});

  @override
  State<UnderfloorHeatingPage> createState() => _UnderfloorHeatingPageState();
}

class _UnderfloorHeatingPageState extends State<UnderfloorHeatingPage> {
  final _singleAreaController = TextEditingController();
  final _duplexArea1Controller = TextEditingController();
  final _duplexArea2Controller = TextEditingController();

  BuildingType? _buildingType;
  FloorStatus? _floorStatus;
  int? _facadeCount;

  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedRegion;

  WindowType? _windowType;
  WindowAreaType? _windowAreaType;
  InsulationType? _insulationType;

  bool _showResults = false;

  final List<_RoomInput> _rooms = [];

  static const double _singleAreaFallbackPipeCoefficient = 6.0;
  static const double _duplexAreaPipeCoefficient = 6.2;

  static const List<int> _capacitySteps = [24, 28, 30, 35, 42, 45];

  final List<String> _allCities = TermoLocationData.allCities;

  final Map<String, List<String>> _metroDistricts = const {
  'Adana': [
    'Aladağ',
    'Ceyhan',
    'Çukurova',
    'Feke',
    'İmamoğlu',
    'Karaisalı',
    'Karataş',
    'Kozan',
    'Pozantı',
    'Saimbeyli',
    'Sarıçam',
    'Seyhan',
    'Tufanbeyli',
    'Yumurtalık',
    'Yüreğir',
  ],
  'Ankara': [
    'Akyurt',
    'Altındağ',
    'Ayaş',
    'Bala',
    'Beypazarı',
    'Çamlıdere',
    'Çankaya',
    'Çubuk',
    'Elmadağ',
    'Etimesgut',
    'Evren',
    'Gölbaşı',
    'Güdül',
    'Haymana',
    'Kalecik',
    'Kahramankazan',
    'Keçiören',
    'Kızılcahamam',
    'Mamak',
    'Nallıhan',
    'Polatlı',
    'Pursaklar',
    'Sincan',
    'Şereflikoçhisar',
    'Yenimahalle',
  ],
  'Antalya': [
    'Akseki',
    'Aksu',
    'Alanya',
    'Demre',
    'Döşemealtı',
    'Elmalı',
    'Finike',
    'Gazipaşa',
    'Gündoğmuş',
    'İbradı',
    'Kaş',
    'Kemer',
    'Kepez',
    'Konyaaltı',
    'Korkuteli',
    'Kumluca',
    'Manavgat',
    'Muratpaşa',
    'Serik',
  ],
  'Aydın': [
    'Bozdoğan',
    'Buharkent',
    'Çine',
    'Didim',
    'Efeler',
    'Germencik',
    'İncirliova',
    'Karacasu',
    'Karpuzlu',
    'Koçarlı',
    'Köşk',
    'Kuşadası',
    'Kuyucak',
    'Nazilli',
    'Söke',
    'Sultanhisar',
    'Yenipazar',
  ],
  'Balıkesir': [
    'Altıeylül',
    'Ayvalık',
    'Balya',
    'Bandırma',
    'Bigadiç',
    'Burhaniye',
    'Dursunbey',
    'Edremit',
    'Erdek',
    'Gömeç',
    'Gönen',
    'Havran',
    'İvrindi',
    'Karesi',
    'Kepsut',
    'Manyas',
    'Marmara',
    'Savaştepe',
    'Sındırgı',
    'Susurluk',
  ],
  'Bursa': [
    'Büyükorhan',
    'Gemlik',
    'Gürsu',
    'Harmancık',
    'İnegöl',
    'İznik',
    'Karacabey',
    'Keles',
    'Kestel',
    'Mudanya',
    'Mustafakemalpaşa',
    'Nilüfer',
    'Orhaneli',
    'Orhangazi',
    'Osmangazi',
    'Yenişehir',
    'Yıldırım',
  ],
  'Denizli': [
    'Acıpayam',
    'Babadağ',
    'Baklan',
    'Bekilli',
    'Beyağaç',
    'Bozkurt',
    'Buldan',
    'Çal',
    'Çameli',
    'Çardak',
    'Çivril',
    'Güney',
    'Honaz',
    'Kale',
    'Merkezefendi',
    'Pamukkale',
    'Sarayköy',
    'Serinhisar',
    'Tavas',
  ],
  'Diyarbakır': [
    'Bağlar',
    'Bismil',
    'Çermik',
    'Çınar',
    'Çüngüş',
    'Dicle',
    'Eğil',
    'Ergani',
    'Hani',
    'Hazro',
    'Kayapınar',
    'Kocaköy',
    'Kulp',
    'Lice',
    'Silvan',
    'Sur',
    'Yenişehir',
  ],
  'Erzurum': [
    'Aşkale',
    'Aziziye',
    'Çat',
    'Hınıs',
    'Horasan',
    'İspir',
    'Karaçoban',
    'Karayazı',
    'Köprüköy',
    'Narman',
    'Oltu',
    'Olur',
    'Palandöken',
    'Pasinler',
    'Pazaryolu',
    'Şenkaya',
    'Tekman',
    'Tortum',
    'Uzundere',
    'Yakutiye',
  ],
  'Eskişehir': [
    'Alpu',
    'Beylikova',
    'Çifteler',
    'Günyüzü',
    'Han',
    'İnönü',
    'Mahmudiye',
    'Mihalgazi',
    'Mihalıççık',
    'Odunpazarı',
    'Sarıcakaya',
    'Seyitgazi',
    'Sivrihisar',
    'Tepebaşı',
  ],
  'Gaziantep': [
    'Araban',
    'İslahiye',
    'Karkamış',
    'Nizip',
    'Nurdağı',
    'Oğuzeli',
    'Şahinbey',
    'Şehitkamil',
    'Yavuzeli',
  ],
  'Hatay': [
    'Altınözü',
    'Antakya',
    'Arsuz',
    'Belen',
    'Defne',
    'Dörtyol',
    'Erzin',
    'Hassa',
    'İskenderun',
    'Kırıkhan',
    'Kumlu',
    'Payas',
    'Reyhanlı',
    'Samandağ',
    'Yayladağı',
  ],
  'İstanbul': [
    'Adalar',
    'Arnavutköy',
    'Ataşehir',
    'Avcılar',
    'Bağcılar',
    'Bahçelievler',
    'Bakırköy',
    'Başakşehir',
    'Bayrampaşa',
    'Beşiktaş',
    'Beykoz',
    'Beylikdüzü',
    'Beyoğlu',
    'Büyükçekmece',
    'Çatalca',
    'Çekmeköy',
    'Esenler',
    'Esenyurt',
    'Eyüpsultan',
    'Fatih',
    'Gaziosmanpaşa',
    'Güngören',
    'Kadıköy',
    'Kağıthane',
    'Kartal',
    'Küçükçekmece',
    'Maltepe',
    'Pendik',
    'Sancaktepe',
    'Sarıyer',
    'Silivri',
    'Sultanbeyli',
    'Sultangazi',
    'Şile',
    'Şişli',
    'Tuzla',
    'Ümraniye',
    'Üsküdar',
    'Zeytinburnu',
  ],
};

  final Set<String> _coastalCities = const {
    'Adana',
    'Antalya',
    'Artvin',
    'Aydın',
    'Balıkesir',
    'Bartın',
    'Çanakkale',
    'Edirne',
    'Düzce',
    'Giresun',
    'Hatay',
    'İstanbul',
    'İzmir',
    'Kırklareli',
    'Kocaeli',
    'Mersin',
    'Muğla',
    'Ordu',
    'Rize',
    'Sakarya',
    'Samsun',
    'Sinop',
    'Tekirdağ',
    'Trabzon',
    'Yalova',
    'Zonguldak',
  };


  @override
  void dispose() {
    _singleAreaController.dispose();
    _duplexArea1Controller.dispose();
    _duplexArea2Controller.dispose();

    for (final room in _rooms) {
      room.dispose();
    }
    super.dispose();
  }

  bool get _isDubleks => _buildingType == BuildingType.dubleks;
  bool get _isMetro => _selectedCity != null && _metroDistricts.containsKey(_selectedCity);
  bool get _isCoastal => _selectedCity != null && _coastalCities.contains(_selectedCity);

  List<String> get _districts => _selectedCity == null ? const [] : (_metroDistricts[_selectedCity] ?? []);

  List<String> get _regionalOptions {
    if (_isCoastal) {
      return const ['Kıyı Kesim', 'İç Kesim', 'Yüksek Kesim'];
    }
    return const ['Merkez', 'Ara Bölge', 'Yüksek Kesim'];
  }

  double get _mainArea {
    if (_isDubleks) {
      return _parseDouble(_duplexArea1Controller.text) +
          _parseDouble(_duplexArea2Controller.text);
    }
    return _parseDouble(_singleAreaController.text);
  }

  double get _roomsAreaTotal {
    if (_isDubleks) return 0;
    return _rooms.fold(0.0, (sum, room) => sum + room.areaValue);
  }

  double get _totalArea {
    if (_isDubleks) return _mainArea;
    if (_roomsAreaTotal > 0) return _roomsAreaTotal;
    return _mainArea;
  }

  double get _buildingFactor {
    switch (_buildingType) {
      case null:
        return 1.00;
      case BuildingType.daire:
        return 1.00;
      case BuildingType.mustakil:
        return 1.12;
      case BuildingType.dubleks:
        return 1.08;
    }
  }

  double get _floorFactor {
    switch (_floorStatus) {
      case null:
        return 1.00;
      case FloorStatus.girisKat:
        return 1.08;
      case FloorStatus.araKat:
        return 1.00;
      case FloorStatus.catiKat:
        return 1.10;
    }
  }

  double get _facadeFactor {
    switch (_facadeCount) {
      case null:
        return 1.00;
      case 1:
        return 0.96;
      case 2:
        return 1.00;
      case 3:
        return 1.07;
      case 4:
        return 1.12;
      default:
        return 1.00;
    }
  }

  double _cityClimateFactor(String city) {
    const warmCities = {
      'Adana',
      'Antalya',
      'Aydın',
      'Balıkesir',
      'Çanakkale',
      'Hatay',
      'İzmir',
      'Mersin',
      'Muğla',
      'Ordu',
      'Rize',
      'Samsun',
      'Trabzon',
      'Tekirdağ',
      'Yalova',
    };

    const coldCities = {
      'Ağrı',
      'Ardahan',
      'Artvin',
      'Bayburt',
      'Bingöl',
      'Bitlis',
      'Erzincan',
      'Erzurum',
      'Gümüşhane',
      'Hakkari',
      'Kars',
      'Muş',
      'Sivas',
      'Tunceli',
      'Van',
    };

    const coolCities = {
      'Afyonkarahisar',
      'Ankara',
      'Bilecik',
      'Bolu',
      'Burdur',
      'Çankırı',
      'Çorum',
      'Elazığ',
      'Eskişehir',
      'Isparta',
      'Karabük',
      'Kastamonu',
      'Kayseri',
      'Kırıkkale',
      'Kırşehir',
      'Kütahya',
      'Malatya',
      'Nevşehir',
      'Niğde',
      'Tokat',
      'Uşak',
      'Yozgat',
    };

    if (warmCities.contains(city)) return 0.94;
    if (coldCities.contains(city)) return 1.18;
    if (coolCities.contains(city)) return 1.08;
    return 1.00;
  }

  double _districtAdjustment() {
    if (!_isMetro || _selectedDistrict == null) return 1.0;

    const slightlyCoolDistricts = {
      'Çatalca',
      'Şile',
      'Beykoz',
      'Sarıyer',
      'Silivri',
      'Arnavutköy',
      'Kahramankazan',
      'Gölbaşı',
      'Beypazarı',
      'Çeşme',
      'Urla',
      'Foça',
      'Seferihisar',
      'Döşemealtı',
      'Konyaaltı',
      'Nilüfer',
      'Mudanya',
      'Kartepe',
      'Sapanca',
    };

    const coolerDistricts = {
      'Bağcılar',
      'Esenyurt',
      'Avcılar',
      'Küçükçekmece',
      'Başakşehir',
      'Sultangazi',
      'Keçiören',
      'Mamak',
      'Etimesgut',
      'Sincan',
      'Altındağ',
      'Bornova',
      'Buca',
      'Karabağlar',
      'Osmangazi',
      'Yıldırım',
    };

    if (slightlyCoolDistricts.contains(_selectedDistrict)) return 1.03;
    if (coolerDistricts.contains(_selectedDistrict)) return 1.06;
    return 1.0;
  }

  double _regionFactor() {
    if (_isCoastal) {
      switch (_selectedRegion) {
        case 'Kıyı Kesim':
          return 0.93;
        case 'İç Kesim':
          return 1.02;
        case 'Yüksek Kesim':
          return 1.12;
      }
    } else {
      switch (_selectedRegion) {
        case 'Merkez':
          return 1.00;
        case 'Ara Bölge':
          return 1.05;
        case 'Yüksek Kesim':
          return 1.12;
      }
    }
    return 1.00;
  }

  double get _climateFactor {
    if (_selectedCity == null) return 1.00;
    return _cityClimateFactor(_selectedCity!) *
        (_isMetro ? _districtAdjustment() : _regionFactor());
  }

  double get _windowFactor {
    switch (_windowType) {
      case null:
        return 1.00;
      case WindowType.tekCam:
        return 1.10;
      case WindowType.ciftCam:
        return 1.00;
      case WindowType.konforCam:
        return 0.95;
    }
  }

  double get _windowAreaFactor {
    switch (_windowAreaType) {
      case null:
        return 1.00;
      case WindowAreaType.az:
        return 0.96;
      case WindowAreaType.normal:
        return 1.00;
      case WindowAreaType.fazla:
        return 1.08;
    }
  }

  double get _insulationFactor {
    switch (_insulationType) {
      case null:
        return 1.00;
      case InsulationType.zayif:
        return 1.10;
      case InsulationType.orta:
        return 1.00;
      case InsulationType.iyi:
        return 0.92;
    }
  }

  double get _globalAdjustmentFactor {
    return _buildingFactor *
        _floorFactor *
        _facadeFactor *
        _climateFactor *
        _windowFactor *
        _windowAreaFactor *
        _insulationFactor;
  }

  double get _basePipeLength {
    if (_isDubleks) {
      return _mainArea * _duplexAreaPipeCoefficient;
    }

    final roomsBase = _rooms.fold(0.0, (sum, room) => sum + room.basePipeLength);
    if (roomsBase > 0) return roomsBase;

    return _mainArea * _singleAreaFallbackPipeCoefficient;
  }

  double get _adjustedPipeLength {
    return _basePipeLength * _globalAdjustmentFactor;
  }

  double get _duplexFloor1Area => _parseDouble(_duplexArea1Controller.text);
  double get _duplexFloor2Area => _parseDouble(_duplexArea2Controller.text);

  double get _duplexFloor1AdjustedPipeLength =>
      _duplexFloor1Area * _duplexAreaPipeCoefficient * _globalAdjustmentFactor;

  double get _duplexFloor2AdjustedPipeLength =>
      _duplexFloor2Area * _duplexAreaPipeCoefficient * _globalAdjustmentFactor;

  int _collectorCountForPipe(double pipeLength) {
    if (pipeLength <= 0) return 0;
    return max(1, (pipeLength / 80).ceil());
  }

  int get _kat1CollectorCount =>
      _collectorCountForPipe(_duplexFloor1AdjustedPipeLength);

  int get _kat2CollectorCount =>
      _collectorCountForPipe(_duplexFloor2AdjustedPipeLength);

  int get _roomBasedCollectorCount {
    if (_isDubleks) {
      return _kat1CollectorCount + _kat2CollectorCount;
    }

    return _rooms
        .where((room) => room.areaValue > 0)
        .map((room) => room.buildResult(_globalAdjustmentFactor).loopCount)
        .fold(0, (sum, loopCount) => sum + loopCount);
  }

  bool get _needsSplitCollectorGroup => _roomBasedCollectorCount > 15;

  String get _collectorDesignWarning {
    if (!_needsSplitCollectorGroup) return '';

    return 'Yerden ısıtma kollektörlerinde piyasada yaygın uygulama 12-15 ağız aralığındadır. '
        'Tesisatı bu duruma göre dizayn ediniz ve 2 ayrı kollektör grubu kullanınız.';
  }

  int? _nextCapacity(int current) {
    final index = _capacitySteps.indexOf(current);
    if (index == -1 || index >= _capacitySteps.length - 1) return null;
    return _capacitySteps[index + 1];
  }

  int? get _recommendedCapacityKw {
    final power = _estimatedHeatingPowerKw;
    if (power <= 0 || power > 45) return null;

    for (final step in _capacitySteps) {
      if (power <= step) {
        return step;
      }
    }
    return null;
  }

  int? get _advisoryCapacityKw {
    final power = _estimatedHeatingPowerKw;
    final recommended = _recommendedCapacityKw;

    if (power <= 0 || power > 45 || recommended == null) return null;

    final threshold = recommended * 0.70;
    if (power > threshold) {
      return _nextCapacity(recommended);
    }
    return null;
  }

  double get _estimatedHeatingPowerKw {
    if (_roomBasedCollectorCount <= 0) return 0;
    return _roomBasedCollectorCount * 1.5;
  }

  String get _calculatedCapacityText =>
      '${_formatNumber(_estimatedHeatingPowerKw)} kW';

  String get _recommendedCapacityText {
    final power = _estimatedHeatingPowerKw;
    if (power <= 0) return '-';
    if (power > 45) {
      return '45 kW üzeri';
    }

    final recommended = _recommendedCapacityKw;
    if (recommended == null) return '-';
    return '$recommended kW';
  }

  String get _advisoryCapacityText {
    final power = _estimatedHeatingPowerKw;
    if (power <= 0 || power > 45) return '-';

    final advisory = _advisoryCapacityKw;
    if (advisory == null) return '-';
    return '$advisory kW';
  }

  String get _pdfLocationText => _selectedDistrict ?? _selectedRegion ?? '-';

  String get _boilerSuggestion {
    final power = _estimatedHeatingPowerKw;

    if (power <= 0) return 'Önce alan bilgisi giriniz';
    if (power > 45) {
      return '45 kW üzeri - Duvar Tipi Yoğuşmalı Kazan Önerilir';
    }

    final recommended = _recommendedCapacityKw;
    if (recommended == null) return 'Önce alan bilgisi giriniz';

    return '$recommended kW Yoğuşmalı Kombi';
  }

  String get _upperCapacityAdviceText {
    final power = _estimatedHeatingPowerKw;

    if (power <= 0) return '';
    if (power > 45) {
      return '45 kW üzeri uygulamalarda duvar tipi yoğuşmalı kazan önerilir ve uzman desteği alınmalıdır.';
    }

    final advisory = _advisoryCapacityKw;
    if (advisory == null) return '';

    return 'Tavsiye edilen üst kapasite: $advisory kW';
  }

  String get _summaryText {
    if (_estimatedHeatingPowerKw <= 0) {
      return _isDubleks
          ? 'Kat 1 ve Kat 2 alan bilgileri girildiğinde sonuç oluşur.'
          : 'Mahaller ve alan bilgileri girildiğinde sonuç oluşur.';
    }

    if (_estimatedHeatingPowerKw > 45) {
      return '45 kW üzeri uygulamalarda duvar tipi yoğuşmalı kazan önerilir ve uzman desteği alınmalıdır.';
    }

    if (_advisoryCapacityKw != null) {
      return 'Hesaplanan kapasite barem mantığına göre değerlendirilmiştir. $_upperCapacityAdviceText';
    }

    return 'Hesaplanan kapasiteye göre önerilen kapasite yeterlidir.';
  }

  String get _underfloorSummaryText {
    final totalPipe = _formatNumber(_adjustedPipeLength);
    final capacity = _calculatedCapacityText;

    if (_isDubleks) {
      if (_estimatedHeatingPowerKw > 45) {
        return 'Sonuç: $totalPipe mt boru, Kat 1 = $_kat1CollectorCount ağız kollektör, Kat 2 = $_kat2CollectorCount ağız kollektör ve teknik hesaplamalara göre $capacity kapasite hesaplanmıştır. 45 kW üzeri uygulamalarda duvar tipi yoğuşmalı kazan önerilir.';
      }

      final advisoryText = _advisoryCapacityKw != null
          ? ' Tavsiye edilen üst kapasite: ${_advisoryCapacityKw} kW.'
          : '';

      return 'Sonuç: $totalPipe mt boru, Kat 1 = $_kat1CollectorCount ağız kollektör, Kat 2 = $_kat2CollectorCount ağız kollektör ve teknik hesaplamalara göre $capacity kapasite hesaplanmıştır. Önerilen kapasite: ${_recommendedCapacityText}.$advisoryText';
    }

    if (_estimatedHeatingPowerKw > 45) {
      return 'Sonuç: $totalPipe mt boru, $_roomBasedCollectorCount ağız kollektör ve teknik hesaplamalara göre $capacity kapasite hesaplanmıştır. 45 kW üzeri uygulamalarda duvar tipi yoğuşmalı kazan önerilir.';
    }

    final advisoryText = _advisoryCapacityKw != null
        ? ' Tavsiye edilen üst kapasite: ${_advisoryCapacityKw} kW.'
        : '';

    return 'Sonuç: $totalPipe mt boru, $_roomBasedCollectorCount ağız kollektör ve teknik hesaplamalara göre $capacity kapasite hesaplanmıştır. Önerilen kapasite: ${_recommendedCapacityText}.$advisoryText';
  }

  List<PdfResultItem> _buildRoomDistributionItems() {
    if (_isDubleks) {
      final kat1HeatLoss = (_duplexFloor1Area * 65 * _globalAdjustmentFactor).round();
      final kat2HeatLoss = (_duplexFloor2Area * 65 * _globalAdjustmentFactor).round();

      return [
        PdfResultItem(
          label: 'Kat 1',
          value:
              '${_formatNumber(_duplexFloor1Area)} m² | $kat1HeatLoss W | $_kat1CollectorCount hat',
        ),
        PdfResultItem(
          label: 'Kat 2',
          value:
              '${_formatNumber(_duplexFloor2Area)} m² | $kat2HeatLoss W | $_kat2CollectorCount hat',
        ),
      ];
    }

    return _rooms
        .where((room) => room.areaValue > 0)
        .map((room) {
          final result = room.buildResult(_globalAdjustmentFactor);
          final heatLossWatt =
              (room.areaValue * 65 * _globalAdjustmentFactor).round();

          return PdfResultItem(
            label: room.type?.label ?? 'Seçilmemiş Mahal',
            value:
                '${_formatNumber(room.areaValue)} m² | $heatLossWatt W | ${result.loopCount} hat',
          );
        })
        .toList();
  }

  PdfDocumentData _buildUnderfloorPdfData() {
    final bool isDubleks = _isDubleks;

    final List<PdfResultItem> summaryHighlights = [
      PdfResultItem(
        label: 'Toplam Alan',
        value: _formatNumber(_totalArea),
        unit: 'm²',
      ),
      PdfResultItem(
        label: 'Toplam Boru',
        value: _formatNumber(_adjustedPipeLength),
        unit: 'mt',
      ),
      if (!isDubleks)
        PdfResultItem(
          label: 'Kollektör',
          value: '$_roomBasedCollectorCount Ağız',
        ),
      if (isDubleks)
        PdfResultItem(
          label: 'Kat 1 Kollektör',
          value: '$_kat1CollectorCount Ağız',
        ),
      if (isDubleks)
        PdfResultItem(
          label: 'Kat 2 Kollektör',
          value: '$_kat2CollectorCount Ağız',
        ),
      PdfResultItem(
        label: 'Hesaplanan Kapasite',
        value: _formatNumber(_estimatedHeatingPowerKw),
        unit: 'kW',
      ),
    ];

    final List<PdfResultItem> technicalItems = [
      PdfResultItem(
        label: 'Toplam Boru Metrajı',
        value: _formatNumber(_adjustedPipeLength),
        unit: 'mt',
      ),
      if (!isDubleks)
        PdfResultItem(
          label: 'Toplam Kollektör',
          value: '$_roomBasedCollectorCount Ağız',
        ),
      if (isDubleks)
        PdfResultItem(
          label: 'Kat 1 Kollektör',
          value: '$_kat1CollectorCount Ağız',
        ),
      if (isDubleks)
        PdfResultItem(
          label: 'Kat 2 Kollektör',
          value: '$_kat2CollectorCount Ağız',
        ),
      PdfResultItem(
        label: 'Hesaplanan Kapasite',
        value: _formatNumber(_estimatedHeatingPowerKw),
        unit: 'kW',
      ),
    ];

    final List<String> notes = [
      'Devreler 80 metreyi aşmayacak şekilde projelendirilmelidir.',
      'Nihai cihaz seçimi uygulama koşullarına göre uzman değerlendirmesi ile netleştirilmelidir.',
      if (_needsSplitCollectorGroup) _collectorDesignWarning,
    ];

    return PdfDocumentData(
      type: PdfReportType.underfloor,
      title: 'TermoPlan PDF Raporu',
      subtitle: 'Yerden ısıtma hesaplama sonuçlarına göre oluşturulmuş rapor.',
      meta: PdfProjectMeta(
        createdAt: DateTime.now(),
        isPremium: true,
        appName: 'TermoPlan',
        reportCode: 'TP-${DateTime.now().millisecondsSinceEpoch}',
      ),
      summary: PdfSummaryData(
        mainResult: _underfloorSummaryText,
        recommendedDevice: '',
        highlights: summaryHighlights,
      ),
      customer: PdfCustomerData(
        name: '',
        phone: '',
        city: _selectedCity ?? '-',
        district: _pdfLocationText,
        projectName: null,
      ),
      sections: [
        PdfSectionData(
          title: 'Yerden Isıtma Giriş Bilgileri',
          items: [
            PdfResultItem(
              label: 'Net Alan',
              value: _formatNumber(_totalArea),
              unit: 'm²',
            ),
            PdfResultItem(
              label: 'Konut Tipi',
              value: _buildingType?.label ?? '-',
            ),
            PdfResultItem(
              label: 'Cephe Durumu',
              value: '$_facadeCount Cephe',
            ),
            PdfResultItem(
              label: 'İzolasyon Durumu',
              value: _insulationType?.label ?? '-',
            ),
            PdfResultItem(
              label: 'Cam Durumu',
              value: _windowType?.label ?? '-',
            ),
            PdfResultItem(
              label: 'Kat Durumu',
              value: _floorStatus?.label ?? '-',
            ),
          ],
        ),
        PdfSectionData(
          title: _isDubleks
              ? 'Kat Bazlı Yerden Isıtma Dağılımı'
              : 'Oda Bazlı Yerden Isıtma Dağılımı',
          items: _buildRoomDistributionItems(),
        ),
        PdfSectionData(
          title: 'Teknik Bilgiler',
          items: technicalItems,
        ),
      ],
      notes: notes,
    );
  }

  Future<void> _sharePdfReport() async {
    FocusScope.of(context).unfocus();

    final error = _validateInputs();
    if (error != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    try {
      final engine = TermoPdfEngineImpl();
      final bytes = await engine.generate(_buildUnderfloorPdfData());
      final file = XFile.fromData(
        Uint8List.fromList(bytes),
        mimeType: 'application/pdf',
        name: 'termo_plan_yerden_isitma_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      final box = context.findRenderObject() as RenderBox;

await Share.shareXFiles(
  [file],
  text: 'TermoPlan ile hazırladığım yerden ısıtma hesabı raporunu paylaşıyorum.',
  sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF paylaşılırken bir hata oluştu: $e'),
        ),
      );
    }
  }

  Future<void> _shareCalculationSummary() async {
    await _sharePdfReport();
  }

  Future<void> _openExpertSupport() async {
    FocusScope.of(context).unfocus();
    final uri = Uri.parse('https://wa.me/905307847260');

    try {
      final launched = await launchUrl(uri);
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

  void _syncLocationSelections() {
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
      if (_selectedRegion != null && !_regionalOptions.contains(_selectedRegion)) {
        _selectedRegion = null;
      }
    }
  }

 // 2) underfloor_heating_page.dart
// dubleks değilse oda zorunlu olsun
String? _validateInputs() {
  if (_buildingType == null) return 'Lütfen yapı tipini seçin.';

  if (_isDubleks) {
    if (_parseDouble(_duplexArea1Controller.text) <= 0) {
      return 'Lütfen Kat 1 alanını girin.';
    }
    if (_parseDouble(_duplexArea2Controller.text) <= 0) {
      return 'Lütfen Kat 2 alanını girin.';
    }
  } else {
    if (_rooms.isEmpty) {
      return 'Lütfen en az bir oda ekleyin.';
    }

    for (int i = 0; i < _rooms.length; i++) {
      final room = _rooms[i];
      if (room.type == null) {
        return '${i + 1}. oda için mahal tipini seçin.';
      }
      if (room.areaValue <= 0) {
        return '${i + 1}. oda için alan bilgisini girin.';
      }
    }
  }

  if (_floorStatus == null) return 'Lütfen kat durumunu seçin.';
  if (_facadeCount == null) return 'Lütfen cephe sayısını seçin.';
  if (_selectedCity == null) return 'Lütfen il seçin.';
  if (_isMetro && _selectedDistrict == null) return 'Lütfen ilçe seçin.';
  if (!_isMetro && _selectedRegion == null) return 'Lütfen ilçe/bölge seçin.';
  if (_windowType == null) return 'Lütfen cam tipini seçin.';
  if (_windowAreaType == null) return 'Lütfen cam alanını seçin.';
  if (_insulationType == null) return 'Lütfen izolasyon durumunu seçin.';

  return null;
}

  void _calculateResults() {
    FocusScope.of(context).unfocus();
    final error = _validateInputs();
    if (error != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      setState(() {
        _showResults = false;
      });
      return;
    }

    setState(() {
      _showResults = true;
    });
  }

  void _addRoom() {
    setState(() {
      _rooms.add(_RoomInput());
    });
  }

  void _removeRoom(int index) {
    if (_rooms.length == 1) return;
    setState(() {
      _rooms[index].dispose();
      _rooms.removeAt(index);
    });
  }

  double _parseDouble(String value) {
    return double.tryParse(value.replaceAll(',', '.').trim()) ?? 0;
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = _TermoTheme();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.pageBg,
      appBar: AppBar(
        toolbarHeight: 64,
        elevation: 0,
        backgroundColor: theme.pageBg,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const SizedBox.shrink(),
        iconTheme: IconThemeData(color: theme.textDark),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          children: [
            _buildHeroCard(theme),
            const SizedBox(height: 14),
            _buildModuleIntroCard(theme),
            const SizedBox(height: 16),
            _buildSectionCard(
              theme: theme,
              icon: Icons.home_rounded,
              title: '1. Alan ve Konut Bilgisi',
              subtitle: 'm², yapı tipi, kat durumu ve cephe sayısını seçin',
              child: Column(
                children: [
                  DropdownButtonFormField<BuildingType>(
      menuMaxHeight: 320,
                    hint: const Text('Seçiniz'),
                    value: _buildingType,
                    decoration: _inputDecoration(
                      theme: theme,
                      label: 'Yapı Tipi',
                      icon: Icons.apartment_rounded,
                    ),
                    items: BuildingType.values.map((type) {
                      return DropdownMenuItem<BuildingType>(
                        value: type,
                        child: Text(type.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _buildingType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  if (_isDubleks) ...[
                    TextFormField(
                      controller: _duplexArea1Controller,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDecoration(
                        theme: theme,
                        label: 'Kat 1 Alanı (m²)',
                        icon: Icons.looks_one_rounded,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _duplexArea2Controller,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDecoration(
                        theme: theme,
                        label: 'Kat 2 Alanı (m²)',
                        icon: Icons.looks_two_rounded,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ] else ...[
                    TextFormField(
                      controller: _singleAreaController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDecoration(
                        theme: theme,
                        label: 'Alan (m²)',
                        icon: Icons.square_foot_rounded,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                  const SizedBox(height: 12),
                  DropdownButtonFormField<FloorStatus>(
      menuMaxHeight: 320,
                    value: _floorStatus,
                    decoration: _inputDecoration(
                      theme: theme,
                      label: 'Kat Durumu',
                      icon: Icons.layers_rounded,
                    ),
                    items: [
                      const DropdownMenuItem<FloorStatus>(
                        value: null,
                        child: Text('Seçiniz'),
                      ),
                      ...FloorStatus.values.map((type) {
                        return DropdownMenuItem<FloorStatus>(
                          value: type,
                          child: Text(type.label),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _floorStatus = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
      menuMaxHeight: 320,
                    value: _facadeCount,
                    decoration: _inputDecoration(
                      theme: theme,
                      label: 'Cephe Sayısı',
                      icon: Icons.crop_square_rounded,
                    ),
                    items: const [
                      DropdownMenuItem<int>(
                        value: null,
                        child: Text('Seçiniz'),
                      ),
                      DropdownMenuItem<int>(value: 1, child: Text('1 Cephe')),
                      DropdownMenuItem<int>(value: 2, child: Text('2 Cephe')),
                      DropdownMenuItem<int>(value: 3, child: Text('3 Cephe')),
                      DropdownMenuItem<int>(value: 4, child: Text('4 Cephe')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _facadeCount = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _buildSectionCard(
              theme: theme,
              icon: Icons.location_on_rounded,
              title: '2. Konum Bilgisi',
              subtitle:
                  'Büyükşehirlerde ilçe, diğer illerde bölgesel seçim yapılır',
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
      menuMaxHeight: 320,
                    value: _selectedCity,
                    decoration: _inputDecoration(
                      theme: theme,
                      label: 'İl',
                      icon: Icons.location_city_rounded,
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Seçiniz'),
                      ),
                      ..._allCities.map((city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCity = value;
                        _syncLocationSelections();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  if (_isMetro)
                    DropdownButtonFormField<String>(
      menuMaxHeight: 320,
                      value: _selectedDistrict,
                      decoration: _inputDecoration(
                        theme: theme,
                        label: 'İlçe',
                        icon: Icons.map_rounded,
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Seçiniz'),
                        ),
                        ..._districts.map((district) {
                          return DropdownMenuItem<String>(
                            value: district,
                            child: Text(district),
                          );
                        }),
                      ],
                      onChanged: _selectedCity == null ? null : (value) {
                        setState(() {
                          _selectedDistrict = value;
                        });
                      },
                    )
                  else
                    DropdownButtonFormField<String>(
      menuMaxHeight: 320,
                      value: _selectedRegion,
                      decoration: _inputDecoration(
                        theme: theme,
                        label: 'Bölge',
                        icon: Icons.landscape_rounded,
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Seçiniz'),
                        ),
                        ..._regionalOptions.map((region) {
                          return DropdownMenuItem<String>(
                            value: region,
                            child: Text(region),
                          );
                        }),
                      ],
                      onChanged: _selectedCity == null ? null : (value) {
                        setState(() {
                          _selectedRegion = value;
                        });
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _buildSectionCard(
              theme: theme,
              icon: Icons.window_rounded,
              title: '3. Cam ve İzolasyon',
              subtitle: 'Cam tipi, cam alanı ve izolasyon kalitesini seçin',
              child: Column(
                children: [
                  DropdownButtonFormField<WindowType>(
      menuMaxHeight: 320,
                    value: _windowType,
                    decoration: _inputDecoration(
                      theme: theme,
                      label: 'Cam Tipi',
                      icon: Icons.window_rounded,
                    ),
                    items: [
                      const DropdownMenuItem<WindowType>(
                        value: null,
                        child: Text('Seçiniz'),
                      ),
                      ...WindowType.values.map((item) {
                        return DropdownMenuItem<WindowType>(
                          value: item,
                          child: Text(item.label),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _windowType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<WindowAreaType>(
      menuMaxHeight: 320,
                    value: _windowAreaType,
                    decoration: _inputDecoration(
                      theme: theme,
                      label: 'Cam Alanı',
                      icon: Icons.crop_landscape_rounded,
                    ),
                    items: [
                      const DropdownMenuItem<WindowAreaType>(
                        value: null,
                        child: Text('Seçiniz'),
                      ),
                      ...WindowAreaType.values.map((item) {
                        return DropdownMenuItem<WindowAreaType>(
                          value: item,
                          child: Text(item.label),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _windowAreaType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<InsulationType>(
      menuMaxHeight: 320,
                    value: _insulationType,
                    decoration: _inputDecoration(
                      theme: theme,
                      label: 'İzolasyon Durumu',
                      icon: Icons.shield_moon_rounded,
                    ),
                    items: [
                      const DropdownMenuItem<InsulationType>(
                        value: null,
                        child: Text('Seçiniz'),
                      ),
                      ...InsulationType.values.map((item) {
                        return DropdownMenuItem<InsulationType>(
                          value: item,
                          child: Text(item.label),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _insulationType = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _buildSummaryTopCards(theme),
            if (!_isDubleks) ...[
              const SizedBox(height: 14),
              _buildRoomsSection(theme),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _calculateResults,
                icon: const Icon(Icons.calculate_rounded),
                label: const Text(
                  'Hesapla',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.turquoise,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            if (_showResults) ...[
              const SizedBox(height: 14),
              _buildResultSection(theme),
            ],
            if (!_showResults) ...[
              const SizedBox(height: 14),
              _buildExpertSupportButton(theme),
            ],
            const SizedBox(height: 14),
            _buildNoteCard(theme),
          ],
        ),
      ),
    ));
  }

  Widget _buildHeroCard(_TermoTheme theme) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: AspectRatio(
      aspectRatio: 6.30,
      child: Image.asset(
        'assets/header/underfloor_header_clean.png',
        fit: BoxFit.cover,
        width: double.infinity,
      ),
    ),
  );
}

  Widget _buildModuleIntroCard(_TermoTheme theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: theme.shadow,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: theme.softOrange,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.heat_pump_rounded,
              color: theme.orangeText,
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yerden Isıtma Hesabı',
                  style: TextStyle(
                    color: theme.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Boru metrajı, kollektör ağız sayısı ve cihaz kapasitesini tek ekranda profesyonel şekilde hesaplar.',
                  style: TextStyle(
                    color: theme.textSoft,
                    fontSize: 13.3,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required _TermoTheme theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: theme.shadow,
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
                  color: theme.softTurquoise,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: theme.turquoise),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: theme.textDark,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: theme.textSoft,
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

  Widget _buildSummaryTopCards(_TermoTheme theme) {
    return Row(
      children: [
        Expanded(
          child: _InfoMiniCard(
            title: 'Toplam Alan',
            value: '${_formatNumber(_totalArea)} m²',
            icon: Icons.square_foot_rounded,
            color: theme.orange,
            bgColor: theme.softOrange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoMiniCard(
            title: 'Düzeltme Katsayısı',
            value: _formatNumber(_globalAdjustmentFactor),
            icon: Icons.tune_rounded,
            color: theme.turquoise,
            bgColor: theme.softTurquoise,
          ),
        ),
      ],
    );
  }

  Widget _buildRoomsSection(_TermoTheme theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: theme.shadow,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.meeting_room_rounded, color: theme.textDark),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '4. Mahaller / Odalar',
                  style: TextStyle(
                    color: theme.textDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_rooms.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.softSection,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.cardBorder),
              ),
              child: Text(
                'Henüz oda eklenmedi. Devam etmek için aşağıdaki "Oda Ekle" butonunu kullanın.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.textSoft,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
            )
          else
            ...List.generate(_rooms.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildRoomCard(index, _rooms[index], theme),
              );
            }),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _addRoom,
              icon: const Icon(Icons.add),
              label: const Text(
                'Oda Ekle',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.orange,
                side: BorderSide(color: theme.orange, width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(int index, _RoomInput room, _TermoTheme theme) {
    final roomResult = room.buildResult(_globalAdjustmentFactor);
    final heatLossWatt = (room.areaValue * 65 * _globalAdjustmentFactor).round();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: theme.softSection,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<RoomType>(
      menuMaxHeight: 320,
                  value: room.type,
                  decoration: _inputDecoration(
                    theme: theme,
                    label: 'Mahal Tipi',
                    icon: Icons.home_work_rounded,
                  ),
                  items: [
                    const DropdownMenuItem<RoomType>(
                      value: null,
                      child: Text('Seçiniz'),
                    ),
                    ...RoomType.values.map((type) {
                      return DropdownMenuItem<RoomType>(
                        value: type,
                        child: Text(type.label),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      room.type = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () => _removeRoom(index),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.softRed,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.delete_outline_rounded, color: theme.red),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: room.areaController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDecoration(
              theme: theme,
              label: 'Alan (m²)',
              icon: Icons.straighten_rounded,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SoftMetricBox(
                  title: 'Isı Kaybı',
                  value: '$heatLossWatt W',
                  bgColor: theme.softOrange,
                  titleColor: theme.orangeText,
                  valueColor: theme.orangeText,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SoftMetricBox(
                  title: 'Hat / Devre',
                  value: '${roomResult.loopCount} ağız',
                  bgColor: theme.softTurquoise,
                  titleColor: theme.turquoiseText,
                  valueColor: theme.turquoiseText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SoftMetricBox(
                  title: 'Baz Katsayı',
                  value: room.type == null ? '-' : '${room.type!.coefficient.toStringAsFixed(1)} m/m²',
                  bgColor: theme.softBlue,
                  titleColor: theme.blueText,
                  valueColor: theme.blueText,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SoftMetricBox(
                  title: 'Açıklama',
                  value: room.type?.shortNote ?? '-',
                  bgColor: theme.softPetrol,
                  titleColor: theme.textDark,
                  valueColor: theme.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection(_TermoTheme theme) {
    final isHighCapacity = _estimatedHeatingPowerKw > 45;
    final mainCapacityValue = isHighCapacity
        ? '45 kW üzeri'
        : _recommendedCapacityText;
    final mainCapacitySubtitle = isHighCapacity
        ? 'Duvar tipi yoğuşmalı kazan önerilir'
        : 'Ana cihaz kapasitesi';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: theme.shadow,
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.orange,
                  theme.turquoise,
                ],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.20),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Sonuç Hazır',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _underfloorSummaryText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.6,
                    height: 1.45,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ResultMetricTile(
                  title: 'Toplam Boru',
                  value: '${_formatNumber(_adjustedPipeLength)} m',
                  icon: Icons.timeline_rounded,
                  bgColor: theme.softTurquoise,
                  color: theme.turquoiseText,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ResultMetricTile(
                  title: _isDubleks ? 'Toplam Ağız' : 'Kollektör',
                  value: '$_roomBasedCollectorCount ağız',
                  icon: Icons.account_tree_rounded,
                  bgColor: theme.softOrange,
                  color: theme.orangeText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ResultMetricTile(
                  title: 'Hesaplanan',
                  value: _calculatedCapacityText,
                  icon: Icons.bolt_rounded,
                  bgColor: theme.softBlue,
                  color: theme.blueText,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ResultMetricTile(
                  title: isHighCapacity ? 'Sistem Tipi' : 'Önerilen',
                  value: mainCapacityValue,
                  icon: Icons.local_fire_department_rounded,
                  bgColor: theme.softRedStrong,
                  color: theme.redText,
                ),
              ),
            ],
          ),
          if (_isDubleks) ...[
            const SizedBox(height: 12),
            _MainResultCard(
              title: 'Kat 1 / Kat 2 Kollektör Dağılımı',
              value: 'Kat 1: $_kat1CollectorCount ağız  •  Kat 2: $_kat2CollectorCount ağız',
              subtitle: 'Her kat kendi boru metrajına göre hesaplanmıştır',
              color: theme.orangeText,
              bgColor: theme.softOrange,
              icon: Icons.layers_rounded,
            ),
          ],
          const SizedBox(height: 12),
          _MainResultCard(
            title: isHighCapacity ? 'Cihaz Değerlendirmesi' : 'Önerilen Cihaz',
            value: isHighCapacity
                ? 'Duvar Tipi Yoğuşmalı Kazan'
                : '$mainCapacityValue Yoğuşmalı Kombi',
            subtitle: mainCapacitySubtitle,
            color: theme.redText,
            bgColor: theme.softRedStrong,
            icon: Icons.thermostat_rounded,
          ),
          if (_advisoryCapacityKw != null) ...[
            const SizedBox(height: 12),
            _MainResultCard(
              title: 'Tavsiye Edilen Üst Kapasite',
              value: _advisoryCapacityText,
              subtitle: '%70 barem eşiği geçildiği için üst kademe opsiyonu',
              color: theme.redText,
              bgColor: theme.softRedStrong,
              icon: Icons.trending_up_rounded,
            ),
          ],
          if (_needsSplitCollectorGroup) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6E9),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: theme.orange.withOpacity(0.55)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: theme.orangeText),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _collectorDesignWarning,
                      style: TextStyle(
                        color: theme.orangeText,
                        fontWeight: FontWeight.w800,
                        height: 1.45,
                        fontSize: 13.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.softPetrol,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              _summaryText,
              style: TextStyle(
                color: theme.textDark,
                fontWeight: FontWeight.w700,
                height: 1.45,
                fontSize: 13.8,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sharePdfReport,
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: const Text(
                'PDF RAPOR',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.orange,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _shareCalculationSummary,
              icon: const Icon(Icons.share_rounded),
              label: const Text(
                'PAYLAŞ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.turquoise,
                side: BorderSide(color: theme.turquoise, width: 1.4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openExpertSupport,
              icon: const Icon(Icons.support_agent_rounded),
              label: const Text(
                'UZMAN GÖRÜŞÜ AL',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildExpertSupportButton(_TermoTheme theme) {
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

  Widget _buildNoteCard(_TermoTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.softNote,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: theme.textDark),
              const SizedBox(width: 8),
              Text(
                'Önemli Not',
                style: TextStyle(
                  color: theme.textDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Bu hesap ön keşif ve teklif hazırlığı için tahmini sonuç üretir. Nihai boru dağılımı, net kullanılabilir alan, sabit mobilya bölgeleri, dönüşler ve mahal planına göre değişebilir.',
            style: TextStyle(
              color: theme.textSoft,
              fontSize: 14.1,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Devreler 80 metreyi aşmayacak şekilde projelendirilmelidir.',
            style: TextStyle(
              color: theme.orangeText,
              fontSize: 14.1,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (_needsSplitCollectorGroup) ...[
            const SizedBox(height: 8),
            Text(
              _collectorDesignWarning,
              style: TextStyle(
                color: theme.orangeText,
                fontSize: 14.1,
                fontWeight: FontWeight.w800,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required _TermoTheme theme,
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: theme.turquoise),
      filled: true,
      fillColor: Colors.white,
      labelStyle: TextStyle(
        color: theme.textSoft,
        fontWeight: FontWeight.w600,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.turquoise, width: 1.4),
      ),
    );
  }
}

enum BuildingType {
  daire('Daire'),
  mustakil('Müstakil'),
  dubleks('Dubleks');

  final String label;
  const BuildingType(this.label);
}

enum FloorStatus {
  girisKat('Zemin Kat'),
  araKat('Ara Kat'),
  catiKat('Çatı Katı');

  final String label;
  const FloorStatus(this.label);
}

enum WindowType {
  tekCam('Tek Cam'),
  ciftCam('Çift Cam'),
  konforCam('Konfor Camı (Low-E)');

  final String label;
  const WindowType(this.label);
}

enum WindowAreaType {
  az('Az'),
  normal('Orta'),
  fazla('Çok');

  final String label;
  const WindowAreaType(this.label);
}

enum InsulationType {
  zayif('Zayıf'),
  orta('Orta'),
  iyi('İyi');

  final String label;
  const InsulationType(this.label);
}

enum RoomType {
  salon(
    label: 'Salon / Oturma Odası',
    coefficient: 6.5,
    shortNote: 'Standart yaşam alanı',
  ),
  yatakOdasi(
    label: 'Yatak Odası',
    coefficient: 6.0,
    shortNote: 'Dengeli kullanım',
  ),
  cocukOdasi(
    label: 'Çocuk Odası',
    coefficient: 6.0,
    shortNote: 'Konfor odaklı',
  ),
  mutfak(
    label: 'Mutfak',
    coefficient: 5.5,
    shortNote: 'Net alan değişebilir',
  ),
  banyo(
    label: 'Banyo / WC',
    coefficient: 8.0,
    shortNote: 'Daha sık hatve',
  ),
  hol(
    label: 'Hol / Koridor / Antre',
    coefficient: 5.0,
    shortNote: 'Geçiş alanı',
  );

  final String label;
  final double coefficient;
  final String shortNote;

  const RoomType({
    required this.label,
    required this.coefficient,
    required this.shortNote,
  });
}

class _RoomInput {
  RoomType? type;
  final TextEditingController areaController;

  _RoomInput({
    this.type,
    String initialArea = '',
  }) : areaController = TextEditingController(text: initialArea);

  double get areaValue {
    final raw = areaController.text.replaceAll(',', '.').trim();
    return double.tryParse(raw) ?? 0;
  }

  double get basePipeLength {
    return areaValue * (type?.coefficient ?? 0);
  }

  _RoomResult buildResult(double factor) {
    final adjusted = basePipeLength * factor;
    final loops = adjusted <= 0 ? 0 : max(1, (adjusted / 80).ceil());

    return _RoomResult(
      adjustedPipeLength: adjusted,
      loopCount: loops,
    );
  }

  void dispose() {
    areaController.dispose();
  }
}

class _RoomResult {
  final double adjustedPipeLength;
  final int loopCount;

  _RoomResult({
    required this.adjustedPipeLength,
    required this.loopCount,
  });
}

class _TermoTheme {
  final Color pageBg = const Color(0xffF3F7FA);
  final Color cardBg = const Color(0xffFFFFFF);
  final Color softSection = const Color(0xffFAFCFD);
  final Color cardBorder = const Color(0xffDCE7EE);
  final Color shadow = const Color(0xffB7CAD6).withOpacity(0.16);

  final Color turquoise = const Color(0xffFF7A1A);
  final Color lightBlue = const Color(0xffFFA24A);
  final Color orange = const Color(0xffF2A257);

  final Color textDark = const Color(0xff23404D);
  final Color textSoft = const Color(0xff728391);

  final Color orangeText = const Color(0xffEC9850);
  final Color turquoiseText = const Color(0xffE87517);
  final Color blueText = const Color(0xff55AEDD);
  final Color redText = const Color(0xffC62828);

  final Color softOrange = const Color(0xffFDF4EC);
  final Color softTurquoise = const Color(0xffFFF1E7);
  final Color softBlue = const Color(0xffEDF7FD);
  final Color softPetrol = const Color(0xffEEF5F7);
  final Color softNote = const Color(0xffF7FBFD);
  final Color softRedStrong = const Color(0xffFDECEC);

  final Color red = const Color(0xffE96B63);
  final Color softRed = const Color(0xffFDEEEE);
}

class _InfoMiniCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _InfoMiniCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffDCE7EE)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xff728391),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xff23404D),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftMetricBox extends StatelessWidget {
  final String title;
  final String value;
  final Color bgColor;
  final Color titleColor;
  final Color valueColor;

  const _SoftMetricBox({
    required this.title,
    required this.value,
    required this.bgColor,
    required this.titleColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultMetricTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color bgColor;
  final Color color;

  const _ResultMetricTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.bgColor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 132),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 13, 12, 13),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.75),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xff728391),
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xff23404D),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          ],
        ),
      ),
    );
  }
}

class _MainResultCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final IconData icon;

  const _MainResultCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.72),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xff728391),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xff23404D),
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xff728391),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}