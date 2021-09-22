import 'package:flutter/material.dart';
import 'package:adas/tflite/recognition.dart';
import 'package:adas/ui/Settings/settings_data.dart';
import 'package:adas/ui/box_widget.dart';
import 'package:adas/ui/camera_view.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class DetectionView extends StatefulWidget {
  @override
  _DetectionViewState createState() => _DetectionViewState();
}

class _DetectionViewState extends State<DetectionView> {
  List<Recognition>? results;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          CameraView(resultsCallback),
          boundingBoxes(results),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                'Object detection',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrangeAccent.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget boundingBoxes(List<Recognition>? results) {
    if (results == null) {
      return Container();
    }
    return Stack(
      children: results
          .map((e) => BoxWidget(
                result: e,
              ))
          .toList(),
    );
  }

  void resultsCallback(List<Recognition>? results) {
    if (mounted) {
      var contains = results?.where(
          (element) => element.location!.bottom <= SettingsData.distance);
      if (contains!.isNotEmpty) {
        FlutterRingtonePlayer.playNotification();
      }

      setState(() {
        this.results = results;
      });
    }
  }
}
