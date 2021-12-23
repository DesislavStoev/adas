import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:adas/tflite/classifier.dart';
import 'package:adas/tflite/recognition.dart';
import 'package:camera/camera.dart';
import 'package:adas/ui/camera_view_singleton.dart';
import 'package:adas/utils/isolate_utils.dart';

class CameraView extends StatefulWidget {
  final Function(List<Recognition>? recognitions) resultsCallback;

  const CameraView(this.resultsCallback);

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  List<CameraDescription>? cameras;
  CameraController? cameraController;
  bool predicting = false;
  Classifier? classifier;
  IsolateUtils? isolateUtils;

  @override
  void initState() {
    super.initState();
    initStateAsync();
  }

  void initStateAsync() async {
    WidgetsBinding.instance!.addObserver(this);

    isolateUtils = IsolateUtils();
    await isolateUtils!.start();
    initializeCamera();

    if (classifier == null) {
      classifier = Classifier();
    }
  }

  void initializeCamera() async {
    cameras = await availableCameras();

    cameraController = CameraController(cameras![0], ResolutionPreset.high,
        enableAudio: false);

    await cameraController!.initialize().then((_) async {
      await cameraController!.startImageStream(onImage);

      Size previewSize = cameraController!.value.previewSize ?? Size(0, 0);
      Size screenSize = MediaQuery.of(context).size;

      //TODO X axis is not very accurate, need to fix it.
      CameraViewSingleton.ratioX =
          screenSize.width / (previewSize.width); //? empty spaces on the right
      CameraViewSingleton.ratioY = screenSize.height / previewSize.height;
    });
  }

  onImage(CameraImage cameraImage) async {
    if (classifier?.interpreter != null && classifier?.labels != null) {
      if (predicting || cameraController == null) {
        return;
      }
      setState(() {
        predicting = true;
      });

      var isolateData = IsolateData(
          cameraImage, classifier!.interpreter!.address, classifier!.labels!);

      var inferenceResults = await inference(isolateData);
      widget.resultsCallback(inferenceResults['recognition']);

      if (mounted) {
        setState(() {
          predicting = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> inference(IsolateData isolateData) async {
    ReceivePort responsePort = ReceivePort();
    isolateUtils!.sendPort!
        .send(isolateData..responsePort = responsePort.sendPort);
    var results = await responsePort.first;
    return results;
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return Container();
    }

    return CameraPreview(cameraController!);
  }

  @override
  void dispose() async {
    super.dispose();
    //TODO find better way to dispose
    await cameraController!.dispose();
    isolateUtils!.stop();
  }
}
