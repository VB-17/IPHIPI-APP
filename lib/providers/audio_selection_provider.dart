import 'package:flutter/foundation.dart';

class AudioSelectionState extends ChangeNotifier {
  double _startX = 0.0;
  double _endX = 0.0;
  double _canvasWidth = 0.0;

  double get startX => _startX;
  double get endX => _endX;
  double get canvasWidth => _canvasWidth;

  int startSeek(Duration duration) =>
      ((startX / canvasWidth) * duration.inMilliseconds).round();

  int endSeek(Duration duration) =>
      ((endX / canvasWidth) * duration.inMilliseconds).round();

  set startX(double value) {
    _startX = value;
    notifyListeners();
  }

  set endX(double value) {
    _endX = value;
    notifyListeners();
  }

  void setCanvasWidth(double width) {
    _canvasWidth = width;
    notifyListeners();
  }
}
