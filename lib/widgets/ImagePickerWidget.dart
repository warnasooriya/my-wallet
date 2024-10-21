import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Function to pick image from the camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  // Widget to build image picker buttons (camera and gallery)
  Widget buildImagePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () => _pickImage(ImageSource.camera), // Pick from camera
          icon: Icon(Icons.camera_alt),
          label: Text('Camera'),
        ),
        SizedBox(width: 20),
        ElevatedButton.icon(
          onPressed: () => _pickImage(ImageSource.gallery), // Pick from gallery
          icon: Icon(Icons.photo_library),
          label: Text('Gallery'),
        ),
      ],
    );
  }

  // Widget to display selected image
  Widget buildImagePreview() {
    return _imageFile != null
        ? kIsWeb
            ? Image.network(_imageFile!.path, height: 200, width: 200)
            : Image.file(File(_imageFile!.path), height: 200, width: 200)
        : Text('No image selected.');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildImagePicker(), // Show camera and gallery buttons
        SizedBox(height: 20),
        buildImagePreview(), // Show image preview
      ],
    );
  }
}
