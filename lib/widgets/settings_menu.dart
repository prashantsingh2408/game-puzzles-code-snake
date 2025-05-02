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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Game Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Background Settings Section
              const Text(
                'Background Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildSettingRow(
                'Use Background Image',
                Switch(
                  value: settings.useBackgroundImage,
                  onChanged: (value) {
                    setState(() {
                      settings.updateSettings(useBackgroundImage: value);
                      widget.onSettingsChanged();
                    });
                  },
                ),
              ),
              if (!settings.useBackgroundImage)
                _buildSettingRow(
                  'Background Color',
                  ColorPickerButton(
                    currentColor: settings.backgroundColor,
                    onColorChanged: (color) {
                      setState(() {
                        settings.updateSettings(backgroundColor: color);
                        widget.onSettingsChanged();
                      });
                    },
                  ),
                ),
              
              const SizedBox(height: 20),
              // Game Settings Section
              const Text(
                'Game Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Infinite Viewport'),
                value: settings.infiniteViewport,
                onChanged: (bool value) {
                  setState(() {
                    settings.infiniteViewport = value;
                    widget.onSettingsChanged();
                  });
                },
              ),
              
              // Add obstacle density control
              ListTile(
                title: const Text('Obstacle Density'),
                subtitle: Slider(
                  value: settings.obstacleDensity.toDouble(),
                  min: 1,
                  max: 3,
                  divisions: 2,
                  label: {
                    1: 'Few',
                    2: 'Medium',
                    3: 'Many'
                  }[settings.obstacleDensity],
                  onChanged: (double value) {
                    setState(() {
                      settings.obstacleDensity = value.round();
                      widget.onSettingsChanged();
                    });
                  },
                ),
              ),
              
              SwitchListTile(
                title: const Text('Timer Mode'),
                value: settings.timerMode,
                onChanged: (value) {
                  setState(() {
                    settings.updateSettings(timerMode: value);
                    widget.onSettingsChanged();
                  });
                },
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
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
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