import 'package:flutter/material.dart';

class LocationListTile extends StatelessWidget {
  final String location;
  final Function(String)? onPress;
  const LocationListTile({
    super.key,
    required this.location,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: () {
            onPress == null ? () {} : onPress!(location);
          },
          horizontalTitleGap: 12,
          leading: const Icon(
            Icons.location_on,
            size: 25,
            color: Color.fromRGBO(247, 243, 237, 1),
          ),
          title: Text(
            location,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        )
      ],
    );
  }
}
