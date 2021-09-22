import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class SettingsData {
  static const String DISTANCE = 'Distance';
  static const int DISTANCE_MAX = 1000;
  static const int DISTANCE_MIN = 0;
  static const double DISTANCE_DEFAULT_VALUE = 1.0;
  static const String ACCURACY = 'Accuracy';
  static const double ACCURACY_MAX = 0.99;
  static const double ACCURACY_MIN = 0.01;
  static const double ACCURACY_DEFAULT_VALUE = 0.60;
  static double _distance = DISTANCE_DEFAULT_VALUE;
  static double _accuracy = ACCURACY_DEFAULT_VALUE;

  static double get distance => _distance;
  static double get accuracy => _accuracy;

  static Future initSettings() async {
    try {
      final file = await _localFile;

      final contentString = await file.readAsString();
      final Map<String, dynamic> json = jsonDecode(contentString);
      _distance = json['distance'] ?? _distance;
      _accuracy = json['accuracy'] ?? _accuracy;
    } catch (e) {
      _distance = DISTANCE_DEFAULT_VALUE;
      _accuracy = ACCURACY_DEFAULT_VALUE;
    }
  }

  static Future<File> writeSettings() async {
    final file = await _localFile;
    var content = '{"distance":$_distance,"accuracy":$_accuracy}';
    return file.writeAsString(content);
  }

  static void increase(String label) {
    switch (label) {
      case DISTANCE:
        if (_distance < DISTANCE_MAX) {
          _distance++;
        }
        break;
      case ACCURACY:
        if (_accuracy < ACCURACY_MAX) {
          _accuracy += 0.01;
        }
        break;
      default:
    }
  }

  static void decrease(String label) {
    switch (label) {
      case DISTANCE:
        if (_distance > DISTANCE_MIN) {
          _distance--;
        }
        break;
      case ACCURACY:
        if (_accuracy > ACCURACY_MIN) {
          _accuracy -= 0.01;
        }
        break;
      default:
    }
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/settings.txt');
  }
}
