import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:public_assist_hub/components/colors.dart';
import 'package:public_assist_hub/components/form_validation.dart';
import 'package:public_assist_hub/screens/change_password_screen.dart'; // New import
import 'package:public_assist_hub/screens/login_screen.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _contactController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  XFile? _selectedImage;
  String? _imageUrl;

  String? _selectedDistrict;
  String? _selectedPlace;
  String? _selectedLocalPlace;
  String? _selectedMunicipality;

  List<Map<String, dynamic>> districts = [];
  List<Map<String, dynamic>> places = [];
  List<Map<String, dynamic>> localPlaces = [];
  List<Map<String, dynamic>> municipalities = [];

  bool _isEditing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchDistricts();
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('tbl_user').doc(uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['user_name'] ?? '';
          _emailController.text = data['user_email'] ?? '';
          _contactController.text = data['user_contact'] ?? '';
          _addressController.text = data['user_address'] ?? '';
          _imageUrl = data['user_photo'];
          _selectedLocalPlace = data['localplace_id'];
          _selectedMunicipality = data['municipality_id'];
          _isLoading = false;
        });
        await _fetchMunicipalityAndPlace();
      }
    } catch (e) {
      print("Error fetching user data: $e");
      _showErrorToast("Failed to load profile");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchDistricts() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('tbl_district').get();
      setState(() {
        districts = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'district_name': doc['district_name'],
                })
            .toList();
      });
    } catch (e) {
      print("Error fetching districts: $e");
    }
  }

  Future<void> _fetchPlaces(String districtId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('tbl_place')
          .where('district_id', isEqualTo: districtId)
          .get();
      setState(() {
        places = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'place_name': doc['place_name'],
                })
            .toList();
      });
    } catch (e) {
      print("Error fetching places: $e");
    }
  }

  Future<void> _fetchLocalPlaces(String placeId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('tbl_local_place')
          .where('place_id', isEqualTo: placeId)
          .get();
      setState(() {
        localPlaces = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'localplace_name': doc['localplace_name'],
                })
            .toList();
      });
    } catch (e) {
      print("Error fetching local places: $e");
    }
  }

  Future<void> _fetchMunicipalities(String districtId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('tbl_municipality')
          .where('district_id', isEqualTo: districtId)
          .get();
      setState(() {
        municipalities = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'municipality_name': doc['municipality_name'],
                })
            .toList();
      });
    } catch (e) {
      print("Error fetching municipalities: $e");
    }
  }

  Future<void> _fetchMunicipalityAndPlace() async {
    if (_selectedLocalPlace != null) {
      DocumentSnapshot localPlaceDoc = await _firestore
          .collection('tbl_local_place')
          .doc(_selectedLocalPlace)
          .get();
      if (localPlaceDoc.exists) {
        String placeId = localPlaceDoc['place_id'];
        setState(() => _selectedPlace = placeId);
        DocumentSnapshot placeDoc =
            await _firestore.collection('tbl_place').doc(placeId).get();
        if (placeDoc.exists) {
          String districtId = placeDoc['district_id'];
          setState(() => _selectedDistrict = districtId);
          await _fetchPlaces(districtId);
          await _fetchLocalPlaces(placeId);
          await _fetchMunicipalities(districtId);
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = XFile(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      String? newImageUrl = _imageUrl;
      if (_selectedImage != null) {
        final ref = FirebaseStorage.instance.ref().child('User/user$uid.jpg');
        await ref.putFile(File(_selectedImage!.path));
        newImageUrl = await ref.getDownloadURL();
      }

      await _firestore.collection('tbl_user').doc(uid).update({
        'user_name': _nameController.text,
        'user_email': _emailController.text,
        'user_contact': _contactController.text,
        'user_address': _addressController.text,
        'localplace_id': _selectedLocalPlace,
        'municipality_id': _selectedMunicipality,
        'user_photo': newImageUrl,
      });

      setState(() => _isEditing = false);
      _showSuccessToast("Profile updated successfully");
    } catch (e) {
      print("Error updating profile: $e");
      _showErrorToast("Failed to update profile: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      print("Error signing out: $e");
      _showErrorToast("Failed to sign out");
    }
  }

  void _showSuccessToast(String message) {
    CherryToast.success(
      title: Text(message, style: const TextStyle(color: Colors.black)),
    ).show(context);
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
        title: Text('Profile',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: MyColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _updateProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _isEditing ? _pickImage : null,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: _selectedImage != null
                                  ? FileImage(File(_selectedImage!.path))
                                  : _imageUrl != null
                                      ? NetworkImage(_imageUrl!)
                                      : const AssetImage(
                                              'assets/dummy-profile.png')
                                          as ImageProvider,
                            ),
                            if (_isEditing)
                              const Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Color(0xFF33A4BB),
                                  child: Icon(Icons.edit,
                                      size: 18, color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      enabled: _isEditing,
                      validator: FormValidation.validateName,
                      decoration: _inputDecoration('Name', Icons.person),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      enabled: false,
                      decoration: _inputDecoration('Email', Icons.email),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _contactController,
                      enabled: _isEditing,
                      validator: FormValidation.validateContact,
                      decoration:
                          _inputDecoration('Contact Number', Icons.phone),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _addressController,
                      enabled: _isEditing,
                      validator: FormValidation.validateAddress,
                      decoration: _inputDecoration('Address', Icons.home),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedDistrict,
                      onChanged: _isEditing
                          ? (value) {
                              setState(() {
                                _selectedDistrict = value;
                                _selectedPlace = null;
                                _selectedLocalPlace = null;
                                _selectedMunicipality = null;
                                _fetchPlaces(value!);
                                _fetchMunicipalities(value);
                              });
                            }
                          : null,
                      validator: FormValidation.validateDropdown,
                      decoration:
                          _inputDecoration('District', Icons.location_on),
                      items: districts.map((district) {
                        return DropdownMenuItem<String>(
                          value: district['id'],
                          child: Text(district['district_name']),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedPlace,
                      onChanged: _isEditing
                          ? (value) {
                              setState(() {
                                _selectedPlace = value;
                                _selectedLocalPlace = null;
                                _fetchLocalPlaces(value!);
                              });
                            }
                          : null,
                      validator: FormValidation.validateDropdown,
                      decoration:
                          _inputDecoration('Place', Icons.location_city),
                      items: places.map((place) {
                        return DropdownMenuItem<String>(
                          value: place['id'],
                          child: Text(place['place_name']),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedLocalPlace,
                      onChanged: _isEditing
                          ? (value) =>
                              setState(() => _selectedLocalPlace = value)
                          : null,
                      validator: FormValidation.validateDropdown,
                      decoration: _inputDecoration('Local Place', Icons.place),
                      items: localPlaces.map((localPlace) {
                        return DropdownMenuItem<String>(
                          value: localPlace['id'],
                          child: Text(localPlace['localplace_name']),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedMunicipality,
                      onChanged: _isEditing
                          ? (value) =>
                              setState(() => _selectedMunicipality = value)
                          : null,
                      validator: FormValidation.validateDropdown,
                      decoration:
                          _inputDecoration('Municipality', Icons.domain),
                      items: municipalities.map((municipality) {
                        return DropdownMenuItem<String>(
                          value: municipality['id'],
                          child: Text(municipality['municipality_name']),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ChangePasswordScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Change Password',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _signOut,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Sign Out',
                          style: GoogleFonts.poppins(
                            color: Colors.red,
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
      prefixIcon: Icon(icon, color: const Color(0xFF33A4BB)),
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color.fromARGB(255, 72, 72, 72)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF33A4BB)),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
