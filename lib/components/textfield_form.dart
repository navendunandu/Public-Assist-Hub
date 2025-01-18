import 'package:flutter/material.dart';

class TextfieldFormApp extends StatefulWidget {
  final String label;
  final TextEditingController textController;
  bool obscureText = false;
  final IconData icon;
  TextfieldFormApp({super.key, required this.label, required this.icon, required this.textController});

  @override
  State<TextfieldFormApp> createState() => _TextfieldFormAppState();
}

class _TextfieldFormAppState extends State<TextfieldFormApp> {
   bool _obscureText = true;

  final TextEditingController _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return TextFormField(
                      style: const TextStyle(color: Colors.white),
                      controller: widget.textController,
                      obscureText: widget.obscureText,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          widget.icon,
                          color: Color(0xFF33A4BB),
                        ),
                        hintText: widget.label,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(

                            color: Color.fromARGB(255, 72, 72, 72),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF33A4BB), // Color when focused
                          ),
                        ),
                        suffixIcon: widget.obscureText ? IconButton(
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
                        ): null,
                      ),
                      cursorColor: Color(0xFF33A4BB),
                    );
  }
}