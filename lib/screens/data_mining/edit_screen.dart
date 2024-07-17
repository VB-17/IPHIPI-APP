import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iphipi/data/repo/audio_repo.dart';
import 'package:iphipi/providers/audio_player_provider.dart';
import 'package:iphipi/providers/audio_selection_provider.dart';
import 'package:iphipi/widgets/audio_player.dart';
import 'package:iphipi/widgets/selection_canvas.dart';

import 'package:provider/provider.dart';

class MinerEditScreen extends StatefulWidget {
  const MinerEditScreen({super.key});

  @override
  State<MinerEditScreen> createState() => _MinerEditScreenState();
}

class _MinerEditScreenState extends State<MinerEditScreen> {
  Uint8List? audioData;

  @override
  initState() {
    super.initState();
    _fetchAudioBytes();
  }

  Future<void> _fetchAudioBytes() async {
    try {
      Uint8List? data = await AudioRepo().getAudio();
      print("Fetched audio data: $data");
      setState(() {
        audioData = data;
      });
    } catch (e) {
      print("Error fetching audio data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set landscape orientation when entering this page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Reset orientation when leaving this page
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
          return;
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('MinerEdit'),
          backgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: (audioData != null)
                      ? [
                          // SelectionCanvas(),
                          const SizedBox(height: 40),
                          Consumer<AudioSelectionState>(
                            builder: (context, state, child) {
                              return AudioPlayerFromBytes(
                                audioData: audioData!,
                                selectionState: state,
                              );
                            },
                          ),
                        ]
                      : [const CircularProgressIndicator()],
                ),
              ),
              const SizedBox(width: 20),
              Container(
                height: MediaQuery.of(context).size.height,
                width: 100, // Adjust width as per your requirement
                color: Colors.grey.shade200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.pause),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
