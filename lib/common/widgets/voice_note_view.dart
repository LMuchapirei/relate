import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';


class FullScreenVoiceNoteView extends StatefulWidget {
  final String audioUrl;

  FullScreenVoiceNoteView({required this.audioUrl});

  @override
  _FullScreenVoiceNoteViewState createState() => _FullScreenVoiceNoteViewState();
}

class _FullScreenVoiceNoteViewState extends State<FullScreenVoiceNoteView> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(widget.audioUrl));
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Voice Note')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: _togglePlayPause,
              iconSize: 64.0,
            ),
            Text(_isPlaying ? 'Playing...' : 'Paused'),
          ],
        ),
      ),
    );
  }
}