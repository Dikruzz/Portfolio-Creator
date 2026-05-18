import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/ai_generation_models.dart';

class OpenAiClient {
  const OpenAiClient({
    required this.httpClient,
    required this.apiKey,
    this.model = 'gpt-5.2',
    this.endpoint = 'https://api.openai.com/v1/responses',
  });

  final http.Client httpClient;
  final String apiKey;
  final String model;
  final String endpoint;

  bool get isConfigured => apiKey.trim().isNotEmpty;

  Future<OpenAiResponsePayload> createResponse({
    required List<AiPromptMessage> messages,
    int maxOutputTokens = 900,
  }) async {
    if (!isConfigured) {
      throw const OpenAiConfigurationException('OPENAI_API_KEY is not configured.');
    }

    final response = await httpClient.post(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': model,
        'input': messages.map((message) => message.toJson()).toList(),
        'max_output_tokens': maxOutputTokens,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw OpenAiRequestException('OpenAI request failed (${response.statusCode}). ${response.body}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return OpenAiResponsePayload(
      text: _extractText(decoded),
      rawJson: decoded.cast<String, Object?>(),
    );
  }

  String _extractText(Map<String, dynamic> decoded) {
    final outputText = decoded['output_text'];
    if (outputText is String && outputText.trim().isNotEmpty) return outputText.trim();

    final output = decoded['output'];
    if (output is List) {
      final buffer = StringBuffer();
      for (final item in output) {
        if (item is! Map) continue;
        final content = item['content'];
        if (content is! List) continue;
        for (final contentItem in content) {
          if (contentItem is Map && contentItem['text'] is String) {
            buffer.writeln(contentItem['text'] as String);
          }
        }
      }
      final text = buffer.toString().trim();
      if (text.isNotEmpty) return text;
    }

    throw const OpenAiRequestException('OpenAI response did not include text output.');
  }
}

class OpenAiConfigurationException implements Exception {
  const OpenAiConfigurationException(this.message);
  final String message;
  @override
  String toString() => message;
}

class OpenAiRequestException implements Exception {
  const OpenAiRequestException(this.message);
  final String message;
  @override
  String toString() => message;
}
