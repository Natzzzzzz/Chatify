import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../features/chat/domain/entities/chat_message.dart';

class SystemMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const SystemMessageBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final text = message.text ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
