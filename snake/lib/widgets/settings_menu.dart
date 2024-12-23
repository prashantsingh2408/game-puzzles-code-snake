import 'package:flutter/material.dart';
import '../game/game_settings.dart';

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
      backgroundColor: Colors.black87,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Game Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Timer Mode', style: TextStyle(color: Colors.white)),
              value: settings.timerMode,
              activeColor: Colors.green,
              onChanged: (value) {
                setState(() {
                  settings.updateSettings(timerMode: value);
                  widget.onSettingsChanged();
                });
              },
            ),
            if (settings.timerMode)
              ListTile(
                title: const Text('Time to Collect Food', style: TextStyle(color: Colors.white)),
                trailing: DropdownButton<int>(
                  dropdownColor: Colors.black87,
                  value: settings.timerDuration,
                  items: [5, 10, 15, 20].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(
                        '$value sec',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      settings.updateSettings(timerDuration: value);
                      widget.onSettingsChanged();
                    });
                  },
                ),
              ),
            ListTile(
              title: const Text('Game Speed', style: TextStyle(color: Colors.white)),
              trailing: SizedBox(
                width: 200,
                child: Slider(
                  value: settings.gameSpeed,
                  min: 0.5,
                  max: 2.0,
                  divisions: 3,
                  label: '${settings.gameSpeed}x',
                  activeColor: Colors.green,
                  onChanged: (value) {
                    setState(() {
                      settings.updateSettings(gameSpeed: value);
                      widget.onSettingsChanged();
                    });
                  },
                ),
              ),
            ),
            SwitchListTile(
              title: const Text('Wall Collision', style: TextStyle(color: Colors.white)),
              value: settings.wallCollision,
              activeColor: Colors.green,
              onChanged: (value) {
                setState(() {
                  settings.updateSettings(wallCollision: value);
                  widget.onSettingsChanged();
                });
              },
            ),
            SwitchListTile(
              title: const Text('Self Collision', style: TextStyle(color: Colors.white)),
              subtitle: const Text(
                'Snake dies when hitting itself',
                style: TextStyle(color: Colors.grey),
              ),
              value: settings.selfCollision,
              activeColor: Colors.green,
              onChanged: (value) {
                setState(() {
                  settings.updateSettings(selfCollision: value);
                  widget.onSettingsChanged();
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
} 