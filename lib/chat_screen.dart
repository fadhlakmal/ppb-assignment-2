import 'package:flutter/material.dart';
import 'package:myapp/chat_bubble.dart';
import 'package:myapp/chat_manager.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      // tunggu respon bot baru update ui
      _chatManager.sendUserMessage(text).then((_) => {setState(() {})});
      _controller.clear();
    }
  }

  final ChatManager _chatManager = ChatManager();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ChatBot App')),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: Column(
                  children:
                      _chatManager.messages
                          .asMap()
                          .entries
                          .map((item) => ChatBubble(message: item.value))
                          .toList(),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(onPressed: _sendMessage, icon: Icon(Icons.send)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
