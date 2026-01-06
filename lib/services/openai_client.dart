import 'package:dio/dio.dart';
import 'dart:convert';

/// OpenAI Client for chat completions with streaming support
/// Optimized for customer support chatbot use cases
class OpenAIClient {
  final Dio dio;

  OpenAIClient(this.dio);

  /// Standard chat completion - blocks until response is complete
  ///
  /// Best for: Simple Q&A where you need the full answer at once
  Future<Completion> createChatCompletion({
    required List<ChatMessage> messages,
    String model = 'gpt-3.5-turbo',
    double temperature = 0.7,
    int? maxTokens,
  }) async {
    try {
      final requestData = <String, dynamic>{
        'model': model,
        'messages': messages
            .map((m) => {
                  'role': m.role,
                  'content': m.content,
                })
            .toList(),
        'temperature': temperature,
      };

      if (maxTokens != null) {
        requestData['max_tokens'] = maxTokens;
      }

      final response = await dio.post('/chat/completions', data: requestData);

      final text = response.data['choices'][0]['message']['content'];
      return Completion(text: text);
    } on DioException catch (e) {
      throw OpenAIException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['error']?['message'] ??
            e.message ??
            'Unknown error',
      );
    }
  }

  /// Streams chat responses in real-time
  ///
  /// Best for: Chat interfaces where you want to show responses as they arrive
  Stream<StreamCompletion> streamChatCompletion({
    required List<ChatMessage> messages,
    String model = 'gpt-3.5-turbo',
    double temperature = 0.7,
    int? maxTokens,
  }) async* {
    try {
      final requestData = <String, dynamic>{
        'model': model,
        'messages': messages
            .map((m) => {
                  'role': m.role,
                  'content': m.content,
                })
            .toList(),
        'stream': true,
        'temperature': temperature,
      };

      if (maxTokens != null) {
        requestData['max_tokens'] = maxTokens;
      }

      final response = await dio.post(
        '/chat/completions',
        data: requestData,
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data.stream;
      await for (var line in LineSplitter().bind(utf8.decoder.bind(stream))) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6);
          if (data == '[DONE]') break;

          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            final delta = json['choices'][0]['delta'] as Map<String, dynamic>;
            final content = delta['content'] ?? '';
            final finishReason = json['choices'][0]['finish_reason'];

            yield StreamCompletion(
              content: content,
              finishReason: finishReason,
            );

            if (finishReason != null) break;
          } catch (e) {
            // Skip malformed JSON lines
            continue;
          }
        }
      }
    } on DioException catch (e) {
      throw OpenAIException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['error']?['message'] ??
            e.message ??
            'Unknown error',
      );
    }
  }

  /// User-friendly streaming wrapper that just yields content strings
  Stream<String> streamContentOnly({
    required List<ChatMessage> messages,
    String model = 'gpt-3.5-turbo',
    double temperature = 0.7,
    int? maxTokens,
  }) async* {
    await for (final chunk in streamChatCompletion(
      messages: messages,
      model: model,
      temperature: temperature,
      maxTokens: maxTokens,
    )) {
      if (chunk.content.isNotEmpty) {
        yield chunk.content;
      }
    }
  }
}

/// Message model for chat conversations
class ChatMessage {
  final String role;
  final dynamic content;

  ChatMessage({required this.role, required this.content});
}

/// Standard completion response
class Completion {
  final String text;

  Completion({required this.text});
}

/// Streaming completion chunk
class StreamCompletion {
  final String content;
  final String? finishReason;

  StreamCompletion({
    required this.content,
    this.finishReason,
  });
}

/// Exception for OpenAI API errors
class OpenAIException implements Exception {
  final int statusCode;
  final String message;

  OpenAIException({required this.statusCode, required this.message});

  @override
  String toString() => 'OpenAIException: $statusCode - $message';
}
