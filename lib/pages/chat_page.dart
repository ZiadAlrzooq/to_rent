import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_rent/pages/chat_details.dart';
import 'package:to_rent/widgets/custom_app_bar.dart';

class ChatsPage extends StatelessWidget {
  final String currentUserId;

  ChatsPage({required this.currentUserId});

  Future<Map<String, dynamic>> getUserInfo(String userId) async {
    // Fetch profile picture from users collection
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final pfp = userDoc['profilePicture'] ?? '';

    // Fetch username from usernames collection
    final usernameDoc = await FirebaseFirestore.instance
        .collection('usernames')
        .where('uid', isEqualTo: userId)
        .limit(1)
        .get();
    final username =
        usernameDoc.docs.isNotEmpty ? usernameDoc.docs[0].id : 'Unknown';

    return {'username': username, 'pfp': pfp};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'الدردشات'),
      drawer: CustomDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final chatId = chat.id;
              final participants = List<String>.from(chat['participants']);
              final lastMessage = chat['lastMessage'] ?? '';
              final otherUserId =
                  participants.firstWhere((id) => id != currentUserId);
                print('otherUserId: $otherUserId');
              // Use FutureBuilder to fetch user info for each chat item
              return FutureBuilder<Map<String, dynamic>>(
                future: getUserInfo(otherUserId),
                builder: (context, userInfoSnapshot) {
                  if (!userInfoSnapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final userInfo = userInfoSnapshot.data!;
                  final username = userInfo['username'];
                  final pfpUrl = userInfo['pfp'];

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: pfpUrl.isNotEmpty
                            ? NetworkImage(pfpUrl)
                            : AssetImage('assets/default_pfp.png')
                                as ImageProvider,
                      ),
                      title: Text(username,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              currentUserId: currentUserId,
                              otherUserId: otherUserId,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
