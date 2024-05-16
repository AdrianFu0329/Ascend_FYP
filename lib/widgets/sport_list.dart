import 'package:flutter/material.dart';

class SportsList extends StatefulWidget {
  const SportsList({super.key});

  @override
  _SportsListState createState() => _SportsListState();
}

class _SportsListState extends State<SportsList> {
  final List<String> sports = [
    'Football',
    'Basketball',
    'Badminton',
    'Futsal',
    'Jogging',
    'Gym',
    'Tennis',
    'Hiking',
  ];

  final Map<String, bool> selectedSports = {};

  @override
  void initState() {
    super.initState();
    for (var sport in sports) {
      selectedSports[sport] = false;
    }
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
                value: selectedSports[sports[index]],
                onChanged: (value) {
                  setState(() {
                    selectedSports[sports[index]] = value!;
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
