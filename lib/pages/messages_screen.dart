import 'package:ascend_fyp/database/database_service.dart';
import 'package:ascend_fyp/widgets/chat_card.dart';
import 'package:ascend_fyp/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'Messages',
            style: Theme.of(context).textTheme.titleLarge!,
          ),
          actions: [
            GestureDetector(
              onTap: () {},
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.add,
                  color: Color.fromRGBO(247, 243, 237, 1),
                ),
              ),
            )
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: getUserChatsFromDatabase(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CustomLoadingAnimation(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No chats found.'),
                );
              } else if (snapshot.hasData) {
                List<DocumentSnapshot> allChatsList = snapshot.data!.docs;

                // Filter events where current user's UID is in the doc id
                List<DocumentSnapshot> filteredChatsList =
                    allChatsList.where((doc) {
                  String chatRoomId = doc.id;
                  return chatRoomId.contains(currentUser!.uid);
                }).toList();

                if (filteredChatsList.isEmpty) {
                  return const Center(
                    child: Text('You have no chats at the moment!'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredChatsList.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot doc = filteredChatsList[index];
                    Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;

                    String userId = data['senderId'] == currentUser!.uid
                        ? data['receiverId']
                        : data['senderId'];

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ChatCard(
                        userId: userId,
                        timestamp: data['timestamp'],
                        chatRoomId: doc.id,
                      ),
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text('You have no chats at the moment!'),
                );
              }
            }));
  }
}
