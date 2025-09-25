import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIResponseService {
  // API key ko .env file se load karo
  static String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? "";

  static const String _apiUrl = "https://api.openai.com/v1/chat/completions";

  /// Detect language roughly (optional, can pass to AI for style control)
  static String detectLanguage(String message) {
    final msg = message.toLowerCase();
    if (RegExp(r'[\u0900-\u097F]').hasMatch(msg)) {
      return "hindi";
    } else if (RegExp(r'[a-z]').hasMatch(msg)) {
      return "english";
    } else {
      return "hinglish";
    }
  }

  /// Generate AI-driven response
  static Future<String> generateResponse(String message) async {
    final language = detectLanguage(message);

    // Construct system prompt
    String systemPrompt = """
You are a friendly and empathetic Love Guru 💖.
Answer questions about love, relationships, marriage, compatibility,
and emotions in a natural, supportive tone.

Language style: $language
If hindi → pure hindi, 
if english → pure english,
if hinglish → mix of roman hindi + english (casual chat).
Keep answers short, warm, and natural.
""";

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_apiKey",
        },
        body: jsonEncode({
          "model": "gpt-4.0-mini", // lightweight latest model
          "messages": [
            {"role": "system", "content": systemPrompt},
            {"role": "user", "content": message}
          ],
          "max_tokens": 150,
          "temperature": 0.9,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data["choices"][0]["message"]["content"];
        return text.trim();
      } else {
        return "Sorry, I'm having trouble connecting 💔 (Error ${response.statusCode})";
      }
    } catch (e) {
      return "Oops! Something went wrong 😢 ($e)";
    }
  }
}
