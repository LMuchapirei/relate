import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:relate/common/values/video_metadata.dart';
import 'package:relate/common/widgets/video_controls.dart';
import 'package:rxdart/rxdart.dart';

class VoiceNoteView extends StatefulWidget {
  final String noteUrlPath;
  const VoiceNoteView({
    super.key,
    required this.noteUrlPath,
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
        _audioPlayer = AudioPlayer(
          
        )..setUrl(widget.noteUrlPath);
                              
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