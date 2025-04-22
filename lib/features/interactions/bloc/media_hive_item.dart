import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:relate/common/values/video_metadata.dart';
import 'package:relate/common/widgets/map_full_view.dart';
import 'package:relate/common/widgets/map_preview.dart';
import 'package:relate/common/widgets/video_controls.dart';
import 'package:relate/common/widgets/video_player.dart';
import 'package:relate/common/widgets/video_preview.dart';
import 'package:rxdart/rxdart.dart';
// import 'package:relate/common/widgets/video_preview.dart'; find a fix for this
import 'package:video_player/video_player.dart';

part 'media_hive_item.g.dart';
// part 'package:relate/features/interactions/bloc/media_hive_item.g.dart'

@HiveType(typeId: 0)
enum MediaHiveType {
  @HiveField(0)
  image,
  @HiveField(1)
  voice,
  @HiveField(2)
  video,
  @HiveField(3)
  location,
  @HiveField(4)
  pdf,
}

@HiveType(typeId: 1)
enum LocationHiveType {
  @HiveField(0)
  online,
  @HiveField(1)
  local,
}

@HiveType(typeId: 2)
class MediaHiveItem extends HiveObject {
  @HiveField(0)
  final MediaHiveType type;

  @HiveField(1)
  final String content; // file path or location string

  @HiveField(2)
  final String interactionId;

  @HiveField(3)
  final LocationHiveType locationType;

  MediaHiveItem({
    required this.type,
    required this.content,
    required this.interactionId,
    this.locationType = LocationHiveType.local,
  });

    String formatDuration(Duration? duration) {
    if (duration == null) return '00:00';
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<String> getVoiceNoteDuration() async {
    if (type != MediaHiveType.voice){
      return "";
    }
    try {
      AudioPlayer audioPlayer = AudioPlayer();
      await audioPlayer.setFilePath(content);
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

extension PreviewMedia on MediaHiveItem {
  Widget getPreview(BuildContext context,String? url,MediaHiveItem item){
    Widget child = Container();
    switch(type){
      case MediaHiveType.image:
      final file = File(item.content);
       child = Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: FileImage(file),
                    fit: BoxFit.cover,
                  ),
                ),
              );
        break;
      case MediaHiveType.voice:
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
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return const Text('Error loading duration');
                          } else {
                            return Text('${snapshot.data}');
                            
                          }
                        },
                      ),
                    IconButton(onPressed: (){
                      
                    }, icon: const Icon(Icons.play_arrow))

                  ],
                ),
              );
        break;
      case MediaHiveType.video:
        child = VideoPreview(
                  videoUrl: item.content,
                  width: 200,
                  height: 150,
        );
        break;
      case MediaHiveType.location:
        final coordinates = content.split(',');
        final latitude = double.parse(coordinates[0]);
        final longitude = double.parse(coordinates[1]);
        child = LocationPreview(latitude: latitude,longitude: longitude);
        break;

      case MediaHiveType.pdf:
      break;
    }
    return child;
  }
}



extension CarouselMedia on MediaHiveItem {
  Widget getCarouselView(BuildContext context,MediaHiveItem item) {
    switch(type) {
      case MediaHiveType.image:
        final file = File(item.content);
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(file),
              fit: BoxFit.contain,
            ),
          ),
        );
        
      case MediaHiveType.voice:
        return VoiceNoteView(
          item:item
        );
      case MediaHiveType.video:
        return  VideoPlayerView(url: item.content, dataSourceType: DataSourceType.file);      
      case MediaHiveType.pdf:
      return Placeholder();
      case MediaHiveType.location:
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



MediaHiveType? getMediaTypeFromExtension(String extension) {
  final ext = extension.toLowerCase().replaceAll('.', '');

  switch (ext) {
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
    case 'bmp':
      return MediaHiveType.image;

    case 'mp3':
    case 'wav':
    case 'm4a':
    case 'aac':
      return MediaHiveType.voice;

    case 'mp4':
    case 'mov':
    case 'avi':
    case 'mkv':
      return MediaHiveType.video;

    case 'pdf':
      return MediaHiveType.pdf;

    default:
      return null; 
  }
}


class VoiceNoteView extends StatefulWidget {
  final MediaHiveItem item;
  const VoiceNoteView({
    super.key,
    required this.item,
  });

  @override
  State<VoiceNoteView> createState() => _VoiceNoteViewState();
}

class _VoiceNoteViewState extends State<VoiceNoteView> {
   late AudioPlayer _audioPlayer;

    Stream<PositionData> get positionDataStream => Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
    _audioPlayer.positionStream,
    _audioPlayer.bufferedPositionStream,
    _audioPlayer.durationStream,
    (position, bufferedPosition, duration) => PositionData(
      position: position, 
      bufferedPosition: bufferedPosition, 
      duration: duration ?? Duration.zero),
  );

    @override
  void initState() {
    super.initState();
        _audioPlayer = AudioPlayer()
                              ..setFilePath(widget.item.content);
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.dispose();
  }

  
  @override
  Widget build(BuildContext context) {
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
              onSeek: _audioPlayer.seek,
            );
          },
        ),
          SizedBox(
            height: 20.h,
          ),
          Controls(audioPlayer: _audioPlayer)
        ],
      ),
    );
  }
}