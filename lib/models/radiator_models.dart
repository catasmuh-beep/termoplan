class ExistingRadiatorSystemInput {
  final String city;
  final String district;
  final String buildingType;
  final double totalAreaM2;
  final String floorStatus;
  final String facadeType;
  final String insulationLevel;
  final String windowQuality;
  final String windowArea;
  final double existingRadiatorMeters;

  const ExistingRadiatorSystemInput({
    required this.city,
    required this.district,
    required this.buildingType,
    required this.totalAreaM2,
    required this.floorStatus,
    required this.facadeType,
    required this.insulationLevel,
    required this.windowQuality,
    required this.windowArea,
    required this.existingRadiatorMeters,
  });

  ExistingRadiatorSystemInput copyWith({
    String? city,
    String? district,
    String? buildingType,
    double? totalAreaM2,
    String? floorStatus,
    String? facadeType,
    String? insulationLevel,
    String? windowQuality,
    String? windowArea,
    double? existingRadiatorMeters,
  }) {
    return ExistingRadiatorSystemInput(
      city: city ?? this.city,
      district: district ?? this.district,
      buildingType: buildingType ?? this.buildingType,
      totalAreaM2: totalAreaM2 ?? this.totalAreaM2,
      floorStatus: floorStatus ?? this.floorStatus,
      facadeType: facadeType ?? this.facadeType,
      insulationLevel: insulationLevel ?? this.insulationLevel,
      windowQuality: windowQuality ?? this.windowQuality,
      windowArea: windowArea ?? this.windowArea,
      existingRadiatorMeters:
          existingRadiatorMeters ?? this.existingRadiatorMeters,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'city': city,
      'district': district,
      'buildingType': buildingType,
      'totalAreaM2': totalAreaM2,
      'floorStatus': floorStatus,
      'facadeType': facadeType,
      'insulationLevel': insulationLevel,
      'windowQuality': windowQuality,
      'windowArea': windowArea,
      'existingRadiatorMeters': existingRadiatorMeters,
    };
  }

  factory ExistingRadiatorSystemInput.fromMap(Map<String, dynamic> map) {
    return ExistingRadiatorSystemInput(
      city: (map['city'] ?? '').toString(),
      district: (map['district'] ?? '').toString(),
      buildingType: (map['buildingType'] ?? '').toString(),
      totalAreaM2: _toDouble(map['totalAreaM2']),
      floorStatus: (map['floorStatus'] ?? '').toString(),
      facadeType: (map['facadeType'] ?? '').toString(),
      insulationLevel: (map['insulationLevel'] ?? '').toString(),
      windowQuality: (map['windowQuality'] ?? '').toString(),
      windowArea: (map['windowArea'] ?? '').toString(),
      existingRadiatorMeters: _toDouble(map['existingRadiatorMeters']),
    );
  }

  static ExistingRadiatorSystemInput empty() {
    return const ExistingRadiatorSystemInput(
      city: '',
      district: '',
      buildingType: '',
      totalAreaM2: 0,
      floorStatus: '',
      facadeType: '',
      insulationLevel: '',
      windowQuality: '',
      windowArea: '',
      existingRadiatorMeters: 0,
    );
  }
}

class RadiatorRoomInput {
  final String roomName;
  final String roomType;
  final double areaM2;
  final String facadeType;
  final String windowArea;

  const RadiatorRoomInput({
    required this.roomName,
    required this.roomType,
    required this.areaM2,
    required this.facadeType,
    required this.windowArea,
  });

  RadiatorRoomInput copyWith({
    String? roomName,
    String? roomType,
    double? areaM2,
    String? facadeType,
    String? windowArea,
  }) {
    return RadiatorRoomInput(
      roomName: roomName ?? this.roomName,
      roomType: roomType ?? this.roomType,
      areaM2: areaM2 ?? this.areaM2,
      facadeType: facadeType ?? this.facadeType,
      windowArea: windowArea ?? this.windowArea,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomName': roomName,
      'roomType': roomType,
      'areaM2': areaM2,
      'facadeType': facadeType,
      'windowArea': windowArea,
    };
  }

