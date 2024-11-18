import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
class VideoPreview extends StatelessWidget {
  final String videoUrl;
  final double? width;
  final double? height;

  const VideoPreview({
    super.key,
    required this.videoUrl,
    this.width,
    this.height,
  });

  Future<String?> _getVideoThumbnail() async {
    final fileName = await VideoThumbnail.thumbnailFile(
      video: videoUrl,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 250,
      quality: 75,
    );
    return fileName;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getVideoThumbnail(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            width: width ?? 150,
            height: height ?? 150,
            color: Colors.grey[300],
            child: const Center(child: Icon(Icons.error)),
          );
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            // Thumbnail
            Container(
              width: width ?? 150,
              height: height ?? 150,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(snapshot.data!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Play button overlay
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        );
      },
    );
  }
}