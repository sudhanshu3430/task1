import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'home_screen.dart'; // Import the HomeScreen class

class NewScreen extends StatefulWidget {
  final String accessToken;

  NewScreen({required this.accessToken});

  @override
  _NewScreenState createState() => _NewScreenState();
}

class _NewScreenState extends State<NewScreen> {
  File? _imageFile;

  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _cardExpirationController = TextEditingController();
  TextEditingController _cardHolderController = TextEditingController();
  TextEditingController _cardNumberController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();

  void _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final apiUrl = 'https://interview-api.onrender.com/v1/cards';
      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${widget.accessToken}',
      };

      final response = await http.post(Uri.parse(apiUrl),
          headers: headers,
          body: jsonEncode(<String, dynamic>{
            "name": _nameController.text,
            "cardExpiration": _cardExpirationController.text,
            "cardHolder": _cardHolderController.text,
            "cardNumber": _cardNumberController.text,
            "category": _categoryController.text,
          }));

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final String id = responseData['id'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Card added successfully')),
        );

        // Delay navigation to allow user to see the Snackbar
        await Future.delayed(Duration(seconds: 2));

        // Navigate to the home screen and replace the current screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              accessToken: widget.accessToken,
              newCardId: id,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create card')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Card'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              color: Colors.grey[300],
              child: _imageFile != null
                  ? Image.file(_imageFile!)
                  : IconButton(
                      icon: Icon(Icons.file_upload),
                      onPressed: _pickImage,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _cardExpirationController,
                      decoration: InputDecoration(labelText: 'Card Expiration'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter card expiration';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _cardHolderController,
                      decoration: InputDecoration(labelText: 'Card Holder'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter card holder';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _cardNumberController,
                      decoration: InputDecoration(labelText: 'Card Number'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter card number';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _categoryController,
                      decoration: InputDecoration(labelText: 'Category'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter category';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
