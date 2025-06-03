import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:relate/common/widgets/modals.dart';
import 'package:relate/features/relationship/bloc/topic_bloc.dart';
import 'package:relate/features/relationship/bloc/topic_events.dart';
import 'package:relate/features/relationship/bloc/topic_states.dart';
import 'package:relate/features/relationship/bloc/topic_model.dart';

class ManageRelation extends StatefulWidget {
  final String relationshipId;
  const ManageRelation({super.key, required this.relationshipId});

  @override
  State<ManageRelation> createState() => _ManageRelationState();
}

class _ManageRelationState extends State<ManageRelation> {
  bool _isBirthdayLogExpanded = false;

  // Sample birthday log entries - replace with actual data
  final List<BirthdayLogEntry> _birthdayLogs = [
    BirthdayLogEntry(
      date: '23 Nov 2023',
      reflection: 'Ate a lot and talked about moving in together in six months',
    ),
    BirthdayLogEntry(
      date: '23 Nov 2022',
      reflection: 'Celebrated at the beach house, discussed future travel plans',
    ),
  ];

  @override
  void initState() {
    super.initState();
    context.read<TopicsBloc>().add(LoadTopics(widget.relationshipId));
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
                ..._birthdayLogs.map((entry) => _buildBirthdayLogEntry(entry)),
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

  Widget _buildBirthdayLogEntry(BirthdayLogEntry entry) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.date,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            entry.reflection,
            style: TextStyle(
              fontSize: 14.sp,
            ),
          ),
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
            // Handle adding new birthday log entry
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

// Helper extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}