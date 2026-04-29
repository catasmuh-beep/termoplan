import '../constants/termo_units.dart';

class TermoFormatters {
  const TermoFormatters._();

  static String formatNumber(double value, {int fractionDigits = 1}) {
    final isWhole = value % 1 == 0;
    return value.toStringAsFixed(isWhole ? 0 : fractionDigits);
  }

  static String formatKw(double value) {
    return '${formatNumber(value)} ${TermoUnits.kw}';
  }

  static String formatSquareMeters(double value) {
    return '${formatNumber(value)} ${TermoUnits.squareMeter}';
  }

  static String formatRadiatorMeters(double value) {
    return '${formatNumber(value)} ${TermoUnits.radiatorMeter}';
  }

  static String formatBtu(double value) {
    final isWhole = value % 1 == 0;
    return '${value.toStringAsFixed(isWhole ? 0 : 1)} ${TermoUnits.btu}';
  }

  static String formatInteger(int value, {String? unit}) {
    if (unit == null || unit.isEmpty) return '$value';
    return '$value $unit';
  }
}