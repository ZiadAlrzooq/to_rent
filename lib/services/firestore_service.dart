import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:to_rent/services/auth_service.dart';

class FirestoreService {
  Future<void> createUser(String uid, String email, String username) async {
    final batch = FirebaseFirestore.instance.batch();
    final userRef = FirebaseFirestore.instance.collection('users').doc(email);
    final usernameRef =
        FirebaseFirestore.instance.collection('usernames').doc(username);
    batch.set(userRef, {'uid': uid, 'email': email});
    batch.set(usernameRef, {'uid': uid});
    await batch.commit();
  }
}
