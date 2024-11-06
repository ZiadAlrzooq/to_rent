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
  final ChatService chatService = ChatService();

  ChatScreen({required this.currentUserId, required this.otherUserId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: chatService.getChatId(currentUserId, otherUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final chatId = snapshot.data!;

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
      },
    );
  }
}

