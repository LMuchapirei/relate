import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_player/video_player.dart';
import '../values/enums.dart';
import 'package:just_audio/just_audio.dart';

import '../values/video_metadata.dart';
import '../widgets/video_controls.dart';
import '../widgets/video_player.dart';
import '../widgets/video_preview.dart';
import '../widgets/map_preview.dart';
import '../widgets/map_full_view.dart';



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
    MediaItem(type: MediaType.location, content: '37.7749,-122.4194'), // San Francisco
    MediaItem(type: MediaType.image, content:  'https://via.placeholder.com/150'),
    MediaItem(type: MediaType.location, content: '-17.824858, 31.053028'), // San Francisco
    MediaItem(type: MediaType.image, content:  'https://via.placeholder.com/160'),
    MediaItem(type: MediaType.image, content:  'https://via.placeholder.com/170'),
    MediaItem(type: MediaType.voice, content: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'),
    MediaItem(type: MediaType.voice, content: 'https://file-examples.com/storage/fef4e75e176737761a179bf/2017/11/file_example_MP3_700KB.mp3'),
    MediaItem(type: MediaType.video, content: 'https://file-examples.com/storage/fef4e75e176737761a179bf/2017/04/file_example_MP4_1920_18MG.mp4'),
    MediaItem(type: MediaType.video, content: 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_10mb.mp4'),
    MediaItem(type: MediaType.location, content: '37.7749,-122.4194'), // San Francisco
];


extension PreviewMedia on MediaItem {
  Widget getPreview(BuildContext context,String? url){
    Widget child = Container();
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
        child =  VideoPreview(
              videoUrl: url ?? "",
              width: 200,
              height: 150,
            );
        break;
      case MediaType.location:
        final coordinates = content.split(',');
        final latitude = double.parse(coordinates[0]);
        final longitude = double.parse(coordinates[1]);
        child =LocationPreview(latitude: latitude,longitude: longitude);
        break;
    }
    return child;
  }
}



extension CarouselMedia on MediaItem {
  Widget getCarouselView(BuildContext context,AudioPlayer audioPlayer,Stream<PositionData> positionDataStream,String? url) {
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
            ],
          ),
        );

      case MediaType.video:
        return  VideoPlayerView(url: url ?? "", dataSourceType: DataSourceType.network);
        
      case MediaType.location:
        final coordinates = content.split(',');
        final latitude = double.parse(coordinates[0]);
        final longitude = double.parse(coordinates[1]);
        return MapFullView(
          latitude: latitude,
          longitude: longitude,
        );
    }
  }
}













