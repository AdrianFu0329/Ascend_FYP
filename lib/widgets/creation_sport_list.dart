import 'package:flutter/material.dart';

class CreationSportsList extends StatefulWidget {
  final Function(String?) onSelectionChanged;
  final ValueNotifier<bool> resetNotifier;

  const CreationSportsList({
    super.key,
    required this.onSelectionChanged,
    required this.resetNotifier,
  });

  @override
  _CreationSportsListState createState() => _CreationSportsListState();
}

class _CreationSportsListState extends State<CreationSportsList> {
  final List<String> sports = [
    'Football',
    'Basketball',
    'Badminton',
    'Futsal',
    'Jogging',
    'Gym',
    'Tennis',
    'Hiking',
    'Cycling',
    'Other',
  ];

  String? selectedSport;

  @override
  void initState() {
    widget.resetNotifier.addListener(_resetSelection);
    super.initState();
  }

  @override
  void dispose() {
    widget.resetNotifier.removeListener(_resetSelection); // Add this line
    super.dispose();
  }

  void _resetSelection() {
    setState(() {
      selectedSport = null;
    });
    widget.onSelectionChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
            ),
            itemCount: sports.length,
            itemBuilder: (context, index) {
              return CheckboxListTile(
                title: Text(
                  sports[index],
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                value: selectedSport == sports[index],
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      selectedSport = sports[index];
                    } else {
                      selectedSport = null;
                    }
                    widget.onSelectionChanged(selectedSport);
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
