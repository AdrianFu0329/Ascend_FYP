import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle msgStyle = TextStyle(
      fontSize: 11,
      fontFamily: 'Merriweather Sans',
      fontWeight: FontWeight.normal,
      color: isCurrentUser
          ? Theme.of(context).scaffoldBackgroundColor
          : const Color.fromRGBO(247, 243, 237, 1),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isCurrentUser ? Colors.greenAccent : Colors.black38,
      ),
      child: Text(
        message,
        style: msgStyle,
      ),
    );
  }
}
