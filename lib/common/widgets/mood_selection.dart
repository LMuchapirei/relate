import 'package:flutter/material.dart';

class MoodTrackerScreen extends StatefulWidget {
  @override
  _MoodTrackerScreenState createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen>
    with SingleTickerProviderStateMixin {
  int _selectedMoodIndex = 4; // Default mood index (Happy)

  final List<String> moods = ["Unhappy", "Sad", "Normal", "Good", "Happy"];
  final List<Color> moodColors = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.lightGreen,
    Colors.yellowAccent,
  ];

  final List<IconData> moodIcons = [
    Icons.sentiment_very_dissatisfied,
    Icons.sentiment_dissatisfied,
    Icons.sentiment_neutral,
    Icons.sentiment_satisfied,
    Icons.sentiment_very_satisfied,
  ];

  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);

    // Pulsating animation
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
         color: Colors.white
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Instruction Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Select current mood and I'll randomly suggest someone to interact with based on the mood you pick",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            SizedBox(height: 40),
            // Mood Indicator with Pulsating Effect
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _selectedMoodIndex != -1 ? _pulseAnimation.value : 1.0,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: moodColors[_selectedMoodIndex],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              moodColors[_selectedMoodIndex].withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        moodIcons[_selectedMoodIndex],
                        size: 80,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 40),
            // Mood Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(moods.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMoodIndex = index;
                    });
                  },
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _selectedMoodIndex == index
                              ? moodColors[index]
                              : Colors.grey.withOpacity(0.3),
                          shape: BoxShape.circle,
                          boxShadow: _selectedMoodIndex == index
                              ? [
                                  BoxShadow(
                                    color: moodColors[index].withOpacity(0.6),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  )
                                ]
                              : [],
                        ),
                        child: Icon(
                          moodIcons[index],
                          color: _selectedMoodIndex == index
                              ? Colors.black87
                              : Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        moods[index],
                        style: TextStyle(
                          color: _selectedMoodIndex == index
                              ? Colors.white
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            SizedBox(height: 50),
            // Suggest Interaction Button
            ElevatedButton.icon(
              onPressed: () {
                // Handle AI suggestion action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: Icon(Icons.psychology, color: Colors.white),
              label: Text(
                'Suggest Interaction',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
