import 'package:ascend_fyp/navigation/animation/sliding_nav.dart';
import 'package:ascend_fyp/community/events/screens/details/event_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';

class EventCard extends StatefulWidget {
  final String eventId;
  final String groupId;
  final String userId;
  final String eventTitle;
  final List<dynamic> requestList;
  final List<dynamic> acceptedList;
  final List<dynamic> attendanceList;
  final String eventDate;
  final String eventStartTime;
  final String eventEndTime;
  final String eventFees;
  final String eventSport;
  final String eventLocation;
  final String posterURL;
  final int participants;
  final bool isOther;
  final bool isGroupEvent;
  final Function(bool)? toRefresh;

  const EventCard({
    super.key,
    required this.eventId,
    required this.userId,
    required this.eventTitle,
    required this.requestList,
    required this.acceptedList,
    required this.attendanceList,
    required this.eventDate,
    required this.eventStartTime,
    required this.eventEndTime,
    required this.eventFees,
    required this.eventSport,
    required this.eventLocation,
    required this.posterURL,
    required this.participants,
    required this.isOther,
    required this.isGroupEvent,
    required this.groupId,
    this.toRefresh,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  @override
  Widget build(BuildContext context) {
    void navigateToEventDetailsScreen() async {
      final result = await Navigator.of(context).push(
        SlidingNav(
          builder: (context) => EventDetailsScreen(
            eventId: widget.eventId,
            groupId: widget.groupId,
            userId: widget.userId,
            eventTitle: widget.eventTitle,
            requestList: widget.requestList,
            acceptedList: widget.acceptedList,
            attendanceList: widget.attendanceList,
            eventDate: widget.eventDate,
            eventStartTime: widget.eventStartTime,
            eventEndTime: widget.eventEndTime,
            eventFees: widget.eventFees,
            eventSport: widget.eventSport,
            eventLocation: widget.eventLocation,
            posterURL: widget.posterURL,
            participants: widget.participants,
            isOther: widget.isOther,
            isGroupEvent: widget.isGroupEvent,
          ),
        ),
      );

      if (result) {
        setState(() {
          if (widget.toRefresh != null) {
            widget.toRefresh!(true);
          }
        });
      }
    }

    Widget buildCard() {
      return SizedBox(
        height: 200,
        child: Card(
          color: Theme.of(context).cardColor,
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Stack(
            children: [
              FutureBuilder<Image>(
                future: getPoster(widget.posterURL),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CustomLoadingAnimation();
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "An unexpected error occurred. Try again later...",
                      ),
                    );
                  } else {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: snapshot.data!.image,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                      ),
                    );
                  }
                },
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Flexible(
                      child: Text(
                        widget.eventTitle,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            widget.eventSport,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            "Date: ${widget.eventDate}",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: navigateToEventDetailsScreen,
      child: buildCard(),
    );
  }
}
