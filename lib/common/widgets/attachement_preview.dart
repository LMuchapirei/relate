
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CarouselScreen extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  CarouselScreen({required this.imageUrls, required this.initialIndex});

  @override
  _CarouselScreenState createState() => _CarouselScreenState();
}

class _CarouselScreenState extends State<CarouselScreen> {
  late PageController _pageController;

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
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return Center(
                child: Hero(
                  tag: 'image_tag_$index',
                  child: Image.network(
                    widget.imageUrls[index],
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
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
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ],
                      ),
            ))
        ],
      ),
    );
  }
}