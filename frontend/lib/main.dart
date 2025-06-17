import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

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

class CsvUploadDialog extends StatefulWidget {
  final void Function(String? filePath) onFileSelected;
  const CsvUploadDialog({super.key, required this.onFileSelected});

  @override
  State<CsvUploadDialog> createState() => _CsvUploadDialogState();
}

class _CsvUploadDialogState extends State<CsvUploadDialog> {
  String? _fileName;
  String? _filePath;
  bool _filePicked = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xls', 'xlsx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _fileName = result.files.single.name;
        _filePath = result.files.single.path;
        _filePicked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white.withOpacity(0.85),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cargue el archivo .csv de los niveles de los ríos',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.upload_file),
                    label: Text(_fileName ?? 'Seleccionar archivo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black54,
                      elevation: 0,
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed:
                      _filePicked
                          ? () {
                            widget.onFileSelected(_filePath);
                            Navigator.of(context).pop();
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade400,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Enviar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

  // Coordenadas relativas (0.0 - 1.0) para cada pin
  final Map<String, Offset> _pinPositions = {
    'ayacucho': Offset(0.13, 0.75), // left: 120, top: 420 (aprox)
    'caicara': Offset(0.35, 0.62),  // left: 320, top: 350
    'bolivar': Offset(0.55, 0.53),  // left: 500, top: 300
    'palua': Offset(0.88, 0.35),    // left: 800, top: 200
  };

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
          return Stack(
            children: [
              // Imagen de fondo (BoxFit.contain para que no se recorte)
              Positioned.fill(
                child: Image.asset(
                  'Assets/fondo.png',
                  fit: BoxFit.contain,
                ),
              ),
              // Pin: Puerto Ayacucho
              Align(
                alignment: Alignment(
                  -0.74, // (0.13*2-1)
                  0.5,   // (0.75*2-1)
                ),
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoverAyacucho = true),
                  onExit: (_) => setState(() => _hoverAyacucho = false),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_hoverAyacucho) _HoverLabel(text: 'PUERTO AYACUCHO'),
                      if (!_hoverAyacucho)
                        Icon(Icons.location_on, color: Colors.blue, size: 32),
                    ],
                  ),
                ),
              ),
              // Pin: Caicara
              Align(
                alignment: Alignment(
                  -0.3, // (0.35*2-1)
                  0.24, // (0.62*2-1)
                ),
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoverCaicara = true),
                  onExit: (_) => setState(() => _hoverCaicara = false),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_hoverCaicara) _HoverLabel(text: 'CAICARA'),
                      if (!_hoverCaicara)
                        Icon(Icons.location_on, color: Colors.blue, size: 32),
                    ],
                  ),
                ),
              ),
              // Pin: Ciudad Bolívar
              Align(
                alignment: Alignment(
                  0.1, // (0.55*2-1)
                  0.06, // (0.53*2-1)
                ),
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoverBolivar = true),
                  onExit: (_) => setState(() => _hoverBolivar = false),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_hoverBolivar) _HoverLabel(text: 'CIUDAD BOLÍVAR'),
                      if (!_hoverBolivar)
                        Icon(Icons.location_on, color: Colors.blue, size: 32),
                    ],
                  ),
                ),
              ),
              // Pin: Palúa
              Align(
                alignment: Alignment(
                  0.76, // (0.88*2-1)
                  -0.3, // (0.35*2-1)
                ),
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoverPalua = true),
                  onExit: (_) => setState(() => _hoverPalua = false),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_hoverPalua) _HoverLabel(text: 'PALÚA'),
                      if (!_hoverPalua)
                        Icon(Icons.location_on, color: Colors.blue, size: 32),
                    ],
                  ),
                ),
              ),
              // Botón "Predicción general"
              Positioned(
                right: 40,
                bottom: 40,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            ],
          );
        },
      ),
    );
  }
}

class _HoverLabel extends StatelessWidget {
  final String text;
  const _HoverLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _LocationDialog extends StatelessWidget {
  final String nombre;
  const _LocationDialog({required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Text(
          nombre,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
