// ignore_for_file: library_private_types_in_public_api

import 'package:path/path.dart' as p;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:relate/common/widgets/flutter_toast.dart';
import 'package:relate/features/interactions/bloc/interaction_file_controller.dart';
import 'package:relate/features/interactions/bloc/media_hive_item.dart';

import '../common/widgets/file_picker.dart';

//// Add on edit mode
class InteractionSummaryScreen extends StatefulWidget {
  final ScrollController controller;
  final String interactionId;
  const InteractionSummaryScreen({super.key,  required this.controller, required this.interactionId});
  @override
  _InteractionSummaryScreenState createState() =>
      _InteractionSummaryScreenState();
}

class _InteractionSummaryScreenState extends State<InteractionSummaryScreen> {
  final List<String> notes = [];
  final TextEditingController summaryController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController feelingController = TextEditingController();
  final InteractionFileController fileController = InteractionFileController();

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
  void _addNote() {
  if (noteController.text.isEmpty) {
    _showSnackbar("Please enter a note before adding.");
    return;
  }
    setState(() {
      notes.add(noteController.text);
      noteController.clear(); 
    });
  }

  void _deleteNote(int index) {
    setState(() {
      notes.removeAt(index); 
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Interaction Summary',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          controller: widget.controller,
          scrollDirection: Axis.vertical,
          children: [
            _buildInteractionDetails(),
            const SizedBox(height: 16),
            _buildNotesSection(),
            const SizedBox(height: 16),
            _buildSummarySection(),
            const SizedBox(height: 16),
            SizedBox(
              height: 300.h,
              child: const UnifiedMoodSelector()),
            const SizedBox(height: 16),
            _buildFeelingSection(),
            const SizedBox(height: 32),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionDetails() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.people, size: 28),
               SizedBox(width: 8),
              Text(
                'Physical Meeting',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '18:30pm',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                '12 Jan 2025',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }


    Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: noteController,
            decoration: const InputDecoration(
              hintText: 'Enter a new note...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _addNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                ),
                child: const Text('Add Note',style: TextStyle(color: Colors.white),),
              ),
              GestureDetector(
                onTap: () async {
                 final result = await showFilePickerOptions(context);
                 final file = result["fileObject"];
                 if(file is XFile){
                    final bytes = await file.readAsBytes();
                    final extension = p.extension(file.path);
                    final type = getMediaTypeFromExtension(extension);
                    final saveResponse = await fileController.saveMediaItem(
                          type: type ?? MediaHiveType.image ,
                          bytes: bytes,
                          extension: extension,
                          interactionId: widget.interactionId
                      );
                    if(saveResponse){
                      toastInfo(msg: "Saved attachment.");
                    }
                 }

                },
                child: SvgPicture.asset("assets/images/attach.svg",height: 20.h,)),
              GestureDetector(
                onTap: () async  {
                  final result = await showVoiceNotePickerOptions(context);
                  final file = result["fileObject"];
                 if(file is XFile){
                    final bytes = await file.readAsBytes();
                    final extension = p.extension(file.path);
                    final type = getMediaTypeFromExtension(extension);
                    final saveResponse = await fileController.saveMediaItem(
                          type: type ?? MediaHiveType.image ,
                          bytes: bytes,
                          extension: extension,
                          interactionId: widget.interactionId
                      );
                    if(saveResponse){
                      toastInfo(msg: "Saved voice attachment.");
                    }
                 }
                },
                child: SvgPicture.asset("assets/images/waveform.svg",height: 25.h,)),
              GestureDetector(
                onTap: () async  {
                  
                },
                child: SvgPicture.asset("assets/images/location.svg",height: 25.h,)),
            ],
          ),
          const SizedBox(height: 8),
          //// Find a way to make the item grow
          SizedBox(
            height: notes.length > 1 ? 100.h : 40.h,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${index + 1}. ${notes[index]}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () => _deleteNote(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: summaryController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Enter summary...',
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeelingSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Describe how you felt',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: feelingController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Enter how you felt...',
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: () {
            // Handle Save action
          },
          style: ElevatedButton.styleFrom(
            fixedSize: Size(100.w, 30.h),
            backgroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Text('Save',style: TextStyle(color: Colors.white),),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Close the screen
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[400],
            fixedSize: Size(100.w, 30.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Text('Cancel',style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }

}


class UnifiedMoodSelector extends StatefulWidget {
  const UnifiedMoodSelector({super.key});

  @override
  _UnifiedMoodSelectorState createState() => _UnifiedMoodSelectorState();
}

class _UnifiedMoodSelectorState extends State<UnifiedMoodSelector>
    with SingleTickerProviderStateMixin {
  double _moodValue = 0.0;

  // Mood data
  final List<String> moodEmojis = ['😢', '😟', '😐', '😊', '😁'];
  final List<String> moodLabels = [
    'Very Unpleasant',
    'Unpleasant',
    'Neutral',
    'Pleasant',
    'Very Pleasant',
  ];

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2), // Duration for pulsing effect
    )..repeat(reverse: true); // Repeat the animation back and forth

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: _getMoodColor(0),
      end: _getMoodColor(0),
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getMoodColor(double value) {
    switch (value.round()) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.lightGreen;
      case 4:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _onMoodChanged(double newValue) {
    setState(() {
      _moodValue = newValue;
      _colorAnimation = ColorTween(
        begin: _colorAnimation.value,
        end: _getMoodColor(_moodValue),
      ).animate(_animationController);
    });
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
           color: Colors.grey[300],
           borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding:  EdgeInsets.symmetric(vertical: 20.0.h, horizontal: 10.0.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Pick from the scale how you felt?",
                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: RadialGraphPainter(
                          scale: _scaleAnimation.value,
                          moodColor: _colorAnimation.value!,
                        ),
                        child: Container(
                          width: 150,
                          height: 150,
                          child: Center(
                            child: Text(
                              moodEmojis[_moodValue.round()],
                              style: TextStyle(fontSize: 64),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                moodLabels[_moodValue.round()],
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              SizedBox(height: 5.h),
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: 10.w),
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 12.0,
                    activeTrackColor: Colors.transparent,
                    inactiveTrackColor: Colors.transparent,
                    thumbColor: _getMoodColor(_moodValue),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 16.0,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        height: 12.0,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.red, Colors.orange, Colors.yellow, Colors.lightGreen, Colors.green],
                            stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                          ),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                      Slider(
                        value: _moodValue,
                        min: 0,
                        max: 4,
                        divisions: 4,
                        onChanged: (newValue) {
                          _onMoodChanged(newValue);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Very Unpleasant", style: TextStyle(color: Colors.grey)),
                  Text("Very Pleasant", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// RadialGraphPainter for smooth ripple effect with synchronized mood color
class RadialGraphPainter extends CustomPainter {
  final double scale;
  final Color moodColor;

  RadialGraphPainter({required this.scale, required this.moodColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = moodColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      double radius = (size.width / 2) * ((5 - i) / 5) * scale;
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, paint);
      paint.color = paint.color.withOpacity(0.3 + (i * 0.1));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
