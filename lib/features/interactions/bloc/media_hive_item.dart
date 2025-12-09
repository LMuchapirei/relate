import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart' as ja;

import 'package:relate/common/widgets/map_full_view.dart';
import 'package:relate/common/widgets/map_preview.dart';

import 'package:relate/common/widgets/video_player.dart';
import 'package:relate/common/widgets/video_preview.dart';

// import 'package:relate/common/widgets/video_preview.dart'; find a fix for this
import 'package:video_player/video_player.dart';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:relate/common/widgets/pdf_viewer_page.dart';

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

  @HiveField(4)
  String? fileId;

  @HiveField(5)
  String? bucketId;

  @HiveField(6)
  String? remoteUrl;

  @HiveField(7)
  int syncStatus; // 0: Synced, 1: Pending, 2: Failed

  @HiveField(8)
  String? transcript;

  MediaHiveItem({
    required this.type,
    required this.content,
    required this.interactionId,
    this.locationType = LocationHiveType.local,
    this.fileId,
    this.bucketId,
    this.remoteUrl,
    this.syncStatus = 1, // Default to Pending
    this.transcript,
  });

  String formatDuration(Duration? duration) {
    if (duration == null) return '00:00';
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<String> getVoiceNoteDuration() async {
    if (type != MediaHiveType.voice) {
      return "";
    }
    try {
      debugPrint('Getting duration for: $content');
      ja.AudioPlayer audioPlayer = ja.AudioPlayer();
      if (content.startsWith('http')) {
        await audioPlayer.setUrl(content);
      } else {
        final file = File(content);
        if (!await file.exists()) {
          debugPrint('File does not exist: $content');
          return '00:00';
        }
        await audioPlayer.setFilePath(content);
      }
      final duration = audioPlayer.duration;
      if (duration == null) {
        return '00:00';
      }
      final result = formatDuration(duration);
      return result;
    } catch (e) {
      debugPrint('Error getting duration: $e');
      return "00:00";
    }
  }
}

extension PreviewMedia on MediaHiveItem {
  Widget getPreview(BuildContext context, String? url, MediaHiveItem item) {
    Widget child = Container();
    switch (type) {
      case MediaHiveType.image:
        final isRemote = item.content.startsWith('http');
        child = Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8.0),
            image: DecorationImage(
              image: isRemote
                  ? NetworkImage(item.content) as ImageProvider
                  : FileImage(File(item.content)),
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
              SvgPicture.asset(
                "assets/images/waveform.svg",
                height: 25.h,
                colorFilter:
                    const ColorFilter.mode(Colors.black, BlendMode.srcIn),
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
              IconButton(onPressed: () {}, icon: const Icon(Icons.play_arrow))
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
        child = LocationPreview(latitude: latitude, longitude: longitude);
        break;

      case MediaHiveType.pdf:
        child = Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.picture_as_pdf, size: 40.sp, color: Colors.red),
              SizedBox(height: 5.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  item.content.split('/').last,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10.sp),
                ),
              ),
            ],
          ),
        );
        break;
    }
    return child;
  }
}

extension CarouselMedia on MediaHiveItem {
  Widget getCarouselView(BuildContext context, MediaHiveItem item) {
    switch (type) {
      case MediaHiveType.image:
        final isRemote = item.content.startsWith('http');
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: isRemote
                  ? NetworkImage(item.content) as ImageProvider
                  : FileImage(File(item.content)),
              fit: BoxFit.contain,
            ),
          ),
        );

      case MediaHiveType.voice:
        return VoiceNoteView(item: item);
      case MediaHiveType.video:
        return VideoPlayerView(
            url: item.content, dataSourceType: DataSourceType.file);
      case MediaHiveType.pdf:
        final isRemote = item.content.startsWith('http');
        return PDFViewerWidget(
          url: isRemote ? item.content : null,
          filePath: isRemote ? null : item.content,
        );
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
  late PlayerController _playerController;
  bool _isPlaying = false;
  String? _duration;

  @override
  void initState() {
    super.initState();
    _playerController = PlayerController();
    _preparePlayer();
  }

  Future<void> _preparePlayer() async {
    try {
      String path = widget.item.content;
      if (path.startsWith('http')) {
        final file = await _downloadFile(path);
        if (file != null) {
          path = file.path;
        } else {
          debugPrint('Failed to download file');
          return;
        }
      }

      await _playerController.preparePlayer(
        path: path,
        shouldExtractWaveform: true,
        noOfSamples: 100,
        volume: 1.0,
      );

      final duration = await _playerController.getDuration(DurationType.max);
      setState(() {
        _duration =
            widget.item.formatDuration(Duration(milliseconds: duration));
      });

      _playerController.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state == PlayerState.playing;
          });
        }
      });
    } catch (e) {
      debugPrint('Error preparing player: $e');
    }
  }

  Future<File?> _downloadFile(String url) async {
    try {
      final request = await HttpClient().getUrl(Uri.parse(url));
      final response = await request.close();
      final bytes = await consolidateHttpClientResponseBytes(response);
      final dir = await getApplicationDocumentsDirectory();
      final file =
          File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      debugPrint('Error downloading file: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE6E6FA), // Light purple
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  if (_isPlaying) {
                    await _playerController.pausePlayer();
                  } else {
                    await _playerController.startPlayer();
                  }
                },
                child: Container(
                  width: 40.h,
                  height: 40.h,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF6A5ACD), // Dark purple
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                _duration ?? '00:00',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chat_bubble_outline,
                color: Colors.grey[600],
                size: 20.h,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          AudioFileWaveforms(
            size: Size(double.infinity, 60.h),
            playerController: _playerController,
            enableSeekGesture: true,
            waveformType: WaveformType.fitWidth,
            playerWaveStyle: const PlayerWaveStyle(
              fixedWaveColor: Color(0xFFB0C4DE),
              liveWaveColor: Color(0xFF6A5ACD),
              spacing: 6,
            ),
          ),
          if (widget.item.transcript != null &&
              widget.item.transcript!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                widget.item.transcript!,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[800],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ] else ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                "Transcript not available",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
