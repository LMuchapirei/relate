import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:relate/features/interactions/bloc/interaction_file_controller.dart';
import 'package:relate/features/interactions/bloc/media_hive_item.dart';
import 'package:relate/features/interactions/bloc/interaction_summary_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import '../../pages/interaction_summary.dart';
import '../values/enums.dart';
import 'attachment_preview.dart';
import 'modals.dart';
import 'package:relate/common/widgets/video_player.dart'; // For VideoPlayerView

class InteractionExpansionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String app;
  final String time;
  final String date;
  final String interactionId;

  const InteractionExpansionCard(
      {super.key,
      required this.icon,
      required this.title,
      required this.app,
      required this.date,
      required this.time,
      required this.interactionId});

  @override
  State<InteractionExpansionCard> createState() =>
      _InteractionExpansionCardState();
}

class _InteractionExpansionCardState extends State<InteractionExpansionCard> {
  late PageController _pageController;
  int _selectedSummaryIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  List<MediaHiveItem> _mediaList = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
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
          leading: Icon(widget.icon, color: Colors.black),
          onExpansionChanged: (value) async {
            if (value) {
              final userId = FirebaseAuth.instance.currentUser?.uid;
              final localMedia = await InteractionFileController()
                  .getMediaItemsForInteraction(widget.interactionId);

              List<MediaHiveItem> summaryMedia = [];
              if (userId != null) {
                final summaries =
                    await InteractionSummaryController().getSummaries(
                  userId: userId,
                  relationshipId: widget.interactionId,
                );
                for (var summary in summaries) {
                  for (var file in summary.files) {
                    summaryMedia.add(MediaHiveItem(
                      type: getMediaTypeFromExtension(
                              file.name.split('.').last) ??
                          MediaHiveType.image,
                      content: file.url,
                      interactionId: widget.interactionId,
                      locationType: LocationHiveType.online,
                      remoteUrl: file.url,
                      syncStatus: 0,
                    ));
                  }
                }
              }

              setState(() {
                _mediaList = [...localMedia, ...summaryMedia];
              });
            }
          },
          title: SizedBox(
            height: 50.h,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 10.h)),
                      Text(widget.app),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(widget.time, style: TextStyle(fontSize: 10.h)),
                      const SizedBox(height: 4),
                    ],
                  ),
                )
              ],
            ),
          ),
          children: [
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
                      offset: const Offset(0, 4),
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                        itemCount: _mediaList.length,
                        itemBuilder: (context, index) {
                          final item = _mediaList[index]; //
                          return GestureDetector(
                              onTap: () async {
                                final result = await showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) => CarouselScreen(
                                    mediaList: _mediaList,
                                    initialIndex: index,
                                  ),
                                );
                                if (result is Map && result['deletionFlag']) {
                                  final mediaList =
                                      await InteractionFileController()
                                          .getMediaItemsForInteraction(
                                              widget.interactionId);
                                  setState(() {
                                    _mediaList = mediaList;
                                  });
                                }
                              },
                              child: item.getPreview(
                                  context, _mediaList[index].content, item));
                        },
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    // Meeting information section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.meeting_room,
                                color: Colors.black54),
                            const SizedBox(width: 8),
                            Text(
                              widget.app, //'Physical Meeting',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'CDB',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Divider(thickness: 1, color: Colors.grey.shade300),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.date,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        // Icon(Icons.more_horiz, color: Colors.black54, size: 18),
                        PopupMenuButton<MenuOptions>(
                          icon: const Icon(Icons.more_horiz),
                          color: Colors.white,
                          onSelected: (MenuOptions result) async {
                            switch (result) {
                              case MenuOptions.edit:
                                displayBottomModalSheetLarge(
                                    context,
                                    DraggableScrollableSheet(
                                        maxChildSize: 0.9,
                                        initialChildSize: 0.9,
                                        builder: (context, controller) {
                                          return InteractionSummaryScreen(
                                            controller: controller,
                                            interactionId: widget.interactionId,
                                          );
                                        }),
                                    isScroll: true);
                                break;
                              case MenuOptions.bookmark:
                                print('Profile selected');
                                break;
                              case MenuOptions.summaries:
                                // Fetch summaries using the controller
                                final userId =
                                    FirebaseAuth.instance.currentUser?.uid;
                                if (userId != null) {
                                  final summaries =
                                      await InteractionSummaryController()
                                          .getSummaries(
                                    userId: userId,
                                    relationshipId: widget.interactionId,
                                  );
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) {
                                      return Container(
                                        height: 600.h,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20.r),
                                            topRight: Radius.circular(20.r),
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 60.h,
                                                  left: 16.w,
                                                  right: 16.w),
                                              child: PageView.builder(
                                                itemCount: summaries.length,
                                                controller: PageController(
                                                    initialPage: 0),
                                                onPageChanged: (i) {
                                                  // Optional: Update state if needed, but be careful about rebuilding
                                                },
                                                itemBuilder: (context, index) {
                                                  final item = summaries[index];
                                                  return SingleChildScrollView(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // Header / Summary Title
                                                        Text(
                                                          item.summary
                                                              .toUpperCase(),
                                                          style: TextStyle(
                                                            fontSize: 18.sp,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            letterSpacing: 1.2,
                                                          ),
                                                        ),
                                                        SizedBox(height: 16.h),

                                                        // Mood and Feeling Row
                                                        Row(
                                                          children: [
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          12.w,
                                                                      vertical:
                                                                          6.h),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .blue
                                                                    .shade50,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20.r),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .blue
                                                                        .shade100),
                                                              ),
                                                              child: Row(
                                                                children: [
                                                                  Text("Mood: ",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color: Colors
                                                                              .blue
                                                                              .shade800)),
                                                                  Text(
                                                                      "${item.mood}",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .blue
                                                                              .shade800)),
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width: 10.w),
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          12.w,
                                                                      vertical:
                                                                          6.h),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .purple
                                                                    .shade50,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20.r),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .purple
                                                                        .shade100),
                                                              ),
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                      "Feeling: ",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color: Colors
                                                                              .purple
                                                                              .shade800)),
                                                                  Text(
                                                                      item
                                                                          .feeling,
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .purple
                                                                              .shade800)),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 20.h),

                                                        // Notes Section
                                                        if (item.notes
                                                            .isNotEmpty) ...[
                                                          Text(
                                                            "Notes",
                                                            style: TextStyle(
                                                              fontSize: 14.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors.grey
                                                                  .shade700,
                                                            ),
                                                          ),
                                                          SizedBox(height: 8.h),
                                                          ...item.notes
                                                              .map(
                                                                  (note) =>
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.only(bottom: 6.h),
                                                                        child:
                                                                            Row(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Padding(
                                                                              padding: EdgeInsets.only(top: 6.h),
                                                                              child: Icon(Icons.circle, size: 6.sp, color: Colors.black54),
                                                                            ),
                                                                            SizedBox(width: 8.w),
                                                                            Expanded(
                                                                              child: Text(
                                                                                note,
                                                                                style: TextStyle(fontSize: 14.sp, height: 1.4),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      )),
                                                          SizedBox(
                                                              height: 20.h),
                                                        ],

                                                        // Media Section
                                                        if (item.files
                                                            .isNotEmpty) ...[
                                                          Text(
                                                            "Attachments",
                                                            style: TextStyle(
                                                              fontSize: 14.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors.grey
                                                                  .shade700,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              height: 10.h),
                                                          SizedBox(
                                                            height: 200.h,
                                                            child: ListView
                                                                .separated(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              itemCount: item
                                                                  .files.length,
                                                              separatorBuilder:
                                                                  (context,
                                                                          index) =>
                                                                      SizedBox(
                                                                          width:
                                                                              10.w),
                                                              itemBuilder:
                                                                  (context,
                                                                      fileIndex) {
                                                                final attachment =
                                                                    item.files[
                                                                        fileIndex];
                                                                final fileUrl =
                                                                    attachment
                                                                        .url;
                                                                final mimeType =
                                                                    attachment
                                                                        .mime;

                                                                Widget content;
                                                                if (mimeType
                                                                    .startsWith(
                                                                        'image/')) {
                                                                  content = Image
                                                                      .network(
                                                                    fileUrl,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    width: double
                                                                        .infinity,
                                                                    height: double
                                                                        .infinity,
                                                                    errorBuilder: (context,
                                                                            error,
                                                                            stackTrace) =>
                                                                        const Icon(
                                                                            Icons.broken_image),
                                                                  );
                                                                } else if (mimeType
                                                                    .startsWith(
                                                                        'video/')) {
                                                                  content =
                                                                      VideoPlayerView(
                                                                    url:
                                                                        fileUrl,
                                                                    dataSourceType:
                                                                        DataSourceType
                                                                            .network,
                                                                  );
                                                                } else if (mimeType
                                                                    .startsWith(
                                                                        'audio/')) {
                                                                  content = Center(
                                                                      child: Icon(
                                                                          Icons
                                                                              .audiotrack,
                                                                          color: Colors
                                                                              .blue,
                                                                          size:
                                                                              40));
                                                                } else {
                                                                  content = Center(
                                                                      child: Icon(
                                                                          Icons
                                                                              .insert_drive_file,
                                                                          color: Colors
                                                                              .grey,
                                                                          size:
                                                                              40));
                                                                }

                                                                return Container(
                                                                  width: 200.w,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12.r),
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade200),
                                                                  ),
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12.r),
                                                                    child:
                                                                        content,
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            Positioned(
                                              top: 16.h,
                                              right: 16.w,
                                              child: IconButton(
                                                icon: Icon(Icons.close),
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("User not logged in")));
                                }
                                break;
                              case MenuOptions.share:
                                break;
                              case MenuOptions.delete:
                                break;
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<MenuOptions>>[
                            const PopupMenuItem<MenuOptions>(
                              value: MenuOptions.edit,
                              child: ListTile(
                                leading: Icon(Icons.edit),
                                title: Text('Add Summary'),
                              ),
                            ),
                            const PopupMenuItem<MenuOptions>(
                              value: MenuOptions.summaries,
                              child: ListTile(
                                leading: Icon(Icons.summarize),
                                title: Text('View Summary'),
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
                            const PopupMenuItem<MenuOptions>(
                              value: MenuOptions.delete,
                              child: ListTile(
                                leading: Icon(Icons.delete),
                                title: Text('Delete'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//// Extracted to a new screen that uses an Expansion List Tile
Widget _buildInteractionItem(BuildContext context,
    {required String title,
    required String time,
    required String date,
    required String app,
    required IconData icon,
    required bool isExpanded}) {
  return GestureDetector(
    onTap: () {
      // Fix this and show
      // displayBottomModalSheetLarge(context,
      // DraggableScrollableSheet(
      //   maxChildSize: 0.9,
      //   initialChildSize: 0.9,
      //   builder: (context,controller) {
      //     return InteractionSummaryScreen(controller: controller,);
      //   }
      // ),isScroll: true);
    },
    child: Container(
      height: 50.h,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(10.h),
      decoration: BoxDecoration(
          color: Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(20.h)),
      child: Row(
        children: [
          SizedBox(
            width: 20.w,
          ),
          Icon(icon, color: Colors.black),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(app),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(time),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          )
        ],
      ),
    ),
  );
}
