import 'package:flutter/material.dart';
import 'package:adas/test_on_image/camera_test_view.dart';
import 'package:adas/tflite/recognition.dart';
import 'package:adas/ui/box_widget.dart';

class DetectionTestView extends StatefulWidget {
  const DetectionTestView({Key? key}) : super(key: key);

  @override
  _DetectionTestViewState createState() => _DetectionTestViewState();
}

class _DetectionTestViewState extends State<DetectionTestView> {
  List<Recognition>? results;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          CameraTestView(resultsCallback),
          boundingBoxes(results),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                'Test Object detection',
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
      setState(() {
        this.results = results;
      });
    }
  }
}
