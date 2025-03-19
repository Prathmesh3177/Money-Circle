import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String userId;
  final String groupId;

  DatabaseService({required this.userId, required this.groupId});

  final FirebaseFirestore _db = FirebaseFirestore.instance;

Future<void> contributeAmount(double amount, String userEmail) async {
  try {
    DocumentReference groupDocRef = _db.collection('groups').doc(groupId);
    DocumentReference userDocRef = _db.collection('users').doc(userId);

    await _db.runTransaction((transaction) async {
   
      DocumentSnapshot groupSnapshot = await transaction.get(groupDocRef);
      double currentGroupFund = (groupSnapshot.data() as Map<String, dynamic>)['groupFund'] ?? 0.0;

      
      DocumentSnapshot userSnapshot = await transaction.get(userDocRef);
      double userContribution = (userSnapshot.data() as Map<String, dynamic>)['totalContributed'] ?? 0.0;
      double totalWithdrawn = (userSnapshot.data() as Map<String, dynamic>)['totalWithdrawn'] ?? 0.0;

     
      double remainingContribution = amount;

      if (totalWithdrawn > 0) {
        if (remainingContribution >= totalWithdrawn) {

          remainingContribution -= totalWithdrawn; 
          totalWithdrawn = 0.0; 
        } else {
       
          totalWithdrawn -= remainingContribution;
          remainingContribution = 0.0; 
        }
      }

      // Update the group fund
      transaction.update(groupDocRef, {
        'groupFund': currentGroupFund + amount, // Full contribution added to the group fund
      });

      // Update user's data
      transaction.update(userDocRef, {
        'totalContributed': userContribution + remainingContribution, // Add remaining contribution
        'totalWithdrawn': totalWithdrawn, // Update debt (0 if fully cleared)
      });
    });

    // Log the transaction (Deposit)
    await addTransaction(amount, true, userEmail);
  } catch (e) {
    throw Exception('Failed to contribute amount: $e');
  }
}

  /// Withdraw an amount from the group fund
