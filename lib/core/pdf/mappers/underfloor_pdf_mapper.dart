import '../models/pdf_document_data.dart';

class RoomUFH {
  final String name;
  final double area;
  final int floor; // 1 veya 2

  const RoomUFH({
    required this.name,
    required this.area,
    this.floor = 1,
  });
}

class UnderfloorPdfInput {
  final String customerName;
  final String customerPhone;
  final String city;
  final String district;

  final String housingType; // Daire / Müstakil / Dublex
  final String facadeCount; // 1 Cephe / 2 Cephe / 3 Cephe / 4 Cephe
  final String insulationStatus;
  final String glassStatus;
  final String floorStatus;
  final String floorCovering; // Seramik / Parke vs.

  final double totalArea;
  final double recommendedKw;
  final List<RoomUFH> rooms;
  final List<String> notes;

  const UnderfloorPdfInput({
    required this.customerName,
    required this.customerPhone,
    required this.city,
    required this.district,
    required this.housingType,
    required this.facadeCount,
    required this.insulationStatus,
    required this.glassStatus,
    required this.floorStatus,
    required this.floorCovering,
    required this.totalArea,
    required this.recommendedKw,
    required this.rooms,
    this.notes = const [],
  });
}

class RoomUFHResult {
  final String name;
  final double area;
  final int floor;
  final String spacingText; // 10 cm / 15 cm / 20 cm
  final double coefficient; // 10.0 / 6.6 / 4.9
  final double pipeLength;
  final int circuits;
  final double circuitLength;

  const RoomUFHResult({
    required this.name,
    required this.area,
    required this.floor,
    required this.spacingText,
    required this.coefficient,
    required this.pipeLength,
    required this.circuits,
    required this.circuitLength,
  });
}

class UnderfloorProjectResult {
  final List<RoomUFHResult> roomResults;
  final double totalPipeLength;
  final int totalCircuits;
  final int floor1Circuits;
  final int floor2Circuits;
  final bool isDublex;

  const UnderfloorProjectResult({
    required this.roomResults,
    required this.totalPipeLength,
    required this.totalCircuits,
    required this.floor1Circuits,
    required this.floor2Circuits,
    required this.isDublex,
  });
}

class UnderfloorPdfMapper {
  static const double maxCircuitLength = 80.0;

