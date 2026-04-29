import 'package:flutter/material.dart';

class TermoUI {
  const TermoUI._();

  // Renkler
  static const Color pageBg = Color(0xFFF3F7FA);
  static const Color cardBg = Colors.white;
  static const Color cardBorder = Color(0xFFDCE7EE);
  static const Color shadow = Color(0x11000000);

  static const Color orange = Color(0xFFF2A257);
  static const Color softOrange = Color(0xFFFFF4E8);
  static const Color softOrange2 = Color(0xFFFFE7CC);

  static const Color turquoise = Color(0xFF27B8B0);
  static const Color softTurquoise = Color(0xFFE8F7F5);

  static const Color iceBlue = Color(0xFF8CCEF0);
  static const Color premiumPurple = Color(0xFF7C4DFF);
  static const Color premiumBg = Color(0xFFF2EDFF);

  static const Color freeGreen = Color(0xFF18A957);
  static const Color freeBg = Color(0xFFEAF8EF);

  static const Color textDark = Color(0xFF23404D);
  static const Color textSoft = Color(0xFF728391);

  static const Color success = Color(0xFF18A957);
  static const Color warning = Color(0xFFF2A257);
  static const Color danger = Color(0xFFE25757);

  // Font boyutları
  static const double appBarTitleSize = 19;
  static const double sectionTitleSize = 17;
  static const double sectionSubtitleSize = 13.5;
  static const double cardTitleSize = 16.5;
  static const double fieldLabelSize = 14.5;
  static const double buttonTextSize = 15;
  static const double resultValueSize = 26;
  static const double resultLabelSize = 14;
  static const double smallNoteSize = 12.8;

  // Radius
  static const double pageRadius = 24;
  static const double cardRadius = 24;
  static const double innerRadius = 18;
  static const double fieldRadius = 16;
  static const double buttonRadius = 16;
  static const double chipRadius = 14;

  // Padding
  static const double pageHorizontal = 16;
  static const double cardPadding = 16;
  static const double sectionGap = 14;
  static const double itemGap = 12;
  static const double smallGap = 8;

  // Buton yükseklikleri
  static const double primaryButtonHeight = 54;
  static const double secondaryButtonHeight = 52;

  // Font weight
  static const FontWeight heavy = FontWeight.w800;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight medium = FontWeight.w500;

  // Ortak gölge
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: shadow,
      blurRadius: 18,
      offset: Offset(0, 8),
    ),
  ];

  static InputDecoration inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: turquoise),
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(
        color: textSoft,
        fontWeight: semiBold,
        fontSize: fieldLabelSize,
      ),
      hintStyle: const TextStyle(
        color: textSoft,
        fontWeight: medium,
        fontSize: fieldLabelSize,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadius),
        borderSide: const BorderSide(color: cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadius),
        borderSide: const BorderSide(color: cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadius),
        borderSide: const BorderSide(color: turquoise, width: 1.4),
      ),
    );
  }

  static BoxDecoration sectionCardDecoration() {
    return BoxDecoration(
      color: cardBg,
      borderRadius: BorderRadius.circular(cardRadius),
      border: Border.all(color: cardBorder),
      boxShadow: cardShadow,
    );
  }

  static ButtonStyle primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: turquoise,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(buttonRadius),
      ),
    );
  }

  static ButtonStyle secondaryOutlinedButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: turquoise,
      side: const BorderSide(color: turquoise, width: 1.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(buttonRadius),
      ),
    );
  }
}