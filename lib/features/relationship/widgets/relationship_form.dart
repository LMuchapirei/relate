// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'dart:io';

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
      body: BlocBuilder<RelationShipFormBlocs, RelationshipFormStates>(
          builder: (context, state) {
        // double frequency = state.frequency; // Removed
        // double rating = state.rating; // Removed
        return Padding(
          padding: EdgeInsets.all(16.0.h),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (state.profilePicture != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        File(state.profilePicture!.path),
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                SizedBox(
                  height: 20.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Add Profile image'),
                      GestureDetector(
                          onTap: () async {
                            final result =
                                await showImagePickerOptions(context);
                            if (result is Map) {
                              final fileObject = result['fileObject'] as XFile;
                              context
                                  .read<RelationShipFormBlocs>()
                                  .add(ProfilePictureEvent(fileObject));
                            }
                          },
                          child: SvgPicture.asset(
                            "assets/images/attach.svg",
                            height: 20.h,
                          )),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                _buildRelationshipTypeSelector(state),
                SizedBox(height: 20.h),
                _buildFrequencySelector(state.frequency, (value) {
                  context
                      .read<RelationShipFormBlocs>()
                      .add(FrequencyEvent(value));
                }),
                _buildRatingSelector(state.rating, (value) {
                  context.read<RelationShipFormBlocs>().add(RatingEvent(value));
                }),
                _buildTextInput('First Name', firstNameController, (value) {
                  context
                      .read<RelationShipFormBlocs>()
                      .add(FirstNameEvent(value));
                }),
                SizedBox(height: 10.h),
                _buildTextInput('Last Name', lastNameController, (value) {
                  context
                      .read<RelationShipFormBlocs>()
                      .add(LastNameEvent(value));
                }),
                _buildTextInput('Nick Name', nickNameController, (value) {
                  context
                      .read<RelationShipFormBlocs>()
                      .add(NickNameEvent(value));
                }),
                SizedBox(height: 10.h),
                _buildTextInput('Phone Number', phoneNumberController, (value) {
                  context
                      .read<RelationShipFormBlocs>()
                      .add(PhoneNumberEvent(value));
                }),
                SizedBox(height: 20.h),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildFormOptionsButton('Create', onTap: () async {
                      RelationshipController().submitRelationship(context);
                      // Refresh relationships after submission
                      context
                          .read<RelationshipListBloc>()
                          .add(LoadRelationships());
                      Navigator.of(context).pop(state);
                    }),
                    buildFormOptionsButton('Cancel', onTap: () {
                      Navigator.of(context).pop(null);
                    }, primary: false),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTextInput(String label, TextEditingController controller,
      void Function(String)? onChanged) {
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
    final TextEditingController tagController = TextEditingController();
    final List<String> predefinedTags = [
      '#family',
      '#friend',
      '#work',
      '#church',
      '#mentor',
      '#teammate',
      '#romantic',
      '#colleague',
      '#acquaintance',
      '#neighbor',
      '#business_partner'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Tags (e.g. #friend, #work)'),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: tagController,
                decoration: InputDecoration(
                  hintText: 'Add a tag',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    final tag = value.startsWith('#') ? value : '#$value';
                    context.read<RelationShipFormBlocs>().add(AddTagEvent(tag));
                    tagController.clear();
                  }
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.add_circle),
              onPressed: () {
                if (tagController.text.isNotEmpty) {
                  final value = tagController.text;
                  final tag = value.startsWith('#') ? value : '#$value';
                  context.read<RelationShipFormBlocs>().add(AddTagEvent(tag));
                  tagController.clear();
                }
              },
            ),
          ],
        ),
        SizedBox(height: 10),
        Text('Suggested Tags:',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        SizedBox(height: 5),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: predefinedTags.map((tag) {
            final isSelected = state.tags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  context.read<RelationShipFormBlocs>().add(AddTagEvent(tag));
                } else {
                  context
                      .read<RelationShipFormBlocs>()
                      .add(RemoveTagEvent(tag));
                }
              },
              backgroundColor: Colors.grey[300],
              selectedColor: Colors.green[200],
            );
          }).toList(),
        ),
        SizedBox(height: 10),
        if (state.tags.isNotEmpty) ...[
          Text('Selected Tags:',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          SizedBox(height: 5),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: state.tags
                .map((tag) => Chip(
                      label: Text(tag),
                      onDeleted: () {
                        context
                            .read<RelationShipFormBlocs>()
                            .add(RemoveTagEvent(tag));
                      },
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildFrequencySelector(
      String currentFrequency, Function(String) onChanged) {
    final List<String> frequencies = [
      'Daily',
      'Weekly',
      'Monthly',
      'Quarterly',
      'Yearly'
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Interaction Frequency'),
        SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          children: frequencies.map((freq) {
            return ChoiceChip(
              label: Text(freq),
              selected: currentFrequency == freq,
              onSelected: (selected) {
                if (selected) {
                  onChanged(freq);
                }
              },
              selectedColor: Colors.green[200],
              backgroundColor: Colors.grey[300],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRatingSelector(
      double currentRating, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Relationship Rating'),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < currentRating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 32,
              ),
              onPressed: () {
                onChanged(index + 1.0);
              },
            );
          }),
        ),
      ],
    );
  }
}
