import 'package:flutter/material.dart';
import 'package:myfinanceapp/services/auth_service.dart';
import 'package:myfinanceapp/services/expenses_type_service.dart';
import 'package:myfinanceapp/utils/constants.dart';
import 'package:myfinanceapp/widgets/BuildElevatedButton.dart';
import 'package:myfinanceapp/widgets/BuildTextField.dart';
import 'package:uuid/uuid.dart';

class ExpensesTypesScreen extends StatefulWidget {
  @override
  _ExpensesTypesScreenState createState() => _ExpensesTypesScreenState();
}

class _ExpensesTypesScreenState extends State<ExpensesTypesScreen> {
  final _expensesTypeController = TextEditingController();
  final _descriptionController = TextEditingController();
  var uuid = Uuid();
  final ExpensesTypeService _expensesTypeService = ExpensesTypeService();
  List<Map<String, dynamic>> _expenseTypes =
      []; // To hold the list of expense types

  @override
  void initState() {
    super.initState();
    _loadExpenseTypes(); // Load the expense types when the screen is initialized
  }

  // Method to load the expense types from the service
  Future<void> _loadExpenseTypes() async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user != null) {
        final expenses =
            await _expensesTypeService.getItemsForUser(user['uid']!);
        setState(() {
          _expenseTypes = List.from(expenses); // Create a modifiable list
        });
      }
    } catch (e) {
      print('Error loading expense types: $e');
    }
  }

  // Submit method to add a new expense type
  Future<void> _submitExpensesType() async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user == null) return;

      if (_expensesTypeController.text.trim() == '') {
        _showSnackbar('Please enter expense type');
        return;
      }

      final expenseType = {
        'id': uuid.v4(),
        'name': _expensesTypeController.text.trim(),
        'description': _descriptionController.text.trim(),
        'userId': user['uid'],
      };

      final int result =
          await _expensesTypeService.insertIncomeType(expenseType);

      if (result > 0) {
        _clearForm();
        _showSnackbar('Expense type added successfully');
        await _loadExpenseTypes(); // Reload the list after adding
      } else {
        _showSnackbar('Failed to add expense type');
      }
    } catch (e) {
      _showSnackbar('Error adding expense type: $e');
    }
  }

  // Clear the form fields
  void _clearForm() {
    _expensesTypeController.clear();
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
          content: Text('Are you sure you want to delete this expense type?'),
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

  // Method to delete the expense type
  Future<bool> _deleteExpenseType(String id, int index, String userId) async {
    bool status = false;
    final bool? confirmed = await _showDeleteConfirmationDialog();
    if (confirmed == null || !confirmed) return false;
    try {
      // Proceed with deletion after confirmation
      final result = await _expensesTypeService.delete(id, userId);

      if (result > 0) {
        // Only remove the item from the list if the deletion was successful
        status = true;
      } else {
        _showSnackbar('Failed to delete expense type');
      }
    } catch (e) {
      _showSnackbar('Error deleting expense type');
    }
    return status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses Types'),
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
              _buildExpenseList(),
            ],
          ),
        ),
      ),
    );
  }

  // Build the form card
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
              _expensesTypeController,
              'Expenses Type',
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
              onPressed: _submitExpensesType,
              buttonText: 'Save Expenses Type',
            ),
          ],
        ),
      ),
    );
  }

  // Build the expense type list
  Widget _buildExpenseList() {
    return _expenseTypes.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _expenseTypes.length,
            itemBuilder: (context, index) {
              final expenseType = _expenseTypes[index];
              return Card(
                elevation: 4,
                child: ListTile(
                  title: Text(expenseType['name']),
                  subtitle: Text(expenseType['description']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete,
                        color: const Color.fromARGB(255, 230, 156, 46)),
                    onPressed: () async {
                      bool result = await _deleteExpenseType(
                          expenseType['id'], index, expenseType['userId']);
                      if (result) {
                        setState(() {
                          _expenseTypes.removeAt(index);
                        });
                        _showSnackbar('Expense type deleted successfully');
                      }
                    },
                  ),
                ),
              );
            },
          )
        : Center(
            child: Text('No Expense Types Found.'),
          );
  }
}
