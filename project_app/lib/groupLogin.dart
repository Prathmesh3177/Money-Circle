import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_app/GroupService.dart'; // Import your GroupService
import 'package:project_app/login.dart'; // Import UserLoginPage

class GroupDetailsPage extends StatefulWidget {
  @override
  _GroupDetailsPageState createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  final TextEditingController groupIdController = TextEditingController();
  final TextEditingController groupPasswordController = TextEditingController();
  bool _isLoading = false;
  final GroupService _groupService = GroupService();

  // Method to create a new group
  Future<void> createGroup(String groupId, String groupPassword, double initialFund) async {
    try {
      await FirebaseFirestore.instance.collection('groups').doc(groupId).set({
        'groupFund': initialFund,
        'groupId': groupId,
        'groupPassword': groupPassword,
      });

      print('Group created successfully');
    } catch (e) {
      print('Error creating group: $e');
    }
  }

  // Method to proceed with an existing group
  Future<void> _proceedToGroup() async {
    String groupId = groupIdController.text.trim();
    String groupPassword = groupPasswordController.text.trim();

    if (groupId.isEmpty || groupPassword.isEmpty) {
      _showError("Group ID and Password cannot be empty");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var groupDoc = await FirebaseFirestore.instance.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) {
        _showError("Group does not exist. Please create the group first.");
        return;
      }

      if (groupDoc['groupPassword'] != groupPassword) {
        _showError("Incorrect group password.");
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserLoginPage(
            groupId: groupId,
            groupPassword: groupPassword,
          ),
        ),
      );
    } catch (e) {
      _showError("Error proceeding to group: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Show error dialog
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text(
          'Group Login',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(0, 118, 107, 1.0)
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
             const Text(
                "Enter Group Details",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(0, 118, 107, 1.0)
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: groupIdController,
                decoration: InputDecoration(
                  labelText: 'Group ID',
                  labelStyle: TextStyle(color: Colors.black54),
                  hintText: 'Enter Group ID',
                  hintStyle: TextStyle(color: Colors.black38),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
              ),
             const SizedBox(height: 20),
              TextField(
                controller: groupPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Group Password',
                  labelStyle:const TextStyle(color: Colors.black54),
                  hintText: 'Enter Group Password',
                  hintStyle: TextStyle(color: Colors.black38),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
              ),
              SizedBox(height: 30),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            String groupId = groupIdController.text.trim();
                            String groupPassword = groupPasswordController.text.trim();

                            if (groupId.isEmpty || groupPassword.isEmpty) {
                              _showError("Group ID and Password cannot be empty");
                              return;
                            }

                            createGroup(groupId, groupPassword, 0.0);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Create Group',
                            style: TextStyle(fontSize: 18,
                            color:  Color.fromRGBO(0, 118, 107, 1.0)
                            )
                            ,
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _proceedToGroup,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:const Text(
                            'Proceed to Group',
                            style: TextStyle(fontSize: 18,color:  Color.fromRGBO(0, 118, 107, 1.0)),
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
