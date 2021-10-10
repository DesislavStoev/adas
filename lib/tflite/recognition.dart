import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:adas/ui/camera_view_singleton.dart';

class Recognition {
  int _id;
  String _label;
  double _score;
  Rect? _location;

  Recognition(this._id, this._label, this._score, [this._location]);

  Rect? get location => _location;
  int get id => _id;
  String get label => _label;
  double get score => _score;

  Rect get renderLocation {
    var ratioX = CameraViewSingleton.ratio;
    var ratioY = ratioX;

    var transLeft = max(0.1, location!.left * ratioX);
    var transTop = max(0.1, location!.top * ratioY);

    var transWidth = min(
        location!.width * ratioX, CameraViewSingleton.actualPreviewSize.width);

    var transHeigth = min(location!.height * ratioY,
        CameraViewSingleton.actualPreviewSize.height);

    var transformedRect =
        Rect.fromLTWH(transLeft, transTop, transWidth, transHeigth);

    return transformedRect;
  }

  @override
  String toString() {
    return 'Recognition(id: $id, label: $label, score: $score, location: $location)';
  }
}
