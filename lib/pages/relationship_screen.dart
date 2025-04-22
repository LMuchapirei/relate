import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:relate/common/widgets/modals.dart';
import 'package:relate/features/interactions/bloc/interaction_blocs.dart';
import 'package:relate/features/interactions/bloc/interaction_states.dart';
import 'package:relate/features/relationship/models/relationship_model.dart';
import 'package:relate/pages/schedule_interaction.dart';
import '../common/utils.dart';
import '../common/widgets/date_pil.dart';
import '../common/widgets/interaction_card.dart';
import '../common/widgets/month_year_picker.dart';
import '../common/widgets/mood_selection.dart';

class RelationshipDetailsScreen extends StatefulWidget {
  final Relationship relationship;
  const RelationshipDetailsScreen({super.key,required this.relationship});

  @override
  State<RelationshipDetailsScreen> createState() =>
      _RelationshipDetailsScreenState();
}

class _RelationshipDetailsScreenState extends State<RelationshipDetailsScreen> {
  DateTime? selectedMonth = DateTime.now();
  Map<String,dynamic> _filterPeriod = {};
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F1F1),
        body: NestedScrollView(
          headerSliverBuilder: (context, innBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                backgroundColor: const Color(0xFFF1F1F1),
                actions: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                        ),
                        child: _buildInteractionCard(widget.relationship.relationshipType),
                      )
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                  pinned: true,
                  delegate: CustomSliverHeaderDelegate(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: _buildFilterHeader(['Scheduled', 'Done']),
                      ),
                      minHeight: 70,
                      maxHeight: 70))
            ];
          },
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                    child: _buildInteractionSummaryHeader(context)),
                if (selectedMonth != null)
                  SliverToBoxAdapter(child: _buildMonthSelectionDate()),
                SliverToBoxAdapter(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: TabBarView(
                      children: [
                        _buildLiveInteractionList(context),
                        _buildInteractionList(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Opacity(
          opacity: 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50.h))),
                onPressed: () {
                  // Add action for creating a new interaction
                  displayBottomModalSheetLarge(
                      context,
                      DraggableScrollableSheet(
                          maxChildSize: 0.9,
                          initialChildSize: 0.9,
                          builder: (context, controller) {
                            return ScheduleInteractionScreen(
                              controller: controller,
                            );
                          }),
                      isScroll: true);
                },
                backgroundColor: Colors.white,
                child: const Icon(Icons.add),
              ),
              SizedBox(
                height: 10.h,
              ),
              FloatingActionButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50.h))),
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
          isScrollable: false,
          unselectedLabelColor: Colors.black,
          tabs: tabTitle
              .map((e) => _buildFilterTab(e, false))
              .toList() //buildTab(e)).toList()

          ),
    );
  }

  Widget _buildMonthSelectionDate() {
    final dates = getDatesOfMonth(selectedMonth!);//generateMonthDates(selectedMonth!);
    return SizedBox(
        height: 70.h,
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
            itemCount: dates.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: ((context, index) {
              final date = dates[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                  _filterPeriod = date;
                  });

                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  margin: EdgeInsets.all(5.h),
                  width: 60.w,
                  decoration: BoxDecoration(
                      color: date["isToday"] ? Colors.grey : Colors.white,
                      borderRadius: BorderRadius.circular(40.h),
                      border: date["isToday"]
                          ? Border.all(color: Colors.black)
                          : Border.all(color: Colors.transparent)),
                  child: DatePill(
                    month: date["month"]!,
                    date: date["date"]!,
                  ),
                ),
              );
            })));
  }

  /// Randomly select someone to talk to after entering how you are feeling and suggested someone to talk to
  _showRandomInteractionPicker() {
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

  Widget _buildInteractionCard(String relationshipType) {
    return BlocConsumer<InteractionListBloc, InteractionListState>(
      listener: (context, state) {

      },
      builder: (context, state) {
        var interactions = "No Interactions";
        var scheduled = 0;
        if(state is InteractionListLoaded){
          if(state.scheduledInteractions.isNotEmpty){
            interactions = "${state.scheduledInteractions.length} Interactions";
          }
           scheduled = state.scheduledInteractions.map((e)=> e.selectedDate !=null && e.selectedDate!.isAfter(DateTime.now())).length;
        }
        return Container(
          decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                interactions,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                'with ${widget.relationship.firstName}',
                style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.event, color: Colors.black),
                          Text(
                            'Scheduled',
                            style:
                                TextStyle(fontSize: 14.sp, color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '$scheduled',
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
                          const Icon(Icons.event_available, color: Colors.black),
                          Text(
                            'Done',
                            style:
                                TextStyle(fontSize: 14.sp, color: Colors.grey),
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
              const SizedBox(height: 16),
              Center(
                child: Text(
                  relationshipType,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMonthYearPicker(BuildContext context) async {
    if (selectedMonth != null) {
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
    if (result != null && (result as Map<String, dynamic>).isNotEmpty) {
      setState(() {
        selectedMonth = DateTime(result["year"], result["month"] + 1, 1);
      });
    }
  }

  Widget _buildInteractionSummaryHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
         Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Interaction Summary',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              getLast90DaysData(selectedMonth ?? DateTime.now())["label"],
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            _showMonthYearPicker(context);
          },
          icon: const Icon(Icons.calendar_today, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildFilterTab(String title, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        width: MediaQuery.of(context).size.width * 0.4,
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

  Widget _buildLiveInteractionList(BuildContext context) {
    return BlocConsumer<InteractionListBloc, InteractionListState>(
        builder: (context, state) {
          if (state is! InteractionListLoaded) {
            return const Center(
              child: Text("Failed to load interaction Lyst"),
            );
          }
          return ListView(
            children:
                List.generate(state.scheduledInteractions.length, (index) {
              final itemToRender = state.scheduledInteractions[index];
              return Slidable(
                startActionPane: ActionPane(
                  motion: const StretchMotion(),
                  extentRatio: 0.25,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
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
                            horizontal: 10, vertical: 10),
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bookmark,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          // borderRadius: BorderRadius.circular(30.h)
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
                child: InteractionExpansionCard(
                  title: itemToRender.title,
                  time: serializeTimeOfDay(itemToRender.selectedTime),
                  date: itemToRender.selectedDate == null
                      ? ""
                      : itemToRender.selectedDate!.dMMYYY(),
                  app: itemToRender.selectedRedirectApp,
                  interactionId: itemToRender.id ?? "",
                  icon: index % 2 == 0 ? Icons.call : Icons.group,
                ),
              );
            }),
          );
        },
        listener: (context, state) {});
  }

  Widget _buildInteractionList(BuildContext context) {
    return ListView(
      children: List.generate(10, (index) {
        return Slidable(
          startActionPane: ActionPane(
            motion: const StretchMotion(),
            extentRatio: 0.25,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    // borderRadius: BorderRadius.circular(30.h)
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                    // borderRadius: BorderRadius.circular(30.h)
                  ),
                  child: const Icon(
                    Icons.bookmark,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    // borderRadius: BorderRadius.circular(30.h)
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
          child: InteractionExpansionCard(
            title: index % 2 == 0 ? 'Outgoing Call' : 'Physical Meeting',
            time: '15:30pm',
            date: '12 Jan 2025',
            app: index % 2 == 0 ? 'Phone App' : 'CDB',
            interactionId: "",
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
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Calculate current height based on the shrink offset
    final currentHeight =
        (maxExtent - shrinkOffset).clamp(minExtent, maxExtent);

    return SizedBox(
      height: currentHeight,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxExtent ||
        minHeight != oldDelegate.minExtent;
  }
}
