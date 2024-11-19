import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ManageRelation extends StatefulWidget {
  const ManageRelation({super.key});

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

  // Add sample topics log entries
  final List<TopicLogEntry> _topicsLogs = [
    TopicLogEntry(
      date: '15 Mar 2024',
      topic: 'Career goals and aspirations',
      notes: 'Discussed potential job changes and further education plans',
    ),
    TopicLogEntry(
      date: '10 Mar 2024',
      topic: 'Family planning',
      notes: 'Talked about timeline for having kids and preferred parenting styles',
    ),
  ];

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
                ..._topicsLogs.map((entry) => _buildTopicLogEntry(entry)),
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

  Widget _buildTopicLogEntry(TopicLogEntry entry) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.topic,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
              Text(
                entry.date,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            entry.notes,
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
          // Handle adding new entry based on type
          if (type == 'birthday') {
            // Handle adding new birthday log entry
          } else {
            // Handle adding new topic log entry
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
}

class BirthdayLogEntry {
  final String date;
  final String reflection;

  BirthdayLogEntry({
    required this.date,
    required this.reflection,
  });
}

// Add new TopicLogEntry class
class TopicLogEntry {
  final String date;
  final String topic;
  final String notes;

  TopicLogEntry({
    required this.date,
    required this.topic,
    required this.notes,
  });
}

// Helper extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
} 