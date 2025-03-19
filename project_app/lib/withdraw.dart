import 'package:flutter/material.dart';
import 'package:project_app/database.dart';

class WithdrawScreen extends StatefulWidget {
  final String userId;
  final String groupId;

  const WithdrawScreen({super.key, required this.userId, required this.groupId});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  TextEditingController withdrawController = TextEditingController();
  late DatabaseService dbService;

  @override
  void initState() {
    super.initState();

    // Initialize DatabaseService
    dbService = DatabaseService(userId: widget.userId, groupId: widget.groupId);
  }

  @override
  void dispose() {
    withdrawController.dispose();
    super.dispose();
  }

  Future<void> _withdrawAmount(double withdrawAmount) async {
    if (withdrawAmount > 0) {
      try {
        // Perform withdrawal using DatabaseService
        await dbService.withdrawAmount(withdrawAmount, widget.userId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully withdrew \$${withdrawAmount.toStringAsFixed(2)}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
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
                "WITHDRAW MONEY",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // StreamBuilder for group fund
          StreamBuilder<double>(
            stream: dbService.getGroupFundStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData) {
                return const Center(child: Text('No data available'));
              }

              double availableBalance = snapshot.data ?? 0.0;

              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      "AVAILABLE BALANCE",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "\$ ${availableBalance.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 40, fontWeight: FontWeight.w500, color: Color.fromARGB(255, 6, 133, 10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      "Please Enter Amount to Withdraw",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color.fromARGB(135, 135, 135, 100)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      "Enter Amount.",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color.fromARGB(255, 40, 72, 154)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      controller: withdrawController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: "Maximum amount that can be withdrawn is 50,000",
                        hintStyle: TextStyle(color: Color.fromRGBO(135, 135, 135, 100), fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        double withdrawAmount = double.tryParse(withdrawController.text) ?? 0.0;

                        if (withdrawAmount > 0 && withdrawAmount <= availableBalance) {
                          await _withdrawAmount(withdrawAmount);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid amount or insufficient funds')),
                          );
                        }
                      },
                      child: Container(
                        width: 150,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color:  Color.fromRGBO(0, 118, 107, 1.0),
                        ),
                        child: const Center(
                          child: Text(
                            "Withdraw",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
