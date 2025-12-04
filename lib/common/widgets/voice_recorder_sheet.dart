import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class VoiceRecorderSheet extends StatefulWidget {
  const VoiceRecorderSheet({super.key});

  @override
  State<VoiceRecorderSheet> createState() => _VoiceRecorderSheetState();
}

class _VoiceRecorderSheetState extends State<VoiceRecorderSheet> {
  late final AudioRecorder _audioRecorder;
  bool _isRecording = false;
  int _recordDuration = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final path =
            '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(const RecordConfig(), path: path);

        setState(() {
          _isRecording = true;
          _recordDuration = 0;
        });

        _startTimer();
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _stopTimer();
      setState(() {
        _isRecording = false;
      });

      if (path != null && mounted) {
        Navigator.of(context).pop({'fileObject': File(path)});
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _formatDuration(int duration) {
    final String minutes = (duration ~/ 60).toString().padLeft(2, '0');
    final String seconds = (duration % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isRecording ? 'Recording...' : 'Start Recording',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            _formatDuration(_recordDuration),
            style: TextStyle(
              fontSize: 48.sp,
              fontWeight: FontWeight.w300,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          SizedBox(height: 30.h),
          GestureDetector(
            onTap: _isRecording ? _stopRecording : _startRecording,
            child: Container(
              width: 70.h,
              height: 70.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isRecording ? Colors.red : Colors.red,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 32.h,
              ),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
