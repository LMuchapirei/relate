import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:relate/common/widgets/modals.dart';
import 'package:relate/pages/schedule_interaction.dart';

import '../common/utils.dart';
import '../common/widgets/attachement_preview.dart';
import '../common/widgets/date_pil.dart';
import '../common/widgets/interaction_card.dart';
import '../common/widgets/month_year_picker.dart';
import '../common/widgets/mood_selection.dart';
import 'interaction_summary.dart';





class RelationshipDetailsScreen extends StatefulWidget {
  @override
  State<RelationshipDetailsScreen> createState() => _RelationshipDetailsScreenState();
}

class _RelationshipDetailsScreenState extends State<RelationshipDetailsScreen> {

  DateTime? selectedMonth;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F1F1),
      appBar:AppBar(
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
                    "Linear's Relationship",
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
      body: DefaultTabController(
        length: 2,
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInteractionCard(),
                 SizedBox(height: 10.h),
                _buildInteractionSummaryHeader(context),
                 SizedBox(height: 5.h),
                 if(selectedMonth != null)
                _buildMonthSelectionDate(),
                 if(selectedMonth != null)
                 SizedBox(height: 5.h),
                _buildFilterHeader(['Incoming','Outgoing']),
                const SizedBox(height: 16),
                Flexible(
                  flex: 4,
                  child: SingleChildScrollView(
                    child: SizedBox(
                      height: 300.h,
                      child: TabBarView(
                        children: [
                          _buildInteractionList(context),
                          _buildInteractionList(context),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Opacity(
        opacity: 0,
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
                child: const Icon(Icons.add),
                backgroundColor: Colors.white,
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
            SizedBox(height: 16),
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
                          'Incoming',
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
                      'Outgoing',
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
          _buildFilterTab('Incoming', false),
          _buildFilterTab('Outgoing', true),
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
      children: List.generate(8, (index) {
        return  InteractionExpansionCard(
          title: index % 2 == 0 ? 'Outgoing Call' : 'Physical Meeting',
          time: '15:30pm',
          date: '12 Jan 2025',
          app: index % 2 == 0 ? 'Phone App' : 'CDB',
          icon: index % 2 == 0 ? Icons.call : Icons.group,
        );
      }),
    );
  }

}