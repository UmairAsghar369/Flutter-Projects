// lib/features/chat/data/gemini_service.dart
import 'package:google_generative_ai/google_generative_ai.dart';

/// Wraps the Google Generative AI SDK for Gemini chat interactions.
class GeminiService {
  GeminiService(String apiKey)
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            temperature: 0.9,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 8192,
          ),
          systemInstruction: Content.system(
            'You are AuraAI, a helpful, friendly, and knowledgeable AI assistant. '
            'Respond clearly and concisely. Use markdown formatting where appropriate '
            '(bold, italics, bullet lists, code blocks). Be warm, professional, and engaging.',
          ),
        );

  final GenerativeModel _model;
  ChatSession? _chat;

  /// Start a fresh chat session (clears history)
  void startNewSession() {
    _chat = _model.startChat(history: []);
  }

  /// Send a message with streaming. Yields text chunks as they arrive.
  Stream<String> sendMessageStream(String userMessage) async* {
    _chat ??= _model.startChat(history: []);

    final response = _chat!.sendMessageStream(Content.text(userMessage));

    await for (final chunk in response) {
      final text = chunk.text;
      if (text != null && text.isNotEmpty) {
        yield text;
      }
    }
  }

  /// Reset conversation history
  void reset() {
    _chat = _model.startChat(history: []);
  }
}
