import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/pdf/engine/termo_pdf_engine_impl.dart';
import '../core/pdf/models/pdf_document_data.dart';
import '../models/radiator_models.dart';
import '../services/radiator_calculator.dart';
import '../core/constants/termo_options.dart';
import '../core/constants/termo_location_data.dart';

class RadiatorHeatingPage extends StatefulWidget {
  const RadiatorHeatingPage({super.key});

  @override
  State<RadiatorHeatingPage> createState() => _RadiatorHeatingPageState();
}

class _RadiatorHeatingPageState extends State<RadiatorHeatingPage>
    with SingleTickerProviderStateMixin {
  final RadiatorCalculator _calculator = const RadiatorCalculator();
  late final TabController _tabController;

  static const double _radiatorWattPerMeter = 1700.0;
  static const double _maxSinglePanelMeters = 2.0;
  static const List<int> _capacitySteps = [24, 28, 30, 35, 42, 45];

  // ---------------------------------------------------------------------------
  // MEVCUT SİSTEM
  // ---------------------------------------------------------------------------
  String? _existingBuildingType;
  String? _existingFloorStatus;
  String? _existingFacadeCount;

  String? _existingCity;
  String? _existingLocation;

  String? _existingWindowType;
  String? _existingWindowArea;
  String? _existingInsulation;

  final TextEditingController _existingAreaController = TextEditingController();
  final TextEditingController _existingKat1Controller = TextEditingController();
  final TextEditingController _existingKat2Controller = TextEditingController();
  final TextEditingController _existingRadiatorMetersController =
      TextEditingController();

  ExistingRadiatorSystemResult? _existingResult;

  // ---------------------------------------------------------------------------
  // ODA BAZLI
  // ---------------------------------------------------------------------------
  String? _roomBuildingType;
  String? _roomFloorStatus;
  String? _roomGeneralFacadeCount;

  String? _roomCity;
  String? _roomLocation;

  String? _roomWindowType;
  String? _roomWindowArea;
  String? _roomInsulation;

  final TextEditingController _roomKat1Controller = TextEditingController();
  final TextEditingController _roomKat2Controller = TextEditingController();
  final List<_RoomFormData> _rooms = [_RoomFormData()];
  RoomBasedRadiatorSummaryResult? _roomBasedResult;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _existingAreaController.dispose();
    _existingKat1Controller.dispose();
    _existingKat2Controller.dispose();
    _existingRadiatorMetersController.dispose();
    _roomKat1Controller.dispose();
    _roomKat2Controller.dispose();
    for (final room in _rooms) {
      room.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = _RadiatorTheme();

    return Scaffold(
      backgroundColor: theme.pageBg,
      appBar: AppBar(
  elevation: 0,
  backgroundColor: theme.pageBg,
  surfaceTintColor: Colors.transparent,
  centerTitle: true,
  title: const SizedBox.shrink(),
          
        iconTheme: IconThemeData(color: theme.textDark),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _hideKeyboard,
        child: SafeArea(
          top: false,
          child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE9EEF2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: theme.turquoise,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: theme.textDark,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: 'Mevcut Sistem'),
                    Tab(text: 'Oda Bazlı Hesap'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildExistingTab(theme),
                  _buildRoomBasedTab(theme),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1 - MEVCUT SİSTEM
  // ---------------------------------------------------------------------------
  Widget _buildExistingTab(_RadiatorTheme theme) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        _buildHeroCard(
          theme: theme,
          text:
              'Mevcut sistemde yapı tipi, konum, cephe sayısı, kat, cam ve izolasyon etkilerine göre yaklaşık ısı ihtiyacı bulunur; mevcut metraj ile birlikte referans sonuç üretilir.',
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          theme: theme,
          icon: Icons.home_rounded,
          title: '1. Alan ve Konut Bilgisi',
          subtitle: 'm², yapı tipi, cephe sayısı ve kat durumunu seçin',
          child: Column(
            children: [
              _buildDropdownField(
                theme: theme,
                label: 'Yapı Tipi',
                value: _existingBuildingType,
                items: _buildingTypes,
                icon: Icons.apartment_rounded,
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _existingBuildingType = v;
                    _existingResult = null;
                  });
                },
              ),
              const SizedBox(height: 12),
              if (_existingBuildingType == 'Dubleks') ...[
                _buildNumberField(
                  controller: _existingKat1Controller,
                  theme: theme,
                  label: 'Kat 1 Alanı (m²)',
                  icon: Icons.looks_one_rounded,
                  hintText: 'Örnek: 75',
                ),
                const SizedBox(height: 12),
                _buildNumberField(
                  controller: _existingKat2Controller,
                  theme: theme,
                  label: 'Kat 2 Alanı (m²)',
                  icon: Icons.looks_two_rounded,
                  hintText: 'Örnek: 50',
                ),
              ] else ...[
                _buildNumberField(
                  controller: _existingAreaController,
                  theme: theme,
                  label: 'Alan (m²)',
                  icon: Icons.square_foot_rounded,
                  hintText: 'Örnek: 120',
                ),
              ],
              const SizedBox(height: 12),
              _buildDropdownField(
                theme: theme,
                label: 'Cephe Sayısı',
                value: _existingFacadeCount,
                items: _facadeCounts,
                icon: Icons.crop_square_rounded,
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _existingFacadeCount = v;
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildDropdownField(
                theme: theme,
                label: 'Kat Durumu',
                value: _existingFloorStatus,
                items: _floorStatuses,
                icon: Icons.layers_rounded,
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _existingFloorStatus = v;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buildSectionCard(
          theme: theme,
          icon: Icons.location_on_rounded,
          title: '2. Konum Bilgisi',
          subtitle:
              'Büyükşehirlerde ilçe, diğer illerde bölgesel seçim yapılır',
          child: Column(
            children: [
              _buildDropdownField(
                theme: theme,
                label: 'İl',
                value: _existingCity,
                items: _cities,
                icon: Icons.location_city_rounded,
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _existingCity = v;
                    _existingLocation = null;
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildDropdownField(
                theme: theme,
                label: _existingCity == null
                    ? 'İlçe / Bölge'
                    : (_isMetropolitan(_existingCity!) ? 'İlçe' : 'Bölge'),
                value: _existingLocation,
                items: _existingCity == null ? [] : _locationOptionsForCity(_existingCity!),
                icon: _existingCity != null && _isMetropolitan(_existingCity!)
                    ? Icons.map_rounded
                    : Icons.landscape_rounded,
                onChanged: _existingCity == null
                    ? null
                    : (v) {
                        if (v == null) return;
                        setState(() {
                          _existingLocation = v;
                        });
                      },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buildSectionCard(
          theme: theme,
          icon: Icons.window_rounded,
          title: '3. Cam ve İzolasyon',
          subtitle: 'Cam tipi, cam alanı ve izolasyon kalitesini seçin',
          child: Column(
            children: [
              _buildDropdownField(
                theme: theme,
                label: 'Cam Tipi',
                value: _existingWindowType,
                items: _windowTypes,
                icon: Icons.window_rounded,
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _existingWindowType = v;
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildDropdownField(
                theme: theme,
                label: 'Cam Alanı',
                value: _existingWindowArea,
                items: _windowAreas,
                icon: Icons.crop_landscape_rounded,
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _existingWindowArea = v;
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildDropdownField(
                theme: theme,
                label: 'İzolasyon Durumu',
                value: _existingInsulation,
                items: _insulationLevels,
                icon: Icons.shield_moon_rounded,
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _existingInsulation = v;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buildSectionCard(
          theme: theme,
          icon: Icons.straighten_rounded,
          title: '4. Mevcut Radyatör Bilgisi',
          subtitle: 'Toplam mevcut radyatör uzunluğunu m/tül olarak girin',
          child: Column(
            children: [
              _buildNumberField(
                controller: _existingRadiatorMetersController,
                theme: theme,
                label: 'Mevcut Toplam Radyatör (m/tül)',
                icon: Icons.straighten_rounded,
                hintText: 'Örnek: 6',
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Kullanıcı toplam radyatör değerini direkt girer. Örn: 6 m/tül',
                  style: TextStyle(
                    color: theme.textSoft,
                    fontSize: 12.8,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _calculateExistingSystem,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: theme.turquoise,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Hesapla',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ),
        if (_existingResult != null) ...[
          const SizedBox(height: 14),
          _buildExistingResultCard(theme, _existingResult!),
          const SizedBox(height: 14),
          _buildPdfButton(
            theme: theme,
            label: 'PDF RAPORU OLUŞTUR',
            onPressed: _generateExistingPdf,
          ),
          const SizedBox(height: 10),
          _buildShareButton(
            theme: theme,
            label: 'PAYLAŞ',
            onPressed: _generateExistingPdf,
          ),
        ],
        const SizedBox(height: 14),
        _buildExpertSupportButton(theme),
        const SizedBox(height: 14),
        _buildNoteCard(theme),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2 - ODA BAZLI
  // ---------------------------------------------------------------------------
  Widget _buildRoomBasedTab(_RadiatorTheme theme) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        _buildHeroCard(
          theme: theme,
          text:
              'Oda bazlı sistemde yapı tipi, konum, cephe sayısı, kat, cam ve izolasyon bilgileri girilir; ardından her oda için alan ve oda cephesi seçilerek referans radyatör ihtiyacı hesaplanır.',
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          theme: theme,
          icon: Icons.home_rounded,
          title: '1. Alan ve Konut Bilgisi',
          subtitle: 'Yapı tipi, kat durumu ve genel cephe sayısını seçin',
          child: Column(
            children: [
              _buildDropdownField(
                theme: theme,
                label: 'Yapı Tipi',
                value: _roomBuildingType,
                items: _buildingTypes,
                icon: Icons.apartment_rounded,
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _roomBuildingType = v;
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildDropdownField(
                theme: theme,
                label: 'Genel Cephe Sayısı',
                value: _roomGeneralFacadeCount,
                items: _facadeCounts,
                icon: Icons.crop_square_rounded,
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _roomGeneralFacadeCount = v;
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildDropdownField(
                theme: theme,
                label: 'Kat Durumu',
                value: _roomFloorStatus,
                items: _floorStatuses,
                icon: Icons.layers_rounded,
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _roomFloorStatus = v;
                  });
                },
              ),
              if (_roomBuildingType == 'Dubleks') ...[
                const SizedBox(height: 12),
                _buildNumberField(
                  controller: _roomKat1Controller,
                  theme: theme,
                  label: 'Kat 1 Alanı (m²)',
                  icon: Icons.looks_one_rounded,
                  hintText: 'Örnek: 75',
                ),
                const SizedBox(height: 12),
                _buildNumberField(
                  controller: _roomKat2Controller,
                  theme: theme,
                  label: 'Kat 2 Alanı (m²)',
                  icon: Icons.looks_two_rounded,
                  hintText: 'Örnek: 50',
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buildSectionCard(
          theme: theme,
          icon: Icons.location_on_rounded,
          title: '2. Konum Bilgisi',
          subtitle:
              'Büyükşehirlerde ilçe, diğer illerde bölgesel seçim yapılır',
          child: Column(
            children: [
              _buildDropdownField(
                theme: theme,
                label: 'İl',
                value: _roomCity,
                items: _cities,
                icon: Icons.location_city_rounded,
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _roomCity = v;
                    _roomLocation = null;
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildDropdownField(
                theme: theme,
                label: _roomCity == null
                    ? 'İlçe / Bölge'
                    : (_isMetropolitan(_roomCity!) ? 'İlçe' : 'Bölge'),
                value: _roomLocation,
                items: _roomCity == null ? [] : _locationOptionsForCity(_roomCity!),
                icon: _roomCity != null && _isMetropolitan(_roomCity!)
                    ? Icons.map_rounded
                    : Icons.landscape_rounded,
                onChanged: _roomCity == null
                    ? null
                    : (v) {
                        if (v == null) return;
                        setState(() {
                          _roomLocation = v;
                        });
                      },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buildSectionCard(
          theme: theme,
          icon: Icons.window_rounded,
          title: '3. Cam ve İzolasyon',
          subtitle: 'Cam tipi, cam alanı ve izolasyon kalitesini seçin',
          child: Column(
            children: [
              _buildDropdownField(
                theme: theme,
                label: 'Cam Tipi',
                value: _roomWindowType,
                items: _windowTypes,
                icon: Icons.window_rounded,
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _roomWindowType = v;
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildDropdownField(
                theme: theme,
                label: 'Cam Alanı',
                value: _roomWindowArea,
                items: _windowAreas,
                icon: Icons.crop_landscape_rounded,
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _roomWindowArea = v;
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildDropdownField(
                theme: theme,
                label: 'İzolasyon Durumu',
                value: _roomInsulation,
                items: _insulationLevels,
                icon: Icons.shield_moon_rounded,
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _roomInsulation = v;
                  });
                },
              ),
            ],
          ),
        ),
        if (_roomBuildingType != 'Dubleks') ...[
          const SizedBox(height: 14),
          ...List.generate(_rooms.length, (index) {
            return Padding(
              padding:
                  EdgeInsets.only(bottom: index == _rooms.length - 1 ? 0 : 14),
              child: _buildRoomCard(theme, index, _rooms[index]),
            );
          }),
          const SizedBox(height: 14),
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _rooms.add(_RoomFormData());
                });
              },
              icon: const Icon(Icons.add),
              label: const Text(
                'Oda Ekle',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.turquoise,
                side: BorderSide(color: theme.turquoise, width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 14),
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _calculateRoomBased,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: theme.turquoise,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Oda Bazlı Hesapla',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ),
        if (_roomBasedResult != null) ...[
          const SizedBox(height: 14),
          _buildRoomBasedResultCard(theme, _roomBasedResult!),
          const SizedBox(height: 14),
          _buildPdfButton(
            theme: theme,
            label: 'PDF RAPORU OLUŞTUR',
            onPressed: _generateRoomBasedPdf,
          ),
          const SizedBox(height: 10),
          _buildShareButton(
            theme: theme,
            label: 'PAYLAŞ',
            onPressed: _generateRoomBasedPdf,
          ),
        ],
        const SizedBox(height: 14),
        _buildExpertSupportButton(theme),
        const SizedBox(height: 14),
        _buildNoteCard(theme),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // HESAP
  // ---------------------------------------------------------------------------
  void _calculateExistingSystem() {
    _hideKeyboard();

    if (_existingBuildingType == null) {
      _showSnack('Yapı tipi seçiniz.');
      return;
    }
    if (_existingFacadeCount == null) {
      _showSnack('Cephe sayısı seçiniz.');
      return;
    }
    if (_existingFloorStatus == null) {
      _showSnack('Kat durumu seçiniz.');
      return;
    }
    if (_existingCity == null) {
      _showSnack('İl seçiniz.');
      return;
    }
    if (_existingLocation == null) {
      _showSnack('İlçe / Bölge seçiniz.');
      return;
    }
    if (_existingWindowType == null) {
      _showSnack('Cam tipi seçiniz.');
      return;
    }
    if (_existingWindowArea == null) {
      _showSnack('Cam alanı seçiniz.');
      return;
    }
    if (_existingInsulation == null) {
      _showSnack('İzolasyon durumu seçiniz.');
      return;
    }

    final area = _existingTotalArea();
    final existingMeters = _parseDouble(_existingRadiatorMetersController.text);

    if (area <= 0) {
      _showSnack(_existingBuildingType == 'Dubleks'
          ? 'Lütfen Kat 1 ve Kat 2 için geçerli alan girin.'
          : 'Lütfen geçerli bir alan girin.');
      return;
    }

    if (existingMeters <= 0) {
      _showSnack('Lütfen geçerli bir radyatör metrajı girin.');
      return;
    }

    final buildingType = _existingBuildingType!;
    final floorStatus = _existingFloorStatus!;
    final facadeCount = _existingFacadeCount!;
    final city = _existingCity!;
    final location = _existingLocation!;
    final windowType = _existingWindowType!;
    final windowArea = _existingWindowArea!;
    final insulation = _existingInsulation!;

    final correctedWattPerM2 = _buildBaseWattPerM2(
      city: city,
      location: location,
      buildingType: buildingType,
      floorStatus: floorStatus,
      facadeCount: facadeCount,
      windowType: windowType,
      windowArea: windowArea,
      insulationLevel: insulation,
    );

    final input = ExistingRadiatorSystemInput(
      city: city,
      district: location,
      buildingType: buildingType,
      totalAreaM2: area,
      floorStatus: floorStatus,
      facadeType: facadeCount,
      insulationLevel: insulation,
      windowQuality: windowType,
      windowArea: windowArea,
      existingRadiatorMeters: existingMeters,
    );

    final result = _calculator.calculateExistingSystem(
      input: input,
      correctedWattPerM2: correctedWattPerM2,
    );

    setState(() {
      _existingResult = result;
    });
  }

  void _calculateRoomBased() {
    _hideKeyboard();

    if (_roomBuildingType == null) {
      _showSnack('Yapı tipi seçiniz.');
      return;
    }
    if (_roomGeneralFacadeCount == null) {
      _showSnack('Genel cephe sayısı seçiniz.');
      return;
    }
    if (_roomFloorStatus == null) {
      _showSnack('Kat durumu seçiniz.');
      return;
    }
    if (_roomCity == null) {
      _showSnack('İl seçiniz.');
      return;
    }
    if (_roomLocation == null) {
      _showSnack('İlçe / Bölge seçiniz.');
      return;
    }
    if (_roomWindowType == null) {
      _showSnack('Cam tipi seçiniz.');
      return;
    }
    if (_roomWindowArea == null) {
      _showSnack('Cam alanı seçiniz.');
      return;
    }
    if (_roomInsulation == null) {
      _showSnack('İzolasyon durumu seçiniz.');
      return;
    }

    final buildingType = _roomBuildingType!;
    final floorStatus = _roomFloorStatus!;
    final facadeCount = _roomGeneralFacadeCount!;
    final city = _roomCity!;
    final location = _roomLocation!;
    final windowType = _roomWindowType!;
    final windowArea = _roomWindowArea!;
    final insulation = _roomInsulation!;

    final roomInputs = <RadiatorRoomInput>[];

    if (buildingType == 'Dubleks') {
      final kat1Area = _parseDouble(_roomKat1Controller.text);
      final kat2Area = _parseDouble(_roomKat2Controller.text);

      if (kat1Area <= 0) {
        _showSnack('Kat 1 için geçerli bir alan girin.');
        return;
      }
      if (kat2Area <= 0) {
        _showSnack('Kat 2 için geçerli bir alan girin.');
        return;
      }

      roomInputs.add(
        RadiatorRoomInput(
          roomName: 'Kat 1',
          roomType: 'Kat 1',
          areaM2: kat1Area,
          facadeType: facadeCount,
          windowArea: windowArea,
        ),
      );
      roomInputs.add(
        RadiatorRoomInput(
          roomName: 'Kat 2',
          roomType: 'Kat 2',
          areaM2: kat2Area,
          facadeType: facadeCount,
          windowArea: windowArea,
        ),
      );
    } else {
      if (_rooms.isEmpty) {
        _showSnack('Lütfen en az bir oda ekleyin.');
        return;
      }

      for (int i = 0; i < _rooms.length; i++) {
        final room = _rooms[i];
        final area = _parseDouble(room.areaController.text);

        if (room.roomType == null || room.roomType!.trim().isEmpty) {
          _showSnack('${i + 1}. oda için oda tipi seçiniz.');
          return;
        }

        if (room.facadeCount == null || room.facadeCount!.trim().isEmpty) {
          _showSnack('${i + 1}. oda için cephe sayısı seçiniz.');
          return;
        }

        if (area <= 0) {
          _showSnack('${i + 1}. oda için geçerli bir alan girin.');
          return;
        }

        roomInputs.add(
          RadiatorRoomInput(
            roomName: room.roomType!,
            roomType: room.roomType!,
            areaM2: area,
            facadeType: room.facadeCount!,
            windowArea: windowArea,
          ),
        );
      }
    }

    final baseWattPerM2 = _buildBaseWattPerM2(
      city: city,
      location: location,
      buildingType: buildingType,
      floorStatus: floorStatus,
      facadeCount: facadeCount,
      windowType: windowType,
      windowArea: windowArea,
      insulationLevel: insulation,
    );

    final result = _calculator.calculateRoomBasedSummary(
      rooms: roomInputs,
      roomCorrectedWattPerM2: (room) {
        if (buildingType == 'Dubleks') {
          return baseWattPerM2;
        }
        return baseWattPerM2 *
            _roomTypeFactor(room.roomType) *
            _roomFacadeCountFactor(room.facadeType);
      },
    );

    setState(() {
      _roomBasedResult = result;
    });
  }

  double _buildBaseWattPerM2({
  required String city,
  required String location,
  required String buildingType,
  required String floorStatus,
  required String facadeCount,
  required String windowType,
  required String windowArea,
  required String insulationLevel,
}) {
  return _baseWattPerM2(buildingType) *
      _cityClimateFactor(city) *
      (_isMetropolitan(city)
          ? _districtAdjustment(city, location)
          : _regionFactor(city, location)) *
      _insulationFactor(insulationLevel) *
      _windowTypeFactor(windowType) *
      _windowAreaFactor(windowArea) *
      _facadeCountFactor(facadeCount) *
      _floorStatusFactor(floorStatus);
}

double _baseWattPerM2(String value) {
  switch (value) {
    case 'Müstakil':
    case 'Müstakil Ev':
      return 62;
    case 'Dubleks':
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
  if (!_isMetropolitan(city)) return 1.0;

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
  final isCoastal = _coastalNonMetroCities.contains(city);

  if (isCoastal) {
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

double _roomFacadeCountFactor(String value) {
  switch (value) {
    case '1 Cephe':
      return 0.98;
    case '2 Cephe':
      return 1.00;
    case '3 Cephe':
      return 1.05;
    case '4 Cephe':
      return 1.10;
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
    case 'Konfor Camı (Low-E)':
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
    case 'Çok':
      return 1.10;
    case 'Orta':
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
  double _roomTypeFactor(String value) {
    switch (value) {
      case 'Salon':
        return 1.00;
      case 'Oturma Odası':
        return 1.00;
      case 'Yatak Odası':
        return 0.96;
      case 'Çocuk Odası':
        return 0.98;
      case 'Mutfak':
        return 0.95;
      case 'Banyo':
        return 1.10;
      case 'Hol':
      case 'Antre':
        return 0.90;
      case 'Çalışma Odası':
        return 0.97;
      default:
        return 1.00;
    }
  }

  bool _isMetropolitan(String city) => _metroDistricts.containsKey(city);

  List<String> _locationOptionsForCity(String city) {
    return _locationOptionsForCityStatic(city);
  }

  static List<String> _locationOptionsForCityStatic(String city) {
    if (_metroDistricts.containsKey(city)) {
      return _metroDistricts[city]!;
    }

    final zones = <String>['Merkez', 'Ara Bölge', 'Yüksek Kesim'];
    if (_coastalNonMetroCities.contains(city)) {
      zones.add('Kıyı Kesim');
    }
    return zones;
  }

  double _parseDouble(String text) {
    return double.tryParse(text.trim().replaceAll(',', '.')) ?? 0;
  }

  double _existingTotalArea() {
    if (_existingBuildingType == 'Dubleks') {
      return _parseDouble(_existingKat1Controller.text) +
          _parseDouble(_existingKat2Controller.text);
    }
    return _parseDouble(_existingAreaController.text);
  }

  double _existingKat1Area() => _parseDouble(_existingKat1Controller.text);

  double _existingKat2Area() => _parseDouble(_existingKat2Controller.text);

  int _existingKat1HeatNeedW() {
    final totalArea = _existingTotalArea();
    if (totalArea <= 0 || _existingResult == null) return 0;
    if (_existingBuildingType != 'Dubleks') return _existingResult!.totalHeatNeedW;
    return ((_existingKat1Area() / totalArea) * _existingResult!.totalHeatNeedW).round();
  }

  int _existingKat2HeatNeedW() {
    final totalArea = _existingTotalArea();
    if (totalArea <= 0 || _existingResult == null) return 0;
    if (_existingBuildingType != 'Dubleks') return 0;
    return ((_existingKat2Area() / totalArea) * _existingResult!.totalHeatNeedW).round();
  }


  double _normalizeRadiatorMeters(double meters) {
    if (meters <= 0) return 0;
    final rounded = (meters * 2).ceil() / 2;
    return rounded < 0.5 ? 0.5 : rounded;
  }

  double _radiatorMetersFromHeat(int heatNeedW) {
    if (heatNeedW <= 0) return 0;
    return _normalizeRadiatorMeters(heatNeedW / _radiatorWattPerMeter);
  }

  int? _nextCapacity(int current) {
    final index = _capacitySteps.indexOf(current);
    if (index == -1 || index >= _capacitySteps.length - 1) return null;
    return _capacitySteps[index + 1];
  }

  _CapacityDecision _resolveCapacity({
    required double kw,
    required double radiatorMeters,
  }) {
    if (kw <= 0) {
      return const _CapacityDecision(
        recommendedText: '-',
        advisoryText: null,
      );
    }

    if (kw > 45) {
      return const _CapacityDecision(
        recommendedText: '45 kW üzeri - Duvar Tipi Yoğuşmalı Kazan Önerilir',
        advisoryText: null,
      );
    }

    for (int i = 0; i < _capacitySteps.length; i++) {
      final step = _capacitySteps[i];
      if (kw <= step) {
        final threshold = step * 0.70;
        String? advisory;

        if (kw > threshold && i < _capacitySteps.length - 1) {
          advisory = '${_capacitySteps[i + 1]} kW';
        }

        if (radiatorMeters >= 9.0) {
          if (step < 28) {
            advisory = '28 kW';
          } else {
            final next = _nextCapacity(step);
            advisory ??= next != null ? '$next kW' : null;
          }
        }

        if (advisory == '$step kW') {
          advisory = null;
        }

        return _CapacityDecision(
          recommendedText: '$step kW',
          advisoryText: advisory,
        );
      }
    }

    return const _CapacityDecision(
      recommendedText: '45 kW üzeri - Duvar Tipi Yoğuşmalı Kazan Önerilir',
      advisoryText: null,
    );
  }


  double _roomBasedRoundedMetersTotal(RoomBasedRadiatorSummaryResult result) {
    return result.roomResults.fold<double>(
      0,
      (sum, room) => sum + _radiatorMetersFromHeat(room.heatNeedW),
    );
  }

  String _panelDimensionText(double meters) {
    final totalMm = (meters * 1000).round();
    if (totalMm <= 0) return '600 x 0';

    final parts = <int>[];
    var remaining = totalMm;
    const maxPanelMm = 2000;

    while (remaining > maxPanelMm) {
      parts.add(maxPanelMm);
      remaining -= maxPanelMm;
    }

    if (remaining > 0) {
      parts.add(remaining);
    }

    return parts.map((mm) => '600 x $mm').join(' + ');
  }

  String _pdfLocationText(String city, String location) {
    return location.isEmpty ? '-' : location;
  }

  String _existingSummaryText(ExistingRadiatorSystemResult result) {
    final calculatedMeters = _radiatorMetersFromHeat(result.totalHeatNeedW);
    final existingMeters = _normalizeRadiatorMeters(result.existingRadiatorMeters);
    final capacity = _resolveCapacity(
      kw: result.totalHeatNeedW / 1000.0,
      radiatorMeters: calculatedMeters,
    );

    final advisoryText = capacity.advisoryText != null
        ? ' Tavsiye edilen kapasite: ${capacity.advisoryText}.'
        : '';

    if (_existingBuildingType == 'Dubleks') {
      return 'Sonuç: Kat 1 için ${_existingKat1HeatNeedW()} W, Kat 2 için ${_existingKat2HeatNeedW()} W ve toplam ${result.totalHeatNeedW} W ısı kaybı hesaplanmıştır. ${calculatedMeters.toStringAsFixed(1)} m/tül hesaplanan radyatör metrajı ve ${existingMeters.toStringAsFixed(1)} m/tül mevcut radyatör verisine göre önerilen cihaz ${capacity.recommendedText}.$advisoryText';
    }

    return 'Sonuç: ${result.totalHeatNeedW} W ısı ihtiyacı, ${calculatedMeters.toStringAsFixed(1)} m/tül hesaplanan radyatör metrajı ve ${existingMeters.toStringAsFixed(1)} m/tül mevcut radyatör verisine göre önerilen cihaz ${capacity.recommendedText}.$advisoryText';
  }

  String _roomBasedSummaryText(RoomBasedRadiatorSummaryResult result) {
    final totalMeters = _roomBasedRoundedMetersTotal(result);
    final capacity = _resolveCapacity(
      kw: result.totalHeatNeedW / 1000.0,
      radiatorMeters: totalMeters,
    );

    final advisoryText = capacity.advisoryText != null
        ? ' Tavsiye edilen kapasite: ${capacity.advisoryText}.'
        : '';

    if (_roomBuildingType == 'Dubleks' && result.roomResults.length >= 2) {
      final kat1 = result.roomResults[0];
      final kat2 = result.roomResults[1];
      return 'Sonuç: Kat 1 için ${kat1.heatNeedW} W, Kat 2 için ${kat2.heatNeedW} W ve toplam ${result.totalHeatNeedW} W ısı kaybı hesaplanmıştır. ${totalMeters.toStringAsFixed(1)} m/tül toplam radyatör metrajına göre önerilen cihaz ${capacity.recommendedText}.$advisoryText';
    }

    return 'Sonuç: ${result.totalHeatNeedW} W toplam ısı ihtiyacı ve ${totalMeters.toStringAsFixed(1)} m/tül toplam radyatör metrajına göre önerilen cihaz ${capacity.recommendedText}.$advisoryText';
  }

  PdfDocumentData _buildExistingSystemPdfData() {
    final result = _existingResult!;
    final calculatedMeters = _radiatorMetersFromHeat(result.totalHeatNeedW);
    final existingMeters = _normalizeRadiatorMeters(result.existingRadiatorMeters);
    final capacity = _resolveCapacity(
      kw: result.totalHeatNeedW / 1000.0,
      radiatorMeters: calculatedMeters,
    );

    final summaryHighlights = <PdfResultItem>[
      PdfResultItem(label: 'Toplam Isı İhtiyacı', value: '${result.totalHeatNeedW}', unit: 'W'),
      PdfResultItem(label: 'Hesaplanan Metraj', value: calculatedMeters.toStringAsFixed(1), unit: 'm/tül'),
      PdfResultItem(label: 'Mevcut Radyatör', value: existingMeters.toStringAsFixed(1), unit: 'm/tül'),
      PdfResultItem(label: 'Mevcut Radyatöre Göre Önerilen', value: capacity.recommendedText),
      if (capacity.advisoryText != null)
        PdfResultItem(label: 'Tavsiye Edilen', value: capacity.advisoryText!),
    ];

    final sections = <PdfSectionData>[
      PdfSectionData(
        title: 'Radyatör Giriş Bilgileri',
        items: [
          if (_existingBuildingType == 'Dubleks')
            PdfResultItem(label: 'Kat 1 Alanı', value: _existingKat1Area().toStringAsFixed(_existingKat1Area() % 1 == 0 ? 0 : 1), unit: 'm²'),
          if (_existingBuildingType == 'Dubleks')
            PdfResultItem(label: 'Kat 2 Alanı', value: _existingKat2Area().toStringAsFixed(_existingKat2Area() % 1 == 0 ? 0 : 1), unit: 'm²'),
          PdfResultItem(label: 'Toplam Alan', value: _existingTotalArea().toStringAsFixed(_existingTotalArea() % 1 == 0 ? 0 : 1), unit: 'm²'),
          PdfResultItem(label: 'Konut Tipi', value: _existingBuildingType ?? '-'),
          PdfResultItem(label: 'Cephe Durumu', value: _existingFacadeCount ?? '-'),
          PdfResultItem(label: 'Kat Durumu', value: _existingFloorStatus ?? '-'),
          PdfResultItem(label: 'Cam Durumu', value: _existingWindowType ?? '-'),
          PdfResultItem(label: 'Cam Alanı', value: _existingWindowArea ?? '-'),
          PdfResultItem(label: 'İzolasyon Durumu', value: _existingInsulation ?? '-'),
        ],
      ),
      if (_existingBuildingType == 'Dubleks')
        PdfSectionData(
          title: 'Kat Bazlı Isı Kaybı',
          items: [
            PdfResultItem(label: 'Kat 1 Isı Kaybı', value: '${_existingKat1HeatNeedW()}', unit: 'W'),
            PdfResultItem(label: 'Kat 2 Isı Kaybı', value: '${_existingKat2HeatNeedW()}', unit: 'W'),
            PdfResultItem(label: 'Toplam Isı Kaybı', value: '${result.totalHeatNeedW}', unit: 'W'),
          ],
        ),
      PdfSectionData(
        title: 'Teknik Bilgiler',
        items: [
          PdfResultItem(label: 'Toplam Isı İhtiyacı', value: '${result.totalHeatNeedW}', unit: 'W'),
          PdfResultItem(label: 'Hesaplanan Radyatör', value: calculatedMeters.toStringAsFixed(1), unit: 'm/tül'),
          PdfResultItem(label: 'Mevcut Radyatör', value: existingMeters.toStringAsFixed(1), unit: 'm/tül'),
          PdfResultItem(label: 'Önerilen Kombi', value: capacity.recommendedText),
          if (capacity.advisoryText != null)
            PdfResultItem(label: 'Tavsiye Edilen', value: capacity.advisoryText!),
        ],
      ),
    ];

    return PdfDocumentData(
      type: PdfReportType.radiator,
      title: 'TermoPlan PDF Raporu',
      subtitle: 'Radyatör bazlı mevcut sistem sonuçlarına göre oluşturulmuş rapor.',
      meta: PdfProjectMeta(
        createdAt: DateTime.now(),
        isPremium: true,
        appName: 'TermoPlan',
        reportCode: 'TP-${DateTime.now().millisecondsSinceEpoch}',
      ),
      summary: PdfSummaryData(
        mainResult: _existingSummaryText(result),
        recommendedDevice: capacity.recommendedText,
        highlights: summaryHighlights,
      ),
      customer: PdfCustomerData(
        name: '',
        phone: '',
        city: _existingCity ?? '-',
        district: _pdfLocationText(_existingCity ?? '-', _existingLocation ?? '-'),
        projectName: 'Radyatör Bazlı Isıtma Hesabı',
      ),
      sections: sections,
      notes: const [
        'Hesaplamalar 600 seri panel radyatör kabulüne göre oluşturulmuştur.',
        'Nihai cihaz ve metraj seçimi uygulama koşullarına göre uzman değerlendirmesi ile netleştirilmelidir.',
      ],
    );
  }

  PdfDocumentData _buildRoomBasedPdfData() {
    final result = _roomBasedResult!;
    final totalMeters = _roomBasedRoundedMetersTotal(result);
    final capacity = _resolveCapacity(
      kw: result.totalHeatNeedW / 1000.0,
      radiatorMeters: totalMeters,
    );

    final roomItems = result.roomResults.map((room) {
      final roomMeters = _radiatorMetersFromHeat(room.heatNeedW);
      return PdfResultItem(
        label: room.roomName,
        value: '${room.heatNeedW} W | ${roomMeters.toStringAsFixed(1)} m/tül | ${_panelDimensionText(roomMeters)}',
      );
    }).toList();

    final summaryHighlights = <PdfResultItem>[
      PdfResultItem(label: 'Toplam Isı İhtiyacı', value: '${result.totalHeatNeedW}', unit: 'W'),
      PdfResultItem(label: 'Toplam Metraj', value: totalMeters.toStringAsFixed(1), unit: 'm/tül'),
      PdfResultItem(label: 'Önerilen Kombi', value: capacity.recommendedText),
      if (capacity.advisoryText != null)
        PdfResultItem(label: 'Tavsiye Edilen', value: capacity.advisoryText!),
    ];

    final sections = <PdfSectionData>[
      PdfSectionData(
        title: 'Radyatör Giriş Bilgileri',
        items: [
          if (_roomBuildingType == 'Dubleks')
            PdfResultItem(label: 'Kat 1 Alanı', value: _parseDouble(_roomKat1Controller.text).toStringAsFixed(_parseDouble(_roomKat1Controller.text) % 1 == 0 ? 0 : 1), unit: 'm²'),
          if (_roomBuildingType == 'Dubleks')
            PdfResultItem(label: 'Kat 2 Alanı', value: _parseDouble(_roomKat2Controller.text).toStringAsFixed(_parseDouble(_roomKat2Controller.text) % 1 == 0 ? 0 : 1), unit: 'm²'),
          if (_roomBuildingType == 'Dubleks')
            PdfResultItem(label: 'Toplam Alan', value: (_parseDouble(_roomKat1Controller.text) + _parseDouble(_roomKat2Controller.text)).toStringAsFixed(((_parseDouble(_roomKat1Controller.text) + _parseDouble(_roomKat2Controller.text)) % 1 == 0) ? 0 : 1), unit: 'm²'),
          PdfResultItem(label: 'Konut Tipi', value: _roomBuildingType ?? '-'),
          PdfResultItem(label: 'Genel Cephe', value: _roomGeneralFacadeCount ?? '-'),
          PdfResultItem(label: 'Kat Durumu', value: _roomFloorStatus ?? '-'),
          PdfResultItem(label: 'Cam Durumu', value: _roomWindowType ?? '-'),
          PdfResultItem(label: 'Cam Alanı', value: _roomWindowArea ?? '-'),
          PdfResultItem(label: 'İzolasyon Durumu', value: _roomInsulation ?? '-'),
        ],
      ),
      if (_roomBuildingType == 'Dubleks')
        PdfSectionData(
          title: 'Kat Bazlı Radyatör Dağılımı',
          items: roomItems,
        ),
      if (_roomBuildingType != 'Dubleks')
        PdfSectionData(
          title: 'Oda Bazlı Radyatör Dağılımı',
          items: roomItems,
        ),
      PdfSectionData(
        title: 'Teknik Bilgiler',
        items: [
          PdfResultItem(label: 'Toplam Isı İhtiyacı', value: '${result.totalHeatNeedW}', unit: 'W'),
          PdfResultItem(label: 'Toplam Metraj', value: totalMeters.toStringAsFixed(1), unit: 'm/tül'),
          PdfResultItem(label: 'Önerilen Kombi', value: capacity.recommendedText),
          if (capacity.advisoryText != null)
            PdfResultItem(label: 'Tavsiye Edilen', value: capacity.advisoryText!),
        ],
      ),
    ];

    return PdfDocumentData(
      type: PdfReportType.radiator,
      title: 'TermoPlan PDF Raporu',
      subtitle: _roomBuildingType == 'Dubleks'
          ? 'Radyatör bazlı dubleks sonuçlarına göre oluşturulmuş rapor.'
          : 'Radyatör bazlı oda sonuçlarına göre oluşturulmuş rapor.',
      meta: PdfProjectMeta(
        createdAt: DateTime.now(),
        isPremium: true,
        appName: 'TermoPlan',
        reportCode: 'TP-${DateTime.now().millisecondsSinceEpoch}',
      ),
      summary: PdfSummaryData(
        mainResult: _roomBasedSummaryText(result),
        recommendedDevice: capacity.recommendedText,
        highlights: summaryHighlights,
      ),
      customer: PdfCustomerData(
        name: '',
        phone: '',
        city: _roomCity ?? '-',
        district: _pdfLocationText(_roomCity ?? '-', _roomLocation ?? '-'),
        projectName: _roomBuildingType == 'Dubleks'
            ? 'Radyatör Bazlı Dubleks Hesabı'
            : 'Radyatör Bazlı Oda Hesabı',
      ),
      sections: sections,
      notes: const [
        'Oda bazlı metrajlar 600 seri panel radyatör kabulüne göre yuvarlanmıştır.',
        'Nihai cihaz ve metraj seçimi uygulama koşullarına göre uzman değerlendirmesi ile netleştirilmelidir.',
      ],
    );
  }

  Future<void> _generateExistingPdf() async {
    _hideKeyboard();

    if (_existingResult == null) {
      _showSnack('Önce mevcut sistem hesabını oluşturun.');
      return;
    }

    try {
      final engine = TermoPdfEngineImpl();
      final bytes = await engine.generate(_buildExistingSystemPdfData());
      final fileName =
          'termo_plan_radyator_mevcut_${DateTime.now().millisecondsSinceEpoch}.pdf';

      await Share.shareXFiles(
        [
          XFile.fromData(
            Uint8List.fromList(bytes),
            mimeType: 'application/pdf',
            name: fileName,
          ),
        ],
        text: 'TermoPlan ile hazırladığım radyatör bazlı mevcut sistem raporunu paylaşıyorum.',
      );
    } catch (e) {
      if (!mounted) return;
      _showSnack('PDF oluşturulamadı: $e');
    }
  }

  Future<void> _generateRoomBasedPdf() async {
    _hideKeyboard();

    if (_roomBasedResult == null) {
      _showSnack('Önce oda bazlı hesabı oluşturun.');
      return;
    }

    try {
      final engine = TermoPdfEngineImpl();
      final bytes = await engine.generate(_buildRoomBasedPdfData());
      final fileName =
          'termo_plan_radyator_oda_bazli_${DateTime.now().millisecondsSinceEpoch}.pdf';

      await Share.shareXFiles(
        [
          XFile.fromData(
            Uint8List.fromList(bytes),
            mimeType: 'application/pdf',
            name: fileName,
          ),
        ],
        text: 'TermoPlan ile hazırladığım radyatör bazlı oda hesabı raporunu paylaşıyorum.',
      );
    } catch (e) {
      if (!mounted) return;
      _showSnack('PDF oluşturulamadı: $e');
    }
  }

  Widget _buildPdfButton({
    required _RadiatorTheme theme,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.picture_as_pdf_rounded),
        label: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.orange,
          side: BorderSide(color: theme.orange, width: 1.4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }


  Widget _buildShareButton({
    required _RadiatorTheme theme,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.ios_share_rounded),
        label: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: theme.turquoise,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _openExpertSupport() async {
    _hideKeyboard();

    final uri = Uri.parse('https://wa.me/905307847260');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!ok && mounted) {
      _showSnack('WhatsApp bağlantısı açılamadı.');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ---------------------------------------------------------------------------
  // UI ORTAK
  // ---------------------------------------------------------------------------
  Widget _buildHeroCard({
    required _RadiatorTheme theme,
    required String text,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: AspectRatio(
        aspectRatio: 6.30,
        child: Image.asset(
          'assets/header/radiator_header_clean.png',
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required _RadiatorTheme theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: theme.shadow,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: theme.softTurquoise,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: theme.turquoise),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: theme.textDark,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: theme.textSoft,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required _RadiatorTheme theme,
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?>? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      menuMaxHeight: 320,
      value: value,
      decoration: _inputDecoration(
        theme: theme,
        label: label,
        icon: icon,
      ),
      hint: const Text('Seçiniz'),
      borderRadius: BorderRadius.circular(16),
      items: items
          .map(
            (e) => DropdownMenuItem<String>(
              value: e,
              child: Text(
                e,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required _RadiatorTheme theme,
    required String label,
    required IconData icon,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: _inputDecoration(
        theme: theme,
        label: label,
        icon: icon,
      ).copyWith(hintText: hintText),
    );
  }

  InputDecoration _inputDecoration({
    required _RadiatorTheme theme,
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: theme.turquoise),
      filled: true,
      fillColor: Colors.white,
      labelStyle: TextStyle(
        color: theme.textSoft,
        fontWeight: FontWeight.w600,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.turquoise, width: 1.4),
      ),
    );
  }

  Widget _buildExistingResultCard(
    _RadiatorTheme theme,
    ExistingRadiatorSystemResult result,
  ) {
    final calculatedMeters = _radiatorMetersFromHeat(result.totalHeatNeedW);
    final existingMeters = _normalizeRadiatorMeters(result.existingRadiatorMeters);
    final capacity = _resolveCapacity(
      kw: result.totalHeatNeedW / 1000.0,
      radiatorMeters: calculatedMeters,
    );

    return _buildSectionCard(
      theme: theme,
      icon: Icons.analytics_rounded,
      title: '5. Sonuç',
      subtitle: 'Toplam ısı ihtiyacı, metraj ve kombi önerisi',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ResultBox(
                  title: 'Toplam Isı İhtiyacı',
                  value: '${result.totalHeatNeedW} W',
                  bgColor: theme.turquoise,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResultBox(
                  title: 'Hesaplanan Metraj',
                  value: '${calculatedMeters.toStringAsFixed(1)} m/tül',
                  bgColor: theme.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ResultBox(
                  title: 'Mevcut Radyatör',
                  value: '${existingMeters.toStringAsFixed(1)} m/tül',
                  bgColor: theme.textDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResultBox(
                  title: 'Mevcut Radyatöre Göre Önerilen',
                  value: capacity.recommendedText,
                  bgColor: theme.purple,
                ),
              ),
            ],
          ),
          if (_existingBuildingType == 'Dubleks') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ResultBox(
                    title: 'Kat 1 Isı Kaybı',
                    value: '${_existingKat1HeatNeedW()} W',
                    bgColor: theme.turquoise,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ResultBox(
                    title: 'Kat 2 Isı Kaybı',
                    value: '${_existingKat2HeatNeedW()} W',
                    bgColor: theme.orange,
                  ),
                ),
              ],
            ),
          ],
          if (capacity.advisoryText != null) ...[
            const SizedBox(height: 12),
            _ResultBox(
              title: 'Tavsiye Edilen',
              value: capacity.advisoryText!,
              bgColor: theme.red,
              fullWidth: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoomCard(
    _RadiatorTheme theme,
    int index,
    _RoomFormData room,
  ) {
    return _buildSectionCard(
      theme: theme,
      icon: Icons.meeting_room_rounded,
      title: '${index + 4}. Oda ${index + 1}',
      subtitle: 'Oda tipi, alan ve cephe sayısını girin',
      child: Column(
        children: [
          _buildDropdownField(
            theme: theme,
            label: 'Oda Tipi',
            value: room.roomType,
            items: _roomTypes,
            icon: Icons.home_work_rounded,
            onChanged: (v) {
              setState(() {
                room.roomType = v;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildNumberField(
            controller: room.areaController,
            theme: theme,
            label: 'Alan (m²)',
            icon: Icons.straighten_rounded,
            hintText: 'Örnek: 18',
          ),
          const SizedBox(height: 12),
          _buildDropdownField(
            theme: theme,
            label: 'Cephe Sayısı',
            value: room.facadeCount,
            items: _roomFacadeCounts,
            icon: Icons.crop_square_rounded,
            onChanged: (v) {
              setState(() {
                room.facadeCount = v;
              });
            },
          ),
          if (_rooms.length > 1) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    room.dispose();
                    _rooms.removeAt(index);
                  });
                },
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text(
                  'Odayı Sil',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoomBasedResultCard(
    _RadiatorTheme theme,
    RoomBasedRadiatorSummaryResult result,
  ) {
    final totalMeters = _roomBasedRoundedMetersTotal(result);
    final capacity = _resolveCapacity(
      kw: result.totalHeatNeedW / 1000.0,
      radiatorMeters: totalMeters,
    );

    return _buildSectionCard(
      theme: theme,
      icon: Icons.summarize_rounded,
      title: '${_rooms.length + 4}. Toplam Sonuç',
      subtitle: _roomBuildingType == 'Dubleks' ? 'Kat bazlı toplam ihtiyaç ve radyatör metrajı' : 'Oda bazlı toplam ihtiyaç ve radyatör metrajı',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ResultBox(
                  title: 'Toplam Isı İhtiyacı',
                  value: '${result.totalHeatNeedW} W',
                  bgColor: theme.turquoise,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResultBox(
                  title: 'Toplam Metraj',
                  value: '${totalMeters.toStringAsFixed(1)} m/tül',
                  bgColor: theme.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ResultBox(
            title: 'Önerilen Kombi',
            value: capacity.recommendedText,
            bgColor: theme.textDark,
            fullWidth: true,
          ),
          if (capacity.advisoryText != null) ...[
            const SizedBox(height: 12),
            _ResultBox(
              title: 'Tavsiye Edilen',
              value: capacity.advisoryText!,
              bgColor: theme.red,
              fullWidth: true,
            ),
          ],
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _roomBuildingType == 'Dubleks' ? 'Kat Bazlı Sonuçlar' : 'Oda Bazlı Sonuçlar',
              style: TextStyle(
                color: theme.textDark,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...result.roomResults.map(
            (room) {
              final roomMeters = _radiatorMetersFromHeat(room.heatNeedW);
              final panelText = _panelDimensionText(roomMeters);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.softSection,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: theme.cardBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        room.roomName,
                        style: TextStyle(
                          color: theme.textDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${room.heatNeedW} W',
                          style: TextStyle(
                            color: theme.turquoiseText,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${roomMeters.toStringAsFixed(1)} m/tül',
                          style: TextStyle(
                            color: theme.purple,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          panelText,
                          style: TextStyle(
                            color: theme.textSoft,
                            fontWeight: FontWeight.w700,
                            fontSize: 11.8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpertSupportButton(_RadiatorTheme theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _openExpertSupport,
        icon: const Icon(Icons.support_agent_rounded),
        label: const Text(
          'UZMAN DESTEĞİ AL',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF25D366),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteCard(_RadiatorTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.softNote,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: theme.textDark),
              const SizedBox(width: 8),
              Text(
                'Not',
                style: TextStyle(
                  color: theme.textDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'HESAPLAMA TEKNİK, BÖLGESEL VERİLER GÖZ ÖNÜNE ALINARAK YAPILMIŞ OLUP, DOĞRU VE NET SONUÇ KEŞİF YAPILARAK ÇIKARTILMASI TAVSİYE OLUNUR.',
            style: TextStyle(
              color: theme.textSoft,
              fontSize: 13.2,
              height: 1.55,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ROOM FORM DATA
// -----------------------------------------------------------------------------
class _RoomFormData {
  final TextEditingController areaController = TextEditingController();

  String? roomType;
  String? facadeCount;

  void dispose() {
    areaController.dispose();
  }
}

// -----------------------------------------------------------------------------
// CAPACITY DECISION
// -----------------------------------------------------------------------------
class _CapacityDecision {
  final String recommendedText;
  final String? advisoryText;

  const _CapacityDecision({
    required this.recommendedText,
    required this.advisoryText,
  });
}

// -----------------------------------------------------------------------------
// THEME
// -----------------------------------------------------------------------------
class _RadiatorTheme {
  final Color pageBg = const Color(0xffF3F7FA);
  final Color cardBg = const Color(0xffFFFFFF);
  final Color softSection = const Color(0xffFAFCFD);
  final Color cardBorder = const Color(0xffDCE7EE);
  final Color shadow = const Color(0xffB7CAD6).withOpacity(0.16);

  final Color turquoise = const Color(0xffFF7A1A);
  final Color lightBlue = const Color(0xffFFA24A);
  final Color orange = const Color(0xffF2A257);
  final Color purple = const Color(0xff7C4DFF);
  final Color red = const Color(0xffD32F2F);

  final Color textDark = const Color(0xff23404D);
  final Color textSoft = const Color(0xff728391);

  final Color turquoiseText = const Color(0xffE87517);
  final Color softTurquoise = const Color(0xffFFF1E7);
  final Color softOrange = const Color(0xffFDF4EC);
  final Color softNote = const Color(0xffF7FBFD);
}

// -----------------------------------------------------------------------------
// RESULT BOX
// -----------------------------------------------------------------------------
class _ResultBox extends StatelessWidget {
  final String title;
  final String value;
  final Color bgColor;
  final bool fullWidth;

  const _ResultBox({
    required this.title,
    required this.value,
    required this.bgColor,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
            fullWidth ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: fullWidth ? TextAlign.left : TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.2,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: fullWidth ? TextAlign.left : TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SABİTLER
// -----------------------------------------------------------------------------
final List<String> _buildingTypes = TermoOptions.housingTypes;

const List<String> _floorStatuses = [
  'Ara Kat',
  'Zemin Kat',
  'Çatı Katı',
];

final List<String> _facadeCounts = TermoOptions.generalFacadeOptions;

final List<String> _roomFacadeCounts = TermoOptions.roomFacadeOptions;

final List<String> _windowTypes = TermoOptions.windowTypes;

final List<String> _windowAreas = TermoOptions.windowAreas;

const List<String> _insulationLevels = [
  'İyi',
  'Orta',
  'Zayıf',
];

final List<String> _roomTypes = TermoOptions.roomNameSuggestions;

final List<String> _cities = TermoLocationData.allCities;

const Set<String> _coldCities = {
  'Ağrı',
  'Ardahan',
  'Bayburt',
  'Bingöl',
  'Bitlis',
  'Erzincan',
  'Erzurum',
  'Gümüşhane',
  'Hakkâri',
  'Kars',
  'Muş',
  'Sivas',
  'Van',
};

const Set<String> _warmCities = {
  'Adana',
  'Antalya',
  'Aydın',
  'Hatay',
  'İzmir',
  'Mersin',
  'Muğla',
  'Osmaniye',
  'Şanlıurfa',
};

const Set<String> _coastalNonMetroCities = {
  'Artvin',
  'Bartın',
  'Çanakkale',
  'Düzce',
  'Edirne',
  'Giresun',
  'Kırklareli',
  'Rize',
  'Sinop',
  'Yalova',
  'Zonguldak',
};

const Map<String, List<String>> _metroDistricts = {
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
