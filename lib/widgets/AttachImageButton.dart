import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AttachImageButton extends StatelessWidget {
  final Function(XFile?) onImageSelected; // Callback to pass the selected image
  final ImagePicker _picker = ImagePicker(); // ImagePicker instance

  AttachImageButton({
    required this.onImageSelected, // Required callback for image selection
  });

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    onImageSelected(image); // Trigger the callback after image is picked
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: Icon(Icons.camera),

      label: Text('Attach Image'),
      onPressed: _pickImage, // Call the private _pickImage method
      style: OutlinedButton.styleFrom(
        fixedSize: Size(double.infinity, 50),
        side: BorderSide(color: Colors.grey),
      ),
    );
  }
}
