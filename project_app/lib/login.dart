import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_app/GroupService.dart';
import 'package:project_app/authetication.dart'; 
import 'package:project_app/home.dart'; 

class UserLoginPage extends StatefulWidget {
  final String groupId;
  final String groupPassword;


  UserLoginPage({Key? key, required this.groupId, required this.groupPassword}) : super(key: key);

  @override
  _UserLoginPageState createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController _userPasswordController = TextEditingController();
  bool _isLoading = false;
  final GroupService _groupService = GroupService();
  final AuthService _authService = AuthService();

  // Method to register user to the group
  Future<void> initializeUserContribution(String userId, String groupId, String password) async {
    try {
      // Check if the user document already exists
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
   
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'groupId': groupId,          
          'password': password,         
          'totalContributed': 0.0,      
          'totalWithdrawn': 0.0,      
          'userId': userId,            
        });
      }
    } catch (e) {
      print('Error initializing user contribution: $e');
    }
  }

  // Show error dialog
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Login',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: Colors.white),
        
        ),
        backgroundColor: Color.fromRGBO(0, 118, 107, 1.0), // A nice blue color
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Enter Your Details",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(0, 118, 107, 1.0),
                ),
              ),
              const SizedBox(height: 20),
              // User ID TextField
              TextField(
                controller: userIdController,
                decoration: InputDecoration(
                  labelText: 'User ID',
                  labelStyle: const TextStyle(color: Colors.black54),
                  hintText: 'Enter User ID',
                  hintStyle: const TextStyle(color: Colors.black38),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
              ),
              const SizedBox(height: 20),
              // User Password TextField
              TextField(
                controller: _userPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.black54),
                  hintText: 'Enter Password',
                  hintStyle: const TextStyle(color: Colors.black38),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            String userId = userIdController.text.trim();
                            String password = _userPasswordController.text.trim();

                            if (userId.isEmpty || password.isEmpty) {
                              _showError("User ID and Password cannot be empty");
                              return;
                            }

                            initializeUserContribution(userId, widget.groupId, password);
                          }, // Register button
                          style: ElevatedButton.styleFrom(
                            iconColor:  Color.fromRGBO(0, 118, 107, 1.0),
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Register',
                            style: TextStyle(fontSize: 18,color:  Color.fromRGBO(0, 118, 107, 1.0)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            String userId = userIdController.text.trim();
                            String password = _userPasswordController.text.trim();

                            if (userId.isEmpty || password.isEmpty) {
                              _showError("User ID and Password cannot be empty");
                              return;
                            }

                            // Validate user credentials (basic check for demonstration)
                            try {
                              DocumentSnapshot userDoc = await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .get();

                              if (!userDoc.exists || userDoc['password'] != password) {
                                _showError("Invalid User ID or Password");
                                return;
                              }

                              
                              await initializeUserContribution(userId, widget.groupId, password);

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Money( 
                                    userId: userId,
                                    groupId: widget.groupId,
                                  ),
                                ),
                              );
                            } catch (e) {
                              _showError("Error logging in: $e");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                          iconColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(fontSize: 18,color:   Color.fromRGBO(0, 118, 107, 1.0)),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
