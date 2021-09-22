import 'dart:io';
import 'dart:isolate';

import 'package:adas/tflite/classifier.dart';
import 'package:image/image.dart' as imageLib;
import 'package:tflite_flutter/tflite_flutter.dart';

class IsolateTest {
  static const String DEBUG_NAME = "InferenceTestIsolate";
  ReceivePort _receivePort = ReceivePort();
  SendPort? _sendPort;
  SendPort? get sendPort => _sendPort;

  Future<void> start() async {
    await Isolate.spawn<SendPort>(
      entryPoint,
      _receivePort.sendPort,
      debugName: DEBUG_NAME,
    );

    _sendPort = await _receivePort.first;
  }

  static void entryPoint(SendPort sendPort) async {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    await for (final IsolateTestData? isolateData in port) {
      if (isolateData != null) {
        Classifier classifier = Classifier(
            interpreter:
                Interpreter.fromAddress(isolateData.interpreterAddress),
            labels: isolateData.labels);

        imageLib.Image image = isolateData.image;

        if (Platform.isAndroid) {
          image = imageLib.copyRotate(image, 90);
        }
        Map<String, dynamic> results = classifier.predict(image);
        isolateData.responsePort!.send(results);
      }
    }
  }
}

class IsolateTestData {
  imageLib.Image image;
  int interpreterAddress;
  List<String> labels;
  SendPort? responsePort;

  IsolateTestData(this.image, this.interpreterAddress, this.labels);
}
