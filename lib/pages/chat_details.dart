import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:to_rent/services/chat_service.dart';
import 'package:to_rent/widgets/message_input_field.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatScreen extends StatelessWidget {
  final String currentUserId;
  final String otherUserId;
  final String? chatId; // Optional chatId parameter
  final ChatService chatService = ChatService();

  ChatScreen({
    required this.currentUserId,
    required this.otherUserId,
    this.chatId, // Optional parameter
  });

  @override
  Widget build(BuildContext context) {
    // If chatId is provided directly, skip the Future and build UI immediately
    if (chatId != null) {
      return buildChatUI(context, chatId!);
    }

    // Otherwise, get chatId using the service
    return FutureBuilder<String>(
      future: chatService.getChatId(currentUserId, otherUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        return buildChatUI(context, snapshot.data!);
      },
    );
  }

  Widget buildChatUI(BuildContext context, String chatId) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['senderId'] == currentUserId;
                    final timestamp = message['timestamp'] as Timestamp?;
                    final messageTime = timestamp != null
                        ? timeago.format(timestamp.toDate(), locale: 'ar')
                        : '';

                    return ListTile(
                      title: Text(
                        message['content'],
                        textAlign: isMe ? TextAlign.end : TextAlign.start,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: isMe ? Colors.blue : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        messageTime,
                        textAlign: isMe ? TextAlign.end : TextAlign.start,
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          MessageInputField(chatId: chatId, senderId: currentUserId),
        ],
      ),
    );
  }
}
