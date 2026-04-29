class DeviceRecommendation {
  final String title;
  final String subtitle;
  final bool isWarning;

  const DeviceRecommendation({
    required this.title,
    required this.subtitle,
    required this.isWarning,
  });
}

class HeatResult {
  final double area;
  final String city;
  final String? locationLabel;
  final String locationSelectionLabel;
  final String housingType;
  final String facadeCount;
  final String floorType;
  final int insulationLevel;
  final String glassType;
  final String windowArea;
  final double rawKw;
  final DeviceRecommendation device;

  const HeatResult({
    required this.area,
    required this.city,
    required this.locationLabel,
    required this.locationSelectionLabel,
    required this.housingType,
    required this.facadeCount,
    required this.floorType,
    required this.insulationLevel,
    required this.glassType,
    required this.windowArea,
    required this.rawKw,
    required this.device,
  });
}

class UnderfloorRoom {
  final String name;
  final double area;

  const UnderfloorRoom({
    required this.name,
    required this.area,
  });
}

class UnderfloorResult {
  final double totalArea;
  final double totalKw;
  final DeviceRecommendation device;

  const UnderfloorResult({
    required this.totalArea,
    required this.totalKw,
    required this.device,
  });
}

class CityData {
  final String city;
  final bool isMetropolitan;
  final bool hasCoastalZone;
  final List<String> districts;
  final double baseCoefficient;

  const CityData({
    required this.city,
    required this.isMetropolitan,
    required this.hasCoastalZone,
    required this.districts,
    required this.baseCoefficient,
  });
}