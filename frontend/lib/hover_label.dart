import 'package:flutter/material.dart';

class HoverLabel extends StatelessWidget {
  final String? imagePath;

  const HoverLabel({this.imagePath, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imagePath == null) return const SizedBox.shrink();
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: Image.asset(imagePath!, width: 160, fit: BoxFit.cover),
    );
  }
}