  static PdfDocumentData buildPdfData(UnderfloorPdfInput input) {
    final result = calculateProject(
      rooms: input.rooms,
      housingType: input.housingType,
    );

    final summaryText = buildSummaryText(
      totalPipeLength: result.totalPipeLength,
      floor1Circuits: result.floor1Circuits,
      floor2Circuits: result.floor2Circuits,
      totalCircuits: result.totalCircuits,
      recommendedKw: input.recommendedKw,
      isDublex: result.isDublex,
    );

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
        mainResult: summaryText,
        recommendedDevice: 'Yerden Isıtma Sistemi',
        recommendedCapacity: '${input.recommendedKw.toStringAsFixed(0)} kW',
        highlights: [
          PdfResultItem(
            label: 'Toplam Yerden Isıtma Alanı',
            value: _formatNumber(input.totalArea),
            unit: 'm²',
          ),
          PdfResultItem(
            label: 'Toplam Boru Metrajı',
            value: _formatNumber(result.totalPipeLength),
            unit: 'mt',
          ),
          PdfResultItem(
            label: 'Toplam Hat Sayısı',
            value: result.totalCircuits.toString(),
          ),
          if (!result.isDublex)
            PdfResultItem(
              label: 'Kollektör',
              value: '${result.totalCircuits} Ağız',
            ),
          if (result.isDublex)
            PdfResultItem(
              label: 'Kat 1 Kollektör',
              value: '${result.floor1Circuits} Ağız',
            ),
          if (result.isDublex)
            PdfResultItem(
              label: 'Kat 2 Kollektör',
              value: '${result.floor2Circuits} Ağız',
            ),
          PdfResultItem(
            label: 'Önerilen Cihaz',
            value: '${input.recommendedKw.toStringAsFixed(0)} kW',
          ),
        ],
      ),
      customer: PdfCustomerData(
        name: input.customerName,
        phone: input.customerPhone,
        city: input.city,
        district: input.district,
        projectName: null,
      ),
      sections: [
        PdfSectionData(
          title: 'Yerden Isıtma Giriş Bilgileri',
          items: [
            PdfResultItem(
              label: 'Net Alan',
              value: _formatNumber(input.totalArea),
              unit: 'm²',
            ),
            PdfResultItem(
              label: 'Konut Tipi',
              value: input.housingType,
            ),
            PdfResultItem(
              label: 'Cephe Durumu',
              value: input.facadeCount,
            ),
            PdfResultItem(
              label: 'İzolasyon Durumu',
              value: input.insulationStatus,
            ),
            PdfResultItem(
              label: 'Cam Durumu',
              value: input.glassStatus,
            ),
            PdfResultItem(
              label: 'Kat Durumu',
              value: input.floorStatus,
            ),
            PdfResultItem(
              label: 'Zemin Tipi',
              value: input.floorCovering,
            ),
          ],
        ),
        PdfSectionData(
          title: 'Oda Bazlı Yerden Isıtma Dağılımı',
          items: result.roomResults
              .map(
                (room) => PdfResultItem(
                  label:
                      result.isDublex
                          ? 'Kat ${room.floor} - ${room.name}'
                          : room.name,
                  value:
                      '${_formatNumber(room.area)} m² | ${room.spacingText} | ${_formatNumber(room.pipeLength)} mt | ${room.circuits} hat',
                ),
              )
              .toList(),
        ),
        PdfSectionData(
          title: 'Teknik Bilgiler',
          items: [
            PdfResultItem(
              label: 'Toplam Boru Metrajı',
              value: _formatNumber(result.totalPipeLength),
              unit: 'mt',
            ),
            PdfResultItem(
              label: 'Toplam Hat Sayısı',
              value: result.totalCircuits.toString(),
            ),
            PdfResultItem(
              label: 'Maksimum Hat Boyu',
              value: maxCircuitLength.toStringAsFixed(0),
              unit: 'mt',
            ),
            if (!result.isDublex)
              PdfResultItem(
                label: 'Kollektör',
                value: '${result.totalCircuits} Ağız',
              ),
            if (result.isDublex)
              PdfResultItem(
                label: 'Kat 1 Kollektör',
                value: '${result.floor1Circuits} Ağız',
              ),
            if (result.isDublex)
              PdfResultItem(
                label: 'Kat 2 Kollektör',
                value: '${result.floor2Circuits} Ağız',
              ),
            PdfResultItem(
              label: 'Önerilen Cihaz',
              value: '${input.recommendedKw.toStringAsFixed(0)} kW',
            ),
          ],
        ),
      ],
      notes: [
        ...input.notes,
        'Hat boyları 80 mt üstüne çıkarılmadan hesaplanmıştır.',
        'Nihai cihaz seçimi ve uygulama detayları saha şartlarına göre netleştirilmelidir.',
      ],
    );
  }

  static UnderfloorProjectResult calculateProject({
    required List<RoomUFH> rooms,
    required String housingType,
  }) {
    final isDublex = housingType.toLowerCase() == 'dublex';

    final roomResults = rooms.map(calculateRoom).toList();

    final totalPipeLength = roomResults.fold<double>(
      0,
      (sum, item) => sum + item.pipeLength,
    );

    final totalCircuits = roomResults.fold<int>(
      0,
      (sum, item) => sum + item.circuits,
    );

    final floor1Circuits = roomResults
        .where((r) => r.floor == 1)
        .fold<int>(0, (sum, item) => sum + item.circuits);

    final floor2Circuits = roomResults
        .where((r) => r.floor == 2)
        .fold<int>(0, (sum, item) => sum + item.circuits);

    return UnderfloorProjectResult(
      roomResults: roomResults,
      totalPipeLength: totalPipeLength,
      totalCircuits: totalCircuits,
      floor1Circuits: floor1Circuits,
      floor2Circuits: floor2Circuits,
      isDublex: isDublex,
    );
  }

  static RoomUFHResult calculateRoom(RoomUFH room) {
    final info = _roomRule(room.name);
    final pipeLength = room.area * info.coefficient;
    final circuits = (pipeLength / maxCircuitLength).ceil();
    final circuitLength = pipeLength / circuits;

    return RoomUFHResult(
      name: room.name,
      area: room.area,
      floor: room.floor,
      spacingText: info.spacingText,
      coefficient: info.coefficient,
      pipeLength: pipeLength,
      circuits: circuits,
      circuitLength: circuitLength,
    );
  }

  static String buildSummaryText({
    required double totalPipeLength,
    required int floor1Circuits,
    required int floor2Circuits,
    required int totalCircuits,
    required double recommendedKw,
    required bool isDublex,
  }) {
    final pipeText = _formatNumber(totalPipeLength);

    if (!isDublex) {
      return 'Sonuç: $pipeText mt boru, $totalCircuits ağız kollektör ve ${recommendedKw.toStringAsFixed(0)} kW cihaz önerilmektedir.';
    }

    return 'Sonuç: $pipeText mt boru, Kat 1 = $floor1Circuits ağız kollektör, Kat 2 = $floor2Circuits ağız kollektör ve ${recommendedKw.toStringAsFixed(0)} kW cihaz önerilmektedir.';
  }

  static _RoomRule _roomRule(String roomName) {
    final text = roomName.toLowerCase();

    if (text.contains('banyo') || text.contains('wc')) {
      return const _RoomRule(spacingText: '10 cm', coefficient: 10.0);
    }

    if (text.contains('yatak')) {
      return const _RoomRule(spacingText: '20 cm', coefficient: 4.9);
    }

    if (text.contains('hol') || text.contains('antre')) {
      return const _RoomRule(spacingText: '20 cm', coefficient: 4.9);
    }

    return const _RoomRule(spacingText: '15 cm', coefficient: 6.6);
  }

  static String _formatNumber(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }
}

class _RoomRule {
  final String spacingText;
  final double coefficient;

  const _RoomRule({
    required this.spacingText,
    required this.coefficient,
  });
}