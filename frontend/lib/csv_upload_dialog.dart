import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:ui';

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
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              width: 400,
              height: 260,
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
                    const Text(
                      'CARGUE EL ARCHIVO .CSV DE LOS NIVELES DE LOS RÍOS',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Colors.white,
                        letterSpacing: 1.1,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 2)],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pickFile,
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
                              _filePicked
                                  ? () {
                                    widget.onFileSelected(_filePath);
                                    Navigator.of(context).pop();
                                  }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(
                              _filePicked ? 0.28 : 0.12,
                            ),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
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
