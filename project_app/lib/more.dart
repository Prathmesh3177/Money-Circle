import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_app/groupLogin.dart';
import 'package:project_app/home.dart';
import 'package:project_app/login.dart';
import 'package:project_app/transaction.dart';

class moreScreen extends StatefulWidget {
  final String userId;
  final String groupId;

  const moreScreen({super.key, required this.userId, required this.groupId});

  @override
  State<moreScreen> createState() => _moreScreenState();
}

class _moreScreenState extends State<moreScreen> {
  double totalContribution = 0.0;
  double pendingPayment = 0.0;
  double totalgroupFund = 0.0;

  String userId = '';
  String groupId = '';
  String userName = "Parth Jawale";

  Future<void> _fetchUserData() async {
    try {
      // Fetch the user document to get totalWithdrawn and totalContributed
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();

      // Get the value of totalWithdrawn (user's pending payment)
      double userPendingPayment = userDoc['totalWithdrawn'] ?? 0.0;

      // Get the value of totalContributed (user's total contribution)
      double userTotalContribution = userDoc['totalContributed'] ?? 0.0;

     

      // Set the state with the updated values
      setState(() {
        pendingPayment = userPendingPayment; // Store totalWithdrawn in pendingPayment
        totalContribution = userTotalContribution; // Store totalContributed in userTotalContribution
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }


Future<void> _fetchgroupData() async {
    try {
      // Fetch the user document to get totalWithdrawn and totalContributed
      final groupDoc =
          await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).get();

      
      double totalamount = groupDoc['groupFund'] ?? 0.0;

     

      // Set the state with the updated values
      setState(() {
        
           totalgroupFund = totalamount;
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }





  void _logout() async {
    try {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GroupDetailsPage()), // Replace with your login screen widget
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have been logged out')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout failed')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    groupId = widget.groupId;
    _fetchUserData();
    _fetchgroupData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            width: MediaQuery.of(context).size.width,
            height: 100,
            color:  Color.fromRGBO(0, 118, 107, 1.0),
            child: const Column(
              children: [
                Spacer(),
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.white, size: 30),
                    Text(
                      "  Parth Jawale",
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w400,
                          color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildStatCard(
                  "\$${totalContribution.toStringAsFixed(2)}",
                  "Total",
                  "Contribution",
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatCard(
                  "\$${pendingPayment.toStringAsFixed(2)}",
                  "Pending",
                  "Payment",
                  Colors.red,
                ),
              ),
              Expanded(
                child: _buildStatCard(
                  "\$${totalgroupFund.toStringAsFixed(2)}",
                  "Group",
                  "Fund",
                  Colors.yellow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMenuOption("Settings", Icons.settings_outlined, () {}),
          const SizedBox(height: 20),
          _buildMenuOption("Help & Support", Icons.help_center_outlined, () {}),
          const SizedBox(height: 20),
          _buildMenuOption("About us", Icons.info_outline, () {}),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              _logout();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.logout_outlined,
                    color: Color.fromRGBO(0, 118, 107, 1.0),
                    size: 30,
                  ),
                  SizedBox(width: 30),
                  Text(
                    "Log Out",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios)
                ],
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.white,
                child: Container(
                  padding: const EdgeInsets.only(top: 10),
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Money(
                                userId: userId,
                                groupId: groupId,
                              ),
                            ),
                          );
                        },
                        child: const Column(
                          children: [
                            Icon(
                              Icons.home,
                              color: Colors.grey,
                              size: 30,
                            ),
                            Text(
                              "HOME",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(255, 91, 87, 87)),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TransactionPage(userId: userId, groupId: groupId),
                            ),
                          );
                        },
                        child: const Column(
                          children: [
                            Icon(
                              Icons.payment,
                              color: Colors.grey,
                              size: 30,
                            ),
                            Text(
                              "Transaction",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(255, 91, 87, 87)),
                            )
                          ],
                        ),
                      ),
                      const Column(
                        children: [
                          Icon(
                            Icons.contacts,
                            color: Colors.grey,
                            size: 30,
                          ),
                          Text(
                            "GROUPS",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 91, 87, 87)),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => moreScreen(
                                userId: userId,
                                groupId: groupId,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: const [
                            Icon(
                              Icons.more,
                              color: Colors.grey,
                              size: 30,
                            ),
                            Text(
                              "MORE",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(255, 91, 87, 87)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String amount, String title, String subtitle, Color textColor) {
    return Container(
      margin: const EdgeInsets.all(5),
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500, color: textColor),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: Color.fromRGBO(0, 118, 107, 1.0),size: 30,),
            const SizedBox(width: 30),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 25,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }
}
