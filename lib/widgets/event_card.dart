import 'package:ascend_fyp/navigation/sliding_nav.dart';
import 'package:ascend_fyp/pages/event_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/widgets/loading.dart';

class EventCard extends StatelessWidget {
  final String eventId;
  final String userId;
  final String eventTitle;
  final List<dynamic> requestList;
  final List<dynamic> acceptedList;
  final String eventDate;
  final String eventStartTime;
  final String eventEndTime;
  final String eventFees;
  final String eventSport;
  final String eventLocation;
  final String posterURL;
  final String participants;

  const EventCard({
    super.key,
    required this.eventId,
    required this.userId,
    required this.eventTitle,
    required this.requestList,
    required this.acceptedList,
    required this.eventDate,
    required this.eventStartTime,
    required this.eventEndTime,
    required this.eventFees,
    required this.eventSport,
    required this.eventLocation,
    required this.posterURL,
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    void _navigateToEventDetailsScreen() {
      Navigator.of(context).push(
        SlidingNav(
          builder: (context) => EventDetailsScreen(
            eventId: eventId,
            userId: userId,
            eventTitle: eventTitle,
            requestList: requestList,
            acceptedList: acceptedList,
            eventDate: eventDate,
            eventStartTime: eventStartTime,
            eventEndTime: eventEndTime,
            eventFees: eventFees,
            eventSport: eventSport,
            eventLocation: eventLocation,
            posterURL: posterURL,
            participants: participants,
          ),
        ),
      );
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
                future: getEventPoster(posterURL),
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
                        eventTitle,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            eventSport,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            "Date: $eventDate",
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
      onTap: _navigateToEventDetailsScreen,
      child: buildCard(),
    );
  }
}
