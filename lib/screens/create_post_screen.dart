import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:public_assist_hub/components/colors.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

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
    String fileName = 'post_${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference storageRef =
        FirebaseStorage.instance.ref().child('Post/$fileName');

    UploadTask uploadTask = storageRef.putFile(_image!);
    await uploadTask;
    return await storageRef.getDownloadURL();
  }

  Future<void> _submitPost() async {
    if (_captionController.text.isEmpty || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a caption and an image')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      String? imageUrl = await _uploadImage();
      String uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('tbl_post').add({
        'post_caption': _captionController.text,
        'post_description': _descriptionController.text,
        'post_photo': imageUrl ?? '',
        'user_id': uid,
        'post_date': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Post',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: MyColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          Icon(Icons.add_a_photo,
                              size: 50, color: Colors.grey[600]),
                          const SizedBox(height: 10),
                          Text(
                            'Tap to add an image',
                            style: GoogleFonts.poppins(color: Colors.grey[600]),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Caption',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: _captionController,
              decoration: InputDecoration(
                hintText: 'Enter a caption...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Description',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter a description...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Post',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
