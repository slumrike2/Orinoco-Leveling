import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:ui';
import 'dart:io';
import 'package:frontend/orinoco_api.dart';

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
  String? _errorMessage;
  bool _showFormat = false;
  bool _isLoading = false;

  static const int _requiredRows = 31;
  static const String _csvFormat =
      'El archivo debe tener las siguientes columnas :\n'
      'fecha,ayacucho,caicara,ciudad_bolivar,palua\n'
      'donde cada region representa el nivel del rio en esa fecha\n'
      'y debe contener $_requiredRows filas de datos numéricos consecutivos.';

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
        _errorMessage = null;
      });
    }
  }

  Future<void> _trySend() async {
    if (!_filePicked || _filePath == null) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final api = OrinocoApi();
      final file = File(_filePath!);
      final result = await api.predictCsv(file);
      if (!mounted) return;
      Navigator.of(context).pop(result); // Return the prediction data
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst(RegExp(r'Exception: ?'), '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              width: 420,
              height: 320,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(24),
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
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'CARGUE EL ARCHIVO .CSV DE LOS NIVELES DE LOS RÍOS',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: Colors.white,
                              letterSpacing: 1.1,
                              shadows: [
                                Shadow(color: Colors.black54, blurRadius: 2),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: _csvFormat,
                          triggerMode: TooltipTriggerMode.tap,
                          showDuration: const Duration(seconds: 8),
                          child: GestureDetector(
                            onTap:
                                () =>
                                    setState(() => _showFormat = !_showFormat),
                            child: const Icon(
                              Icons.help_outline,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_showFormat)
                      Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _csvFormat,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 4),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _pickFile,
                            icon: const Icon(
                              Icons.upload_file,
                              color: Colors.white,
                            ),
                            label: Text(
                              (_fileName ?? 'SELECCIONAR ARCHIVO')
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.18),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed:
                              _filePicked && !_isLoading ? _trySend : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(
                              _filePicked ? 0.28 : 0.12,
                            ),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                  : const Text(
                                    'ENVIAR',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
