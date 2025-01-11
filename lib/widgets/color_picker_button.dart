import 'package:flutter/material.dart';
import 'color_picker_dialog.dart';

class ColorPickerButton extends StatelessWidget {
  final Color currentColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPickerButton({
    Key? key,
    required this.currentColor,
    required this.onColorChanged,
  }) : super(key: key);

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ColorPickerDialog(
          currentColor: currentColor,
          onColorChanged: onColorChanged,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showColorPicker(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: currentColor,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
} 