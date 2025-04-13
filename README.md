# Mobile Database Asssignment
Fadhl Akmal Madany

5025221028 % 4 == 0 (Hive)

PPB B

Tampilan aplikasi:

![image](https://github.com/user-attachments/assets/1fda4cb2-011b-4b9c-862e-6867fadec608)

## Programming Steps
### Base Chat App (w/o DB and LLM)
**1. Setup flutter project**

Buat project flutter baru dan pada `pubspec.yaml` tambahkan dependency:
- `hive` dan `hive_flutter` untuk persistent db
- `intl` untuk formatting datetime
- `http` untuk api call
- `hive_generator` and `build_runner` untuk code generation yang berhubungan dengan Hive

```yaml
dependencies:
   flutter:
     sdk: flutter
     
   hive: ^2.0.0
   hive_flutter: ^1.1.0
   intl: ^0.20.2
   http: ^1.3.0
 
 dev_dependencies:
   flutter_test:
     sdk: flutter
   
   hive_generator: ^1.1.0
   build_runner: ^2.1.0
```

**2. Struktur utama app**

Buat entry point point aplikasi di `main.dart`, berisi `MaterialApp` dengan `ChatScreen` home page(setup standard).

```dart
 import 'package:flutter/material.dart';
 import 'package:myapp/chat_screen.dart';
 
 void main() async {
   runApp(const MyApp());
 }
 
 class MyApp extends StatelessWidget {
   const MyApp({super.key});
 
   @override
   Widget build(BuildContext context) {
     return const MaterialApp(
       debugShowCheckedModeBanner: true,
       home: ChatScreen(),
     );
   }
 }
```

**3. Message class/model**

Buat class `Message` (`message.dart`) untuk menstruktur data pesan pada chat. Pada approach yang digunakan, terdapat 3 atribut:
- text: Konten pesan.
- isUser: Membedakan chat yang dikirim user dan bot, untuk mempermudah penulisan kode UI.
- dateTime: Timestamp pengiriman pesan.

```dart
 class Message {
   final String text;
   final bool isUser;
   final DateTime dateTime;
 
   Message({required this.text, required this.isUser, required this.dateTime});
 }
```


**4. Logika chat**

Definisikan logika chat (`chat_manager.dart`):
- Simpan list message dengan getter untuk akses data tersebut (sebagai unmodifiable list untuk safety)
```dart
  class ChatManager {
   final List<Message> _messages = [
     Message(text: "Hello, what can i do for you?", isUser: false, dateTime: DateTime.now())
   ];
 
   List<Message> get messages => List.unmodifiable(_messages);

   ...
 }
```

- Metode menambahkan pesan, kita simulasikan api call menggunakan future/promise
```dart
 class ChatManager {
   ...

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

   ...
 }
```

- Metode menghapus pesan
```dart
 import 'package:myapp/message.dart';
 
 class ChatManager {
   ...

   void deleteMessage(Message message) {
     _messages.remove(message);
   }

   ...
 }
```

**5. UI**

Cukup straightforward, buat tampilan untuk chat (`chat_screen.dart`) yang terdiri dari:
- Handler kirim dan hapus pesan.
- Area scrollable, display semua pesan sebagai `ChatBubble` widget.
- Input field dengan tombol kirim dibawah layar.

```dart
class ChatScreen extends StatefulWidget {
   const ChatScreen({super.key});
 
   @override
   State<ChatScreen> createState() => _ChatScreenState();
 }
 
 class _ChatScreenState extends State<ChatScreen> {
   final ChatManager _chatManager = ChatManager();
   final TextEditingController _controller = TextEditingController();

   void _sendMessage() {
     final text = _controller.text.trim();
     if (text.isNotEmpty) {
       // tunggu respon bot baru update ui
       _chatManager.sendUserMessage(text).then((_) => {
         setState(() {})
       });
       _controller.clear();
     }
   }

   void _deleteMessage(Message message) {
     setState(() {
       _chatManager.deleteMessage(message);
     });
   }
 
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
                           .map(
                             (item) => ChatBubble(
                               message: item.value,
                               onDelete: () => _deleteMessage(item.value),
                             ),
                           )
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
```

Pada widget ChatBubble (`chat_bubble`), manfaatkan isUser untuk:
- Alignment: pesan user di kanan dan pesan bot di kiri
- Styles: biru untuk user, abu untuk bot

```dart
 class ChatBubble extends StatelessWidget {
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
```


### Add Hive


### Add LLM

