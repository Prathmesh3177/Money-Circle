import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_app/home.dart';
import 'package:project_app/more.dart';

class TransactionPage extends StatelessWidget {
  final String userId;
  final String groupId;

  const TransactionPage({super.key, required this.userId, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TransactionScreen(userId: userId, groupId: groupId),
      bottomNavigationBar: BottomNavBar(userId: userId, groupId: groupId),
    );
  }
}

class TransactionScreen extends StatefulWidget {
  final String userId;
  final String groupId;

  const TransactionScreen({super.key, required this.userId, required this.groupId});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  // Fetch transactions for a specific group from Firestore
  Future<void> fetchTransactions() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('groupId', isEqualTo: widget.groupId)  // Filter by groupId
          .orderBy('timestamp', descending: true)  // Order by timestamp descending
          .get();

      setState(() {
        transactions = snapshot.docs.map((doc) {
          return {
            'amount': doc['amount'],
            'userId': doc['userId'] ?? "Unknown", // User ID (who made the transaction)
            'type': doc['isDeposit'] ? 'Deposit' : 'Withdraw', // Transaction type
            'date': (doc['timestamp'] as Timestamp).toDate().toString().split(' ')[0], // Format date
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching transactions: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTransactions(); 
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 10, right: 10),
          width: MediaQuery.of(context).size.width,
          height: 100,
          color:  Color.fromRGBO(0, 118, 107, 1.0),
          child: Column(
            children: [
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                    GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(Icons.arrow_back,color: Colors.white,),
              ),

              SizedBox(

                  width: 80,
              ),

                  const Text(
                    "TRANSACTIONS",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        // Transaction History Section
        Expanded(
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : transactions.isEmpty
                  ? Center(child: Text("No transactions found", style: TextStyle(fontSize: 18, color: Colors.grey)))
                  : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            height: 95,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
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
                              mainAxisSize: MainAxisSize.min, // Allow Row to shrink-wrap
                              children: [
                                Container(
                                  height: 70,
                                  width: 70,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color.fromARGB(255, 224, 219, 219),
                                  ),
                                  child: Image.asset("assets/member.png"), // Placeholder image
                                ),
                                const SizedBox(width: 20),
                                Flexible( // Replace Expanded with Flexible
                                  fit: FlexFit.loose, // Allows the text to fit the available space
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            transaction['type'],
                                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                                          ),
                                          const Spacer(),
                                          Icon(
                                            transaction['type'] == 'Deposit' ? Icons.arrow_downward : Icons.arrow_upward,
                                            color: transaction['type'] == 'Deposit' ? Colors.green : Colors.red,
                                          ),
                                        ],
                                      ),
                                      Text(
                                        "Amount: \$${transaction['amount']}",
                                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Date: ${transaction['date']}",
                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.grey),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "By: ${transaction['userId']}",
                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final String userId;
  final String groupId;

  const BottomNavBar({super.key, required this.userId, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  )
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
                  )
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionPage(userId: userId, groupId: groupId),
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
                )
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => moreScreen(
                      userId: userId, // Pass your userId here
                      groupId: groupId, // Pass your groupId here
                    ),
                  ),
                );
              },
              child: Column(
                children: [
                  const Icon(
                    Icons.more,
                    color: Colors.grey,
                    size: 30,
                  ),
                  const Text(
                    "MORE",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 91, 87, 87)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
