import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ButtonStyle buttonStyle = ButtonStyle(
      textStyle: MaterialStateProperty.all<TextStyle>(
        const TextStyle(
          fontSize: 12,
          fontFamily: 'Merriweather Sans',
          fontWeight: FontWeight.normal,
        ),
      ),
      foregroundColor:
          MaterialStateProperty.all<Color>(Color.fromRGBO(247, 243, 237, 1)),
      backgroundColor: MaterialStateProperty.all<Color>(
        Theme.of(context).scaffoldBackgroundColor,
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(
              color: Color.fromRGBO(247, 243, 237, 1), width: 1.5),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Username',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.black),
            ),
            ListTile(
              title: Text(
                'Name',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                'Profile Description',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  // Handle Edit Profile button press
                },
                child: Text('Edit Profile'),
                style: buttonStyle,
              ),
            ),
            const Divider(
              color: Colors.red,
              thickness: 2,
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                mainAxisSpacing: 0.0,
                crossAxisSpacing: 0.0,
                padding: const EdgeInsets.all(16.0),
                children: List.generate(4, (index) {
                  return Container(
                    color: Colors.grey[800],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
