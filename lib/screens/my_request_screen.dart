import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:public_assist_hub/components/colors.dart';

class MyRequestScreen extends StatefulWidget {
  const MyRequestScreen({super.key});

  @override
  State<MyRequestScreen> createState() => _MyRequestScreenState();
}

class _MyRequestScreenState extends State<MyRequestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 4, vsync: this); 
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Request',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: MyColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              GoogleFonts.poppins(fontWeight: FontWeight.w400),
          tabs: const [
            Tab(text: 'Municipality'),
            Tab(text: 'PWD'),
            Tab(text: 'KSEB'),
            Tab(text: 'MVD'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildComplaintList(firestore, uid, 'municipality_id',
              'tbl_municipality', 'municipality_name'),
          _buildComplaintList(firestore, uid, 'pwd_id', 'tbl_pwd', 'pwd_name'),
          _buildComplaintList(
              firestore, uid, 'kseb_id', 'tbl_kseb', 'kseb_name'),
          _buildComplaintList(firestore, uid, 'mvd_id', 'tbl_mvd', 'mvd_name'),
        ],
      ),
    );
  }

  Widget _buildComplaintList(
    FirebaseFirestore firestore,
    String uid,
    String entityIdField,
    String entityCollection,
    String entityNameField,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('tbl_request')
          .where('user_id', isEqualTo: uid)
          .where(entityIdField, isNotEqualTo: '') 
          .orderBy('request_date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text('No crequests found for this category.'));
        }

        return ListView.separated(
          separatorBuilder: (context, index) => const Divider(),
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var request = snapshot.data!.docs[index];
            var requestContent = request['request_description'];
            var requestDateRaw = request['request_date'];
            var requestDate = requestDateRaw != null
                ? requestDateRaw.toDate()
                : DateTime.now();
            var requestPhoto = request['request_photo'];
            var requestReply = request['request_reply'];
            var requestStatus = request['request_status'];
            var entityId = request[entityIdField];

            return FutureBuilder<DocumentSnapshot>(
              future:
                  firestore.collection(entityCollection).doc(entityId).get(),
              builder: (context, entitySnapshot) {
                if (entitySnapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()));
                }
                if (entitySnapshot.hasError ||
                    !entitySnapshot.hasData ||
                    !entitySnapshot.data!.exists) {
                  return const SizedBox.shrink(); 
                }

                var entityName = entitySnapshot.data![entityNameField];

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (requestPhoto.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              requestPhoto,
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(height: 10),
                        Text(
                          requestContent,
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w300),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'To: $entityName',
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 5),
                        if (requestReply.isNotEmpty)
                          Text(
                            'Reply: $requestReply',
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: Colors.blueGrey),
                          ),
                        const SizedBox(height: 5),
                        Text(
                          'Status: ${requestStatus == 0 ? "Pending" : requestStatus == 1 ? "In Progress" : "Resolved"}',
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: requestStatus == 0
                                  ? Colors.red
                                  : requestStatus == 1
                                      ? Colors.orange
                                      : Colors.green),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          DateFormat('MMMM dd, yyyy - hh:mm a')
                              .format(requestDate),
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
