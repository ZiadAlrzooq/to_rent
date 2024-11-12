import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:to_rent/services/auth_service.dart';

class FirestoreService {
  Future<void> createUser(String uid, String email, String username) async {
    final batch = FirebaseFirestore.instance.batch();
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final usernameRef =
        FirebaseFirestore.instance.collection('usernames').doc(username);
    batch.set(userRef, {'email': email});
    batch.set(usernameRef, {'uid': uid});
    await batch.commit();
  }

  // function to check if the username is already taken
  Future<bool> isUsernameTaken(String username) async {
    final usernameRef =
        FirebaseFirestore.instance.collection('usernames').doc(username);
    final doc = await usernameRef.get();
    return doc.exists;
  }

  // Function to get user's profile data
  Future<Map<String, dynamic>> getUserProfileData(String uid) async {
    // Fetch the user's document from the users collection
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!userDoc.exists) {
      throw Exception('User not found');
    }
    // Fetch the username from the usernames collection using the uid
    final usernameQuery = await FirebaseFirestore.instance
        .collection('usernames')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();
    if (usernameQuery.docs.isEmpty) {
      throw Exception('Username not found');
    }
    final username = usernameQuery.docs.first.id;
    // Fetch the ratings from the ratings subcollection
    final ratingsQuery = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('ratings')
        .get();
    final ratings =
        ratingsQuery.docs.map((doc) => doc['rating'] as int).toList();
    final ratingCount = ratings.length;
    // Calculate the average rating
    final averageRating = ratings.isEmpty
        ? 0
        : (ratings.reduce((a, b) => a + b) / ratingCount).round();

    // get posts title and first image
    final postsQuery = await FirebaseFirestore.instance
        .collection('posts')
        .where('posterId', isEqualTo: uid)
        .get();

    final posts = postsQuery.docs.map((doc) {
      final data = doc.data();
      return {
        'postId': doc.id,
        'title': data['title'],
        'image': data['imageUrls'][0],
      };
    }).toList();

    // Combine the data into a single map
    final profileData = {
      'uid': uid,
      'username': username,
      'profilePicture': userDoc.data()?['profilePicture'] ?? '',
      'rating': averageRating,
      'ratingCount': ratingCount,
      'posts': posts,
    };

    return profileData;
  }

  // update pfp
  Future<void> updateProfilePicture(String uid, String profilePicture) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    await userRef.update({'profilePicture': profilePicture});
  }

  // delete post
  Future<void> deletePost(String postId) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    await postRef.delete();
  }
}
