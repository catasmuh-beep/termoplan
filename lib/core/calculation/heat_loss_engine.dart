import 'package:flutter/foundation.dart';

@immutable
class HeatLossRequest {
  final String city;
  final String location;
  final String buildingType;
  final String floorStatus;
  final String facadeCount;
  final String windowType;
  final String windowArea;
  final String insulationLevel;
  final double areaM2;

  const HeatLossRequest({
    required this.city,
    required this.location,
    required this.buildingType,
    required this.floorStatus,
    required this.facadeCount,
    required this.windowType,
    required this.windowArea,
    required this.insulationLevel,
    required this.areaM2,
  });
}

@immutable
class HeatLossResult {
  final double wattPerM2;
  final double totalWatts;
  final double totalKw;

  const HeatLossResult({
    required this.wattPerM2,
    required this.totalWatts,
    required this.totalKw,
  });
}

class HeatLossEngine {
  const HeatLossEngine();

  static const List<String> allCities = [
    'Adana',
    'Adıyaman',
    'Afyonkarahisar',
    'Ağrı',
    'Amasya',
    'Ankara',
    'Antalya',
    'Artvin',
    'Aydın',
    'Balıkesir',
    'Bilecik',
    'Bingöl',
    'Bitlis',
    'Bolu',
    'Burdur',
    'Bursa',
    'Çanakkale',
    'Çankırı',
    'Çorum',
    'Denizli',
    'Diyarbakır',
    'Edirne',
    'Elazığ',
    'Erzincan',
    'Erzurum',
    'Eskişehir',
    'Gaziantep',
    'Giresun',
    'Gümüşhane',
    'Hakkari',
    'Hatay',
    'Isparta',
    'Mersin',
    'İstanbul',
    'İzmir',
    'Kars',
    'Kastamonu',
    'Kayseri',
    'Kırklareli',
    'Kırşehir',
    'Kocaeli',
    'Konya',
    'Kütahya',
    'Malatya',
    'Manisa',
    'Kahramanmaraş',
    'Mardin',
    'Muğla',
    'Muş',
    'Nevşehir',
    'Niğde',
    'Ordu',
    'Rize',
    'Sakarya',
    'Samsun',
    'Siirt',
    'Sinop',
    'Sivas',
    'Tekirdağ',
    'Tokat',
    'Trabzon',
    'Tunceli',
    'Şanlıurfa',
    'Uşak',
    'Van',
    'Yozgat',
    'Zonguldak',
    'Aksaray',
    'Bayburt',
    'Karaman',
    'Kırıkkale',
    'Batman',
    'Şırnak',
    'Bartın',
    'Ardahan',
    'Iğdır',
    'Yalova',
    'Karabük',
    'Kilis',
    'Osmaniye',
    'Düzce',
  ];

  static const Map<String, List<String>> metroDistricts = {
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

  static const Set<String> coastalCities = {
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

  static bool isMetropolitan(String city) => metroDistricts.containsKey(city);

  static List<String> locationOptionsForCity(String city) {
    if (metroDistricts.containsKey(city)) {
      return metroDistricts[city]!;
    }

    if (coastalCities.contains(city)) {
      return const ['Kıyı', 'İç Kesim', 'Yüksek Kesim'];
    }

    return const ['Merkez', 'Ara Bölge', 'Yüksek Kesim'];
  }

  HeatLossResult calculate(HeatLossRequest request) {
    final wattPerM2 = _baseWattPerM2(request.buildingType) *
        _cityClimateFactor(request.city) *
        (isMetropolitan(request.city)
            ? _districtAdjustment(request.city, request.location)
            : _regionFactor(request.city, request.location)) *
        _insulationFactor(request.insulationLevel) *
        _windowTypeFactor(request.windowType) *
        _windowAreaFactor(request.windowArea) *
        _facadeCountFactor(request.facadeCount) *
        _floorStatusFactor(request.floorStatus);

    final totalWatts = request.areaM2 * wattPerM2;
    final totalKw = totalWatts / 1000.0;

    return HeatLossResult(
      wattPerM2: wattPerM2,
      totalWatts: totalWatts,
      totalKw: totalKw,
    );
  }

  double _baseWattPerM2(String value) {
    switch (value) {
      case 'Müstakil':
      case 'Müstakil Ev':
        return 62;
      case 'Dublex':
      case 'Dubleks':
        return 58;
      case 'Daire':
      default:
        return 52;
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

  double _districtAdjustment(String city, String location) {
    if (!isMetropolitan(city)) return 1.0;

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

    if (slightlyCoolDistricts.contains(location)) return 1.03;
    if (coolerDistricts.contains(location)) return 1.06;
    return 1.0;
  }

  double _regionFactor(String city, String location) {
    if (coastalCities.contains(city)) {
      switch (location) {
        case 'Kıyı':
        case 'Kıyı Kesim':
          return 0.93;
        case 'İç Kesim':
        case 'Ara Bölge':
          return 1.02;
        case 'Yüksek Kesim':
          return 1.12;
        default:
          return 1.00;
      }
    }

    switch (location) {
      case 'Merkez':
        return 1.00;
      case 'Ara Bölge':
        return 1.05;
      case 'Yüksek Kesim':
        return 1.12;
      default:
        return 1.00;
    }
  }

  double _floorStatusFactor(String value) {
    switch (value) {
      case 'Zemin Kat':
      case 'Giriş Kat':
        return 1.08;
      case 'Çatı Katı':
      case 'Çatı Altı':
        return 1.10;
      case 'Ara Kat':
      default:
        return 1.00;
    }
  }

  double _facadeCountFactor(String value) {
    switch (value) {
      case '1 Cephe':
        return 0.96;
      case '2 Cephe':
        return 1.00;
      case '3 Cephe':
        return 1.08;
      case '4 Cephe':
        return 1.14;
      default:
        return 1.00;
      }
  }

  double _windowTypeFactor(String value) {
    switch (value) {
      case 'Tek Cam':
        return 1.12;
      case 'Konfor Cam':
      case 'Konfor Low-E Cam':
        return 0.93;
      case 'Çift Cam':
      default:
        return 1.00;
    }
  }

  double _windowAreaFactor(String value) {
    switch (value) {
      case 'Az':
        return 0.95;
      case 'Fazla':
        return 1.10;
      case 'Normal':
      default:
        return 1.00;
    }
  }

  double _insulationFactor(String value) {
    switch (value) {
      case 'İyi':
        return 0.92;
      case 'Zayıf':
        return 1.10;
      case 'Orta':
      default:
        return 1.00;
    }
  }
}