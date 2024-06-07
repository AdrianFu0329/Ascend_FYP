import 'package:ascend_fyp/models/location_autocomplete_prediction.dart';
import 'package:ascend_fyp/widgets/user_list_tile.dart';
import 'package:flutter/material.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({
    super.key,
  });

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  Map<String, dynamic> userData = {};
  TextEditingController searchController = TextEditingController();
  List<AutocompletePrediction> searchPredictions = [];

  Future<void> selectUser(String user) async {
    try {
      String? userId;
      Map<String, dynamic> result = {
        'userId': userId,
      };
      setState(() {
        userData = result;
      });
    } catch (e) {
      debugPrint('Error obtaining user details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(
            Icons.check,
            color: Color.fromRGBO(247, 243, 237, 1),
          ),
          onPressed: () {
            Navigator.pop(context, userData);
          },
        ),
        title: Text(
          "Search User",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Form(
              child: TextFormField(
                controller: searchController,
                onChanged: (value) {},
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: "Search a user",
                  hintStyle: Theme.of(context).textTheme.titleMedium,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Icon(
                      Icons.search,
                      color: Color.fromRGBO(247, 243, 237, 1),
                      size: 20,
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(247, 243, 237, 1),
                      width: 2.5,
                    ),
                  ),
                ),
                style: Theme.of(context).textTheme.titleMedium,
                cursorColor: const Color.fromRGBO(247, 243, 237, 1),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: 0,
                itemBuilder: (context, index) => UserListTile(
                  onPress: (selectedUser) {
                    setState(() {
                      selectUser(selectedUser);
                    });
                  },
                  userId: "jldskfjas", // [index].description!,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
