import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../screens/ai_chatbot_screen.dart';

class ChatbotFloatingButton extends StatelessWidget {
  const ChatbotFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AIChatbotScreen()),
        );
      },
      backgroundColor: AppColors.primaryBlue,
      child: const Icon(Icons.chat_bubble, color: Colors.white),
    );
  }
}
