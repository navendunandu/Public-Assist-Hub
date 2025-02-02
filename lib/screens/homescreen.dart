import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:public_assist_hub/components/colors.dart';
import 'package:public_assist_hub/screens/comment_screen.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? imageUrl;
  String userName = "";

  Set<String> likedPosts = {}; // Stores post IDs that the user liked

  Future<void> _fetchLikedPosts() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot likeSnapshot = await _firestore
        .collection('tbl_like')
        .where('user_id', isEqualTo: uid)
        .get();

    setState(() {
      likedPosts =
          likeSnapshot.docs.map((doc) => doc['post_id'] as String).toSet();
    });
  }

  Future<void> _toggleLike(String postId) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference likesRef = _firestore.collection('tbl_like');

    QuerySnapshot likeSnapshot = await likesRef
        .where('user_id', isEqualTo: uid)
        .where('post_id', isEqualTo: postId)
        .get();

    if (likeSnapshot.docs.isNotEmpty) {
      // Unlike (remove from Firestore)
      await likesRef.doc(likeSnapshot.docs.first.id).delete();
    } else {
      // Like (add to Firestore)
      await likesRef.add({
        'user_id': uid,
        'post_id': postId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

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
          userName = userDoc.get('user_name') ?? 'Error Loading';
          imageUrl = userDoc.get('user_photo');
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
    _fetchLikedPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        shrinkWrap: true,
        children: [
          // Welcome Message
          SizedBox(
            height: 20,
          ),
          Text(
            "Public Service Hub",
            style: GoogleFonts.poppins(
              color: MyColors.primary,
              fontSize: 40,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
                color: MyColors.primary,
                borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16.0),
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    radius: 38,
                    backgroundImage: imageUrl == null
                        ? AssetImage("assets/dummy-profile.png")
                        : NetworkImage(imageUrl!),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Hello,",
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 28),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                                side: BorderSide(color: Colors.white)),
                            onPressed: () {},
                            label: Text(
                              "Report an Issue",
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                            icon: Icon(
                              Icons.report_gmailerrorred,
                              color: Colors.white,
                              size: 24,
                            ),
                          )
                        ],
                      ),
                      Text(
                        userName,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          // Posts List
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('tbl_post')
                .orderBy('post_date', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No posts found.'));
              }

              return ListView.separated(
                separatorBuilder: (context, index) => Divider(),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var post = snapshot.data!.docs[index];
                  var postCaption = post['post_caption'];
                  var postDate = post['post_date'].toDate();
                  var postDescription = post['post_description'];
                  var postPhoto = post['post_photo'];
                  var userId = post['user_id'];

                  return FutureBuilder<DocumentSnapshot>(
                    future: _firestore.collection('tbl_user').doc(userId).get(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              height: 400,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        );
                      }
                      if (userSnapshot.hasError) {
                        return ListTile(
                          title: Text('Error: ${userSnapshot.error}'),
                        );
                      }
                      if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                        return const ListTile(
                          title: Text('User not found.'),
                        );
                      }

                      var userData = userSnapshot.data!;
                      var userName = userData[
                          'user_name']; // Assuming 'name' is stored in tbl_user
                      var userPhoto = userData[
                          'user_photo']; // Assuming 'photo_url' is stored in tbl_user

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User Info
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(userPhoto),
                                    radius: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Post Image
                            if (postPhoto.isNotEmpty)
                              Image.network(
                                postPhoto,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            // Post Caption and Description
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      StreamBuilder<QuerySnapshot>(
                                        stream: _firestore
                                            .collection('tbl_like')
                                            .where('post_id',
                                                isEqualTo: post.id)
                                            .snapshots(),
                                        builder: (context, likeSnapshot) {
                                          if (!likeSnapshot.hasData) {
                                            return const Text("0 Likes");
                                          }

                                          int likeCount =
                                              likeSnapshot.data!.docs.length;
                                          bool isLiked = likeSnapshot.data!.docs
                                              .any((doc) =>
                                                  doc['user_id'] ==
                                                  FirebaseAuth.instance
                                                      .currentUser!.uid);

                                          return Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                onPressed: () =>
                                                    _toggleLike(post.id),
                                                icon: Icon(
                                                  isLiked
                                                      ? Icons.favorite
                                                      : Icons.favorite_outline,
                                                  color: isLiked
                                                      ? Colors.red
                                                      : Colors
                                                          .black, // Changes dynamically
                                                ),
                                              ),
                                              Text(
                                                "($likeCount)",
                                                style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              IconButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              CommentScreen(
                                                                  postId:
                                                                      post.id),
                                                        ));
                                                  },
                                                  icon: Icon(Icons.comment))
                                            ],
                                          );
                                        },
                                      ),
                                      Text(
                                        DateFormat('MMMM dd, yyyy - hh:mm a')
                                            .format(postDate),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    postCaption,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    postDescription,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(
          Icons.add_a_photo_outlined,
          color: Colors.white,
        ),
        tooltip: "Add new Post",
        backgroundColor: MyColors.primary,
      ),
    );
  }
}
