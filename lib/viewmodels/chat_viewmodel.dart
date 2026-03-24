import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../repositories/chat_repository.dart';

enum MessageRole { user, assistant }

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class ChatViewModel extends StateNotifier<ChatState> {
  final ChatRepository _repository;
  final _uuid = const Uuid();

  ChatViewModel(this._repository) : super(const ChatState());

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isLoading) return;

    final userMessage = ChatMessage(
      id: _uuid.v4(),
      content: text.trim(),
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    try {
      final reply = await _repository.sendMessage(state.messages);
      final assistantMessage = ChatMessage(
        id: _uuid.v4(),
        content: reply,
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to get a response. Please try again.',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearChat() {
    state = const ChatState();
  }
}

final chatRepositoryProvider = Provider((_) => ChatRepository());

final chatViewModelProvider =
    StateNotifierProvider.autoDispose<ChatViewModel, ChatState>(
  (ref) => ChatViewModel(ref.read(chatRepositoryProvider)),
);
