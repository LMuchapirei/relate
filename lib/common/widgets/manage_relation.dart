import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:relate/common/widgets/file_picker.dart';
import 'package:relate/common/widgets/modals.dart';
import 'package:relate/common/widgets/video_player.dart';
import 'package:relate/common/widgets/video_preview.dart';
import 'package:relate/features/interactions/bloc/media_hive_item.dart';
import 'package:relate/features/relationship/bloc/birthday_log_model.dart';
import 'package:relate/features/relationship/bloc/birthday_log_state.dart';
import 'package:relate/features/relationship/bloc/topic_bloc.dart';
import 'package:relate/features/relationship/bloc/topic_events.dart';
import 'package:relate/features/relationship/bloc/topic_states.dart';
import 'package:relate/features/relationship/bloc/topic_model.dart';
import 'package:relate/features/relationship/bloc/birthday_log_bloc.dart';
import 'package:relate/features/relationship/bloc/birthday_log_events.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:video_player/video_player.dart';

class ManageRelation extends StatefulWidget {
  final String relationshipId;
  const ManageRelation({super.key, required this.relationshipId});

  @override
  State<ManageRelation> createState() => _ManageRelationState();
}

class _ManageRelationState extends State<ManageRelation> {


  @override
  void initState() {
    super.initState();
    context.read<TopicsBloc>().add(LoadTopics(widget.relationshipId));
    context.read<BirthdayLogsBloc>().add(LoadBirthdayLogs(widget.relationshipId));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.h),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manage Relationship',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            _buildOptionTile(
              icon: Icons.edit,
              title: 'Edit Relationship',
              onTap: () {
                // Handle edit relationship
              },
            ),
            ExpansionTile(
              leading: const Icon(Icons.cake, color: Colors.black),
              title: Text(
                'Birthday Logs',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.sp,
                ),
              ),
              children: [
                BlocBuilder<BirthdayLogsBloc, BirthdayLogState>(
                  builder: (context, state) {
                    if (state is BirthdayLogsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is BirthdayLogsLoaded) {
                      if (state.logs.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Text("No birthday logs yet.", style: TextStyle(fontSize: 14.sp)),
                        );
                      }
                      return Column(
                        children: state.logs.map((log) => _buildBirthdayLogEntryFromModel(log)).toList(),
                      );
                    } else if (state is BirthdayLogsError) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Text(state.error, style: TextStyle(color: Colors.red)),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                _buildAddNewLogButton('birthday'),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.chat_bubble_outline, color: Colors.black),
              title: Text(
                'Topics Logs',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.sp,
                ),
              ),
              children: [
                BlocBuilder<TopicsBloc, TopicState>(
                  builder: (context, state) {
                    if (state is TopicsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is TopicsLoaded) {
                      if (state.topics.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Text("No topics yet.", style: TextStyle(fontSize: 14.sp)),
                        );
                      }
                      return Column(
                        children: state.topics.map((topic) => _buildTopicLogEntry(topic)).toList(),
                      );
                    } else if (state is TopicsError) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Text(state.error, style: TextStyle(color: Colors.red)),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                _buildAddNewLogButton('topic'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthdayLogEntryFromModel(BirthdayLog log) {
  String formattedDate;
  try {
    final parsed = DateTime.tryParse(log.date) ?? DateTime.now();
    formattedDate = DateFormat('dd MMM yyyy').format(parsed);
  } catch (_) {
    formattedDate = log.date;
  }

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formattedDate,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          log.reflection,
          style: TextStyle(
            fontSize: 14.sp,
          ),
        ),
        if (log.attachments.isNotEmpty) ...[
          SizedBox(height: 8.h),
          SizedBox(
            height: 80,
            child: 
            SizedBox(
                      height: 100.h,
                      child: GridView.builder(
                        scrollDirection: Axis.horizontal,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                        itemCount: log.attachments.length,
                        itemBuilder: (context, index) {
                          final item = log.attachments[index];//
                          return GestureDetector(
                            onTap: () async {
                              final result = await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => CarouselScreen(
                                  mediaList: log.attachments,
                                  initialIndex: index,
                                ),
                              );
                              if(result is Map && result['deletionFlag']){
                                /// handle deletion of the media attachment
                              }
                            },
                            child: item.getPreview(context,'',log.attachments[index])
                          );
                        },
                      ),
                    ),
          ),
        ],
        Divider(height: 16.h),
      ],
    ),
  );
}

  Widget _buildTopicLogEntry(Topic topic) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                topic.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
              Text(
                _formatDate(topic.createdAt),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            topic.description,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[800],
            ),
          ),
          Divider(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildAddNewLogButton(String type) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: TextButton.icon(
        onPressed: () {
          if (type == 'birthday') {
            // Show bottom modal to add new birthday log entry
            displayBottomModalSheet(
              context,
              isScroll: true,
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add New Birthday Log',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
                    ),
                    SizedBox(height: 16.h),
                    _AddBirthdayLogForm(
                      relationshipId: widget.relationshipId,
                    ),
                  ],
                ),
              ),
            );
          } else {
            // Show bottom modal to add new topic
            displayBottomModalSheet(
              context,
              isScroll: true,
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add New Topic',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
                    ),
                    SizedBox(height: 16.h),
                    _AddTopicForm(
                      relationshipId: widget.relationshipId,
                    ),
                  ],
                ),
              ),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: Text('Add New ${type.capitalize()} Entry'),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.black,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16.sp,
        ),
      ),
      onTap: onTap,
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')} "
        "${_monthName(date.month)} "
        "${date.year}";
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

