import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:relate/common/widgets/modals.dart';
import 'package:relate/pages/schedule_interaction.dart';
import '../common/utils.dart';
import '../common/widgets/date_pil.dart';
import '../common/widgets/interaction_card.dart';
import '../common/widgets/month_year_picker.dart';
import '../common/widgets/mood_selection.dart';





class RelationshipDetailsScreen extends StatefulWidget {
  const RelationshipDetailsScreen({super.key});

  @override
  State<RelationshipDetailsScreen> createState() => _RelationshipDetailsScreenState();
}

class _RelationshipDetailsScreenState extends State<RelationshipDetailsScreen> {

  DateTime? selectedMonth;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(headerSliverBuilder: (context,innBoxIsScrolled){
          return <Widget>[
            SliverAppBar(
              backgroundColor: const Color(0xFFF1F1F1),
              actions: [
                IconButton(onPressed: (){}, icon: const Icon(Icons.search)),
              ],
              pinned: true,
              floating: false,
              expandedHeight: 200.h,
              automaticallyImplyLeading: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Flex(
                  direction: Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                     Padding(
                       padding:  EdgeInsets.symmetric(
                        horizontal: 4.w ,
                       ),
                       child: _buildInteractionCard(),
                     )
                  ],
                ),
              ),
            ),
             SliverPersistentHeader(
              pinned: true,
              delegate: CustomSliverHeaderDelegate(
              child:  Padding(
                padding: const EdgeInsets.all(5.0),
                child: _buildFilterHeader(['Scheduled','Done']),
              ), 
              minHeight: 60,
              maxHeight: 70
            ))
          ];
        },
         body: Padding(
           padding: const EdgeInsets.all(16.0),
           child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             _buildInteractionSummaryHeader(context),
              if(selectedMonth != null)
             _buildMonthSelectionDate(),
             Expanded(
               child: SizedBox(
                 width: MediaQuery.of(context).size.width,
                 child: TabBarView(
                   children: [
                     _buildInteractionList(context),
                     _buildInteractionList(context),
                   ],
                 ),
               ),
             )
           ],
         ),
      )),
   ),
  floatingActionButton: Opacity(
        opacity: 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50.h))
                ),
                onPressed: () {
                  // Add action for creating a new interaction
                  displayBottomModalSheetLarge(context, DraggableScrollableSheet(
                    maxChildSize: 0.9,
                    initialChildSize: 0.9,
                    builder: (context,controller) {
                      return ScheduleInteractionScreen(controller: controller,);
                    }
                  ),isScroll: true);
                },
                child: const Icon(Icons.add),
                backgroundColor: Colors.white,
              ),
              SizedBox(
                height: 10.h,
              ),
              FloatingActionButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50.h))
                ),
                onPressed: () {
                  // Add action for creating a new interaction
                  _showRandomInteractionPicker();
                },
                backgroundColor: Colors.white,
                child: const Icon(Icons.memory),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterHeader(List<String> tabTitle) {
  return Container(
    height: 40.h,
    margin: EdgeInsets.symmetric(horizontal: 20.w),
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(30.w), 
    ),
    child: TabBar(
      indicator: BoxDecoration(
        color: Colors.grey[400], 
        borderRadius: BorderRadius.circular(30.w),
      ),
      indicatorPadding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 0),
      labelPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 5.h),
      dividerHeight: 0,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.black,
      tabs: tabTitle.map((e) => buildTab(e)).toList()
      
    ),
  );
}
  Widget _buildMonthSelectionDate(){
    final dates = generateMonthDates(selectedMonth!);
    return Container(
        height: 70.h,
        width: MediaQuery.of(context).size.width,
        child:  ListView.builder(
          itemCount: dates.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: ((context, index) {
            final date  = dates[index];
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 5.h),
              margin: EdgeInsets.all(5.h),
              width: 60.w,
              decoration: BoxDecoration(
                color: date["IsToday"]   ? Colors.grey : Colors.white,
                borderRadius: BorderRadius.circular(40.h),
                border: date["IsToday"] ?  Border.all(
                  color: Colors.black
                ) : Border.all(
                  color: Colors.transparent
                )
              ),
              child: DatePill(
                month: date["Month"]!,
                date: date["Date"]!,
              ),
            );
        }))
    );
   }
  /// Randomly select someone to talk to after entering how you are feeling and suggested someone to talk to
  _showRandomInteractionPicker(){
     displayBottomModalSheet(context, MoodTrackerScreen());
   }
Widget buildTab(String title) {
  return Tab(
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.w),
      ),
      child: Align(
        alignment: Alignment.center,
        child: Text(title, style: TextStyle(fontSize: 12.sp)),
      ),
    ),
  );
}

  Widget _buildInteractionCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Color(0xFFFFFFFF),
      child:  Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '10 Interactions',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
            SizedBox(height: 4),
            Text(
              'with Tapiwa Mabika',
              style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    // SizedBox(height: 4.h),
                    Row(
                      children: [
                        const Icon(Icons.arrow_downward, color: Colors.black),
                        Text(
                          'Scheduled',
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '5',
                      style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.arrow_upward, color: Colors.black),
                    Text(
                      'Done',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '5',
                      style: TextStyle(
                          fontSize: 18.h,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'Friendship',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMonthYearPicker(BuildContext context) async {
    if(selectedMonth != null){
      setState(() {
        selectedMonth = null;
      });
      return;
    }
    final result = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return MonthYearPicker();
      },
    );
    /// Change the date to the one from the modal
    if(result != null && (result as Map<String,dynamic>).isNotEmpty){
        setState(() {
          selectedMonth = DateTime(result["year"],result["month"] + 1,1);
      });
    }
  }

  Widget _buildInteractionSummaryHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interaction Summary',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            SizedBox(height: 4),
            Text(
              'Last 90 Days (11 Oct 2024 - 11 Jan 2025)',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            // Action for the calendar button
            _showMonthYearPicker(context);
          },
          icon: const Icon(Icons.calendar_today, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _buildFilterTab('Scheduled', false),
          _buildFilterTab('Done', true),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String title, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[400] : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black87 : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractionList(BuildContext context) {
    return ListView(
      children: List.generate(50, (index) {
        return  Slidable( 
          startActionPane: ActionPane(
              motion: const StretchMotion(),
              extentRatio: 0.25,
              children: [
                 Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      // borderRadius: BorderRadius.circular(30.h)
                    ),
                    child: const Icon(Icons.edit,color: Colors.white,),
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
          child: InteractionExpansionCard(
            title: index % 2 == 0 ? 'Outgoing Call' : 'Physical Meeting',
            time: '15:30pm',
            date: '12 Jan 2025',
            app: index % 2 == 0 ? 'Phone App' : 'CDB',
            icon: index % 2 == 0 ? Icons.call : Icons.group,
          ),
        );
      }),
    );
  }
}

class CustomSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  CustomSliverHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Calculate current height based on the shrink offset
    final currentHeight = (maxExtent - shrinkOffset).clamp(minExtent, maxExtent);

    return SizedBox(
      height: currentHeight,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxExtent || minHeight != oldDelegate.minExtent;
  }
}


