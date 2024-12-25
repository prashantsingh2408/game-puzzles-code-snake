import 'package:flutter/material.dart';
import '../game/game_settings.dart';
import 'color_picker_button.dart';

class SettingsMenu extends StatefulWidget {
  final Function onSettingsChanged;

  const SettingsMenu({Key? key, required this.onSettingsChanged}) : super(key: key);

  @override
  _SettingsMenuState createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  final GameSettings settings = GameSettings();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Game Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildSettingRow(
              'Timer Mode',
              Switch(
                value: settings.timerMode,
                onChanged: (value) {
                  setState(() {
                    settings.updateSettings(timerMode: value);
                    widget.onSettingsChanged();
                  });
                },
              ),
            ),
            _buildSettingRow(
              'Game Speed',
              Slider(
                value: settings.gameSpeed,
                min: 0.5,
                max: 2.0,
                divisions: 3,
                label: '${settings.gameSpeed}x',
                onChanged: (value) {
                  setState(() {
                    settings.updateSettings(gameSpeed: value);
                    widget.onSettingsChanged();
                  });
                },
              ),
            ),
            _buildSettingRow(
              'Wall Collision',
              Switch(
                value: settings.wallCollision,
                onChanged: (value) {
                  setState(() {
                    settings.updateSettings(wallCollision: value);
                    widget.onSettingsChanged();
                  });
                },
              ),
            ),
            _buildSettingRow(
              'Self Collision',
              Switch(
                value: settings.selfCollision,
                onChanged: (value) {
                  setState(() {
                    settings.updateSettings(selfCollision: value);
                    widget.onSettingsChanged();
                  });
                },
              ),
            ),
            _buildSettingRow(
              'Snake Color',
              ColorPickerButton(
                currentColor: settings.snakeColor,
                onColorChanged: (color) {
                  setState(() {
                    settings.updateSettings(snakeColor: color);
                    widget.onSettingsChanged();
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(String label, Widget control) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
          control,
        ],
      ),
    );
  }
} 