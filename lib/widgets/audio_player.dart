import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:iphipi/providers/audio_selection_provider.dart';
import 'package:iphipi/providers/audio_player_provider.dart';

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
  @override
  void initState() {
    super.initState();
    _setAudioSource();
  }

  Future<void> _setAudioSource() async {
    final audioPlayerProvider =
        Provider.of<AudioPlayerProvider>(context, listen: false);

    await audioPlayerProvider.setAudioSource(widget.audioData);
  }

  @override
  Widget build(BuildContext context) {
    final audioPlayerProvider = Provider.of<AudioPlayerProvider>(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: const Key('play_button'),
              onPressed: audioPlayerProvider.isPlaying
                  ? null
                  : () async {
                      int startSeek = widget.selectionState
                          .startSeek(audioPlayerProvider.duration);

                      await audioPlayerProvider.seek(Duration(milliseconds: startSeek));
                      await audioPlayerProvider.play();
                    },
              iconSize: 48.0,
              icon: const Icon(Icons.play_arrow),
              color: Theme.of(context).primaryColor,
            ),
         
            IconButton(
              key: const Key('stop_button'),
              onPressed: audioPlayerProvider.isPlaying ||
                      audioPlayerProvider.isPlaying == false
                  ? audioPlayerProvider.stop
                  : null,
              iconSize: 48.0,
              icon: const Icon(Icons.stop),
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ],
    );
  }
}
