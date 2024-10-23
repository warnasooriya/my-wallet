import 'package:flutter/material.dart';
import 'package:myfinanceapp/services/auth_service.dart';
import 'package:myfinanceapp/services/income_type_service.dart'; // Change this to Income Type Service
import 'package:myfinanceapp/utils/constants.dart';
import 'package:myfinanceapp/widgets/BuildElevatedButton.dart';
import 'package:myfinanceapp/widgets/BuildTextField.dart';
import 'package:uuid/uuid.dart';

class IncomeTypesScreen extends StatefulWidget {
  @override
  _IncomeTypesScreenState createState() => _IncomeTypesScreenState();
}

class _IncomeTypesScreenState extends State<IncomeTypesScreen> {
  final _incomeTypeController = TextEditingController();
  final _descriptionController = TextEditingController();
  var uuid = Uuid();
  final IncomeTypeService _incomeTypeService =
      IncomeTypeService(); // Using Income Type Service
  List<Map<String, dynamic>> _incomeTypes =
      []; // To hold the list of income types

  @override
  void initState() {
    super.initState();
    _loadIncomeTypes(); // Load the income types when the screen is initialized
  }

  // Method to load the income types from the service
  Future<void> _loadIncomeTypes() async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user != null) {
        final incomes = await _incomeTypeService.getItemsForUser(user['uid']!);
        setState(() {
          _incomeTypes = List.from(incomes); // Create a modifiable list
        });
      }
    } catch (e) {
      print('Error loading income types: $e');
    }
  }

  // Submit method to add a new income type
  Future<void> _submitIncomeType() async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user == null) return;

      // Check for empty fields
      if (_incomeTypeController.text.trim() == '' ||
          _descriptionController.text.trim() == '') {
        _showSnackbar('Please fill out both Income Type and Description');
        return;
      }

      final incomeType = {
        'id': uuid.v4(),
        'name': _incomeTypeController.text.trim(),
        'description': _descriptionController.text.trim(),
        'userId': user['uid'],
      };

      final int result = await _incomeTypeService.insertIncomeType(incomeType);

      if (result > 0) {
        _clearForm();
        _showSnackbar('Income type added successfully');
        await _loadIncomeTypes(); // Reload the list after adding
      } else {
        _showSnackbar('Failed to add income type');
      }
    } catch (e) {
      _showSnackbar('Error adding income type: $e');
    }
  }

  // Clear the form fields
  void _clearForm() {
    _incomeTypeController.clear();
    _descriptionController.clear();
  }

  // Show a SnackBar with feedback
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Confirmation'),
          content: Text('Are you sure you want to delete this income type?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Method to delete the income type
  Future<bool> _deleteIncomeType(String id, int index, String userId) async {
    bool status = false;
    final bool? confirmed = await _showDeleteConfirmationDialog();
    if (confirmed == null || !confirmed) return false;
    try {
      // Proceed with deletion after confirmation
      final result = await _incomeTypeService.delete(id, userId);

      if (result > 0) {
        // Only remove the item from the list if the deletion was successful
        status = true;
      } else {
        _showSnackbar('Failed to delete income type');
      }
    } catch (e) {
      _showSnackbar('Error deleting income type');
    }
    return status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Income Types'),
        backgroundColor:
            primaryColor, // Assuming primaryColor is defined in constants.dart
        foregroundColor:
            headerTextColor, // Assuming headerTextColor is defined in constants.dart
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              _buildFormCard(),
              SizedBox(height: 20),
              _buildIncomeList(),
            ],
          ),
        ),
      ),
    );
  }

  // Build the form card for Income Type and Description
  Widget _buildFormCard() {
    return Card(
      elevation: 25,
      margin: EdgeInsets.all(3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
            BuildTextField(
              _incomeTypeController,
              'Income Type',
              TextInputType.text,
            ),
            SizedBox(height: 20),
            BuildTextField(
              _descriptionController,
              'Description',
              TextInputType.multiline,
            ),
            SizedBox(height: 20),
            CustomElevatedButton(
              onPressed: _submitIncomeType,
              buttonText: 'Save Income Type',
            ),
          ],
        ),
      ),
    );
  }

  // Build the income type list
  Widget _buildIncomeList() {
    return _incomeTypes.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _incomeTypes.length,
            itemBuilder: (context, index) {
              final incomeType = _incomeTypes[index];
              return Card(
                elevation: 4,
                child: ListTile(
                  title: Text(incomeType['name']),
                  subtitle: Text(incomeType['description']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete,
                        color: const Color.fromARGB(255, 230, 156, 46)),
                    onPressed: () async {
                      bool result = await _deleteIncomeType(
                          incomeType['id'], index, incomeType['userId']);
                      if (result) {
                        setState(() {
                          _incomeTypes.removeAt(index);
                        });
                        _showSnackbar('Income type deleted successfully');
                      }
                    },
                  ),
                ),
              );
            },
          )
        : Center(
            child: Text('No Income Types Found.'),
          );
  }
}