  factory RadiatorRoomInput.fromMap(Map<String, dynamic> map) {
    return RadiatorRoomInput(
      roomName: (map['roomName'] ?? '').toString(),
      roomType: (map['roomType'] ?? '').toString(),
      areaM2: _toDouble(map['areaM2']),
      facadeType: (map['facadeType'] ?? '').toString(),
      windowArea: (map['windowArea'] ?? '').toString(),
    );
  }

  static RadiatorRoomInput empty() {
    return const RadiatorRoomInput(
      roomName: '',
      roomType: '',
      areaM2: 0,
      facadeType: '',
      windowArea: '',
    );
  }
}

class ExistingRadiatorSystemResult {
  final int totalHeatNeedW;
  final double existingRadiatorMeters;
  final double calculatedRadiatorMeters;
  final String boilerRecommendation;

  const ExistingRadiatorSystemResult({
    required this.totalHeatNeedW,
    required this.existingRadiatorMeters,
    required this.calculatedRadiatorMeters,
    required this.boilerRecommendation,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalHeatNeedW': totalHeatNeedW,
      'existingRadiatorMeters': existingRadiatorMeters,
      'calculatedRadiatorMeters': calculatedRadiatorMeters,
      'boilerRecommendation': boilerRecommendation,
    };
  }

  factory ExistingRadiatorSystemResult.fromMap(Map<String, dynamic> map) {
    return ExistingRadiatorSystemResult(
      totalHeatNeedW: _toInt(map['totalHeatNeedW']),
      existingRadiatorMeters: _toDouble(map['existingRadiatorMeters']),
      calculatedRadiatorMeters: _toDouble(map['calculatedRadiatorMeters']),
      boilerRecommendation: (map['boilerRecommendation'] ?? '').toString(),
    );
  }
}

class RadiatorRoomResult {
  final String roomName;
  final double areaM2;
  final int heatNeedW;
  final double radiatorMeters;

  const RadiatorRoomResult({
    required this.roomName,
    required this.areaM2,
    required this.heatNeedW,
    required this.radiatorMeters,
  });

  Map<String, dynamic> toMap() {
    return {
      'roomName': roomName,
      'areaM2': areaM2,
      'heatNeedW': heatNeedW,
      'radiatorMeters': radiatorMeters,
    };
  }

  factory RadiatorRoomResult.fromMap(Map<String, dynamic> map) {
    return RadiatorRoomResult(
      roomName: (map['roomName'] ?? '').toString(),
      areaM2: _toDouble(map['areaM2']),
      heatNeedW: _toInt(map['heatNeedW']),
      radiatorMeters: _toDouble(map['radiatorMeters']),
    );
  }
}

class RoomBasedRadiatorSummaryResult {
  final int totalHeatNeedW;
  final double totalRadiatorMeters;
  final String boilerRecommendation;
  final List<RadiatorRoomResult> roomResults;

  const RoomBasedRadiatorSummaryResult({
    required this.totalHeatNeedW,
    required this.totalRadiatorMeters,
    required this.boilerRecommendation,
    required this.roomResults,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalHeatNeedW': totalHeatNeedW,
      'totalRadiatorMeters': totalRadiatorMeters,
      'boilerRecommendation': boilerRecommendation,
      'roomResults': roomResults.map((e) => e.toMap()).toList(),
    };
  }

  factory RoomBasedRadiatorSummaryResult.fromMap(Map<String, dynamic> map) {
    final rawRoomResults = map['roomResults'];
    final List<RadiatorRoomResult> parsedRooms =
        rawRoomResults is List
            ? rawRoomResults
                .map(
                  (e) => RadiatorRoomResult.fromMap(
                    Map<String, dynamic>.from(e as Map),
                  ),
                )
                .toList()
            : <RadiatorRoomResult>[];

    return RoomBasedRadiatorSummaryResult(
      totalHeatNeedW: _toInt(map['totalHeatNeedW']),
      totalRadiatorMeters: _toDouble(map['totalRadiatorMeters']),
      boilerRecommendation: (map['boilerRecommendation'] ?? '').toString(),
      roomResults: parsedRooms,
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString().replaceAll(',', '.')) ?? 0;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse(value.toString()) ??
      double.tryParse(value.toString().replaceAll(',', '.'))?.round() ??
      0;
}