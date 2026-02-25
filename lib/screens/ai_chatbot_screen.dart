import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/theme/app_colors.dart';

class AIChatbotScreen extends StatefulWidget {
  const AIChatbotScreen({super.key});

  @override
  State<AIChatbotScreen> createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final String _apiKey =
      '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';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'bot',
      'text':
          'Hello! I\'m LEO (Livestock Expert Optimizer), your AI-powered farm assistant. I can help with livestock management, health monitoring, and farming advice. How can I help you today?',
    });
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userMessage = _controller.text;
    setState(() {
      _messages.add({'role': 'user', 'text': userMessage});
      _isLoading = true;
    });
    _controller.clear();

    try {
      final livestockData = await _getLivestockContext();
      final systemPrompt =
          '''
You are LEO (Livestock Expert Optimizer), an AI assistant exclusively specialized in smart livestock farming and agriculture. 

CRITICAL INSTRUCTION: You MUST ONLY answer questions related to agriculture, livestock management, animal health, farming practices, or agricultural business. If the user asks ANY question unrelated to these topics (such as general knowledge, coding, weather in specific non-farm locations, math, unrelated advice, etc), you MUST politely decline to answer, stating that you are an AI assistant specialized only in farm management and agriculture.

Current Farm Data context (if the user asks about their specific farm):
$livestockData
''';

      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'google/gemma-3-4b-it:free',
          'messages': [
            {
              'role': 'user',
              'content': '$systemPrompt\\n\\nUser Question: $userMessage',
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botResponse = data['choices'][0]['message']['content'];
        setState(() {
          _messages.add({'role': 'bot', 'text': botResponse});
          _isLoading = false;
        });
      } else {
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('OpenRouter Error: $e');
      setState(() {
        _messages.add({
          'role': 'bot',
          'text': 'Error details: ${e.toString()}',
        });
        _isLoading = false;
      });
    }
  }

  Future<String> _getLivestockContext() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('livestock')
          .get();
      if (snapshot.docs.isEmpty) {
        return 'No livestock data available yet in the system.';
      }

      final buffer = StringBuffer();
      buffer.writeln(
        'Total livestock registered on the farm: ${snapshot.docs.length}',
      );
      buffer.writeln('--- Current Active Animal Data ---');

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final name = data['name'] ?? 'Unknown Name';
        final species = data['species'] ?? 'Unknown Species';
        final status = data['status'] ?? 'Normal';
        final temperature = data['temperature']?.toString() ?? 'N/A';
        final tagId = data['tagId'] ?? 'No Tag';

        buffer.writeln(
          '- Name: $name (Species: $species, Tag ID: $tagId) | Health Status: $status | Body Temp: $temperature°C',
        );
      }
      return buffer.toString();
    } catch (e) {
      return 'Unable to fetch farm data at this time.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('LEO - Livestock Expert Optimizer'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isBot = msg['role'] == 'bot';
                      return Align(
                        alignment: isBot
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isBot
                                ? Colors.grey[300]
                                : AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            msg['text']!,
                            style: TextStyle(
                              color: isBot ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask me anything...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primaryBlue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
