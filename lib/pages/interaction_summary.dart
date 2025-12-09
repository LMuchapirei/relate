// ignore_for_file: library_private_types_in_public_api
import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as p;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:relate/common/widgets/flutter_toast.dart';
import 'package:relate/features/interactions/bloc/interaction_file_controller.dart';
import 'package:relate/features/interactions/bloc/interaction_summary_bloc.dart';
import 'package:relate/features/interactions/bloc/interaction_summary_events.dart';
import 'package:relate/features/interactions/bloc/interaction_summary_state.dart';
import 'package:relate/features/interactions/bloc/interaction_summary_controller.dart';
import 'package:relate/global.dart';
import 'package:mime/mime.dart';

import '../common/widgets/file_picker.dart';

//// Add on edit mode
class InteractionSummaryScreen extends StatefulWidget {
  final ScrollController controller;
  final String interactionId;

  const InteractionSummaryScreen({
    super.key,
    required this.controller,
    required this.interactionId,
  });

  @override
  _InteractionSummaryScreenState createState() =>
      _InteractionSummaryScreenState();
}

class _InteractionSummaryScreenState extends State<InteractionSummaryScreen> {
  final TextEditingController summaryController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController feelingController = TextEditingController();
  final InteractionFileController fileController = InteractionFileController();
  final InteractionSummaryController summaryControllerHelper = InteractionSummaryController();
  double moodValue = 0.0;
  List<String> notes = [];
  List<Map<String, String>> attachments = [];

