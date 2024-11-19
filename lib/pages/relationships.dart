import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:relate/pages/relationship_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../common/widgets/modals.dart';
import '../common/widgets/relationship_form.dart';
import '../common/widgets/manage_relation.dart';

class RelationshipsScreen extends StatefulWidget {
  const RelationshipsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RelationshipsScreenState createState() => _RelationshipsScreenState();
}

class _RelationshipsScreenState extends State<RelationshipsScreen> {
  List<bool> isExpandedList = List.generate(5, (index) => false); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.grey[200], 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                  ),
                ),
                Center(
                  child: Text(
                    'Linear',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Number of relationships
                itemBuilder: (context, index) {
                  return _buildRelationshipItem(index);
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to Add Relationship Screen
                displayBottomModalSheet(context, Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: AddRelationshipScreen())
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
              ),
              child: const  Text('Add Relationship',style: TextStyle(
                color: Colors.white
              ),),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Eg: John Doe',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        SizedBox(width: 10),
        IconButton(
          icon: Icon(Icons.more_vert),
          onPressed: () {
            // Handle filter action
          },
        ),
      ],
    );
  }



Widget _buildRelationshipItem(int index) {
  String relationshipType = index % 2 == 0 ? 'Family' : 'Friendship';
  String rating = index % 2 == 0 ? '10' : '5';
  String date = '12 Jan 2025';
  return Slidable(
              startActionPane: ActionPane(
              motion: const StretchMotion(),
              extentRatio: 0.25,
              children: [
                 Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      displayBottomModalSheet(
                        context, 
                        isScroll: true,
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: const ManageRelation(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.settings, color: Colors.white,),
                    ),
                  ),
                ),
              ],
            ),
            endActionPane: ActionPane(
              motion: const StretchMotion(),
              extentRatio: 0.35,
              openThreshold: 0.3,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      // borderRadius: BorderRadius.circular(30.h)
                    ),
                    child: const Icon(Icons.bookmark,color: Colors.white,),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      // borderRadius: BorderRadius.circular(30.h)
                    ),
                    child: const Icon(Icons.delete,color: Colors.white,),
                  ),
                )
              ],
            ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0, 
      ),
      child: Theme(
        data:  ThemeData(
          expansionTileTheme: ExpansionTileThemeData(
             shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.h),
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.h),
              ),
          )
        ).copyWith(dividerColor: Colors.transparent),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>RelationshipDetailsScreen()));
          },
          child: ExpansionTile(
            tilePadding: EdgeInsets.symmetric(horizontal: 16.0.h),
            backgroundColor: Colors.white, // Background color when expanded
            collapsedBackgroundColor: Colors.white, // Background color when collapsed
            leading: CircleAvatar(
                  radius: 24.h,
                  backgroundImage: AssetImage('assets/profile.jpg'),
                ),
            title: Container(
              height: 50.h,
              child: Row(
                children: [
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tadiwa Linear',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          relationshipType,
                          style: TextStyle(
                            fontSize: 14,
                            color: relationshipType == 'Family' ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        rating,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      Text(date, style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            children: const <Widget>[
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Interactions scheduled', style: TextStyle(fontSize: 16)),
                        Text('10')
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Date Created', style: TextStyle(fontSize: 14)),
                        Text('12 Jan 2024')
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Next Interaction', style: TextStyle(fontSize: 14)),
                        Text('14 Oct 2025')                        
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Rating', style: TextStyle(fontSize: 16)),
                        Row(
                          children: [
                            Icon(Icons.sentiment_satisfied, color: Colors.yellow),
                            SizedBox(width: 5),
                            Text('Good', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}