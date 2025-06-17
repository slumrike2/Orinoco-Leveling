import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'csv_upload_dialog.dart';
import 'hover_label.dart';
import 'location_stats_dialog.dart';
import 'dart:ui'; // <-- Add this line

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => CsvUploadDialog(
              onFileSelected: (filePath) {
                // Aquí puedes manejar el archivo seleccionado
              },
            ),
      );
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
              'onEnter': () => setState(() => _hoverAyacucho = true),
              'onExit': () => setState(() => _hoverAyacucho = false),
            },
            {
              'left': 0.29,
              'top': 0.49,
              'hover': _hoverCaicara,
              'label': 'CAICARA',
              'onEnter': () => setState(() => _hoverCaicara = true),
              'onExit': () => setState(() => _hoverCaicara = false),
            },
            {
              'left': 0.57,
              'top': 0.39,
              'hover': _hoverBolivar,
              'label': 'CIUDAD BOLÍVAR',
              'onEnter': () => setState(() => _hoverBolivar = true),
              'onExit': () => setState(() => _hoverBolivar = false),
            },
            {
              'left': 0.75,
              'top': 0.32,
              'hover': _hoverPalua,
              'label': 'PALÚA',
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
                        showDialog(
                          context: context,
                          builder:
                              (context) => LocationStatsDialog(
                                location: pin['label'] as String,
                                weekData: [10, 20, 35, 30, 50, 60, 50],
                                weekDays: [
                                  'Lun',
                                  'Mar',
                                  'Mié',
                                  'Jue',
                                  'Vie',
                                  'Sáb',
                                  'Dom',
                                ],
                              ),
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (pin['hover'] as bool)
                            HoverLabel(text: pin['label'] as String),
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Text(
                        'PREDICCIÓN GENERAL',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
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
