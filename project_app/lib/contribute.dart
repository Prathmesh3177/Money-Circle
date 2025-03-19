import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'database.dart';

class ContributeScreen extends StatefulWidget {
  final String userId;
  final String groupId;

  const ContributeScreen({Key? key, required this.userId, required this.groupId}) : super(key: key);

  @override
  State<ContributeScreen> createState() => _ContributeScreenState();
}

class _ContributeScreenState extends State<ContributeScreen> {
  TextEditingController contributeController = TextEditingController();
  late DatabaseService dbService;

  @override
  void initState() {
    super.initState();
    dbService = DatabaseService(userId: widget.userId, groupId: widget.groupId);
  }

  @override
  void dispose() {
    contributeController.dispose();
    super.dispose();
  }

  Future<void> handleContribution() async {
    // Parse the entered amount
    double amount = double.tryParse(contributeController.text) ?? 0.0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount greater than 0')),
      );
      return;
    }

    try {
      // Call the contributeAmount method in the database service
      await dbService.contributeAmount(amount, widget.userId);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contribution successful!')),
      );

      // Clear the input field
      contributeController.clear();
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Row(
            children: [
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 70),
              const Text(
                "CONTRIBUTE MONEY",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black),
              ),
            ],
          ),
     
     
     
     
     
          const SizedBox(height: 40),

          // Display the total group fund
          StreamBuilder<double>(
            stream: dbService.getGroupFundStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              double groupFund = snapshot.data ?? 0.0;

              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      "TOTAL GROUP FUND",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "\$ ${groupFund.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w500, color: Colors.green),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      "Please Enter Amount to Deposit",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Input field for deposit amount
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      controller: contributeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: "Maximum amount that can be Deposited is 50,000",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Deposit Button
                  Center(
                    child: GestureDetector(
                      onTap: handleContribution,
                      child: Container(
                        width: 150,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color.fromRGBO(0, 118, 107, 1.0),
                        ),
                        child: const Center(
                          child: Text(
                            "Deposit",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
