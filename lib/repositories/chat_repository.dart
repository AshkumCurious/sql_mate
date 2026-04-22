import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sql_practice_app/api_key.dart';
import '../models/chat_message.dart';
import '../viewmodels/chat_viewmodel.dart';

class ChatRepository {
  static const _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const _model = 'gpt-4o-mini';
  static const _apiKey = ApiKey.apiKey;
  static const _systemPrompt = '''
You are an expert SQL tutor. Help users learn SQL through clear explanations, examples, and interesting facts. 
Cover topics like SELECT, JOINs, aggregations, subqueries, window functions, indexing, and query optimization.
Keep responses concise, use code blocks for SQL examples, and be encouraging.
''';

  Future<String> sendMessage(List<ChatMessage> history) async {
    final messages = [
      {'role': 'system', 'content': _systemPrompt},
      ...history.map((m) => {
            'role': m.role == MessageRole.user ? 'user' : 'assistant',
            'content': m.content,
          }),
    ];

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': _model,
        'messages': messages,
        'max_tokens': 1024,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'] as String;
  }
}
