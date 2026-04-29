class TermoOptions {
  const TermoOptions._();

  // Yapı tipleri
  static const List<String> housingTypes = [
    'Daire',
    'Müstakil',
    'Dubleks',
  ];

  // Kat durumu
  static const List<String> floorTypes = [
    'Ara Kat',
    'Zemin Kat',
    'En Üst Kat',
  ];

  // Bina genel cephe
  static const List<String> generalFacadeOptions = [
    '1 Cephe',
    '2 Cephe',
    '3 Cephe',
    '4 Cephe',
  ];

  // Oda bazlı cephe
  static const List<String> roomFacadeOptions = [
    '0 Cephe',
    '1 Cephe',
    '2 Cephe',
    '3 Cephe',
    '4 Cephe',
  ];

  // Cam tipi
  static const List<String> windowTypes = [
    'Tek Cam',
    'Çift Cam',
    'Konfor Camı (Low-E)',
  ];

  // Cam alanı
  static const List<String> windowAreas = [
    'Az',
    'Orta',
    'Çok',
  ];

  // İzolasyon
  static const List<String> insulationLevels = [
    'İyi',
    'Orta',
    'Zayıf',
  ];

  // Oda isim önerileri
  static const List<String> roomNameSuggestions = [
    'Salon',
    'Oturma Odası',
    'Yatak Odası',
    'Çocuk Odası',
    'Mutfak',
    'Banyo',
    'Hol',
    'Antre',
    'Çalışma Odası',
    'Misafir Odası',
  ];
}