import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommentScreen extends StatefulWidget {
  final String postId;
  const CommentScreen({super.key, required this.postId});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _commentController = TextEditingController();

  Future<void> _postComment() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String commentText = _commentController.text.trim();

    if (commentText.isEmpty) return; // Don't allow empty comments

    await _firestore.collection('tbl_comment').add({
      'user_id': uid,
      'post_id': widget.postId,
      'command_content': commentText,
    });

    _commentController.clear(); // Clear the input field after posting
  }

  Future<Map<String, dynamic>?> _fetchUserDetails(
      String id, String collection) async {
    // Check each collection to find the user
    if (collection == "user") {
      DocumentSnapshot userDoc =
          await _firestore.collection("tbl_user").doc(id).get();
      if (userDoc.exists) {
        return {
          'name': userDoc.get('user_name') ?? 'Unknown',
          'photo': userDoc.get('user_photo') ?? '',
        };
      }
    } else if (collection == "mvd") {
      DocumentSnapshot mvdDoc =
          await _firestore.collection("tbl_mvd").doc(id).get();
      if (mvdDoc.exists) {
        return {
          'name': mvdDoc.get('mvd_name') ?? 'Unknown',
          'photo': mvdDoc.get('mvd_photo') ?? '',
        };
      }
    } else if (collection == "kseb") {
      DocumentSnapshot ksebDoc =
          await _firestore.collection("tbl_kseb").doc(id).get();
      if (ksebDoc.exists) {
        return {
          'name': ksebDoc.get('kseb_name') ?? 'Unknown',
          'photo': ksebDoc.get('kseb_photo') ?? '',
        };
      }
    } else if (collection == "pwd") {
      DocumentSnapshot pwdDoc =
          await _firestore.collection("tbl_pwd").doc(id).get();
      if (pwdDoc.exists) {
        return {
          'name': pwdDoc.get('pwd_name') ?? 'Unknown',
          'photo': pwdDoc.get('pwd_photo') ?? '',
        };
      }
    } else if (collection == "municipality") {
      DocumentSnapshot municipalityDoc =
          await _firestore.collection("tbl_municipality").doc(id).get();
      if (municipalityDoc.exists) {
        return {
          'name': municipalityDoc.get('municipality_name') ?? 'Unknown',
          'photo': municipalityDoc.get('municipality_photo') ?? '',
        };
      }
    } else {
      return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Comments", style: GoogleFonts.poppins(fontSize: 20)),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('tbl_comment')
                  .where('post_id', isEqualTo: widget.postId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No comments yet."));
                }

                var comments = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    var comment = comments[index];
                    String commentText = comment['command_content'];
                    String id = "";
                    String collection = "";

                    if (comment['user_id'] != "") {
                      collection = "user";
                      id = comment['user_id'];
                    } else if (comment['mvd_id']) {
                      collection = "mvd";
                      id = comment['mvd_id'];
                    } else if (comment['kseb_id']) {
                      collection = "kseb";
                      id = comment['kseb_id'];
                    } else if (comment['pwd_id']) {
                      collection = "pwd";
                      id = comment['pwd_id'];
                    } else if (comment['municipality_id']) {
                      collection = "municipality";
                      id = comment['municipality_id'];
                    }

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: _fetchUserDetails(id, collection),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text("Loading..."),
                            subtitle: Text(commentText),
                          );
                        }

                        var userData = userSnapshot.data!;
                        String userName = userData['name'];
                        String userPhoto = userData['photo'];

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: userPhoto.isNotEmpty
                                ? NetworkImage(userPhoto)
                                : AssetImage("assets/dummy-profile.png")
                                    as ImageProvider,
                          ),
                          title: Text(userName),
                          subtitle: Text(commentText),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: "Write a comment...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _postComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
