import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:public_assist_hub/components/colors.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';

class CreateComplaintScreen extends StatefulWidget {
  final String entityType; // "Municipality", "PWD", "KSEB", "MVD"

  const CreateComplaintScreen({super.key, required this.entityType});

  @override
  State<CreateComplaintScreen> createState() => _CreateComplaintScreenState();
}

class _CreateComplaintScreenState extends State<CreateComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // Controllers and variables
  final TextEditingController _titleController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Dropdown selections
  String? _selectedDistrict;
  String? _selectedPlace; // Only for KSEB
  String? _selectedLocalPlace; // Only for KSEB
  String? _selectedEntityId;

  // Lists for dropdown options
  List<Map<String, dynamic>> districts = [];
  List<Map<String, dynamic>> places = []; // Only for KSEB
  List<Map<String, dynamic>> localPlaces = []; // Only for KSEB
  List<Map<String, dynamic>> entities = [];

  @override
  void initState() {
    super.initState();
    _fetchDistricts();
  }

  Future<void> _fetchDistricts() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('tbl_district').get();
      setState(() {
        districts = snapshot.docs.map((doc) => {
          'id': doc.id,
          'district_name': doc['district_name'],
        }).toList();
      });
    } catch (e) {
      _showErrorToast("Error fetching districts: $e");
    }
  }

  Future<void> _fetchPlaces(String districtId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('tbl_place')
          .where('district_id', isEqualTo: districtId)
          .get();
      setState(() {
        places = snapshot.docs.map((doc) => {
          'id': doc.id,
          'place_name': doc['place_name'],
        }).toList();
        _selectedPlace = null;
        _selectedLocalPlace = null;
        _selectedEntityId = null;
        entities.clear();
      });
    } catch (e) {
      _showErrorToast("Error fetching places: $e");
    }
  }

  Future<void> _fetchLocalPlaces(String placeId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('tbl_local_place')
          .where('place_id', isEqualTo: placeId)
          .get();
      setState(() {
        localPlaces = snapshot.docs.map((doc) => {
          'id': doc.id,
          'localplace_name': doc['localplace_name'],
        }).toList();
        _selectedLocalPlace = null;
        _selectedEntityId = null;
        entities.clear();
      });
    } catch (e) {
      _showErrorToast("Error fetching local places: $e");
    }
  }

  Future<void> _fetchEntities() async {
    String collectionName;
    String nameField;
    switch (widget.entityType) {
      case 'Municipality':
        collectionName = 'tbl_municipality';
        nameField = 'municipality_name';
        break;
      case 'PWD':
        collectionName = 'tbl_pwd';
        nameField = 'pwd_name';
        break;
      case 'KSEB':
        collectionName = 'tbl_kseb';
        nameField = 'kseb_name';
        break;
      case 'MVD':
        collectionName = 'tbl_mvd';
        nameField = 'mvd_name';
        break;
      default:
        return;
    }

    try {
      QuerySnapshot snapshot;
      if (widget.entityType == 'KSEB' && _selectedLocalPlace != null) {
        snapshot = await _firestore
            .collection(collectionName)
            .where('localplace_id', isEqualTo: _selectedLocalPlace)
            .get();
      } else {
        snapshot = await _firestore
            .collection(collectionName)
            .where('district_id', isEqualTo: _selectedDistrict)
            .get();
      }
      setState(() {
        entities = snapshot.docs.map((doc) => {
          'id': doc.id,
          'name': doc[nameField],
        }).toList();
        _selectedEntityId = null;
      });
    } catch (e) {
      _showErrorToast("Error fetching ${widget.entityType}: $e");
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_image == null) return null;
    String fileName = 'complaint_${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('OfficialComplaint/$uid/$fileName');

    UploadTask uploadTask = storageRef.putFile(_image!);
    await uploadTask;
    return await storageRef.getDownloadURL();
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate() || _selectedEntityId == null || _image == null) {
      _showErrorToast('Please select an entity, add a title, and upload an image');
      return;
    }

    setState(() => _isLoading = true);
    try {
      String? imageUrl = await _uploadImage();

      Map<String, dynamic> complaintData = {
        'complaint_title': _titleController.text,
        'complaint_photo': imageUrl ?? '',
        'complaint_date': FieldValue.serverTimestamp(),
        'complaint_status': 0, // Pending
        'complaint_reply': '',
        'user_id': uid,
        'municipality_id': widget.entityType == 'Municipality' ? _selectedEntityId : '',
        'pwd_id': widget.entityType == 'PWD' ? _selectedEntityId : '',
        'kseb_id': widget.entityType == 'KSEB' ? _selectedEntityId : '',
        'mvd_id': widget.entityType == 'MVD' ? _selectedEntityId : '',
      };

      await _firestore.collection('tbl_complaint').add(complaintData);

      _showSuccessToast('Complaint posted successfully');
      Navigator.pop(context);
    } catch (e) {
      _showErrorToast('Error posting complaint: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessToast(String message) {
    CherryToast.success(title: Text(message, style: const TextStyle(color: Colors.black))).show(context);
  }

  void _showErrorToast(String message) {
    CherryToast.error(
      description: Text(message, style: const TextStyle(color: Colors.black)),
      animationType: AnimationType.fromRight,
      animationDuration: const Duration(milliseconds: 1000),
      autoDismiss: true,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post ${widget.entityType} Complaint',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: MyColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // District Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedDistrict,
                      onChanged: (value) {
                        setState(() {
                          _selectedDistrict = value;
                          if (widget.entityType == 'KSEB') {
                            _fetchPlaces(value!);
                          } else {
                            _fetchEntities();
                          }
                        });
                      },
                      decoration: _inputDecoration('Select District', Icons.location_on),
                      items: districts.map((district) {
                        return DropdownMenuItem<String>(
                          value: district['id'],
                          child: Text(district['district_name']),
                        );
                      }).toList(),
                      validator: (value) => value == null ? 'Please select a district' : null,
                    ),
                    const SizedBox(height: 20),

                    // Place Dropdown (KSEB only)
                    if (widget.entityType == 'KSEB') ...[
                      DropdownButtonFormField<String>(
                        value: _selectedPlace,
                        onChanged: (value) {
                          setState(() {
                            _selectedPlace = value;
                            _fetchLocalPlaces(value!);
                          });
                        },
                        decoration: _inputDecoration('Select Place', Icons.location_city),
                        items: places.map((place) {
                          return DropdownMenuItem<String>(
                            value: place['id'],
                            child: Text(place['place_name']),
                          );
                        }).toList(),
                        validator: (value) => value == null ? 'Please select a place' : null,
                      ),
                      const SizedBox(height: 20),

                      // Local Place Dropdown (KSEB only)
                      DropdownButtonFormField<String>(
                        value: _selectedLocalPlace,
                        onChanged: (value) {
                          setState(() {
                            _selectedLocalPlace = value;
                            _fetchEntities();
                          });
                        },
                        decoration: _inputDecoration('Select Local Place', Icons.place),
                        items: localPlaces.map((localPlace) {
                          return DropdownMenuItem<String>(
                            value: localPlace['id'],
                            child: Text(localPlace['localplace_name']),
                          );
                        }).toList(),
                        validator: (value) => value == null ? 'Please select a local place' : null,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Entity Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedEntityId,
                      onChanged: (value) => setState(() => _selectedEntityId = value),
                      decoration: _inputDecoration('Select ${widget.entityType}', Icons.domain),
                      items: entities.map((entity) {
                        return DropdownMenuItem<String>(
                          value: entity['id'],
                          child: Text(entity['name']),
                        );
                      }).toList(),
                      validator: (value) => value == null ? 'Please select a ${widget.entityType}' : null,
                    ),
                    const SizedBox(height: 20),

                    // Image Picker
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: MyColors.primary),
                        ),
                        child: _image == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, size: 50, color: Colors.grey[600]),
                                  const SizedBox(height: 10),
                                  Text('Tap to add an image',
                                      style: GoogleFonts.poppins(color: Colors.grey[600])),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(_image!, fit: BoxFit.cover),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Complaint Title
                    TextFormField(
                      controller: _titleController,
                      decoration: _inputDecoration('Complaint Title', Icons.title),
                      validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitComplaint,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Submit Complaint',
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
              ),
            ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: MyColors.primary),
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: MyColors.primary),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}