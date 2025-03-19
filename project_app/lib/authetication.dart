import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register user
  Future<User?> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print(e);
      return null;
    }
  }


    Future<void> updateUserGroup(String userId, String groupId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'groupId': groupId,
      });
    } catch (e) {
      throw Exception("Error updating user group: $e");
    }
  }

  // Login user
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Check if user is in a group
  Future<bool> isUserInGroup(String userId) async {
    try {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        var groupId = userDoc['groupId'];
        return groupId != null && groupId.isNotEmpty;
      }
      return false;
    } catch (e) {
      print('Error checking if user is in a group: $e');
      return false;
    }
  }

  // Get current user id
  String getCurrentUserId() {
    User? user = _auth.currentUser;
    return user?.uid ?? ''; // Return the user ID or empty string if not logged in
  }

  // Logout user
  Future<void> logout() async {
    await _auth.signOut();
  }
}
