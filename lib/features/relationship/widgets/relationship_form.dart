// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:relate/features/relationship/bloc/relationship_bloc.dart';
import 'package:relate/features/relationship/bloc/relationship_event.dart';
import 'package:relate/features/relationship/bloc/relationship_state.dart';

import '../../../common/widgets/file_picker.dart';
import '../bloc/relationship_controller.dart';
import 'buttons.dart';

class AddRelationshipScreen extends StatefulWidget {
  const AddRelationshipScreen({super.key});

  @override
  _AddRelationshipScreenState createState() => _AddRelationshipScreenState();
}

class _AddRelationshipScreenState extends State<AddRelationshipScreen> {

  // TextEditingControllers for tracking text input
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController nickNameController = TextEditingController();
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
     backgroundColor: Colors.grey[200], //
      appBar: AppBar(
         backgroundColor: Colors.grey[200], //
        elevation: 0,
        title: Text(
          'Add Relationship',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<RelationShipFormBlocs,RelationshipFormStates>(
        builder: (context,state) {
          double frequency = state.frequency;
          double rating = state.rating;
          return Padding(
            padding:  EdgeInsets.all(16.0.h),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // SvgPicture.asset(
                  //   "assets/images/relationships.svg",
                  //   // color: card.cardColor,
                  //   height: 80.w, // Optional: Set height
                  //   semanticsLabel: 'Logo', // Optional: Screen reader description
                  //  ),
                  if(state.profilePicture != null)
                  Container(
                    color: Colors.red,
                    height: 40,
                    width: 40,
                  ),
                  SizedBox(
                    height: 20.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Add Profile image'),
                          GestureDetector(
                          onTap: () async {
                           final result =  await showImagePickerOptions(context);
                           if(result is Map){
                            final fileObject = result['fileObject'] as XFile;
                             context.read<RelationShipFormBlocs>().add(ProfilePictureEvent(fileObject));
                           }
                          },
                         child: SvgPicture.asset("assets/images/attach.svg",height: 20.h,)),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                   _buildRelationshipTypeSelector(state),
                  SizedBox(height: 20.h),
                  _buildSlider('Interaction Frequency',frequency,
                      (value) {
                        context.read<RelationShipFormBlocs>().add(FrequencyEvent(value));
                  }),
                  _buildSlider('Relationship Rating', rating, (value) {
                      context.read<RelationShipFormBlocs>().add(RatingEvent(value));
                  }),

                  _buildTextInput('First Name', firstNameController,(value){
                    context.read<RelationShipFormBlocs>().add(FirstNameEvent(value));
                  }),
                  SizedBox(height: 10.h),
                  _buildTextInput('Last Name', lastNameController,(value){
                      context.read<RelationShipFormBlocs>().add(LastNameEvent(value));
                  }),
                  _buildTextInput('Nick Name', nickNameController,(value){
                      context.read<RelationShipFormBlocs>().add(NickNameEvent(value));
                  }),
                  SizedBox(height: 10.h),
                  _buildTextInput('Phone Number', phoneNumberController,(value){
                      context.read<RelationShipFormBlocs>().add(PhoneNumberEvent(value));
                  }),
                  SizedBox(height: 20.h),
                 
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildFormOptionsButton('Create', onTap: () {
                       RelationshipController(context).submitRelationship();
                       Navigator.of(context).pop(state);
                      }),
                      buildFormOptionsButton('Cancel',onTap:(){
                        Navigator.of(context).pop(null);
                      },primary: false),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }


  Widget _buildTextInput(String label, TextEditingController controller,void Function(String)? onChanged) {
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
                  onChanged: onChanged,
                ),
              ),
              Text('${controller.text.length}/25'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRelationshipTypeSelector(RelationshipFormStates state) {
    List<Map<String, dynamic>> relationshipTags = [
      {'label': 'Family', 'color': Colors.red},
      {'label': 'Friendship', 'color': Colors.green},
      {'label': 'Work', 'color': Colors.brown},
      {'label': 'Church', 'color': Colors.purple},
      {'label': 'Mentor', 'color': Colors.purple},
      {'label': 'Teammate', 'color': Colors.purple},
      /// --->
      {'label': 'Romantic', 'color': Colors.purple},
      {'label': 'Colleague', 'color': Colors.purple},
      {'label': 'Acquaintance', 'color': Colors.purple},
      {'label': 'Neighbor', 'color': Colors.purple},
      {'label': 'Business Partner', 'color': Colors.purple},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Relationship Type'),
        SizedBox(height: 10),
         Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: relationshipTags.map((e) => _buildChip(e['label'],state)).toList(),
                ),
              ),
      ],
    );
  }

  Widget _buildChip(String tag,RelationshipFormStates state) {
    final isSelected = state.relationshipType == tag;
    return ChoiceChip(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tag, style: TextStyle(color: isSelected ? Colors.black : Colors.white)),
          if (isSelected) SizedBox(width: 6),

        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
         context.read<RelationShipFormBlocs>().add(RelationshipTypeEvent(tag));
        });
      },
      selectedColor: Colors.green,
      backgroundColor: Colors.black54,
      labelStyle: TextStyle(fontWeight: FontWeight.bold),
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