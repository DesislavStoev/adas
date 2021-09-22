import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adas/test_on_image/isolate_test.dart';
import 'package:adas/tflite/classifier.dart';
import 'package:adas/tflite/recognition.dart';
import 'package:adas/ui/camera_view_singleton.dart';
import 'package:image/image.dart' as imageLib;
import 'package:path_provider/path_provider.dart';

class CameraTestView extends StatefulWidget {
  final Function(List<Recognition>? recognitions) resultsCallback;

  const CameraTestView(this.resultsCallback);

  @override
  _CameraTestViewState createState() => _CameraTestViewState();
}

class _CameraTestViewState extends State<CameraTestView>
    with WidgetsBindingObserver {
  Classifier? classifier;
  File? imageFile;
  IsolateTest? isolateTest;

  @override
  void initState() {
    super.initState();
    initStateAsync();
  }

  void initStateAsync() async {
    WidgetsBinding.instance!.addObserver(this);

    // isolateTest = IsolateTest();
    // await isolateTest!.start();
    if (classifier == null) {
      classifier = Classifier();
    }

    File f = await getImageFileFromAssets('a9.jpg');
    var bytes = f.readAsBytesSync();
    var im = imageLib.decodeJpg(bytes);
    // var isolateData = IsolateTestData(
    //     im, classifier!.interpreter!.address, classifier!.labels!);
    // var inferenceResults = await inference(isolateData);
    CameraViewSingleton.ratio = 1;
    CameraViewSingleton.screenSize = MediaQuery.of(context).size;
    if (Platform.isAndroid) {
      im = imageLib.copyRotate(im, 90);
    }
    var thumbnail = imageLib.copyResize(im, width: 300, height: 300);
    Map<String, dynamic> results = classifier!.predict(thumbnail);

    setState(() {
      imageFile = f;
    });

    // widget.resultsCallback(inferenceResults['recognition']);
    widget.resultsCallback(results['recognition']);
  }

  @override
  Widget build(BuildContext context) {
    if (imageFile != null) {
      return Container(
        child: Image.file(imageFile!),
      );
    } else {
      return Container();
    }
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  Future<Map<String, dynamic>> inference(IsolateTestData isolateData) async {
    ReceivePort responsePort = ReceivePort();
    isolateTest!.sendPort!
        .send(isolateData..responsePort = responsePort.sendPort);
    var results = await responsePort.first;
    return results;
  }
}
