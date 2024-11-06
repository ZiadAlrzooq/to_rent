import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to send a message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String messageContent,
  }) async {
    final messageData = {
      'senderId': senderId,
      'content': messageContent,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Add message to the Messages subcollection
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    // Update the last message and timestamp in the chat document
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': messageContent,
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
    });
  }

  // Method to create or get chatId between two users
  Future<String> getChatId(String userId1, String userId2) async {
    final chatId = userId1.compareTo(userId2) < 0 ? "$userId1\_$userId2" : "$userId2\_$userId1";

    final chatDoc = await _firestore.collection('chats').doc(chatId).get();

    if (!chatDoc.exists) {
      // Create the chat document if it doesn't exist
      await _firestore.collection('chats').doc(chatId).set({
        'participants': [userId1, userId2],
        'lastMessage': '',
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      });
    }
    return chatId;
  }
}
