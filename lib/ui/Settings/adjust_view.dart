import 'package:flutter/material.dart';
import 'package:adas/ui/Settings/settings_data.dart';
import 'package:adas/ui/Settings/settings_row.dart';

class AdjustView extends StatefulWidget {
  const AdjustView({Key? key}) : super(key: key);

  @override
  _AdjustViewState createState() => _AdjustViewState();
}

class _AdjustViewState extends State<AdjustView> {
  static const String DISTANCE = 'Distance';
  static const String ACCURACY = 'Accuracy';

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await SettingsData.initSettings();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            SettingsRow(
                DISTANCE, SettingsData.distance, onIncrease, onDecrease),
            SettingsRow(
                ACCURACY, SettingsData.accuracy, onIncrease, onDecrease),
            ElevatedButton(
              onPressed: onSafePressed,
              child: Text('Safe'),
            )
          ],
        ),
      ),
    );
  }

  void onSafePressed() async {
    await SettingsData.writeSettings();
  }

  void onDecrease(String label) {
    if (mounted) {
      SettingsData.decrease(label);
      setState(() {});
    }
  }

  void onIncrease(String label) {
    if (mounted) {
      SettingsData.increase(label);
      setState(() {});
    }
  }
}
