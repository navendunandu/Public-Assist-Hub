import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:public_assist_hub/components/form_validation.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _obscureText = true;
  bool _obscureTextConfirm = true;

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

  List<String> districts = ["District 1", "District 2", "District 3"];
  List<String> places = ["Place 1", "Place 2", "Place 3"];
  List<String> localPlaces = [
    "Local Place 1",
    "Local Place 2",
    "Local Place 3"
  ];
  List<String> municipalities = [
    "Municipality 1",
    "Municipality 2",
    "Municipality 3"
  ];

  Future<void> register() async {
    // Registration logic goes here
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
                const SizedBox(height: 50),
                // Form Fields
                Column(
                  children: [
                    TextFormField(
                      validator:(value) => FormValidation.validateName(value),
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
                      cursorColor: const Color(0xFF33A4BB),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      validator: (value) => FormValidation.validateAddress(value),
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
                      cursorColor: const Color(0xFF33A4BB),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      validator: (value) => FormValidation.validateEmail(value),
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
                      cursorColor: const Color(0xFF33A4BB),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      validator:(value) =>  FormValidation.validatePassword(value),
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
                            color: Colors.white38,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      cursorColor: const Color(0xFF33A4BB),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      validator: (value) => FormValidation.validateConfirmPassword(value, _passwordEditingController.text),
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
                            color: Colors.white38,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureTextConfirm = !_obscureTextConfirm;
                            });
                          },
                        ),
                      ),
                      cursorColor: const Color(0xFF33A4BB),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      validator:(value) => FormValidation.validateContact(value),
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
                      cursorColor: const Color(0xFF33A4BB),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      
                      value: selectedDistrict,
                      onChanged: (newValue) {
                        setState(() {
                          selectedDistrict = newValue;
                        });
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
                          value: district,
                          child: Text(district),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: selectedPlace,
                      onChanged: (newValue) {
                        setState(() {
                          selectedPlace = newValue;
                        });
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
                          value: place,
                          child: Text(place),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: selectedLocalPlace,
                      onChanged: (newValue) {
                        setState(() {
                          selectedLocalPlace = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.place, color: Color(0xFF33A4BB)),
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
                          value: localPlace,
                          child: Text(localPlace),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: selectedMunicipality,
                      onChanged: (newValue) {
                        setState(() {
                          selectedMunicipality = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.domain, color: Color(0xFF33A4BB)),
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
                          value: municipality,
                          child: Text(municipality),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    // Sign Up Button
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              register();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF33A4BB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
