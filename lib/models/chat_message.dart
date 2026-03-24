import '../viewmodels/chat_viewmodel.dart';

class ChatMessage {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
  });

  ChatMessage copyWith({String? content}) => ChatMessage(
        id: id,
        content: content ?? this.content,
        role: role,
        timestamp: timestamp,
      );
}