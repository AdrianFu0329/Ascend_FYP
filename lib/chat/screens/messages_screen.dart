import 'package:ascend_fyp/navigation/animation/sliding_nav.dart';
import 'package:ascend_fyp/chat/screens/user%20search/user_search.dart';
import 'package:ascend_fyp/chat/widgets/chat_card.dart';
import 'package:ascend_fyp/general%20widgets/loading.dart';
import 'package:ascend_fyp/notifications/screens/notification_permission_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with WidgetsBindingObserver {
  final currentUser = FirebaseAuth.instance.currentUser;
  bool _notificationsPermissionGranted = false;
  Stream<List<DocumentSnapshot>>? _filteredChatsListStream;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _checkNotificationPermission();
    deleteChatsWithoutMessages();
    _filteredChatsListStream = _fetchAndFilterChats();
    super.initState();
  }

  Future<void> _refreshChats() async {
    setState(() {
      _filteredChatsListStream = _fetchAndFilterChats();
      //deleteChatsWithoutMessages();
    });
  }

  Future<void> _checkNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;
    if (status != PermissionStatus.granted) {
      final result = await Navigator.of(context).push(
        SlidingNav(
          builder: (context) => const NotificationPermissionScreen(),
        ),
      );

      if (result != null && result) {
        setState(() {
          _notificationsPermissionGranted = true;
        });
      }
    } else {
      setState(() {
        _notificationsPermissionGranted = true;
      });
    }
  }

  Future<void> deleteChatsWithoutMessages() async {
    try {
      QuerySnapshot chatSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('chats')
          .get();
      for (DocumentSnapshot chatDoc in chatSnapshot.docs) {
        CollectionReference messagesRef =
            chatDoc.reference.collection('messages');
        QuerySnapshot messagesSnapshot = await messagesRef.get();
        if (messagesSnapshot.docs.length <= 1) {
          await chatDoc.reference.delete();
          debugPrint('Deleted chat document with id: ${chatDoc.id}');
        }
      }
    } catch (e) {
      debugPrint('Failed to delete chat documents without messages: $e');
    }
  }

  Stream<List<DocumentSnapshot>> _fetchAndFilterChats() {
    final userChatsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('chats')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .where((doc) => doc['timestamp'] != null)
            .toList());

    final groupChatsStream = FirebaseFirestore.instance
        .collection('group_chats')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .where((doc) =>
                doc['timestamp'] != null &&
                doc['memberMap'].containsKey(currentUser!.uid))
            .toList());

    return Rx.combineLatest2<List<DocumentSnapshot>, List<DocumentSnapshot>,
        List<DocumentSnapshot>>(
      userChatsStream,
      groupChatsStream,
      (userChats, groupChats) {
        final combinedChats = [...userChats, ...groupChats];
        combinedChats.sort((a, b) {
          final aTimestamp = a['timestamp'] as Timestamp;
          final bTimestamp = b['timestamp'] as Timestamp;
          return bTimestamp.compareTo(aTimestamp);
        });
        return combinedChats;
      },
    );
  }

  Future<bool> onChatDelete(String chatRoomId, String type) async {
    try {
      DocumentReference chatDocRef = type == "group"
          ? FirebaseFirestore.instance.collection('group_chats').doc(chatRoomId)
          : FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.uid)
              .collection('chats')
              .doc(chatRoomId);

      CollectionReference messagesCollectionRef =
          chatDocRef.collection('messages');

      QuerySnapshot messagesSnapshot = await messagesCollectionRef.get();
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (DocumentSnapshot doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      await chatDocRef.delete();

      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_notificationsPermissionGranted) {
      return const Scaffold(
        body: Center(
          child: CustomLoadingAnimation(page: "chats"),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: ((didPop) {
        if (didPop) {
          return;
        }
        Navigator.pushReplacementNamed(context, '/start');
      }),
      child: RefreshIndicator(
        onRefresh: _refreshChats,
        backgroundColor: Theme.of(context).cardColor,
        color: Colors.red,
        child: Scaffold(
          floatingActionButton: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                SlidingNav(
                  builder: (context) => const UserSearchScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Color.fromRGBO(247, 243, 237, 1),
              ),
            ),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Text(
              'Messages',
              style: Theme.of(context).textTheme.titleLarge!,
            ),
          ),
          body: StreamBuilder<List<DocumentSnapshot>>(
            stream: _filteredChatsListStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CustomLoadingAnimation(page: "chats"),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "lib/assets/images/empty_chats.png",
                        width: 250,
                        height: 250,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You have no chats at the moment!',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              } else {
                _refreshChats();
                List<DocumentSnapshot> filteredChatsList = snapshot.data!;

                return ListView.builder(
                  itemCount: filteredChatsList.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot doc = filteredChatsList[index];
                    Map<String, dynamic>? data =
                        doc.data() as Map<String, dynamic>?;

                    // Handle the case where data is null
                    if (data == null || data['timestamp'] == null) {
                      debugPrint(
                          'Chat document with id: ${doc.id} has null data.');
                      return const SizedBox.shrink();
                    }

                    String userId = data['type'] == "group"
                        ? "Unknown"
                        : data['senderId'] == currentUser!.uid
                            ? data['receiverId']
                            : data['senderId'];

                    bool hasRead;
                    if (data['type'] == "group") {
                      Map<String, dynamic> memberMap = data['memberMap'];
                      hasRead = memberMap[currentUser!.uid] ?? false;
                    } else {
                      hasRead = data['senderId'] == currentUser!.uid
                          ? data['senderRead']
                          : data['receiverRead'];
                    }

                    return Dismissible(
                      key: Key(doc.id), // Unique key for each chat card
                      direction: DismissDirection.startToEnd,
                      background: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20.0),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (DismissDirection direction) async {
                        // Confirm deletion
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              content: Text(
                                "This action will delete this chatroom for you only.\nAre you sure you want to delete this chat?",
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text(
                                    "Delete",
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(
                                    "Cancel",
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (DismissDirection direction) {
                        // Delete chat from Firestore after swipe action
                        onChatDelete(doc.id, data['type']);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ChatCard(
                          userId: data['type'] == "group" ? "Unknown" : userId,
                          timestamp: data['timestamp'],
                          chatRoomId: doc.id,
                          hasRead: hasRead,
                          type: data['type'] ?? "normal", // group or normal
                          toRefresh: (refresh) {
                            if (refresh) {
                              _refreshChats();
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
