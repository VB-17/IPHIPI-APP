import 'dart:ffi';
import 'dart:io';
import 'dart:async';

import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:iphipi/providers/audio_selection_provider.dart';
import 'package:path_provider/path_provider.dart';

class AudioPlayerFromBytes extends StatefulWidget {
  final Uint8List audioData;
  final AudioSelectionState selectionState;

  const AudioPlayerFromBytes({
    Key? key,
    required this.audioData,
    required this.selectionState,
  }) : super(key: key);

  @override
  _AudioPlayerFromBytesState createState() => _AudioPlayerFromBytesState();
}

class _AudioPlayerFromBytesState extends State<AudioPlayerFromBytes> {
  late AudioPlayer player;

  PlayerState? _playerState;
  Duration? _duration;
  Duration? _position;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  bool get _isPlaying => _playerState == PlayerState.playing;

  bool get _isPaused => _playerState == PlayerState.paused;

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
    _playerState = player.state;

    player.getDuration().then(
          (value) => setState(
            () {
              _duration = value;
            },
          ),
        );
    player.getCurrentPosition().then(
          (value) => setState(
            () {
              _position = value;
            },
          ),
        );

    player.setReleaseMode(ReleaseMode.stop);

    setAudioFromBytes(widget.audioData);

    _initStreams();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    super.dispose();
  }

  Future<void> setAudioFromBytes(Uint8List audioData) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp_audio.wav');
    await tempFile.writeAsBytes(audioData);

    await player.setSource(DeviceFileSource(tempFile.path));

    int n = ((_duration!.inMilliseconds / widget.selectionState.canvasWidth) *
            widget.selectionState.startX)
        .round();
    player.seek(Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext context) {
    // print("Duration: $_duration");

    final color = Theme.of(context).primaryColor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: const Key('play_button'),
              onPressed: _isPlaying ? null : _play,
              iconSize: 48.0,
              icon: const Icon(Icons.play_arrow),
              color: color,
            ),
            IconButton(
              key: const Key('pause_button'),
              onPressed: _isPlaying ? _pause : null,
              iconSize: 48.0,
              icon: const Icon(Icons.pause),
              color: color,
            ),
            IconButton(
              key: const Key('stop_button'),
              onPressed: _isPlaying || _isPaused ? _stop : null,
              iconSize: 48.0,
              icon: const Icon(Icons.stop),
              color: color,
            ),
          ],
        ),
      ],
    );
  }

  void _initStreams() {
    _durationSubscription = player.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _positionSubscription = player.onPositionChanged.listen((p) {
      print(p.inMilliseconds);
      setState(() {
        _position = p;
        if (_position != null && widget.selectionState.endX != 0) {
          double canvasWidth = widget.selectionState.canvasWidth;
          double endX = widget.selectionState.endX;

          int endSeek =
              ((endX / canvasWidth) * _duration!.inMilliseconds).round();

          if (_position!.inMilliseconds >= endSeek) {
            _stop();
          }
        }
      });
    });

    _playerCompleteSubscription = player.onPlayerComplete.listen((event) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration.zero;
      });
    });

    _playerStateChangeSubscription =
        player.onPlayerStateChanged.listen((state) {
      setState(() {
        _playerState = state;
      });
    });
  }

  Future<void> _play() async {
    double canvasWidth = widget.selectionState.canvasWidth;
    double startX = widget.selectionState.startX;
    // Calculate the position to seek to
    int startSeek =
        ((startX / canvasWidth) * _duration!.inMilliseconds).round();
    // Seek to the calculated position
    player.seek(Duration(milliseconds: startSeek));

    await player.resume();
    setState(() => _playerState = PlayerState.playing);
  }

  Future<void> _pause() async {
    await player.pause();
    setState(() => _playerState = PlayerState.paused);
  }

  Future<void> _stop() async {
    await player.stop();
    setState(() {
      _playerState = PlayerState.stopped;
      _position = Duration.zero;
    });
  }
}
