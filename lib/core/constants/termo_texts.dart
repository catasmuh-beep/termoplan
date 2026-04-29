class TermoTexts {
  const TermoTexts._();

  // Genel
  static const String appName = 'TermoPlan';
  static const String select = 'Seçiniz';

  // Butonlar
  static const String calculate = 'HESAPLA';
  static const String roomBasedCalculate = 'ODA BAZLI HESAPLA';
  static const String pdfReport = 'PDF RAPOR';
  static const String share = 'PAYLAŞ';
  static const String expertOpinion = 'UZMAN GÖRÜŞÜ AL';
  static const String expertSupport = 'UZMAN DESTEĞİ AL';
  static const String addRoom = 'Oda Ekle';

  // Kart başlıkları
  static const String calculationSummary = 'Hesap Özeti';
  static const String resultEvaluation = 'Sonuç ve Değerlendirme';
  static const String recommendedDevice = 'Önerilen Cihaz';
  static const String technicalInfo = 'Teknik Bilgiler';

  // Sonuç dili
  static const String heatLossByInputs = 'Girilen verilere göre ısı kaybı';
  static const String radiatorSystemEffect =
      'Mevcut / hesaplanan radyatör miktarına göre sistem etkisi';
  static const String effectiveCapacity = 'Esas alınan kapasite';
  static const String recommendedCapacity = 'Önerilen cihaz kapasitesi';
  static const String advisoryCapacity = 'Tavsiye edilen cihaz kapasitesi';

  static const String coolingNeed = 'Hesaplanan soğutma ihtiyacı';
  static const String collectorNeed = 'Toplam kolektör ihtiyacı';
  static const String totalHeatLoss = 'Toplam ısı kaybı';

  // Bilgi / not
  static const String radiatorAverageWarning =
      'Radyatör kapasitesi ortalama 1 m/tül = 1700 W kabulü ile hesaplanmıştır. Marka, model ve işletme şartlarına göre gerçek değer değişebilir.';

  static const String whatsappError = 'WhatsApp bağlantısı açılamadı.';

  // Validasyon
  static const String chooseHousingType = 'Yapı tipi seçiniz.';
  static const String chooseFacadeCount = 'Cephe sayısı seçiniz.';
  static const String chooseFloorStatus = 'Kat durumu seçiniz.';
  static const String chooseCity = 'İl seçiniz.';
  static const String chooseLocation = 'İlçe / Bölge seçiniz.';
  static const String chooseWindowType = 'Cam tipi seçiniz.';
  static const String chooseWindowArea = 'Cam alanı seçiniz.';
  static const String chooseInsulation = 'İzolasyon durumu seçiniz.';
  static const String enterValidArea = 'Lütfen geçerli bir alan girin.';
  static const String enterValidDuplexArea =
      'Lütfen Kat 1 ve Kat 2 için geçerli alan girin.';
  static const String enterValidRadiatorMeters =
      'Lütfen geçerli bir radyatör metrajı girin.';

  // Bölüm başlıkları
  static const String sectionAreaAndHousing = '1. Alan ve Konut Bilgisi';
  static const String sectionLocation = '2. Konum Bilgisi';
  static const String sectionGlassAndInsulation = '3. Cam ve İzolasyon';
  static const String sectionRadiatorInfo = '4. Radyatör Bilgisi';
}