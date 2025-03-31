import 'package:tflite_flutter/tflite_flutter.dart';

class GrammyPredictionModel {
  late Interpreter _interpreter;

  GrammyPredictionModel() {
    _loadModel();
  }

  /// Load the TFLite model
  Future<void> _loadModel() async {
    _interpreter = await Interpreter.fromAsset('grammy_winner_predictor.tflite');
    print("✅ TFLite model loaded successfully");
  }

  /// Predict the winner probability for a given nominee
  Future<double> predictWinner({
    required double history,
    required double streams,
    required double reviews,
    required double buzz,
    required double sales,
  }) async {
    List<double> input = [history, streams, reviews, buzz, sales];
    List<double> output = [0.0];

    _interpreter.run(input, output);
    return output[0]; // Probability score
  }
}