class BirthdayLogEntry {
  final String date;
  final String reflection;

  BirthdayLogEntry({
    required this.date,
    required this.reflection,
  });
}

// Helper extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class _AddTopicForm extends StatefulWidget {
  final String relationshipId;
  const _AddTopicForm({required this.relationshipId});

  @override
  State<_AddTopicForm> createState() => _AddTopicFormState();
}

class _AddTopicFormState extends State<_AddTopicForm> {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Title',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: descController,
          decoration: const InputDecoration(
            labelText: 'Description',
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                final desc = descController.text.trim();
                if (title.isNotEmpty && desc.isNotEmpty) {
                  context.read<TopicsBloc>().add(
                    CreateTopic(
                      relationshipId: widget.relationshipId,
                      title: title,
                      description: desc,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}

class _AddBirthdayLogForm extends StatefulWidget {
  final String relationshipId;
  const _AddBirthdayLogForm({required this.relationshipId});

  @override
  State<_AddBirthdayLogForm> createState() => _AddBirthdayLogFormState();
}

class _AddBirthdayLogFormState extends State<_AddBirthdayLogForm> {
  final dateController = TextEditingController();
  final reflectionController = TextEditingController();
  final List<XFile> _attachments = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    dateController.dispose();
    reflectionController.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment({bool isVideo = false}) async {
    final result = await showFilePickerOptions(context);
    if(result == null) return; 
    final file = result["fileObject"];
    setState(() {
      _attachments.add(file);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: dateController,
          decoration: const InputDecoration(
            labelText: 'Date (e.g. 23 Nov 2023)',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: reflectionController,
          decoration: const InputDecoration(
            labelText: 'Reflection',
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickAttachment(isVideo: false),
              icon: const Icon(Icons.attach_file),
              label: const Text('Add Attachment'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_attachments.isNotEmpty)
          SizedBox(
            height: 80,
            child: 
             ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _attachments.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final file = _attachments[i];
                final isImage = file.mimeType?.startsWith('image/') ?? file.path.endsWith('.jpg') || file.path.endsWith('.png');
                final isVideo = file.mimeType?.startsWith('video/') ?? file.path.endsWith('.mp4') || file.path.endsWith('.mov');
                if (isImage) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(file.path),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  );
                } else if (isVideo) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.videocam, size: 40),
                  );
                } else {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.attach_file, size: 40),
                  );
                }
              },
            ),
          ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final date = dateController.text.trim();
                final reflection = reflectionController.text.trim();
                if (date.isNotEmpty && reflection.isNotEmpty) {
                  List<Map<String, dynamic>> attachmentsMeta = [];
                  for (final file in _attachments) {
                    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
                    attachmentsMeta.add({
                      'path': file.path,
                      'type': mimeType,
                      'name': file.name,
                    });
                  }
                  context.read<BirthdayLogsBloc>().add(
                    CreateBirthdayLog(
                      relationshipId: widget.relationshipId,
                      date: date,
                      reflection: reflection,
                      attachments: attachmentsMeta,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}



class CarouselScreen extends StatefulWidget {
  final List<Map<String,dynamic>> mediaList;
  final int initialIndex;
      
  const CarouselScreen({super.key, 
    required this.initialIndex,
    required this.mediaList,
  });

  @override
  _CarouselScreenState createState() => _CarouselScreenState();
}

class _CarouselScreenState extends State<CarouselScreen> {
  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }



  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white24,
      body: Stack(
        children: [
          // Carousel PageView
          Positioned.fill(
            child: Center(
              child: SizedBox(
                height: 0.75.sh,
                width: 0.8.sw,
                child: PageView.builder(
                controller: _pageController,
                itemCount: widget.mediaList.length,
                onPageChanged: (value) {
                  setState(() {
                    _selectedIndex = value;
                  });
                },
                itemBuilder: (context, index) {
                return widget.mediaList[index].getCarouselView(context,widget.mediaList[index]);
                },
              )
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 0,
            left: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 10.w
              ),
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Close",style: TextStyle(
                    fontSize: 12.h
                  ),)
                  ),
                  IconButton(
                  icon: Icon(Icons.delete_rounded, color: Colors.black,size: 20.h,),
                  onPressed: () async  {

                  },
                ),
                ],
               ),
            ))
        ],
      ),
    );
  }
}


