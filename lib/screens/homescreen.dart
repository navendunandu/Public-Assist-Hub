import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName="";

  Future<void> _fetchUserName() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      print("User: $uid");
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('tbl_user')
          .doc(uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc.get('user_name') ?? 'Unknown User';
        });
      }
    } catch (e) {
      print("Error Loading User: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF33A4BB), // Primary color as background
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Section
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Welcome to",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      "Public Assist Hub",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF33A4BB),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      userName!, // Show the user's name
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Button Section
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      "Choose an option below:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Buttons (Replace with your buttons)
                    // ElevatedButton(
                    //   onPressed: () {
                    //     // Handle button action
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     foregroundColor: Color(0xFF33A4BB),
                    //     backgroundColor: Colors.white,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(20),
                    //     ),
                    //     padding: EdgeInsets.symmetric(
                    //       vertical: 15,
                    //       horizontal: 30,
                    //     ),
                    //   ),
                    //   child: Text(
                    //     "Option 1",
                    //     style: TextStyle(fontSize: 16),
                    //   ),
                    // ),
                    // SizedBox(height: 15),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     // Handle button action
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     foregroundColor: Color(0xFF33A4BB),
                    //     backgroundColor: Colors.white,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(20),
                    //     ),
                    //     padding: EdgeInsets.symmetric(
                    //       vertical: 15,
                    //       horizontal: 30,
                    //     ),
                    //   ),
                    //   child: Text(
                    //     "Option 2",
                    //     style: TextStyle(fontSize: 16),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
