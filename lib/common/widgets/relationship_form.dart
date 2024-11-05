// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class AddRelationshipScreen extends StatefulWidget {
  @override
  _AddRelationshipScreenState createState() => _AddRelationshipScreenState();
}

class _AddRelationshipScreenState extends State<AddRelationshipScreen> {
  double interactionFrequency = 0.5;
  double relationshipRating = 0.5;
  String selectedRelationshipType = 'Family';

  // TextEditingControllers for tracking text input
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  @override
  void dispose() {
    // Dispose the controllers when the widget is disposed
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Add Relationship',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding:  EdgeInsets.all(16.0.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SvgPicture.asset(
              "assets/images/relationships.svg",
              // color: card.cardColor,
              height: 80.w, // Optional: Set height
              semanticsLabel: 'Logo', // Optional: Screen reader description
             ),
            SizedBox(height: 20.h),
             _buildRelationshipTypeSelector(),
            SizedBox(height: 20.h),
            _buildSlider('Interaction Frequency', interactionFrequency,
                (value) {
              setState(() {
                interactionFrequency = value;
              });
            }),
            _buildSlider('Relationship Rating', relationshipRating, (value) {
              setState(() {
                relationshipRating = value;
              });
            }),
            _buildTextInput('First Name', firstNameController),
            SizedBox(height: 10.h),
            _buildTextInput('Last Name', lastNameController),
            SizedBox(height: 10.h),
            _buildTextInput('Phone Number', phoneNumberController),
            SizedBox(height: 20.h),
           
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildFormOptionsButton('Create',onTap:(){

                }),
                buildFormOptionsButton('Cancel',onTap:(){
                  
                },primary: false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton buildFormOptionsButton(String title,{required Function onTap,bool primary = true}) {
    return ElevatedButton(
                onPressed: () {
                  // Handle create action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary ? Colors.black : Colors.grey,
                  fixedSize: Size(100.w, 30.h)
                ),
                child: Text('$title',style: TextStyle(
                  color: primary ? Colors.white : Colors.black
                ),),
              );
  }

  Widget _buildTextInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 5),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.person),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLength: 25,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    counterText: '', // Removes default counter text
                    hintText: 'Enter $label',
                  ),
                  onChanged: (text) {
                    setState(() {}); // Update the UI when text changes
                  },
                ),
              ),
              Text('${controller.text.length}/25'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRelationshipTypeSelector() {
    List<Map<String, dynamic>> relationshipTypes = [
      {'label': 'Family', 'color': Colors.red},
      {'label': 'Friendship', 'color': Colors.green},
      {'label': 'Work', 'color': Colors.brown},
      {'label': 'Church', 'color': Colors.purple},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Relationship Type'),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: relationshipTypes.map((type) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedRelationshipType = type['label'];
                });
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: type['color'],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selectedRelationshipType == type['label']
                        ? Colors.black
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text(type['label'],
                    style: TextStyle(color: Colors.white)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSlider(String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Low'),
            Expanded(
              child: Slider(
                value: value,
                min: 0,
                max: 1,
                onChanged: onChanged,
                activeColor: Colors.red,
                inactiveColor: Colors.grey,
              ),
            ),
            Text('High'),
          ],
        ),
      ],
    );
  }
}