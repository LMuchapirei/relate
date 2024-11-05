import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScheduleInteractionScreen extends StatefulWidget {
  final ScrollController controller;

  const ScheduleInteractionScreen({required this.controller});
  @override
  _ScheduleInteractionScreenState createState() =>
      _ScheduleInteractionScreenState();
}

class _ScheduleInteractionScreenState extends State<ScheduleInteractionScreen> {
  bool isDateSelected = false;
  bool isTimeSelected = false;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool isRedirectEnabled = false;
  String? selectedApp;
  String? selectedPriority = 'Low';

  final List<String> appOptions = [
    'Call',
    'Messages',
    'WhatsApp',
    'Maps'
  ];

  final List<String> priorityOptions = [
    'Low',
    'Medium',
    'High',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Schedule Interaction',
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
          scrollDirection: Axis.vertical,
          controller: widget.controller,
            children: [
              _buildTextFieldSection(),
              const SizedBox(height: 16),
              _buildDateTimeSection(),
              if (isDateSelected) _buildInlineDatePicker(),
              if (isTimeSelected) _buildInlineTimePicker(),
              const SizedBox(height: 16),
              _buildOptionsSection(),
              const SizedBox(height: 32),
              _buildActionButtons(context),
            ]
        ),
      ),
    );
  }

  Widget _buildRedirectDropdown(){
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.apps, color: Colors.black),
          const SizedBox(width: 8),
          const Text('Select App', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<String>(
              value: selectedApp,
              hint: const Text('Choose an app'),
              onChanged: (String? newValue) {
                setState(() {
                  selectedApp = newValue;
                });
              },
              items: appOptions.map<DropdownMenuItem<String>>((String app) {
                return DropdownMenuItem<String>(
                  value: app,
                  child: Text(app),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Title',
              border: InputBorder.none,
            ),
          ),
          SizedBox(height: 8),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Notes',
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.black),
              const SizedBox(width: 8),
              Text('Date', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Switch(
                value: isDateSelected,
                onChanged: (value) {
                  setState(() {
                    isDateSelected = value;
                  });
                },
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.black),
              const SizedBox(width: 8),
              Text('Time', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Switch(
                value: isTimeSelected,
                onChanged: (value) {
                  setState(() {
                    isTimeSelected = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInlineDatePicker() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Date',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          CalendarDatePicker(
            initialDate: selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            onDateChanged: (date) {
              setState(() {
                selectedDate = date;
              });
            },
          ),
        ],
      ),
    );
  }



  Widget _buildInlineTimePicker() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Time',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: selectedTime,
              );
              if (picked != null && picked != selectedTime) {
                setState(() {
                  selectedTime = picked;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
            ),
            child: Text(
              'Pick Time: ${selectedTime.format(context)}',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsSection() {
       return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          const Text('Redirect Application', style: TextStyle(fontSize: 16)),
          Switch(
            value: isRedirectEnabled,
            onChanged: (value) {
              setState(() {
                isRedirectEnabled = value;
              });
            },
          ),
          ],),
          if (isRedirectEnabled)
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: DropdownButton<String>(
                value: selectedApp,
                hint: const Text('Choose an app'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedApp = newValue;
                  });
                },
                items: appOptions.map<DropdownMenuItem<String>>((String app) {
                  return DropdownMenuItem<String>(
                    value: app,
                    child: Text(app),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Priority', style: TextStyle(fontSize: 16)),
              DropdownButton<String>(
                value: selectedPriority,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPriority = newValue;
                  });
                },
                items: priorityOptions
                    .map<DropdownMenuItem<String>>((String priority) {
                  return DropdownMenuItem<String>(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
              ),
            ],
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
            // Handle Add action
          },
          style: ElevatedButton.styleFrom(
            fixedSize: Size(100.w, 30.h),
            backgroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Text(
              'Add',
              style: TextStyle(color: Colors.white),),
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
          child: const Text('Cancel',
          style: TextStyle(
            color: Colors.black
          ),),
        ),
      ],
    );
  }
}
