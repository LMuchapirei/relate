import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../values/enums.dart';

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
      await audioPlayer.setSourceUrl(content);
      final duration = await audioPlayer.getDuration();
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