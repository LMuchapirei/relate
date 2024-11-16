import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import '../enties/media_type.dart';
import '../values/enums.dart';

class CarouselScreen extends StatefulWidget {
  final List<String> imageUrls;
  final List<MediaItem> mediaList;
  final int initialIndex;
      
  const CarouselScreen({super.key, 
    required this.imageUrls,
    required this.initialIndex,
    required this.mediaList,
  });

  @override
  _CarouselScreenState createState() => _CarouselScreenState();
}

class _CarouselScreenState extends State<CarouselScreen> {
  late PageController _pageController;
  late AudioPlayer _audioPlayer;

    Stream<PositionData> get _positionDataStream => Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
    _audioPlayer.positionStream,
    _audioPlayer.bufferedPositionStream,
    _audioPlayer.durationStream,
    (position, bufferedPosition, duration) => PositionData(
      position: position, 
      bufferedPosition: bufferedPosition, 
      duration: duration ?? Duration.zero),
  );

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _audioPlayer = AudioPlayer()
                          ..setUrl(widget.mediaList[widget.initialIndex].content);
  }



  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// wrap this in the relative builder w
    return Scaffold(
      backgroundColor: Colors.white24,
      body: Stack(
        children: [
          // Carousel PageVie
          Positioned.fill(
            child: Center(
              child: SizedBox(
                height: 0.75.sh,
                width: 0.8.sw,
                child: Container(
                  //// Add this decoration to this container
                  // color: Colors.green,
                      // decoration: const BoxDecoration(
                      //     gradient: LinearGradient(
                      //   begin: Alignment.topCenter,
                      //   end: Alignment.bottomCenter,
                      //   colors: [
                      //     Color(0xFF144771), // Dark Blue (top)
                      //     Color(0xFF071A2C), // Lighter Blue (bottom)
                      //   ],
                  // ),
                  // ),
                  child:  PageView.builder(
                  controller: _pageController,
                  itemCount: widget.mediaList.length,
                  onPageChanged: (value) {
                    if(widget.mediaList[value].type == MediaType.voice) {
                      _audioPlayer.setUrl(widget.mediaList[value].content);
                    }
                  },
                  itemBuilder: (context, index) {
                  final url = widget.mediaList[index].type == MediaType.video ? widget.mediaList[index].content : null;
                  return widget.mediaList[index].getCarouselView(context,_audioPlayer,_positionDataStream,url);
                  },
              ),
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