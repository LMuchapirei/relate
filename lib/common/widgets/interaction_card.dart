import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../pages/relationship_screen.dart';
import 'attachement_preview.dart';

class InteractionExpansionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String app;
  final String time;
  final String date;

  const InteractionExpansionCard({ required this.icon,required this.title,required this.app, required this.date,required this.time});


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5
      ),
      child: Theme(
        data: ThemeData().copyWith(
          expansionTileTheme: ExpansionTileThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.h),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.h),
            ),
          ),
          dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          leading:Icon(icon, color: Colors.black) ,
          title: Container(
            height: 50.h,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style:  TextStyle(fontWeight: FontWeight.bold,fontSize: 10.h),),
                      Text(app),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                     Text(time,style: TextStyle(
                      fontSize: 10.h
                     ),),
                     const SizedBox(height: 4),
                    ],
                  ),
                )
              ],
            ),
          ),
          children: [
            // Expanded Content with Grid of Images
                  Center(
        child: Container(
        margin: EdgeInsets.all(16.0.h),
        padding: EdgeInsets.all(12.0.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: Colors.black54, // Border color
            width: 1.5,
          ),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        width: 350.w, // Adjust width as needed
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                        // Horizontal Scrollable Grid
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
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Open the full-screen carousel
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => CarouselScreen(
                          imageUrls: imageUrls,
                          initialIndex: index,
                        ),
                      );
                    },
                    child: Hero(
                      tag: 'image_tag_$index',
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8.0),
                          image: DecorationImage(
                            image: NetworkImage(imageUrls[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
             SizedBox(
              height: 10.h,
            ),
            // Meeting information section
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.meeting_room, color: Colors.black54),
                    SizedBox(width: 8),
                    Text(
                      'Physical Meeting',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Text(
                  'CDB',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
         
            Divider(thickness: 1, color: Colors.grey.shade300),
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                  const Text(
                  'Tuesday, 12 Jun',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                // Icon(Icons.more_horiz, color: Colors.black54, size: 18),
                PopupMenuButton<MenuOptions>(
              icon: const Icon(Icons.more_horiz),
              color: Colors.white,
              onSelected: (MenuOptions result) {
                switch (result) {
                  case MenuOptions.edit:
                    print('Settings selected');
                    break;
                  case MenuOptions.bookmark:
                    print('Profile selected');
                    break;
                  case MenuOptions.share:
                    print('Logout selected');
                    break;
                  case MenuOptions.delete:
                    // TODO: Handle this case.
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuOptions>>[
                const PopupMenuItem<MenuOptions>(
                  value: MenuOptions.delete,
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete'),
                  ),
                ),
                const PopupMenuItem<MenuOptions>(
                  value: MenuOptions.edit,
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                  ),
                ),
                const PopupMenuItem<MenuOptions>(
                  value: MenuOptions.bookmark,
                  child: ListTile(
                    leading: Icon(Icons.bookmark),
                    title: Text('Bookmark'),
                  ),
                ),
                const PopupMenuItem<MenuOptions>(
                  value: MenuOptions.share,
                  child: ListTile(
                    leading: Icon(Icons.share),
                    title: Text('Share'),
                  ),
                    ),
                  ],
                ),
                ],
                ),
                ],
              ),
            ),
          )
          ],
        ),
      ),
    );
  }
}