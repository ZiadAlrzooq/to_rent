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
  final String chatId; // Optional chatId parameter
  final String otherProfilePicture;
  final String otherUsername;
  final ChatService chatService = ChatService();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  ChatScreen({
    required this.otherProfilePicture,
    required this.otherUsername,
    required this.chatId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
              otherProfilePicture,
            ),
          ),
          SizedBox(width: 16),
          Text(otherUsername),
        ],
      )),
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

                    // Check if the next message has the same timestamp
                    bool showTimestamp = false;
                    if (index > 0) {
                      final prevMessage = messages[index - 1];
                      final prevTimestamp =
                          prevMessage['timestamp'] as Timestamp?;
                      final prevMessageTime = prevTimestamp != null
                          ? timeago.format(prevTimestamp.toDate(), locale: 'ar')
                          : '';
                      showTimestamp = messageTime != prevMessageTime;
                    }
                    // if next message is from different sender then show timestamp
                    if (index == 0) {
                      showTimestamp = true;
                    } else {
                      // Check the previous message
                      final prevMessage = messages[index - 1];
                      if (prevMessage['senderId'] != message['senderId']) {
                        showTimestamp = true;
                      }
                    }

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.75),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color:
                                      isMe ? Colors.blue : Colors.grey.shade200,
                                  borderRadius: isMe
                                      ? BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                          bottomLeft: Radius.circular(16),
                                        )
                                      : BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                          bottomRight: Radius.circular(16),
                                        ),
                                ),
                                child: Text(
                                  message['content'],
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            if (showTimestamp) SizedBox(height: 4),
                            if (showTimestamp)
                              Text(
                                messageTime,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(color: Colors.grey),
                              ),
                          ],
                        ),
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
