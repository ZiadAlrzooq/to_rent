import 'package:flutter/material.dart';
import 'package:to_rent/services/chat_service.dart';
class MessageInputField extends StatefulWidget {
  final String chatId;
  final String senderId;

  MessageInputField({required this.chatId, required this.senderId});

  @override
  _MessageInputFieldState createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  final TextEditingController _controller = TextEditingController();
  final ChatService chatService = ChatService();

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      chatService.sendMessage(
        chatId: widget.chatId,
        senderId: widget.senderId,
        messageContent: _controller.text.trim(),
      );
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: "...اكتب رسالة",
              ),
              onSubmitted: (value) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

