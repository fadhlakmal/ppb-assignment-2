import 'package:myapp/message.dart';

class ChatManager {
  final List<Message> _messages = [
    Message(text: "Hello, what can i do for you?", isUser: false, dateTime: DateTime.now())
  ];

  List<Message> get messages => List.unmodifiable(_messages);

  void addUserMessage(String text) {
    _messages.add(Message(text: text, isUser: true, dateTime: DateTime.now()));
  }

  void addBotResponse(String text) {
    _messages.add(Message(text: text, isUser: false, dateTime: DateTime.now()));
  }

  Future<void> sendUserMessage(String text) async {
    addUserMessage(text);

    // sementara simulate bot respon
    await Future.delayed(const Duration(seconds: 1));
    final response = "return '$text'";

    addBotResponse(response);
  }
}
