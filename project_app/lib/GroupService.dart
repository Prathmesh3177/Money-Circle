import 'package:cloud_firestore/cloud_firestore.dart';

class GroupService {
  // Create a new group
  Future<String> createGroup(String groupId, String password) async {
    try {
      // Check if the group already exists
      var groupDoc = await FirebaseFirestore.instance.collection('groups').doc(groupId).get();
      if (groupDoc.exists) {
        return "Group with this ID already exists.";
      }

      // If group doesn't exist, create it
      await FirebaseFirestore.instance.collection('groups').doc(groupId).set({
        'groupId': groupId,
        'password': password,
        'createdAt': FieldValue.serverTimestamp(),
        'members': [], // Add an empty list of members initially
      });

      return "Group created successfully!";
    } catch (e) {
      return "Error creating group: $e";
    }
  }

  // Add a user to the group
  Future<String> addUserToGroup({
    required String groupId,
    required String groupPassword,
  }) async {
    try {
      // Check if the group exists
      var groupDoc = await FirebaseFirestore.instance.collection('groups').doc(groupId).get();

      if (!groupDoc.exists) {
        return "Group not found.";
      }

      // Validate the group password
      if (groupDoc['password'] != groupPassword) {
        return "Incorrect group password.";
      }

      // Proceed with adding a user to the group after validation
      await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
        'members': FieldValue.arrayUnion([groupId]), // This would be a placeholder, but will be used later
      });

      return "User added to the group successfully!";
    } catch (e) {
      return "Error adding user to group: $e";
    }
  }

  // Join an existing group (new method)
 // Updated joinGroup method
Future<String> joinGroup({
  required String groupId,
  required String groupPassword,
}) async {
  try {
    // Check if the group exists
    var groupDoc = await FirebaseFirestore.instance.collection('groups').doc(groupId).get();

    if (!groupDoc.exists) {
      return "Group not found.";
    }

    // Validate group password
    if (groupDoc['password'] != groupPassword) {
      return "Incorrect group password.";
    }

    // No need to validate user credentials here
    // Simply allow the user to join the group once groupId and groupPassword are valid
    return "User joined the group successfully!";
  } catch (e) {
    return "Error joining group: $e";
  }
}

  // Verify if user exists in the group
  Future<String> verifyUserInGroup({
    required String groupId,
    required String groupPassword,
  }) async {
    try {
      // Get the group document
      var groupDoc = await FirebaseFirestore.instance.collection('groups').doc(groupId).get();

      if (!groupDoc.exists) {
        return "Group not found.";
      }

      // Validate group password
      if (groupDoc['password'] != groupPassword) {
        return "Incorrect group password.";
      }

      // Verify if the user is part of the group
      if (groupDoc['members'] != null && !groupDoc['members'].contains(groupId)) {
        return "User is not part of the group.";
      }

      return "User is part of the group!";
    } catch (e) {
      return "Error verifying user in group: $e";
    }
  }
}
