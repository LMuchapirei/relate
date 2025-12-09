import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:relate/features/interactions/bloc/interaction_blocs.dart';
import 'package:relate/features/relationship/bloc/relationship_controller.dart';
import 'package:relate/features/relationship/bloc/relationship_event.dart';
import 'package:relate/features/relationship/models/relationship_model.dart';
import 'package:relate/pages/relationship_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../common/widgets/modals.dart';
import '../common/widgets/manage_relation.dart';
import '../features/interactions/bloc/interaction_events.dart';
import '../features/relationship/bloc/relationship_bloc.dart';
import '../features/relationship/bloc/relationship_state.dart';
import '../features/relationship/widgets/relationship_form.dart';
import '../features/relationship/pages/contact_import_page.dart';

class RelationshipsScreen extends StatefulWidget {
  static const routeName = '/relationships';
  const RelationshipsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RelationshipsScreenState createState() => _RelationshipsScreenState();
}

class _RelationshipsScreenState extends State<RelationshipsScreen> {
  final _searchTextController = TextEditingController();
  String? _selectedTag; // State for selected filter tag

  @override
  void initState() {
    super.initState();
    _searchTextController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchTextController.removeListener(_onSearchChanged);
    _searchTextController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  List<Relationship> _getFilteredRelationships(List<Relationship> all) {
    final query = _searchTextController.text.trim().toLowerCase();

    return all.where((r) {
      final matchesQuery = query.isEmpty ||
          (r.firstName.toLowerCase().contains(query)) ||
          (r.lastName.toLowerCase().contains(query)) ||
          (r.relationshipType?.toLowerCase().contains(query) ?? false);

      final matchesTag = _selectedTag == null || r.tags.contains(_selectedTag);

      return matchesQuery && matchesTag;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          const Padding(
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
          IconButton(
            icon: const Icon(Icons.import_contacts, color: Colors.black),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ContactImportPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<RelationshipListBloc, RelationshipListState>(
        listener: (context, state) {},
        builder: (context, state) {
          final filteredRelationships =
              _getFilteredRelationships(state.relationships);

          // Extract all unique tags
          final allTags =
              state.relationships.expand((r) => r.tags).toSet().toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 10),
                if (allTags.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: Text('All'),
                          selected: _selectedTag == null,
                          onSelected: (selected) {
                            setState(() {
                              _selectedTag = null;
                            });
                          },
                        ),
                        SizedBox(width: 8),
                        ...allTags.map((tag) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                label: Text(tag),
                                selected: _selectedTag == tag,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedTag = selected ? tag : null;
                                  });
                                },
                              ),
                            )),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredRelationships.length,
                    itemBuilder: (context, index) {
                      final currentRelation = filteredRelationships[index];
                      return _buildRelationshipItem(currentRelation);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    displayBottomModalSheet(
                        context,
                        SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.9,
                            child: const AddRelationshipScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding:
                        EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
                  ),
                  child: const Text(
                    'Add Relationship',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchTextController,
            decoration: InputDecoration(
              hintText: 'Eg: Anna Des',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // Handle filter action
          },
        ),
      ],
    );
  }

  Widget _buildRelationshipItem(Relationship relationship) {
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.8,
                    child:
                        ManageRelation(relationshipId: relationship.id ?? ""),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
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
            child: GestureDetector(
              onTap: () {
                if (relationship.id != null) {
                  RelationshipController()
                      .bookmarkRelationship(relationship.id!, bookmarked: true);
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                if (relationship.id != null) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Delete Relationship"),
                        content: const Text(
                            "Are you sure you want to delete this relationship?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Cancel
                            },
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () async {
                              final success = await RelationshipController()
                                  .deleteRelationship(relationship.id!);
                              if (success) {
                                if (mounted) {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                  context
                                      .read<RelationshipListBloc>()
                                      .add(LoadRelationships());
                                }
                              }
                            },
                            child: const Text("Delete",
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
        ),
        child: Theme(
          data: ThemeData(
              expansionTileTheme: ExpansionTileThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.h),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.h),
            ),
          )).copyWith(dividerColor: Colors.transparent),
          child: GestureDetector(
            onTap: () {
              context
                  .read<InteractionListBloc>()
                  .add(LoadScheduledInteractions());
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      RelationshipDetailsScreen(relationship: relationship)));
            },
            child: ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 16.0.h),
              backgroundColor: Colors.white,
              collapsedBackgroundColor: Colors.white,
              leading: CircleAvatar(
                radius: 24.h,
                backgroundImage: relationship.profileImageUrl != null &&
                        relationship.profileImageUrl!.isNotEmpty
                    ? NetworkImage(relationship.profileImageUrl!)
                    : const AssetImage('assets/images/profile.png')
                        as ImageProvider,
              ),
              title: SizedBox(
                height: 60.h,
                child: Row(
                  children: [
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${relationship.firstName} ${relationship.lastName}",
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12.h,
                                fontWeight: FontWeight.bold),
                          ),
                          if (relationship.tags.isNotEmpty)
                            Wrap(
                              spacing: 4,
                              children: relationship.tags
                                  .map((tag) => Text(
                                        tag,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ))
                                  .toList(),
                            )
                          else
                            Text(
                              relationship.relationshipType ?? "",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                              ),
                            ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Icon(
                              relationship.bookMarked ?? false
                                  ? Icons.bookmark
                                  : Icons.bookmark_border_outlined,
                              color: relationship.bookMarked ?? false
                                  ? Colors.amber
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Interactions scheduled',
                              style: TextStyle(fontSize: 16)),
                          Text('10')
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// update this to use the correct field
                          const Text('Date Created',
                              style: TextStyle(fontSize: 14)),
                          Text(relationship.createdAt != null
                              ? DateFormat('dd MMM yyyy')
                                  .format(relationship.createdAt!)
                              : "N/A")
                        ],
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Next Interaction',
                              style: TextStyle(fontSize: 14)),
                          Text('14 Oct 2025')
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Rating', style: TextStyle(fontSize: 16)),
                          Row(
                            children: [
                              Icon(Icons.sentiment_satisfied,
                                  color: Colors.yellow),
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
