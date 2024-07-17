import 'dart:io';
import 'dart:typed_data';

import 'package:easy_audio_trimmer/easy_audio_trimmer.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class AudioTrimmerView extends StatefulWidget {
  final Uint8List? audioBytes;

  const AudioTrimmerView(this.audioBytes, {Key? key}) : super(key: key);
  @override
  State<AudioTrimmerView> createState() => _AudioTrimmerViewState();
}

class _AudioTrimmerViewState extends State<AudioTrimmerView> {
  final Trimmer _trimmer = Trimmer();

  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAudio();
  }

  void _loadAudio() async {
    setState(() {
      isLoading = true;
    });

    if (widget.audioBytes != null) {
      final directory = await getTemporaryDirectory();
      final audioFile = File('${directory.path}/temp_audio.wav');

      List<int> bytesList = widget.audioBytes!.toList();
      await audioFile.writeAsBytes(bytesList);
      await _trimmer.loadAudio(audioFile: audioFile);
    }

    setState(() {
      isLoading = false;
    });
  }

  // _saveAudio() {
  //   setState(() {
  //     _progressVisibility = true;
  //   });

  //   _trimmer.saveTrimmedAudio(
  //     startValue: _startValue,
  //     endValue: _endValue,
  //     audioFileName: DateTime.now().millisecondsSinceEpoch.toString(),
  //     onSave: (outputPath) {
  //       setState(() {
  //         _progressVisibility = false;
  //       });
  //       debugPrint('OUTPUT PATH: $outputPath');
  //     },
  //   );
  // }

  @override
  void dispose() {
    if (mounted) {
      _trimmer.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !Navigator.of(context).userGestureInProgress,
      child: Expanded(
        child: isLoading
            ? const CircularProgressIndicator()
            : Center(
                child: Container(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Visibility(
                        visible: _progressVisibility,
                        child: LinearProgressIndicator(
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(0.5),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TrimViewer(
                            trimmer: _trimmer,
                            viewerHeight: 100,
                            maxAudioLength: const Duration(seconds: 10),
                            viewerWidth: MediaQuery.of(context).size.width,
                            durationStyle: DurationStyle.FORMAT_MM_SS,
                            backgroundColor: Theme.of(context).primaryColor,
                            barColor: Colors.white,
                            durationTextStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                            allowAudioSelection: true,
                            editorProperties: TrimEditorProperties(
                              circleSize: 6,
                              borderPaintColor: Colors.pinkAccent,
                              borderWidth: 4,
                              borderRadius: 5,
                              circlePaintColor: Colors.pink.shade400,
                            ),
                            areaProperties:
                                TrimAreaProperties.edgeBlur(blurEdges: false),
                            onChangeStart: (value) => _startValue = value,
                            onChangeEnd: (value) => _endValue = value,
                            onChangePlaybackState: (value) {
                              if (mounted) {
                                setState(() => _isPlaying = value);
                              }
                            },
                          ),
                        ),
                      ),
                      TextButton(
                        child: _isPlaying
                            ? Icon(
                                Icons.pause,
                                size: 80.0,
                                color: Theme.of(context).primaryColor,
                              )
                            : Icon(
                                Icons.play_arrow,
                                size: 80.0,
                                color: Theme.of(context).primaryColor,
                              ),
                        onPressed: () async {
                          bool playbackState =
                              await _trimmer.audioPlaybackControl(
                            startValue: _startValue,
                            endValue: _endValue,
                          );
                          setState(() => _isPlaying = playbackState);
                        },
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
