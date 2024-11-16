import 'dart:typed_data';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:http/http.dart' as http;
import '../values/enums.dart';
import 'package:just_audio/just_audio.dart';



class MediaItem {
  final MediaType type;
  final String content;

  MediaItem({required this.type,required this.content});

  String formatDuration(Duration? duration) {
    if (duration == null) return '00:00';
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<String> getVoiceNoteDuration() async {
    if (type != MediaType.voice){
      return "";
    }
    try {
      AudioPlayer audioPlayer = AudioPlayer();
      await audioPlayer.setUrl(content);
      final duration = audioPlayer.duration;
      if(duration == null) {
        return '00:00';
      }
      final result = formatDuration(duration);
      return result;
    } catch(e){
      return "00:00";
    }
  }

}


final mediaList = [
    MediaItem(type: MediaType.image, content:  'https://via.placeholder.com/150'),
    MediaItem(type: MediaType.image, content:  'https://via.placeholder.com/160'),
    MediaItem(type: MediaType.image, content:  'https://via.placeholder.com/170'),
    MediaItem(type: MediaType.voice, content: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'),
    MediaItem(type: MediaType.voice, content: 'https://file-examples.com/storage/fef4e75e176737761a179bf/2017/11/file_example_MP3_700KB.mp3'),
    MediaItem(type: MediaType.video, content: 'https://www.w3schools.com/html/mov_bbb.mp4'),
    MediaItem(type: MediaType.location, content: '37.7749,-122.4194'), // San Francisco
];


extension PreviewMedia on MediaItem {
  Widget getPreview(BuildContext context){
    var child = Container();
    switch(type){
      case MediaType.image:
       child = Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: NetworkImage(content),
                    fit: BoxFit.cover,
                  ),
                ),
              );
        break;
      case MediaType.voice:
         child = Container(
                height: 100.h,
                width: 100.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset("assets/images/waveform.svg",height: 25.h,
                      colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                    ),
                    FutureBuilder<String>(
                        future: getVoiceNoteDuration(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            // Show loading indicator while waiting for duration
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            // Show error message if there is an error
                            return const Text('Error loading duration');
                          } else {
                            // Show the formatted duration once it’s available
                            return Text('${snapshot.data}');
                            
                          }
                        },
                      ),
                    /// add a play button here
                    IconButton(onPressed: (){
                      
                    }, icon: const Icon(Icons.play_arrow))

                  ],
                ),
              );
        break;
      case MediaType.video:
        // TODO: Handle this case.
        break;
      case MediaType.location:
        // TODO: Handle this case.
        break;
    }
    return child;
  }
}
// extension AudioPlayback on MediaItem {
//   static final _audioPlayer = AudioPlayer();
//   static final playerController = PlayerController();
  
//   Future<void> playPause() async {
//     if (type != MediaType.voice) return;
//     try {
//       // Download and prepare audio bytes
//       final response = await http.get(Uri.parse(content));
//       final audioBytes = response.bodyBytes;

//         await playerController.preparePlayer(
//           path: content,
//           noOfSamples: 100,
//         );

//       if (_audioPlayer.playing) {
//         await _audioPlayer.pause();
//         await playerController.pausePlayer();
//       } else {
//         await _audioPlayer.setAudioSource(BytesSource(audioBytes));
//         await _audioPlayer.play();
//         await playerController.startPlayer();
//       }
//     } catch (e) {
//       debugPrint('Error playing audio: $e');
//     }
//   }
// }

extension CarouselMedia on MediaItem {
  Widget getCarouselView(BuildContext context,AudioPlayer audioPlayer,Stream<PositionData> positionDataStream) {
    switch(type) {
      case MediaType.image:
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(content),
              fit: BoxFit.contain,
            ),
          ),
        );
        
      case MediaType.voice:
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/images/waveform.svg",
                height: 50.h,
                colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
              ),
              //// We may not need this one
              // FutureBuilder<String>(
              //   future: getVoiceNoteDuration(),
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return const CircularProgressIndicator();
              //     } else if (snapshot.hasError) {
              //       return const Text('Error loading duration');
              //     }
              //     return Text(
              //       '${snapshot.data}',
              //       style: Theme.of(context).textTheme.titleLarge,
              //     );
              //   },
              // ),
              StreamBuilder<PositionData>(
              stream: positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return ProgressBar(
                  barHeight: 8,
                  baseBarColor: Colors.grey[600],
                  bufferedBarColor: Colors.grey[800],
                  progressBarColor: Colors.red,
                  thumbColor: Colors.red,
                  timeLabelTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600
                  ),
                  progress: positionData?.position ?? Duration.zero,
                  buffered: positionData?.bufferedPosition ?? Duration.zero,
                  total: positionData?.duration ?? Duration.zero,
                  onSeek: audioPlayer.seek,
                );
              },
            ),
              SizedBox(
                height: 20.h,
              ),
              Controls(audioPlayer: audioPlayer)
              // Add AudioWaveforms widget
              // SizedBox(
              //   height: 64,
              //   child: AudioFileWaveforms(
              //     size: Size(MediaQuery.of(context).size.width * 0.8, 64.0),
              //     playerController: AudioPlayback.playerController,
              //     enableSeekGesture: true,
              //     waveformType: WaveformType.fitWidth,
              //     playerWaveStyle: const PlayerWaveStyle(
              //       fixedWaveColor: Colors.grey,
              //       liveWaveColor: Colors.blue,
              //       spacing: 6,
              //     ),
              //   ),
              // ),
            ],
          ),
        );

      case MediaType.video:
        return const Center(child: Text('Video Player Coming Soon'));
        
      case MediaType.location:
        return const Center(child: Text('Map View Coming Soon'));
    }
  }
}

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




class BytesSource extends StreamAudioSource {
  final Uint8List bytes;
  BytesSource(this.bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}


class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  const PositionData({required this.position, required this.bufferedPosition, required this.duration});
}



