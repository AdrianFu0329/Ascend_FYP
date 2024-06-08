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
    TextStyle msgStyle = const TextStyle(
      fontSize: 11,
      fontFamily: 'Merriweather Sans',
      fontWeight: FontWeight.normal,
      color: Color.fromRGBO(247, 243, 237, 1),
    );

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.65,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isCurrentUser ? Colors.blue[700] : Colors.grey[700],
          ),
          child: Text(
            message,
            style: msgStyle,
            overflow: TextOverflow.visible, // Ensure text wraps
          ),
        ),
      ),
    );
  }
}
