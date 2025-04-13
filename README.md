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


**4. Chat Messages Logic**

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
**1. Initialize Hive**

inisialisasi hive sebelum menjalankan aplikasi, open (atau create) hive box bernama 'chat' untuk menyimpan message

```dart
 void main() async {
   // Pastikan flutter di inisialisasi sebelum menggunakan platform channels
   WidgetsFlutterBinding.ensureInitialized();

   await Hive.initFlutter();
   await Hive.openBox('chat');

   runApp(const MyApp());
 }
```

**2. Generate TypeAdapter**

Untuk menyimpan custom object di Hive, kita perlu memberitahu hive cara serialisasi dan deserialisasi object `Message` untuk storage melalui `TypeAdapter`:
- `HiveType` menandakan class sebagai Hive model
- Anotasikan member class dengan `HiveField` 
- Tambahkan `part 'message.g.dart'` untuk link dengan generated code file

```dart
import 'package:hive/hive.dart';
 
 part 'message.g.dart';
 
 @HiveType(typeId: 0) // type 0 unique id
 class Message {
   @HiveField(0)
   final String text;
 
   @HiveField(1)
   final bool isUser;
   
   @HiveField(2)
   final DateTime dateTime;
 
   Message({required this.text, required this.isUser, required this.dateTime});
```

- Jalankan command berikut di terminal untuk generate adapter code

```sh
dart run build_runner build
```

- Register adapter tsb. di `main.dart`

```dart
 void main() async {
   WidgetsFlutterBinding.ensureInitialized();
   await Hive.initFlutter();
   Hive.registerAdapter(MessageAdapter());
   await Hive.openBox('chat');

   runApp(const MyApp());
 }
```

3. Update `chat_manager.dart` agar menggunakan hive

- Load pesan-pesan dari Hive saat `ChatManager` di initialisasikan

```dart
 class ChatManager {
   final _myBox = Hive.box("chat");
 
   final List<Message> _messages = [];
 
   List<Message> get messages => List.unmodifiable(_messages);
 
   ChatManager() {
     for (int i = 0; i < _myBox.length; i++) {
       _messages.add(_myBox.get(i));
     }
   }

   ...
 }
```

Aplikasi menggunakan dual-storage, In-memory list untuk UI rendering dan Hive database untuk persistence.
- Buat metode untuk menambahkan pesan ke local list dan hive box
- Update `addUserMessage()` dan `addBotResponse()` agar menggunakan metode tsb.
- Update `deleteMessage()` method untuk menghapus pesan dari kedua storage

**Side Note:** Secara realistis, approach yang lebih bagus adalah dengan menyimpan pesan-pesan dalam list selama penggunaan aplikasi dan hanya menyimpan list tsb. ke database saat aplikasi ditutup atau menjadi background. Tapi untuk aplikasi kecil negligible.

```dart
 class ChatManager {
   ...

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

   ...
 }
```

```dart
 class ChatManager {
   ...

   void deleteMessage(Message message) {
     int index = _messages.indexOf(message);
     if (index != -1) {
       _myBox.deleteAt(index);
       _messages.remove(message);
     }
   }

   ...
 }
```

**Note lagi:** `deleteMessage()` menggunakan `_messages.indexOf(message)` untuk mencari posisi message yang ingin di hapus, dimana `indexOf()` menggunakan operasi `==`. By default, implementasi `==` dari Dart membandingkan object berdasarkan memory address, bukan content/value. Jadi saat kita membuat Message object baru atau mengambil object dari Hive, meskipun memiliki `text`, `isUser`, dan `dateTime` yang sama, tetap akan dianggap object yang berbeda.

Oleh karena itu, operator `==` untuk object tersebut perlu kita ubah (override) agar membadingkan berdasarkan konten. 

```dart
@HiveType(typeId: 0)
class Message {
  ...

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message &&
        other.text == text &&
        other.isUser == isUser &&
        other.dateTime.isAtSameMomentAs(dateTime);
  }
  
  @override
  int get hashCode => Object.hash(text, isUser, dateTime);
  
}
```


### Add LLM
1. Tambah permission internet pada device (android)

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

2. LLM API Logic
```dart
Future<String> callLLM(String prompt) async {
   final response = await http.post(
     Uri.parse(
       'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${API_KEY}',
     ),
     headers: <String, String>{'Content-Type': 'application/json'},
     body: jsonEncode({
       "contents": [
         {
           "parts": [
             {"text": prompt},
           ],
         },
       ],
     }),
   );
 
   if (response.statusCode == 200) {
     final jsonResponse = json.decode(response.body);
     return jsonResponse['candidates'][0]['content']['parts'][0]['text'];
   } else {
     throw Exception('Failed to call LLM: ${response.body}');
   }
 }
```

```dart
  Future<void> sendUserMessage(String text) async {
     addUserMessage(text);
 
     // sementara simulate bot respon
     // await Future.delayed(const Duration(seconds: 1));
     // final response = "return '$text'";
     final response = await callLLM(text);
 
     addBotResponse(response);
  }
```
