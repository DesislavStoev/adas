import 'dart:math';
import 'package:adas/tflite/recognition.dart';
import 'package:adas/ui/Settings/settings_data.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:image/image.dart' as imageLib;

class Classifier {
  static const int INPUT_SIZE = 300;
  static const double SCORE_THRESHOLD = 0.45;
  static const int NUM_RESULTS = 10;

  ImageProcessor? imageProcessor;
  Interpreter? _interpreter;
  List<String>? _labels;
  List<List<int>>? _outputShapes;
  List<TfLiteType>? _outputTypes;

  Classifier({
    Interpreter? interpreter,
    List<String>? labels,
  }) {
    loadModel(interpreter);
    loadLabels(labels);
  }

  void loadModel(Interpreter? interpreter) async {
    try {
      _interpreter = interpreter ??
          await Interpreter.fromAsset(
            'detect.tflite',
            options: InterpreterOptions()..threads = 2,
          );

      var outputTensors = _interpreter!.getOutputTensors();
      _outputShapes = [];
      _outputTypes = [];

      outputTensors.forEach((tensor) {
        print(tensor);
        _outputShapes!.add(tensor.shape);
        _outputTypes!.add(tensor.type);
      });
    } catch (e) {
      print("Error while creating interpreter: $e");
    }
  }

  void loadLabels(List<String>? labels) async {
    try {
      _labels = labels ?? await FileUtil.loadLabels('assets/' + 'label.txt');
    } catch (e) {
      print("Error while loading labels: $e");
    }
  }

  TensorImage getProcessedImage(TensorImage inputImage) {
    var padSize = max(inputImage.height, inputImage.width);
    if (imageProcessor == null) {
      imageProcessor = ImageProcessorBuilder()
          .add(ResizeWithCropOrPadOp(padSize, padSize))
          .add(ResizeOp(INPUT_SIZE, INPUT_SIZE, ResizeMethod.BILINEAR))
          .build();
    }

    inputImage = imageProcessor!.process(inputImage);
    return inputImage;
  }

  Map<String, dynamic> predict(imageLib.Image image) {
    if (_interpreter == null) {
      return Map<String, dynamic>();
    }

    TensorImage inputImage = TensorImage.fromImage(image);

    inputImage = getProcessedImage(inputImage);

    var outputLocations = TensorBufferFloat(_outputShapes![0]);
    var outputClasses = TensorBufferFloat(_outputShapes![1]);
    var outputScores = TensorBufferFloat(_outputShapes![2]);
    var numLocation = TensorBufferFloat(_outputShapes![3]);

    var inputs = [inputImage.buffer];

    var outputs = {
      0: outputLocations.buffer,
      1: outputClasses.buffer,
      2: outputScores.buffer,
      3: numLocation.buffer,
    };

    _interpreter!.runForMultipleInputs(inputs, outputs);
    var resultCount = min(NUM_RESULTS, numLocation.getIntValue(0));

    var locations = BoundingBoxUtils.convert(
      tensor: outputLocations,
      valueIndex: [1, 0, 3, 2],
      boundingBoxAxis: 2,
      boundingBoxType: BoundingBoxType.BOUNDARIES,
      coordinateType: CoordinateType.RATIO,
      height: INPUT_SIZE,
      width: INPUT_SIZE,
    );

    List<Recognition> recognitions = [];
    var labelOffset = 1;

    for (int i = 0; i < resultCount; i++) {
      var score = outputScores.getDoubleValue(i);

      var labelIndex = outputClasses.getIntValue(i) + labelOffset;
      var label = _labels!.elementAt(labelIndex);

      if (score > SettingsData.accuracy) {
        var transformedRect = imageProcessor?.inverseTransformRect(
            locations[i], image.height, image.width);

        recognitions.add(
          Recognition(i, label, score, transformedRect),
        );
      }
    }
    return {'recognition': recognitions};
  }

  Interpreter? get interpreter => _interpreter;

  List<String>? get labels => _labels;
}
