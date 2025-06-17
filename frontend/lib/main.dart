import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/orinoco_api.dart';
import 'csv_upload_dialog.dart';
import 'hover_label.dart';
import 'location_stats_dialog.dart';
import 'general_stats_dialog.dart';
// <-- Add this line

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MapScreen());
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Variables para controlar el hover de cada pin
  bool _hoverAyacucho = false;
  bool _hoverCaicara = false;
  bool _hoverBolivar = false;
  bool _hoverPalua = false;
  Map<String, dynamic>? _predictionResult;

  // Helper to extract week data for a location
  List<double> _getWeekDataForLocation(String locationKey) {
    if (_predictionResult == null) return [10, 20, 35, 30, 50, 60, 50];
    final preds = _predictionResult!["7_day_prediction"] as List<dynamic>?;
    if (preds == null) return [10, 20, 35, 30, 50, 60, 50];
    return preds
        .map((e) => (e[locationKey] as num?)?.toDouble() ?? 0.0)
        .toList();
  }

  // Helper to extract week days (e.g. 'Lun', 'Mar', ...) or dates
  List<String> _getWeekLabels() {
    if (_predictionResult == null) {
      return ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    }
    final preds = _predictionResult!["7_day_prediction"] as List<dynamic>?;
    if (preds == null) return ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return preds.map((e) {
      final dateStr = e['date'] as String?;
      if (dateStr == null) return '';
      final date = DateTime.tryParse(dateStr);
      if (date == null) return dateStr;
      // Get weekday short name in Spanish
      const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      return days[date.weekday % 7] +
          '\n' +
          dateStr.substring(5); // e.g. Lun\n06-01
    }).toList();
  }

  // Helper to extract all rivers' data for general stats
  List<List<double>> _getAllRiversData() {
    if (_predictionResult == null) {
      return [
        [10, 20, 30, 40, 50, 60, 30],
        [8, 15, 25, 35, 45, 55, 25],
        [12, 18, 28, 38, 48, 58, 28],
        [5, 10, 20, 30, 40, 50, 20],
      ];
    }
    final preds = _predictionResult!["7_day_prediction"] as List<dynamic>?;
    if (preds == null)
      return [
        [10, 20, 30, 40, 50, 60, 30],
        [8, 15, 25, 35, 45, 55, 25],
        [12, 18, 28, 38, 48, 58, 28],
        [5, 10, 20, 30, 40, 50, 20],
      ];
    List<String> keys = ['ayacucho', 'caicara', 'ciudad_bolivar', 'palua'];
    return keys
        .map(
          (k) => preds.map((e) => (e[k] as num?)?.toDouble() ?? 0.0).toList(),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => CsvUploadDialog(
              onFileSelected: (_) {}, // No-op, all logic is in the dialog now
            ),
      );
      // Only proceed if result is not null (valid CSV)
      if (result != null) {
        setState(() {
          _predictionResult = result;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          // Define pin positions as percentages (adjust these for your map)
          final pins = [
            {
              'left': 0.12, // 16% from the left
              'top': 0.78, // 74% from the top
              'hover': _hoverAyacucho,
              'label': 'PUERTO AYACUCHO',
              'imagePath': 'Assets/ptoayacuchoimg.png',
              'onEnter': () => setState(() => _hoverAyacucho = true),
              'onExit': () => setState(() => _hoverAyacucho = false),
            },
            {
              'left': 0.29,
              'top': 0.49,
              'hover': _hoverCaicara,
              'label': 'CAICARA',
              'imagePath': 'Assets/caicaraimg.png',
              'onEnter': () => setState(() => _hoverCaicara = true),
              'onExit': () => setState(() => _hoverCaicara = false),
            },
            {
              'left': 0.57,
              'top': 0.39,
              'hover': _hoverBolivar,
              'label': 'CIUDAD BOLÍVAR',
              'imagePath': 'Assets/cdbolivarimg.png',
              'onEnter': () => setState(() => _hoverBolivar = true),
              'onExit': () => setState(() => _hoverBolivar = false),
            },
            {
              'left': 0.75,
              'top': 0.32,
              'hover': _hoverPalua,
              'label': 'PALÚA',
              'imagePath': 'Assets/paluaimg.png',
              'onEnter': () => setState(() => _hoverPalua = true),
              'onExit': () => setState(() => _hoverPalua = false),
            },
          ];

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset('Assets/fondo.png', fit: BoxFit.cover),
              ),
              // Pins
              ...pins.map(
                (pin) => Positioned(
                  left: (pin['left'] as double) * width,
                  top: (pin['top'] as double) * height,
                  child: MouseRegion(
                    onEnter: (_) => (pin['onEnter'] as void Function())(),
                    onExit: (_) => (pin['onExit'] as void Function())(),
                    child: GestureDetector(
                      onTap: () {
                        // Map pin label to API key
                        final label = pin['label'] as String;
                        String key = '';
                        if (label.contains('AYACUCHO'))
                          key = 'ayacucho';
                        else if (label.contains('CAICARA'))
                          key = 'caicara';
                        else if (label.contains('BOLÍVAR'))
                          key = 'ciudad_bolivar';
                        else if (label.contains('PALÚA'))
                          key = 'palua';
                        showDialog(
                          context: context,
                          builder:
                              (context) => LocationStatsDialog(
                                location: label,
                                weekData: _getWeekDataForLocation(key),
                                weekDays: _getWeekLabels(),
                              ),
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (pin['hover'] as bool)
                            HoverLabel(imagePath: pin['imagePath'] as String),
                          if (!(pin['hover'] as bool))
                            Icon(
                              Icons.location_on,
                              color: Colors.blue,
                              size: 32,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Botón "Predicción general" con glassmorphism
              Positioned(
                right: 40,
                bottom: 40,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => GeneralStatsDialog(
                            barDataSets: _getAllRiversData(),
                            lineDataSets: _getAllRiversData(),
                            labels: _getWeekLabels(),
                            barNames: [
                              'Puerto Ayacucho',
                              'Caicara',
                              'Ciudad Bolívar',
                              'Palúa',
                            ],
                            lineNames: [
                              'Puerto Ayacucho',
                              'Caicara',
                              'Ciudad Bolívar',
                              'Palúa',
                            ],
                          ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Predicción general',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
