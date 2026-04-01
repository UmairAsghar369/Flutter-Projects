// lib/features/chat/presentation/providers/chat_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../features/chat/data/gemini_service.dart';
import '../../../../features/chat/domain/message_model.dart';
import '../../../../core/constants/app_constants.dart';

// ─── GeminiService provider ───────────────────────────────────────────────────

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService(AppConstants.geminiApiKey);
});

// ─── Chat state ───────────────────────────────────────────────────────────────

class ChatState {
  final List<MessageModel> messages;
  final bool isLoading;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

// ─── Chat notifier ────────────────────────────────────────────────────────────

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this._ref) : super(const ChatState());

  final Ref _ref;
  final _uuid = const Uuid();
  StreamSubscription<String>? _streamSub;

  GeminiService get _service => _ref.read(geminiServiceProvider);

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = MessageModel(
      id: _uuid.v4(),
      content: text.trim(),
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    // Add user message and a placeholder AI message
    final aiPlaceholderId = _uuid.v4();
    final aiPlaceholder = MessageModel(
      id: aiPlaceholderId,
      content: '',
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
      isStreaming: true,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg, aiPlaceholder],
      isLoading: true,
      clearError: true,
    );

    try {
      final stream = _service.sendMessageStream(text.trim());
      final buffer = StringBuffer();

      _streamSub = stream.listen(
        (chunk) {
          buffer.write(chunk);
          _updateStreamingMessage(aiPlaceholderId, buffer.toString());
        },
        onDone: () {
          _finalizeMessage(aiPlaceholderId, buffer.toString());
        },
        onError: (e) {
          _handleError(aiPlaceholderId, e.toString());
        },
        cancelOnError: true,
      );
    } catch (e) {
      _handleError(aiPlaceholderId, e.toString());
    }
  }

  void _updateStreamingMessage(String id, String content) {
    final updated = state.messages.map((m) {
      if (m.id == id) return m.copyWith(content: content);
      return m;
    }).toList();
    state = state.copyWith(messages: updated);
  }

  void _finalizeMessage(String id, String content) {
    final updated = state.messages.map((m) {
      if (m.id == id) {
        return m.copyWith(
          content: content.isEmpty ? '_(No response)_' : content,
          isStreaming: false,
        );
      }
      return m;
    }).toList();
    state = state.copyWith(messages: updated, isLoading: false);
  }

  void _handleError(String id, String errorMsg) {
    final updated = state.messages.map((m) {
      if (m.id == id) {
        return m.copyWith(
          content: '⚠️ Something went wrong. Please try again.\n\n_${errorMsg}_',
          isStreaming: false,
          isError: true,
        );
      }
      return m;
    }).toList();
    state = state.copyWith(messages: updated, isLoading: false);
  }

  void newChat() {
    _streamSub?.cancel();
    _service.reset();
    state = const ChatState();
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>(
  (ref) => ChatNotifier(ref),
);
