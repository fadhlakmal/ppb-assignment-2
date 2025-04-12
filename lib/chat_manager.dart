import 'package:hive/hive.dart';
import 'package:myapp/message.dart';

class ChatManager {
  final _myBox = Hive.box("chat");

  final List<Message> _messages = [];

  List<Message> get messages => List.unmodifiable(_messages);

  ChatManager() {
    for (int i = 0; i < _myBox.length; i++) {
      _messages.add(_myBox.get(i));
    }
  }

  void _addBoth(Message message) {
    int index = _myBox.length;
    _myBox.put(index, message);
    _messages.add(message);
  }

  void addUserMessage(String text) {
    final message = Message(text: text, isUser: true, dateTime: DateTime.now());
    _addBoth(message);
  }

  void addBotResponse(String text) {
    final message = Message(
      text: text,
      isUser: false,
      dateTime: DateTime.now(),
    );
    _addBoth(message);
  }

  Future<void> sendUserMessage(String text) async {
    addUserMessage(text);

    // sementara simulate bot respon
    await Future.delayed(const Duration(seconds: 1));
    final response = "return '$text'";

    addBotResponse(response);
  }

  void deleteMessage(Message message) {
    int index = _messages.indexOf(message);
    if (index != -1) {
      _myBox.deleteAt(index);
      _messages.remove(message);
    }
  }
}
