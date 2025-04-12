import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 0)
class Message {
  @HiveField(0)
  final String text;

  @HiveField(1)
  final bool isUser;
  
  @HiveField(2)
  final DateTime dateTime;

  Message({required this.text, required this.isUser, required this.dateTime});
}