Future<void> withdrawAmount(double amount, String userId) async {
  try {
    DocumentReference groupDocRef = _db.collection('groups').doc(groupId);
    DocumentReference userDocRef = _db.collection('users').doc(userId);

    await _db.runTransaction((transaction) async {
      // Fetch current group fund
      DocumentSnapshot groupSnapshot = await transaction.get(groupDocRef);
      double currentGroupFund = (groupSnapshot.data() as Map<String, dynamic>)['groupFund'] ?? 0.0;

      // Ensure group fund has sufficient balance
      if (currentGroupFund < amount) {
        throw Exception('Insufficient group fund to withdraw');
      }

      // Fetch user's data
      DocumentSnapshot userSnapshot = await transaction.get(userDocRef);
      double userContribution = (userSnapshot.data() as Map<String, dynamic>)['totalContributed'] ?? 0.0;
      double totalWithdrawn = (userSnapshot.data() as Map<String, dynamic>)['totalWithdrawn'] ?? 0.0;

      // Ensure user has contributed at least ₹100
      if (userContribution < 100.0) {
        throw Exception('You must have contributed at least ₹100 to withdraw from the group fund.');
      }

      // Calculate the interest (2% of the withdrawn amount)
      double interest = amount * 0.02;

      if (amount <= userContribution) {
        // Deduct the amount from the user's contribution
        transaction.update(userDocRef, {
          'totalContributed': userContribution - amount, // Update user's contribution
        });
      } else {
        // Calculate excess withdrawal
        double excessWithdrawal = amount - userContribution;

        transaction.update(userDocRef, {
          'totalContributed': 0.0, // Contribution becomes 0
          'totalWithdrawn': totalWithdrawn + excessWithdrawal + interest, // Add the excess amount and interest to totalWithdrawn
        });
      }

      // Update the group fund
      transaction.update(groupDocRef, {
        'groupFund': currentGroupFund - amount, // Deduct the withdrawn amount from the group fund
      });
    });

    // Log the transaction
    await addTransaction(amount, false, userId);
  } catch (e) {
    throw Exception('Failed to withdraw amount: $e');
  }
}

 
  /// Adds a transaction record to Firestore
  Future<void> addTransaction(double amount, bool isDeposit, String userEmail) async {
    try {
      await _db.collection('transactions').add({
        'userId': userId,
        'groupId': groupId,
        'userEmail': userEmail,
        'amount': amount,
        'isDeposit': isDeposit,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error adding transaction: $e');
    }
  }

  /// gey groupFund
  Stream<double> getGroupFundStream() {
    try {
      DocumentReference groupDocRef = _db.collection('groups').doc(groupId);

      return groupDocRef.snapshots().map((snapshot) {
        if (snapshot.exists) {
          return (snapshot.data() as Map<String, dynamic>)['groupFund'] ?? 0.0;
        }
        return 0.0;
      });
    } catch (e) {
      throw Exception('Error fetching group fund stream: $e');
    }
  }

  Future<double> getUserContribution() async {
    try {
      DocumentReference userDocRef = _db.collection('users').doc(userId);

      DocumentSnapshot userSnapshot = await userDocRef.get();
      return (userSnapshot.data() as Map<String, dynamic>)['totalContributed'] ?? 0.0;
    } catch (e) {
      throw Exception('Error fetching user contribution: $e');
    }
  }

  /// Get the total withdrawn r
  Future<double> getTotalWithdrawn() async {
    try {
      DocumentReference userDocRef = _db.collection('users').doc(userId);

      DocumentSnapshot userSnapshot = await userDocRef.get();
      return (userSnapshot.data() as Map<String, dynamic>)['totalWithdrawn'] ?? 0.0;
    } catch (e) {
      throw Exception('Error fetching total withdrawn: $e');
    }
  }

 
Stream<double> getUserContributionStream() {
  return _db
      .collection('users') 
      .doc(userId)
      .snapshots() 
      .map((snapshot) {
    if (snapshot.exists) {
      return (snapshot.data() as Map<String, dynamic>)['totalContributed'] ?? 0.0;
    } else {
      return 0.0;
    }
  });
}

//user total withdrawn
Future<double> getUserTotalWithdrawn() async {
  try {
  
    DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

  
    DocumentSnapshot userSnapshot = await userDocRef.get();

    
    double totalWithdrawn = userSnapshot['totalWithdrawn'] ?? 0.0;

    return totalWithdrawn;
  } catch (e) {
    print('Error fetching user total withdrawn: $e');
    return 0.0; 
  }
}

Future<void> createGroup(String groupId, double initialFund) async {
  try {
    
    await FirebaseFirestore.instance.collection('groups').doc(groupId).set({
      'groupFund': initialFund, 
      'groupId': groupId,       
      'groupPassword': '',     
    });

    print('Group created successfully');
  } catch (e) {
    print('Error creating group: $e');
  }
}




//leave group
 Future<bool> leaveGroup() async {
  try {
    DocumentReference userDocRef = _db.collection('users').doc(userId);
    DocumentSnapshot userSnapshot = await userDocRef.get();

    if (!userSnapshot.exists) {
      return false; 
    }

   
    double totalWithdrawn = (userSnapshot.data() as Map<String, dynamic>)['totalWithdrawn'] ?? 0.0;

   
    if (totalWithdrawn > 0) {
      throw Exception("You cannot leave the group until you repay all withdrawn funds.");
    }

    
    DocumentReference groupDocRef = _db.collection('groups').doc(groupId);
    DocumentSnapshot groupSnapshot = await groupDocRef.get();

    if (!groupSnapshot.exists) {
      return false; 
    }

   
    List<dynamic> participants = (groupSnapshot.data() as Map<String, dynamic>)['participants'] ?? [];

    if (participants.contains(userId)) {
      participants.remove(userId);
      await groupDocRef.update({
        'participants': participants,
      });
    }

    
    List<dynamic> userGroups = (userSnapshot.data() as Map<String, dynamic>)['groups'] ?? [];

    if (userGroups.contains(groupId)) {
      userGroups.remove(groupId);
      await userDocRef.update({
        'groups': userGroups,
      });
    }

    return true; 
  } catch (e) {
    print('Error while leaving group: $e');
    return false; 
  }
}




}
