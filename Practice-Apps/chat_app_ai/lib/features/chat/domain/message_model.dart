// lib/features/chat/domain/message_model.dart

/// Represents a single chat message (user or AI)
class MessageModel {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isStreaming;
  final bool isError;

  const MessageModel({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isStreaming = false,
    this.isError = false,
  });

  MessageModel copyWith({
    String? content,
    bool? isStreaming,
    bool? isError,
  }) {
    return MessageModel(
      id: id,
      content: content ?? this.content,
      role: role,
      timestamp: timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
      isError: isError ?? this.isError,
    );
  }
}

enum MessageRole { user, assistant }
