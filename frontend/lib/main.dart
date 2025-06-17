import 'package:flutter/material.dart';
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
                            HoverLabel(imagePath: pin['imagePath'] as String,),
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
                            barDataSets: [
                              [10, 20, 30, 40, 50, 60, 30], // Ejemplo 1
                              [8, 15, 25, 35, 45, 55, 25], // Ejemplo 2
                              [12, 18, 28, 38, 48, 58, 28], // Ejemplo 3
                              [5, 10, 20, 30, 40, 50, 20], // Ejemplo 4
                            ],
                            lineDataSets: [
                              [10, 20, 30, 40, 50, 60, 30],
                              [8, 15, 25, 35, 45, 55, 25],
                              [12, 18, 28, 38, 48, 58, 28],
                              [5, 10, 20, 30, 40, 50, 20],
                            ],
                            labels: [
                              'Lun',
                              'Mar',
                              'Mié',
                              'Jue',
                              'Vie',
                              'Sáb',
                              'Dom',
                            ],
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
