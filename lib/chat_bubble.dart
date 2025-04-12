import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/message.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  final VoidCallback onDelete;

  const ChatBubble({super.key, required this.message, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, right: 8, left: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: message.isUser ? Colors.blue[200] : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message.text),
                SizedBox(height: 4),
                Text(DateFormat('hh:mm a').format(message.dateTime)),
              ],
            ),
          ),
          IconButton(onPressed: onDelete, icon: Icon(Icons.delete, size: 16.0)),
        ],
      ),
    );
  }
}
