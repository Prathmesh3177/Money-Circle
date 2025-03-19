import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_app/contribute.dart';
import 'package:project_app/database.dart';
import 'package:project_app/groupLogin.dart';
import 'package:project_app/membersPage.dart';
import 'package:project_app/more.dart';
import 'package:project_app/transaction.dart';
import 'package:project_app/withdraw.dart';
 import 'package:carousel_slider/carousel_slider.dart';

class Money extends StatefulWidget {
  final String userId;
  final String groupId;

  const Money({super.key, required this.userId, required this.groupId});

  @override
  State<Money> createState() => _MoneyState(this.userId, this.groupId);
}

class _MoneyState extends State<Money> {
  double availableBalance = 0.0;
  double groupFund = 0.0;

  late DatabaseService dbService;
  final String userId;
  final String groupId;

  _MoneyState(this.userId, this.groupId);

  final TextEditingController depositController = TextEditingController();
  final TextEditingController withdrawController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dbService = DatabaseService(userId: userId, groupId: groupId);
    // Fetch group fund initially
    _fetchGroupFund();
  }

  @override
  void dispose() {
    depositController.dispose();
    withdrawController.dispose();
    super.dispose();
  }

  // Fetch group fund
  Future<void> _fetchGroupFund() async {
    try {
      DocumentSnapshot groupDoc = await FirebaseFirestore.instance.collection('groups').doc(groupId).get();
      if (groupDoc.exists) {
        setState(() {
          groupFund = groupDoc['groupFund'] ?? 0.0; // Fetch the total group fund
        });
      }
    } catch (e) {
      print('Error fetching group fund: $e');
    }
  }

  // Method to handle leaving the group
  void _leaveGroup() async {
    // Check if user can leave the group (their withdrawn amount must be 0)
    double totalWithdrawn = await dbService.getUserTotalWithdrawn();
    if (totalWithdrawn == 0.0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Leave Group'),
            content: const Text('Are you sure you want to leave the group?'),
            actions: [
              TextButton(
                onPressed: () {
              Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GroupDetailsPage()), // Replace with your login screen widget
      );
                  
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  bool result = await dbService.leaveGroup();
                  if (result) {
                    Navigator.of(context).pop();
                    Navigator.pop(context); // Navigate back to previous screen
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error leaving the group')),
                    );
                  }
                },
                child: const Text('Leave'),
              ),
            ],
          );
        },
      );
    } else {
      // Show error if the user has withdrawn an amount
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot leave the group because you have withdrawn money.')),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchGroupFund(); // Refresh data when widget is visible again
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            width: MediaQuery.of(context).size.width,
            height: 250,
            color: Color.fromRGBO(0, 118, 107, 1.0),

            child: Column(
              children: [
                const SizedBox(height: 70),
                Row(
                  children: [
                    GestureDetector(
                      child: const Icon(
                        Icons.menu,
                        color: Colors.white,
                      ),
                      onTap: () {
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MemberPage(groupId:groupId),
  ),
);

                      },
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      "VIEW GROUP",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
       
              
              
                const SizedBox(height: 50),
                Container(
                  height: 80,
                  width: 390,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Group Fund
                      Flexible(
                        child: StreamBuilder<double>(
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

                            double groupFund = snapshot.data ?? 0.0;

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "\$ ${groupFund.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(255, 6, 133, 10),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Text(
                                  "Group Fund",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 90, 88, 88),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 10), // Adjust spacing

                      // Your Contribution
                      Flexible(
                        child: StreamBuilder<double>(
                          stream: dbService.getUserContributionStream(),
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

                            double userContribution = snapshot.data ?? 0.0;

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "\$ ${userContribution.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                     color:Color.fromRGBO(0, 118, 107, 1.0)

                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Text(
                                  "Your Contribution",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 90, 88, 88),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 10),

                      // Interest Rate (hardcoded as 0.00)
                      const Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "\$ 2.00",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.red
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "Interest Rate",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 90, 88, 88),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
  


Expanded(
  child: Container(
    padding: EdgeInsets.only(left: 60),
    color: const Color.fromARGB(255, 234, 232, 232),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(),

        
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: CarouselSlider(
            options: CarouselOptions(
              height: 250.0, 
            
              autoPlay: true,
              enlargeCenterPage: true, 
              aspectRatio: 16/9,
              viewportFraction: 1, 
              scrollPhysics: BouncingScrollPhysics(),
            ),
            items: [
            
              "assets/visa.png",
                "assets/master.png",
               
              
            ].map((cardImage) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                   margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: DecorationImage(
                        image: AssetImage(cardImage), 
                        fit: BoxFit.cover, 
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),

        const Spacer(),

        Row(
          children: [
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContributeScreen(
                      userId: userId,
                      groupId: groupId,
                    ),
                  ),
                );
              },
              child: Container(
                height: 60,
                width: 200,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    color: const Color.fromARGB(255, 3, 120, 7)),
                child: const Center(
                  child: Row(
                    children: [
                      SizedBox(width: 10),
                      Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "CONTRIBUTE",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
          ],
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WithdrawScreen(
                      userId: userId,
                      groupId: groupId,
                    ),
                  ),
                );
              },
              child: Container(
                height: 60,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  color: Color.fromRGBO(0, 118, 107, 1.0),
                ),
                child: const Center(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.arrow_downward,
                        color: Colors.white,
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "WITHDRAW",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
          ],
        ),
        const SizedBox(height: 10),

        // Leave Group Button
        Row(
          children: [
            const Spacer(),
            GestureDetector(
              onTap: _leaveGroup,
              child: Container(
                height: 60,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  color: Color.fromRGBO(128, 0, 0, 1.0),
                ),
                child: const Center(
                  child: Row(
                    children: [
                      SizedBox(width: 10),
                      Icon(
                        Icons.exit_to_app,
                        color: Colors.white,
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "LEAVE GROUP",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
          ],
        ),
        const SizedBox(height: 20),
      ],
    ),
  ),
),

      
      
      
                      Container(
            color: Colors.white,
            child: Container(
              padding: const EdgeInsets.only(top: 10),
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Column(
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
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TransactionPage(userId: userId,groupId: groupId,)));
                    },
                    child: GestureDetector(
                      onTap: () {
          
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TransactionPage(userId: userId,groupId: groupId,)),
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
                  onTap: (){

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
                      children: [
                        GestureDetector(
                          child: const Icon(
                            Icons.more,
                            color: Colors.grey,
                            size: 30,
                          ),
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
          )
      
      
        ],
      ),
    );
  }
}
