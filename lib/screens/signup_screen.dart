// ignore_for_file: avoid_print

import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:public_assist_hub/components/form_validation.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:public_assist_hub/components/loader_screen.dart';
import 'package:public_assist_hub/main.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:public_assist_hub/screens/login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _obscureTextConfirm = true;
  XFile? _selectedImage;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    fetchDistricts();
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

  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _addressEditingController =
      TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _passwordEditingController =
      TextEditingController();
  final TextEditingController _confirmPasswordEditingController =
      TextEditingController();
  final TextEditingController _contactEditingController =
      TextEditingController();

  String? selectedDistrict;
  String? selectedPlace;
  String? selectedLocalPlace;
  String? selectedMunicipality;

  List<Map<String, dynamic>> districts = [];
  List<Map<String, dynamic>> places = [];
  List<Map<String, dynamic>> localPlaces = [];
  List<Map<String, dynamic>> municipalities = [];

  void clearSelection() {
    selectedDistrict = null;
    selectedLocalPlace = null;
    selectedPlace = null;
    selectedMunicipality = null;
  }

  Future<void> fetchDistricts() async {
    clearSelection();
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await firebase.collection("tbl_district").get();

      // Extract district data into a list of maps
      if (querySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> response = querySnapshot.docs
            .map((doc) => {
                  'id': doc.id, // Document ID
                  'district_name':
                      doc['district_name'], // Field in the document
                })
            .toList();

        // Update the state with the fetched districts
        setState(() {
          districts = response;
        });
      } else {
        print("District Data is Empty");
      }
    } catch (e) {
      print("Error fetching districts: $e");
      CherryToast.error(
              description: Text("Something went wrong! Please try again.",
                  style: TextStyle(color: Colors.black)),
              animationType: AnimationType.fromRight,
              animationDuration: Duration(milliseconds: 1000),
              autoDismiss: true)
          .show(context);
    }
  }

  Future<void> fetchPlaces(String id) async {
    clearSelection();
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot = await firebase
          .collection("tbl_place")
          .where('district_id', isEqualTo: id)
          .get();

      // Extract place data into a list of maps
      if (querySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> response = querySnapshot.docs
            .map((doc) => {
                  'id': doc.id, // Document ID
                  'place_name': doc['place_name'], // Field in the document
                })
            .toList();
        print("Place: $response");
        // Update the state with the fetched places
        setState(() {
          places = response;
        });
      } else {
        print("Place data is empty");
      }
    } catch (e) {
      print("Error fetching places: $e");
      CherryToast.error(
              description: Text("Something went wrong! Please try again.",
                  style: TextStyle(color: Colors.black)),
              animationType: AnimationType.fromRight,
              animationDuration: Duration(milliseconds: 1000),
              autoDismiss: true)
          .show(context);
    }
  }

  Future<void> fetchMuncipalities(String id) async {
    clearSelection();
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot = await firebase
          .collection("tbl_municipality")
          .where('district_id', isEqualTo: id)
          .get();

      // Extract municipality data into a list of maps
      if (querySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> response = querySnapshot.docs
            .map((doc) => {
                  'id': doc.id, // Document ID
                  'municipality_name':
                      doc['municipality_name'], // Field in the document
                })
            .toList();

        // Update the state with the fetched municipalitys
        setState(() {
          municipalities = response;
        });
      } else {
        print("Municipality Data is empty");
      }
    } catch (e) {
      print("Error fetching places: $e");
      CherryToast.error(
              description: Text("Something went wrong! Please try again.",
                  style: TextStyle(color: Colors.black)),
              animationType: AnimationType.fromRight,
              animationDuration: Duration(milliseconds: 1000),
              autoDismiss: true)
          .show(context);
    }
  }

  Future<void> fetchLocal(String id) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot = await firebase
          .collection("tbl_local_place")
          .where('place_id', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> response = querySnapshot.docs
            .map((doc) => {
                  'id': doc.id, // Document ID
                  'localplace_name':
                      doc['localplace_name'], // Field in the document
                })
            .toList();
        // Update the state with the fetched places
        setState(() {
          localPlaces = response;
        });
      } else {
        print("Localplace Data is empty");
      }
    } catch (e) {
      print("Error fetching places: $e");
      CherryToast.error(
              description: Text("Something went wrong! Please try again.",
                  style: TextStyle(color: Colors.black)),
              animationType: AnimationType.fromRight,
              animationDuration: Duration(milliseconds: 1000),
              autoDismiss: true)
          .show(context);
    }
  }

  Future<void> register() async {
    Loader.showLoader(context);
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailEditingController.text,
        password: _passwordEditingController.text,
      );
      if (credential.user!.uid.isNotEmpty) {
        await storeData(credential.user!.uid);
      } else {
        Loader.hideLoader(context);
        print("Error User Authentication");
        CherryToast.error(
                description: Text("Something went wrong! Please try again.",
                    style: TextStyle(color: Colors.black)),
                animationType: AnimationType.fromRight,
                animationDuration: Duration(milliseconds: 1000),
                autoDismiss: true)
            .show(context);
      }
    } on FirebaseAuthException catch (e) {
      Loader.hideLoader(context);
      if (e.code == 'weak-password') {
        CherryToast.error(
                description: Text("The password provided is too weak",
                    style: TextStyle(color: Colors.black)),
                animationType: AnimationType.fromRight,
                animationDuration: Duration(milliseconds: 1000),
                autoDismiss: true)
            .show(context);
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        CherryToast.error(
                description: Text("The account already exists for that email.",
                    style: TextStyle(color: Colors.black)),
                animationType: AnimationType.fromRight,
                animationDuration: Duration(milliseconds: 1000),
                autoDismiss: true)
            .show(context);
        print('The account already exists for that email.');
      }
    } catch (e) {
      Loader.hideLoader(context);
      print(e);
      CherryToast.error(
              description: Text("Something went wrong! Please try again.",
                  style: TextStyle(color: Colors.black)),
              animationType: AnimationType.fromRight,
              animationDuration: Duration(milliseconds: 1000),
              autoDismiss: true)
          .show(context);
    }
  }

  Future<void> storeData(String uid) async {
    try {
      final user = <String, dynamic>{
        "user_name": _nameEditingController.text,
        "user_email": _emailEditingController.text,
        "user_contact": _contactEditingController.text,
        "user_address": _addressEditingController.text,
        "localplace_id": selectedLocalPlace,
        "municipality_id": selectedMunicipality,
        "user_photo": "",
        "user_password": _passwordEditingController.text,
      };
      await firebase
          .collection("tbl_user")
          .doc(uid)
          .set(user)
          .onError((e, _) => print("Error writing document: $e"));
      if (_selectedImage != null) {
        await uploadImage(uid);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(),
            ));
      } else {
        CherryToast.success(
                title: Text("User Registration Successful",
                    style: TextStyle(color: Colors.black)))
            .show(context);
      }
    } catch (e) {
      CherryToast.error(
              description: Text("Something went wrong! Please try again.",
                  style: TextStyle(color: Colors.black)),
              animationType: AnimationType.fromRight,
              animationDuration: Duration(milliseconds: 1000),
              autoDismiss: true)
          .show(context);
      print("Error storing data: $e");
    }
  }

  Future<void> uploadImage(String uid) async {
    try {
      final Reference ref =
          FirebaseStorage.instance.ref().child('User/user$uid.jpg');
      await ref.putFile(File(_selectedImage!.path));
      final imageUrl = await ref.getDownloadURL();
      await firebase
          .collection('tbl_user')
          .doc(uid)
          .update({'user_photo': imageUrl});

      CherryToast.success(
              title: Text("User Registration Successful",
                  style: TextStyle(color: Colors.black)))
          .show(context);
    } catch (e) {
      CherryToast.error(
              description: Text("Something went wrong! Please try again.",
                  style: TextStyle(color: Colors.black)),
              animationType: AnimationType.fromRight,
              animationDuration: Duration(milliseconds: 1000),
              autoDismiss: true)
          .show(context);
      print("Error uploading file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                // Welcome Text
                Text(
                  "Create Account",
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 44,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 5),
                Text(
                  "Register to get started",
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                // Form Fields
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: const Color(0xff4c505b),
                                backgroundImage: _selectedImage != null
                                    ? FileImage(File(_selectedImage!.path))
                                    : _imageUrl != null
                                        ? NetworkImage(_imageUrl!)
                                        : const AssetImage(
                                                'assets/dummy-profile.png')
                                            as ImageProvider,
                                child: _selectedImage == null &&
                                        _imageUrl == null
                                    ? const Icon(
                                        Icons.add,
                                        size: 40,
                                        color:
                                            Color.fromARGB(255, 134, 134, 134),
                                      )
                                    : null,
                              ),
                              if (_selectedImage != null || _imageUrl != null)
                                const Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: CircleAvatar(
                                    backgroundColor:
                                        Color.fromARGB(255, 139, 181, 203),
                                    radius: 18,
                                    child: Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        validator: (value) =>
                            FormValidation.validateName(value),
                        controller: _nameEditingController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Color(0xFF33A4BB),
                          ),
                          hintText: 'Enter Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 72, 72, 72),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFF33A4BB),
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.name,
                        cursorColor: const Color(0xFF33A4BB),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        validator: (value) =>
                            FormValidation.validateEmail(value),
                        controller: _emailEditingController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Color(0xFF33A4BB),
                          ),
                          hintText: 'Enter Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 72, 72, 72),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFF33A4BB),
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: const Color(0xFF33A4BB),
                      ),

                      const SizedBox(height: 20),
                      TextFormField(
                        validator: (value) =>
                            FormValidation.validateContact(value),
                        controller: _contactEditingController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.phone,
                            color: Color(0xFF33A4BB),
                          ),
                          hintText: 'Enter Contact Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 72, 72, 72),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFF33A4BB),
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        cursorColor: const Color(0xFF33A4BB),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        validator: (value) =>
                            FormValidation.validateAddress(value),
                        controller: _addressEditingController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.home,
                            color: Color(0xFF33A4BB),
                          ),
                          hintText: 'Enter Address',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 72, 72, 72),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFF33A4BB),
                            ),
                          ),
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        cursorColor: const Color(0xFF33A4BB),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        validator: (value) =>
                            FormValidation.validateDropdown(value),
                        value: selectedDistrict,
                        onChanged: (newValue) {
                          setState(() {
                            selectedDistrict = newValue;
                          });
                          fetchMuncipalities(newValue!);
                          fetchPlaces(newValue);
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.location_on,
                              color: Color(0xFF33A4BB)),
                          hintText: 'Select District',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 72, 72, 72)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Color(0xFF33A4BB)),
                          ),
                        ),
                        items: districts.map((district) {
                          return DropdownMenuItem<String>(
                            value: district[
                                'id'], // Use the document ID as the value
                            child: Text(district[
                                'district_name']), // Display the district name
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        validator: (value) =>
                            FormValidation.validateDropdown(value),
                        value: selectedPlace,
                        onChanged: (newValue) {
                          setState(() {
                            selectedPlace = newValue;
                          });
                          fetchLocal(newValue!);
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.location_city,
                              color: Color(0xFF33A4BB)),
                          hintText: 'Select Place',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 72, 72, 72)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Color(0xFF33A4BB)),
                          ),
                        ),
                        items: places.map((place) {
                          return DropdownMenuItem<String>(
                            value: place['id'],
                            child: Text(place['place_name']),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        validator: (value) =>
                            FormValidation.validateDropdown(value),
                        value: selectedLocalPlace,
                        onChanged: (newValue) {
                          setState(() {
                            selectedLocalPlace = newValue;
                          });
                        },
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.place, color: Color(0xFF33A4BB)),
                          hintText: 'Select Local Place',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 72, 72, 72)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Color(0xFF33A4BB)),
                          ),
                        ),
                        items: localPlaces.map((localPlace) {
                          return DropdownMenuItem<String>(
                            value: localPlace['id'],
                            child: Text(localPlace['localplace_name']),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        validator: (value) =>
                            FormValidation.validateDropdown(value),
                        value: selectedMunicipality,
                        onChanged: (newValue) {
                          setState(() {
                            selectedMunicipality = newValue;
                          });
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.domain,
                              color: Color(0xFF33A4BB)),
                          hintText: 'Select Municipality',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 72, 72, 72)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Color(0xFF33A4BB)),
                          ),
                        ),
                        items: municipalities.map((municipality) {
                          return DropdownMenuItem<String>(
                            value: municipality['id'],
                            child: Text(municipality['municipality_name']),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        validator: (value) =>
                            FormValidation.validatePassword(value),
                        controller: _passwordEditingController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Color(0xFF33A4BB),
                          ),
                          hintText: 'Enter Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 72, 72, 72),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFF33A4BB),
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color.fromARGB(255, 116, 116, 116),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                        keyboardType: TextInputType.visiblePassword,
                        cursorColor: const Color(0xFF33A4BB),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        validator: (value) =>
                            FormValidation.validateConfirmPassword(
                                value, _passwordEditingController.text),
                        controller: _confirmPasswordEditingController,
                        obscureText: _obscureTextConfirm,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Color(0xFF33A4BB),
                          ),
                          hintText: 'Confirm Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 72, 72, 72),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFF33A4BB),
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureTextConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color.fromARGB(255, 116, 116, 116),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureTextConfirm = !_obscureTextConfirm;
                              });
                            },
                          ),
                        ),
                        keyboardType: TextInputType.visiblePassword,
                        cursorColor: const Color(0xFF33A4BB),
                      ),
                      const SizedBox(height: 30),
                      // Sign Up Button
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  register();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF33A4BB),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                "Register",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Flexible(
                              child: Text("Already have an account? ",
                                  style: TextStyle(color: Colors.black))),
                          GestureDetector(
                            onTap: () {
                              // Navigate to login screen
                            },
                            child: const Text(
                              'Login here',
                              style: TextStyle(
                                color: Color(0xFF33A4BB),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
