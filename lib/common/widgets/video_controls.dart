import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class Controls extends StatelessWidget {
  final AudioPlayer audioPlayer;
  
  const Controls({
    super.key,
    required this.audioPlayer,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        if(!(playing ?? false)) {
          return IconButton(
            onPressed: audioPlayer.play,
            color: Colors.black,
            icon: const Icon(Icons.play_arrow_rounded),
          );
        } else if (processingState != ProcessingState.completed) {
          return IconButton(
            onPressed: audioPlayer.pause,
            color: Colors.black,
            icon: const Icon(Icons.pause_rounded,),
          );
        }
        return const Icon(
          Icons.play_arrow_rounded,
          size: 80,
          color: Colors.black,
        );
      },
    );
  }
}