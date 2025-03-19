import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';



class MemberPage extends StatefulWidget {
  final String groupId; // Add groupId as a required parameter

  const MemberPage({super.key, required this.groupId}); // Accept groupId in the constructor

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  List<Map<String, dynamic>> members = [];
  bool isLoading = true;

  // Fetch all members from Firestore in the current group
 Future<void> fetchMembers() async {
  final groupId = widget.groupId; // Assuming groupId is passed to the widget

  if (groupId == null) return; // Check if groupId is valid

  try {
    // Query Firestore for users that belong to the groupId
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users') // Assuming your collection is named 'users'
        .where('groupId', isEqualTo: groupId) // Filter by groupId
        .get();

    setState(() {
      members = snapshot.docs.map((doc) {
        return {
          'userId': doc['userId'] ?? 'Unknown', // Display userId or a placeholder
          'totalContributed': doc['totalContributed'] ?? 0, // Default to 0 if not available
          'totalWithdrawn': doc['totalWithdrawn'] ?? 0, // Default to 0 if not available
        };
      }).toList();
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    print("Error fetching members: $e");
  }
}
 
  @override
  void initState() {
    super.initState();
    fetchMembers(); // Fetch members for the passed groupId
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            width: MediaQuery.of(context).size.width,
            height: 120,
            color:  Color.fromRGBO(0, 118, 107, 1.0),
            child:  Column(
              children: [

                SizedBox(height: 80,),
                
                    Row(
            children: [
            
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(Icons.arrow_back,color: Colors.white,),
              ),
              const SizedBox(width: 110),
              const Text(
                "MEMBERS",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ],
          ),
     
              ],
            ),
          ),

          SizedBox(

              height: 10,
          ),
        
            Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: const TextField(
              decoration: InputDecoration(
                hintText: "Search Member",
                hintStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: Color.fromARGB(255, 16, 8, 8),
                ),
                suffixIcon: Icon(Icons.search, size: 30),
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(),
              ),
            ),
          ),
          // Member List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : members.isEmpty
                    ? const Center(
                        child: Text(
                          "No members found",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
   :   Expanded(
  child: isLoading
      ? const Center(child: CircularProgressIndicator())
      : members.isEmpty
          ? const Center(
              child: Text(
                "No members found",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: members.length,
              itemBuilder: (BuildContext context, int index) {
                final member = members[index];
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    height: 100,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color.fromRGBO(255, 255, 255, 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Member profile image
                        Container(
                          height: 70,
                          width: 70,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromARGB(255, 224, 219, 219),
                          ),
                          child: Image.asset(
                            "assets/member.png", // Placeholder image
                          ),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member['userId'] ?? 'Unknown', // Display userId or a placeholder
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                const Text(
                                  "Total Contributed: ",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "${member['totalContributed']} \$",
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text(
                                  "Total Withdrawn: ",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "${member['totalWithdrawn']} \$",
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
),
      
          ),
        ],
      ),
    );
  }
}

