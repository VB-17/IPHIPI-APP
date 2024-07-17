import 'dart:typed_data';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class AudioPlayerProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  Uint8List? _audioData;
  int _startSeekMilliseconds = 0;
  int _endSeekMilliseconds = 0;

  AudioPlayerProvider() {
    _audioPlayer.onDurationChanged.listen((newDuration) {
      _duration = newDuration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      _position = newPosition;
      if (_position.inMilliseconds >= _endSeekMilliseconds) {
        stop();
      }
      notifyListeners();
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      _audioPlayer.state = state;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      _position = Duration.zero;
      notifyListeners();
    });
  }

  Duration get duration => _duration;
  Duration get position => _position;
  bool get isPlaying => _audioPlayer.state == PlayerState.playing;
  bool get isPaused => _audioPlayer.state == PlayerState.paused;

  Future<void> setAudioSource(Uint8List audioData) async {
    _audioData = audioData;
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp_audio.wav');
    await tempFile.writeAsBytes(audioData);

    await _audioPlayer.setSource(DeviceFileSource(tempFile.path));
    notifyListeners();
  }

  Future<void> play(
      {int? startSeekMilliseconds, int? endSeekMilliseconds}) async {
    _startSeekMilliseconds = startSeekMilliseconds ?? 0;
    _endSeekMilliseconds = endSeekMilliseconds ?? _duration.inMilliseconds;

    if (_audioData != null) {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_audio.wav');
      await tempFile.writeAsBytes(_audioData!);
      await _audioPlayer.setSource(DeviceFileSource(tempFile.path));
    }

    await _audioPlayer.seek(Duration(milliseconds: _startSeekMilliseconds));
    await _audioPlayer.resume();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _audioPlayer.state = PlayerState.stopped;
    _position = Duration.zero;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
