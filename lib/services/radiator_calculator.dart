import '../models/radiator_models.dart';

const double radiatorWattPerMeter = 1400.0;

double round1(double value) => double.parse(value.toStringAsFixed(1));

class RadiatorCalculator {
  const RadiatorCalculator();

  ExistingRadiatorSystemResult calculateExistingSystem({
    required ExistingRadiatorSystemInput input,
    required double correctedWattPerM2,
  }) {
    final totalHeatNeedW = (input.totalAreaM2 * correctedWattPerM2).round();

    final calculatedRadiatorMeters =
        round1(totalHeatNeedW / radiatorWattPerMeter);

    return ExistingRadiatorSystemResult(
      totalHeatNeedW: totalHeatNeedW,
      existingRadiatorMeters: round1(input.existingRadiatorMeters),
      calculatedRadiatorMeters: calculatedRadiatorMeters,
      boilerRecommendation: recommendBoiler(
        totalHeatNeedW: totalHeatNeedW,
        existingRadiatorMeters: input.existingRadiatorMeters,
      ),
    );
  }

  RadiatorRoomResult calculateRoom({
    required RadiatorRoomInput room,
    required double correctedWattPerM2,
  }) {
    final heatNeedW = (room.areaM2 * correctedWattPerM2).round();
    final radiatorMeters = round1(heatNeedW / radiatorWattPerMeter);

    return RadiatorRoomResult(
      roomName: room.roomName,
      areaM2: round1(room.areaM2),
      heatNeedW: heatNeedW,
      radiatorMeters: radiatorMeters,
    );
  }

  RoomBasedRadiatorSummaryResult calculateRoomBasedSummary({
    required List<RadiatorRoomInput> rooms,
    required double Function(RadiatorRoomInput room) roomCorrectedWattPerM2,
  }) {
    final List<RadiatorRoomResult> roomResults = [];

    for (final room in rooms) {
      final corrected = roomCorrectedWattPerM2(room);
      roomResults.add(
        calculateRoom(
          room: room,
          correctedWattPerM2: corrected,
        ),
      );
    }

    final int totalHeatNeedW = roomResults.fold<int>(
      0,
      (sum, item) => sum + item.heatNeedW,
    );

    final double totalRadiatorMeters = round1(
      roomResults.fold<double>(
        0.0,
        (sum, item) => sum + item.radiatorMeters,
      ),
    );

    return RoomBasedRadiatorSummaryResult(
      totalHeatNeedW: totalHeatNeedW,
      totalRadiatorMeters: totalRadiatorMeters,
      boilerRecommendation: recommendBoiler(
        totalHeatNeedW: totalHeatNeedW,
        existingRadiatorMeters: totalRadiatorMeters,
      ),
      roomResults: roomResults,
    );
  }

  String recommendBoiler({
    required int totalHeatNeedW,
    required double existingRadiatorMeters,
  }) {
    final double heatKw = totalHeatNeedW / 1000.0;
    const List<int> boilers = [24, 28, 30, 35, 42, 45];

    int selectedByHeat = boilers.last;
    for (final b in boilers) {
      if (heatKw <= b) {
        selectedByHeat = b;
        break;
      }
    }

    int minimumByRadiator = 24;
    if (existingRadiatorMeters >= 17) {
      minimumByRadiator = 35;
    } else if (existingRadiatorMeters >= 14) {
      minimumByRadiator = 30;
    } else if (existingRadiatorMeters >= 9) {
      minimumByRadiator = 28;
    }

    final int selected =
        selectedByHeat > minimumByRadiator ? selectedByHeat : minimumByRadiator;

    final double ratio = heatKw / selected;
    int? nextBoiler;

    final int index = boilers.indexOf(selected);
    if (index != -1 && index < boilers.length - 1) {
      nextBoiler = boilers[index + 1];
    }

    if (ratio >= 0.70 && nextBoiler != null) {
      return '$selected kW ( $nextBoiler kW tercih edilebilir )';
    }

    return '$selected kW';
  }

  double buildRoomCorrectedWattPerM2({
    required double baseWattPerM2,
    required String roomType,
    required String facadeType,
    required String windowArea,
  }) {
    final roomTypeFactor = _roomTypeFactor(roomType);
    final facadeFactor = _facadeFactor(facadeType);
    final windowFactor = _windowAreaFactor(windowArea);

    return baseWattPerM2 * roomTypeFactor * facadeFactor * windowFactor;
  }

  double _roomTypeFactor(String roomType) {
    switch (roomType.trim().toLowerCase()) {
      case 'salon':
      case 'oturma odası':
      case 'oturma odasi':
        return 1.00;
      case 'yatak odası':
      case 'yatak odasi':
        return 0.96;
      case 'çocuk odası':
      case 'cocuk odasi':
        return 0.98;
      case 'mutfak':
        return 0.95;
      case 'banyo':
        return 1.10;
      case 'hol':
      case 'antre':
        return 0.90;
      case 'çalışma odası':
      case 'calisma odasi':
        return 0.97;
      default:
        return 1.00;
    }
  }

  double _facadeFactor(String facadeType) {
    switch (facadeType.trim().toLowerCase()) {
      case 'iç oda':
      case 'ic oda':
        return 0.95;
      case 'ara cephe':
        return 1.00;
      case 'köşe':
      case 'kose':
      case 'köşe / dış cephe':
      case 'kose / dis cephe':
        return 1.08;
      case 'çok cepheli / geniş dışa açık':
      case 'cok cepheli / genis disa acik':
        return 1.12;
      default:
        return 1.00;
    }
  }

  double _windowAreaFactor(String windowArea) {
    switch (windowArea.trim().toLowerCase()) {
      case 'küçük':
      case 'kucuk':
      case 'küçük pencere alanı':
      case 'kucuk pencere alani':
      case 'az':
        return 0.95;
      case 'orta':
      case 'orta pencere alanı':
      case 'orta pencere alani':
      case 'normal':
        return 1.00;
      case 'geniş':
      case 'genis':
      case 'geniş pencere alanı':
      case 'genis pencere alani':
      case 'fazla':
        return 1.08;
      default:
        return 1.00;
    }
  }
}