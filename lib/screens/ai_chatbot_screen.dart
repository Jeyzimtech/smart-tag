import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
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
  late final GenerativeModel _model;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: 'AIzaSyBOk-Kjbmk-3Vbo_tlY8Z3foClEj2wH53U',
    );
    _messages.add({'role': 'bot', 'text': 'Hello! I\'m LEO (Livestock Expert Optimizer), your AI-powered farm assistant. I can help with livestock management, health monitoring, and farming advice. How can I help you today?'});
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
      final prompt = '''
You are LEO (Livestock Expert Optimizer), an AI assistant for smart livestock farming.

Current Farm Data:
$livestockData

User Question: $userMessage

Provide helpful, concise advice about livestock management, health, or farming practices. If the question is about their farm data, use the context above.''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final botResponse = response.text ?? 'Sorry, I couldn\'t process that.';
      
      setState(() {
        _messages.add({'role': 'bot', 'text': botResponse});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'bot', 'text': 'Sorry, I encountered an error. Please try again.'});
        _isLoading = false;
      });
    }
  }

  Future<String> _getLivestockContext() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('livestock').get();
      if (snapshot.docs.isEmpty) {
        return 'No livestock data available yet.';
      }
      return 'Total livestock: ${snapshot.docs.length}';
    } catch (e) {
      return 'Unable to fetch farm data.';
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
                  alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isBot ? Colors.grey[300] : AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(color: isBot ? Colors.black : Colors.white),
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
