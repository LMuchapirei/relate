// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:relate/features/interactions/bloc/interaction_file_controller.dart';
import 'package:relate/features/interactions/bloc/media_hive_item.dart';

class CarouselScreen extends StatefulWidget {
  final List<MediaHiveItem> mediaList;
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
                    final result = await InteractionFileController().deleteMediaItem(widget.mediaList[_selectedIndex]);
                    Navigator.of(context).pop({"deletionFlag":result});
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