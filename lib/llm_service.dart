import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> callLLM(String prompt) async {
  final response = await http.post(
    Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=AIzaSyBiJyPQsGG2KLeef7OvP2kx_oLMTTt0tAQ',
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
