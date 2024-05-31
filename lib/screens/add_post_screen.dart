import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPostScreen extends StatefulWidget {
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State {
  TextEditingController _postTextController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  String? _imageUrl;

  Future _getImageFromCamera() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _imageUrl = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Post'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'Enter your username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                _getImageFromCamera();
              },
              child: Container(
                height: 200,
                color: Colors.grey[200],
                child: _imageUrl != null
                    ? Image.network(
                  _imageUrl!,
                  fit: BoxFit.cover,
                )
                    : Icon(
                  Icons.camera_alt,
                  size: 100,
                  color: Colors.grey[400],
                ),
                alignment: Alignment.center,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _postTextController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Write your post here...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
// Check if post text, image, and username are provided
                if (_postTextController.text.isNotEmpty &&
                    _imageUrl != null &&
                    _usernameController.text.isNotEmpty) {
// Save the post to Firestore
                  FirebaseFirestore.instance.collection('posts').add({
                    'text': _postTextController.text,
                    'image_url': _imageUrl,
                    'username': _usernameController.text,
                    'timestamp': Timestamp.now(),
                  }).then((_) {
// If save is successful, go back to the previous screen
                    Navigator.pop(context);
                  }).catchError((error) {
// If there's an error, show an error message
                    print('Error saving post: $error');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to save post. Please try again.'),
                      ),
                    );
                  });
                } else {
// If post text, image, or username is not provided, show a message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Please write a post, select an image, and enter your username.'),
                    ),
                  );
                }
              },
              child: Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}