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
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset('Assets/fondo.png', fit: BoxFit.cover),
          ),
          // Pin: Puerto Ayacucho
          Positioned(
            left: 210, // Adjusted for your map
            top: 710,
            child: MouseRegion(
              onEnter: (_) => setState(() => _hoverAyacucho = true),
              onExit: (_) => setState(() => _hoverAyacucho = false),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) =>
                            LocationStatsDialog(location: 'PUERTO AYACUCHO'),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_hoverAyacucho) HoverLabel(text: 'PUERTO AYACUCHO'),
                    if (!_hoverAyacucho)
                      Icon(Icons.location_on, color: Colors.blue, size: 32),
                  ],
                ),
              ),
            ),
          ),
          // Pin: Caicara
          Positioned(
            left: 380, // Adjusted for your map
            top: 470,
            child: MouseRegion(
              onEnter: (_) => setState(() => _hoverCaicara = true),
              onExit: (_) => setState(() => _hoverCaicara = false),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => LocationStatsDialog(location: 'CAICARA'),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_hoverCaicara) HoverLabel(text: 'CAICARA'),
                    if (!_hoverCaicara)
                      Icon(Icons.location_on, color: Colors.blue, size: 32),
                  ],
                ),
              ),
            ),
          ),
          // Pin: Ciudad Bolívar
          Positioned(
            left: 870, // Adjusted for your map
            top: 360,
            child: MouseRegion(
              onEnter: (_) => setState(() => _hoverBolivar = true),
              onExit: (_) => setState(() => _hoverBolivar = false),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) =>
                            LocationStatsDialog(location: 'CIUDAD BOLÍVAR'),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_hoverBolivar) HoverLabel(text: 'CIUDAD BOLÍVAR'),
                    if (!_hoverBolivar)
                      Icon(Icons.location_on, color: Colors.blue, size: 32),
                  ],
                ),
              ),
            ),
          ),
          // Pin: Palúa
          Positioned(
            left: 1150, // Adjusted for your map
            top: 280,
            child: MouseRegion(
              onEnter: (_) => setState(() => _hoverPalua = true),
              onExit: (_) => setState(() => _hoverPalua = false),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => LocationStatsDialog(location: 'PALÚA'),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_hoverPalua) HoverLabel(text: 'PALÚA'),
                    if (!_hoverPalua)
                      Icon(Icons.location_on, color: Colors.blue, size: 32),
                  ],
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
      ),
    );
  }
}