  void _addNote(BuildContext context) {
    if (noteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a note before adding.")),
      );
      return;
    }
    setState(() {
      notes.add(noteController.text);
      noteController.clear();
    });
  }

  void _deleteNote(BuildContext context, int index) {
    setState(() {
      notes.removeAt(index);
    });
  }

  void _onMoodChanged(double value) {
    setState(() {
      moodValue = value;
    });
    context.read<InteractionSummaryBloc>().add(UpdateMoodEvent(value));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InteractionSummaryBloc, InteractionSummaryState>(
      listener: (context, state) {
        // if (state.saveSuccess && state) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text("Summary saved successfully!")),
        //   );
        //   Navigator.pop(context);
        // }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to save: ${state.error}")),
          );
        }
      },
      child: Scaffold(
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
              _buildNotesSection(context),
              const SizedBox(height: 16),
              _buildSummarySection(context),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: UnifiedMoodSelector(
                  initialValue: moodValue,
                  onMoodChanged: _onMoodChanged,
                ),
              ),
              const SizedBox(height: 16),
              _buildFeelingSection(context),
              const SizedBox(height: 32),
              _buildActionButtons(context),
            ],
          ),
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


    Widget _buildNotesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: noteController,
            decoration: InputDecoration(
              hintText: 'Enter a new note...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _addNote(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text('Add Note', style: TextStyle(color: Colors.white)),
              ),
              GestureDetector(
                onTap: () async {
                  final result = await showFilePickerOptions(context);
                  if(result == null) return; 
                  final file = result["fileObject"];
                  if (file is XFile) {
                    // Upload to Appwrite and get url, name, mime
                    final fileMeta = await summaryControllerHelper.uploadFileToAppwrite(
                      file.path,
                      '683801e4001503aecbc3',
                    );
                    if (fileMeta.isNotEmpty) {
                      setState(() {
                        attachments.add(fileMeta);
                      });
                      toastInfo(msg: "Attachment uploaded.");
                    }
                  }
                },
                child: SvgPicture.asset("assets/images/attach.svg", height: 20.h),
              ),
              GestureDetector(
                onTap: () async {
                  final result = await showVoiceNotePickerOptions(context);
                  final file = result["fileObject"];
                  if (file is XFile) {
                    final fileMeta = await summaryControllerHelper.uploadFileToAppwrite(
                      file.path,
                      '683801e4001503aecbc3',
                    );
                    if (fileMeta.isNotEmpty) {
                      setState(() {
                        attachments.add(fileMeta);
                      });
                      toastInfo(msg: "Voice attachment uploaded.");
                    }
                  }
                },
                child: SvgPicture.asset("assets/images/waveform.svg", height: 25.h),
              ),
              GestureDetector(
                onTap: () async {
                  // Handle location if needed
                },
                child: SvgPicture.asset("assets/images/location.svg", height: 25.h),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Show attachments with delete option
          if (attachments.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Attachments:', style: TextStyle(fontWeight: FontWeight.bold)),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: attachments.length,
                  itemBuilder: (context, index) {
                    final att = attachments[index];
                    final url = att['url'] ?? '';
                    final name = att['name'] ?? '';
                    final mime = att['mime'] ?? '';
                    final fileId = _extractAppwriteFileId(url);
                    final isImage = mime.startsWith('image/');
                    return ListTile(
                      leading: isImage
                          ? Image.network(url, width: 40, height: 40, fit: BoxFit.cover)
                          : Icon(Icons.attach_file),
                      title: Text(name),
                      subtitle: Text(mime),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          if (fileId != null) {
                            try {
                              final storage = Storage(Global.client);
                              await storage.deleteFile(
                                bucketId: '683801e4001503aecbc3',
                                fileId: fileId,
                              );
                              setState(() {
                                attachments.removeAt(index);
                              });
                              toastInfo(msg: "Attachment deleted.");
                            } catch (e) {
                              toastInfo(msg: "Failed to delete attachment.");
                            }
                          } else {
                            toastInfo(msg: "Invalid file link.");
                          }
                        },
                      ),
                    );
                  },
                ),
              ],
            ),

          const SizedBox(height: 8),
          //// Find a way to make the item grow
          SizedBox(
            height: notes.length > 1 ? 100.h : 60.h,
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
                          icon: const  Icon(Icons.delete),
                          color: Colors.black,
                          onPressed: () => _deleteNote(context, index),
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

  Widget _buildSummarySection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: summaryController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Enter summary...',
              border: InputBorder.none,
            ),
            onChanged: (value) {
              context.read<InteractionSummaryBloc>().add(UpdateSummaryEvent(value));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeelingSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Describe how you felt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: feelingController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Enter how you felt...',
              border: InputBorder.none,
            ),
            onChanged: (value) {
              context.read<InteractionSummaryBloc>().add(UpdateFeelingEvent(value));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return BlocBuilder<InteractionSummaryBloc, InteractionSummaryState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: 
                  () {
                    if (notes.isEmpty) {
                      toastInfo(msg: "Please add at least one note.");
                      return;
                    }
                    if (summaryController.text.trim().isEmpty) {
                      toastInfo(msg: "Please enter a summary.");
                      return;
                    }
                    if (feelingController.text.trim().isEmpty) {
                      toastInfo(msg: "Please describe how you felt.");
                      return;
                    }
                    if (moodValue == 0.0) {
                      toastInfo(msg: "Please select your mood.");
                      return;
                    }
                    if (FirebaseAuth.instance.currentUser?.uid == null) {
                      toastInfo(msg: "You need to be logged in to save.");
                      return;
                    }
                    context.read<InteractionSummaryBloc>().add(
                      SaveSummaryEvent(
                        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                        relationshipId: widget.interactionId,
                        attachments: List.from(attachments), // <-- Pass attachments as list of maps
                        notes: List.from(notes),
                        summary: summaryController.text,
                        feeling: feelingController.text,
                        mood: moodValue,
                      ),
                    );
                    Navigator.pop(context);
                  },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(100, 30),
                backgroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: 
                  const Text('Save', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[400],
                fixedSize: const Size(100, 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }
}

/// Helper to extract Appwrite fileId from the file URL
String? _extractAppwriteFileId(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return null;
  final segments = uri.pathSegments;
  final filesIndex = segments.indexOf('files');
  if (filesIndex != -1 && filesIndex + 1 < segments.length) {
    return segments[filesIndex + 1];
  }
  return null;
}

// UnifiedMoodSelector with callback
class UnifiedMoodSelector extends StatefulWidget {
  final double initialValue;
  final ValueChanged<double> onMoodChanged;

  const UnifiedMoodSelector({
    super.key,
    required this.initialValue,
    required this.onMoodChanged,
  });

  @override
  _UnifiedMoodSelectorState createState() => _UnifiedMoodSelectorState();
}

class _UnifiedMoodSelectorState extends State<UnifiedMoodSelector>
    with SingleTickerProviderStateMixin {
  late double _moodValue;

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
    _moodValue = widget.initialValue;
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
    widget.onMoodChanged(_moodValue);
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
