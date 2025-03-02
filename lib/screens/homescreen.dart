import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:public_assist_hub/components/colors.dart';
import 'package:public_assist_hub/screens/comment_screen.dart';
import 'package:public_assist_hub/screens/create_complaint_screen.dart';
import 'package:public_assist_hub/screens/create_post_screen.dart';
import 'package:public_assist_hub/screens/my_complaints_screen.dart';
import 'package:public_assist_hub/screens/profile_screen.dart';
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

  Set<String> likedPosts = {};

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
      await likesRef.doc(likeSnapshot.docs.first.id).delete();
    } else {
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
      if (kDebugMode) {
        print("Error Loading User: $e");
      }
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const Text(
                "Select an Option",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 10,
                crossAxisSpacing: 20,
                children: [
                  _buildGridOption("Electricity", Icons.electric_bolt, context),
                  _buildGridOption(
                      "Municipality", Icons.location_city, context),
                  _buildGridOption("Public Work", Icons.build, context),
                  _buildGridOption(
                      "Motor Vehicle", Icons.directions_car, context),
                ],
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyComplaintsScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'View My Complaints',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridOption(String title, IconData icon, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        if (title == "My Complaints") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyComplaintsScreen()),
          );
        } else {
          String entityType;
          switch (title) {
            case "Electricity":
              entityType = "KSEB";
              break;
            case "Municipality":
              entityType = "Municipality";
              break;
            case "Public Work":
              entityType = "PWD";
              break;
            case "Motor Vehicle":
              entityType = "MVD";
              break;
            default:
              return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CreateComplaintScreen(entityType: entityType),
            ),
          );
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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
          SizedBox(height: 20),
          Text(
            "Public Assist Hub",
            style: GoogleFonts.poppins(
              color: MyColors.primary,
              fontSize: 36,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: MyColors.primary.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello,",
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              userName,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfileScreen()),
                      );
                    },
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      backgroundImage: imageUrl == null
                          ? AssetImage("assets/dummy-profile.png")
                          : NetworkImage(imageUrl!),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 40,
            thickness: 1,
            color: Colors.grey[300],
          ),
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

                  var postDateRaw = post['post_date'];
                  var postDate = postDateRaw != null
                      ? postDateRaw.toDate()
                      : DateTime.now();
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
                      var userName = userData['user_name'];
                      var userPhoto = userData['user_photo'];

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                            if (postPhoto.isNotEmpty)
                              Image.network(
                                postPhoto,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
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
                                                      : Colors.black,
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'report_fab',
            onPressed: () => _showBottomSheet(context),
            backgroundColor: Colors.redAccent,
            tooltip: "Report Issue",
            child: Icon(Icons.warning_amber_rounded, color: Colors.white),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'photo_fab',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreatePostScreen()),
              );
            },
            backgroundColor: MyColors.primary,
            tooltip: "Add New Post",
            child: Icon(Icons.add_a_photo_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
