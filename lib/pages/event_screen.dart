import 'package:ascend_fyp/pages/create_events_screen.dart';
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  const EventCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(32, 47, 57, 1),
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
    );
  }
}

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  void _createEventPressed() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      builder: (context) => const CreateEventsScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textBoxStyle = const TextStyle(
      color: Color.fromRGBO(192, 192, 192, 1),
      fontSize: 14,
    );

    OutlineInputBorder normalBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(
        color: Color.fromRGBO(192, 192, 192, 1),
        width: 2,
      ),
    );

    OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(
        color: Color.fromRGBO(192, 192, 192, 1),
        width: 2.5,
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                SizedBox(
                  height: 70,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: TextField(
                      style: textBoxStyle,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: textBoxStyle,
                        prefixIcon: const Icon(Icons.search,
                            color: Color.fromRGBO(192, 192, 192, 1)),
                        filled: true,
                        fillColor: const Color.fromRGBO(20, 23, 26, 1),
                        border: normalBorder,
                        focusedBorder: focusedBorder,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Options',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        onPressed: _createEventPressed,
                        icon: const Icon(Icons.add),
                        color: Colors.red,
                        iconSize: 24,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: EventCard(),
                );
              },
              childCount: 3, // Replace with your actual event card count
            ),
          ),
        ],
      ),
    );
  }
}