extension CarouselMediaView on Map<String,dynamic> {
  Widget getCarouselView(BuildContext context,Map<String,dynamic> item) {
    switch(item["mime"].split('/')[0]) {
      case 'image':
        final itemPath = item["url"];
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(itemPath),
              fit: BoxFit.contain,
            ),
          ),
        );
        
      case 'audio':
        final itemPath = item["url"];
        return VoiceNoteView(
          item:itemPath
        );
      case 'video':
        final itemPath = item["url"];
        return  VideoPlayerView(
          url: itemPath, 
          dataSourceType: DataSourceType.network);     
      case 'quicktime':
        final itemPath = item["url"];
        return  VideoPlayerView(
          url: itemPath, 
          dataSourceType: DataSourceType.network);     
      case 'application':
      return Placeholder();
      // add an option to handle pdfs and other application files
      // case 'pdf':
      //     return PdfViewer(
      //       filePath: item["url"],
      //     );
      // case 'audio':
      case 'location':
       return Placeholder();
        // final coordinates = content.split(',');
        // final latitude = double.parse(coordinates[0]);
        // final longitude = double.parse(coordinates[1]);
        // return MapFullView(
        //   latitude: latitude,
        //   longitude: longitude,
        // );
    }
    return Placeholder();
  }
}

extension PreviewMedia on Map<String,dynamic> {
  Widget getPreview(BuildContext context,String? url,Map<String,dynamic> item){
    Widget child = Container();
    final mime = item["mime"].split('/')[0];
    switch(mime){
      case 'image':
      final itemPath = item["url"];
       child = Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: NetworkImage(itemPath),
                    fit: BoxFit.cover,
                  ),
                ),
              );
        break;
      case 'audio':
        //  child = Container(
        //         height: 100.h,
        //         width: 100.w,
        //         decoration: BoxDecoration(
        //           color: Colors.grey.shade300,
        //           borderRadius: BorderRadius.circular(8.0),
        //         ),
        //         child: Column(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             SvgPicture.asset("assets/images/waveform.svg",height: 25.h,
        //               colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
        //             ),
        //             FutureBuilder<String>(
        //                 future: getVoiceNoteDuration(),
        //                 builder: (context, snapshot) {
        //                   if (snapshot.connectionState == ConnectionState.waiting) {
        //                     return const CircularProgressIndicator();
        //                   } else if (snapshot.hasError) {
        //                     return const Text('Error loading duration');
        //                   } else {
        //                     return Text('${snapshot.data}');
                            
        //                   }
        //                 },
        //               ),
        //             IconButton(onPressed: (){
                      
        //             }, icon: const Icon(Icons.play_arrow))

        //           ],
        //         ),
        //       );
        break;
      case 'video':
       final itemPath = item["url"];
        child = VideoPreview(
                  videoUrl: itemPath,
                  width: 200,
                  height: 150,
        );
        break;
      case 'quicktime':
       final itemPath = item["url"];
        child = VideoPreview(
                  videoUrl: itemPath,
                  width: 200,
                  height: 150,
        );
        break;
      case 'location':
        // final coordinates = content.split(',');
        // final latitude = double.parse(coordinates[0]);
        // final longitude = double.parse(coordinates[1]);
        // child = LocationPreview(latitude: latitude,longitude: longitude);
        // break;

      case 'application':
      break;
    }
    return child;
  }
}