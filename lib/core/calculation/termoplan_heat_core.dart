class TermoPlanHeatInput {
  final String city;
  final String location;
  final String buildingType;
  final String floorStatus;
  final String facadeCount;
  final String windowType;
  final String windowArea;
  final String insulationLevel;
  final double areaM2;

  const TermoPlanHeatInput({
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

class TermoPlanHeatResult {
  final int totalWatt;
  final double totalKw;
  final double wattPerM2;
  final double baseWattPerM2;
  final double totalFactor;

  const TermoPlanHeatResult({
    required this.totalWatt,
    required this.totalKw,
    required this.wattPerM2,
    required this.baseWattPerM2,
    required this.totalFactor,
  });
}

class TermoPlanHeatCore {
  const TermoPlanHeatCore();

  TermoPlanHeatResult calculate(TermoPlanHeatInput input) {
    final base = _baseWattPerM2(input.city, input.location);

    final totalFactor =
        _buildingFactor(input.buildingType) *
        _floorFactor(input.floorStatus) *
        _facadeFactor(input.facadeCount) *
        _windowFactor(input.windowType) *
        _windowAreaFactor(input.windowArea) *
        _insulationFactor(input.insulationLevel);

    final wattPerM2 = base * totalFactor;
    final totalWatt = (input.areaM2 * wattPerM2).round();

    return TermoPlanHeatResult(
      totalWatt: totalWatt,
      totalKw: totalWatt / 1000.0,
      wattPerM2: wattPerM2,
      baseWattPerM2: base,
      totalFactor: totalFactor,
    );
  }

  double _baseWattPerM2(String city, String location) {
    final c = city.trim();
    final l = location.trim();

    const veryCold = {
      'Ağrı',
      'Ardahan',
      'Erzurum',
      'Kars',
      'Muş',
      'Bitlis',
      'Van',
      'Hakkari',
      'Bayburt',
    };

    const cold = {
      'Afyonkarahisar',
      'Ankara',
      'Bilecik',
      'Bingöl',
      'Bolu',
      'Burdur',
      'Çankırı',
      'Çorum',
      'Elazığ',
      'Erzincan',
      'Eskişehir',
      'Gümüşhane',
      'Isparta',
      'Karabük',
      'Kastamonu',
      'Kayseri',
      'Kırıkkale',
      'Kırşehir',
      'Konya',
      'Kütahya',
      'Malatya',
      'Nevşehir',
      'Niğde',
      'Sivas',
      'Tokat',
      'Tunceli',
      'Uşak',
      'Yozgat',
    };

    const mild = {
      'İstanbul',
      'Bursa',
      'Kocaeli',
      'Sakarya',
      'Tekirdağ',
      'Edirne',
      'Çanakkale',
      'Balıkesir',
      'Samsun',
      'Trabzon',
      'Ordu',
      'Giresun',
      'Rize',
      'Zonguldak',
      'Düzce',
      'Bartın',
      'Sinop',
      'Amasya',
    };

    const warm = {
      'Adana',
      'Antalya',
      'Aydın',
      'Hatay',
      'İzmir',
      'Mersin',
      'Muğla',
      'Osmaniye',
      'Şanlıurfa',
      'Diyarbakır',
      'Mardin',
      'Batman',
      'Siirt',
      'Kilis',
      'Gaziantep',
    };

    double value;

    if (veryCold.contains(c)) {
      value = 145;
    } else if (cold.contains(c)) {
      value = 110;
    } else if (mild.contains(c)) {
      value = 85;
    } else if (warm.contains(c)) {
      value = 70;
    } else {
      value = 95;
    }

    if (l == 'Yüksek Kesim') {
      value *= 1.15;
    } else if (l == 'Ara Bölge' || l == 'İç Kesim') {
      value *= 1.08;
    } else if (l == 'Kıyı Kesim') {
      value *= 0.92;
    }

    return value;
  }

  double _buildingFactor(String value) {
    switch (value.trim()) {
      case 'Müstakil':
        return 1.18;
      case 'Dubleks':
        return 1.10;
      case 'Daire':
      default:
        return 1.00;
    }
  }

  double _floorFactor(String value) {
    switch (value.trim()) {
      case 'Giriş Kat':
      case 'Giriş':
        return 1.10;
      case 'Çatı Kat':
      case 'Çatı':
        return 1.13;
      case '-Kot':
      case 'Bodrum':
        return 1.08;
      case 'Ara Kat':
      case 'Ara':
      default:
        return 1.00;
    }
  }

  double _facadeFactor(String value) {
    final count = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 2;

    switch (count) {
      case 0:
        return 0.90;
      case 1:
        return 0.96;
      case 2:
        return 1.00;
      case 3:
        return 1.08;
      case 4:
        return 1.15;
      default:
        return 1.00;
    }
  }

  double _windowFactor(String value) {
    switch (value.trim()) {
      case 'Tek Cam':
        return 1.18;
      case 'Konfor Cam':
      case 'Low-e':
      case 'Konfor (Low-e)':
        return 0.92;
      case 'Çift Cam':
      default:
        return 1.00;
    }
  }

 double _windowAreaFactor(String value) {
  switch (value.trim()) {
    case 'Az':
      return 0.94;
    case 'Çok':
    case 'Fazla':
      return 1.12;
    case 'Orta':
    case 'Normal':
    default:
      return 1.00;
  }
}

  double _insulationFactor(String value) {
    switch (value.trim()) {
      case 'Zayıf':
        return 1.25;
      case 'İyi':
        return 0.82;
      case 'Orta':
      default:
        return 1.00;
    }
  }
}