import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myfinanceapp/services/auth_service.dart';
import 'package:myfinanceapp/services/expenses_type_service.dart';
import 'package:myfinanceapp/services/income_type_service.dart';
import 'package:myfinanceapp/services/transaction_service.dart';
import 'package:myfinanceapp/utils/constants.dart';
import 'package:myfinanceapp/widgets/AttachImageButton.dart';
import 'package:myfinanceapp/widgets/BuildDatePicker.dart';
import 'package:myfinanceapp/widgets/BuildDropdown.dart';
import 'package:myfinanceapp/widgets/BuildDropdownMap.dart';
import 'package:myfinanceapp/widgets/BuildElevatedButton.dart';
import 'package:myfinanceapp/widgets/BuildTextField.dart';
import 'package:uuid/uuid.dart';

class TransactionScreen extends StatefulWidget {
  final Map? transaction;

  TransactionScreen({
    this.transaction,
  });

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  late TextEditingController _amountController;
  final _remarksController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedTransactionType;
  String? _selectedSection;
  XFile? _imageFile;
  final List<Map<String, dynamic>> transactionSections = [];
  final ImagePicker _picker = ImagePicker();
  var uuid = Uuid();
  final IncomeTypeService _incomeTypeService = IncomeTypeService();
  final ExpensesTypeService _expensesTypeService = ExpensesTypeService();
  final TransactionService _transactionService = TransactionService();

  @override
  void initState() {
    print('opening transaction screen');
    print(widget.transaction);
    super.initState();
    _selectedTransactionType = widget.transaction?['type'];
    _selectedSection = widget.transaction?['section'];
    _remarksController.text = widget.transaction?['description'] ?? '';
    loadTransactionSection();
    _amountController = TextEditingController(
      text: widget.transaction?['amount']?.toString() ?? '',
    );
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
        backgroundColor: primaryColor,
        foregroundColor: headerTextColor,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 25,
            margin: EdgeInsets.all(
                3), // Removes margin so the card covers the full area
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(
                  25)), // Removes border radius to cover entire screen
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  BuildDropdown('Transaction Type', ['Income', 'Expense'],
                      _selectedTransactionType, (newValue) {
                    setState(() => _selectedTransactionType = newValue);
                    loadTransactionSection();
                  }),
                  SizedBox(height: 20),
                  BuildDropdownMap(_selectedTransactionType ?? '', 'Section',
                      transactionSections, _selectedSection, (newValue) {
                    setState(() => _selectedSection = newValue);
                  }, 'id', 'name'),
                  SizedBox(height: 20),
                  DatePickerWidget(
                    selectedDate: _selectedDate,
                    onDateChanged: (newDate) {
                      setState(() {
                        _selectedDate = newDate;
                      });
                    },
                    label: "Date",
                  ),
                  SizedBox(height: 20),
                  BuildTextField(
                      _amountController, 'Amount', TextInputType.number,
                      isNumberOnly: true),
                  SizedBox(height: 20),
                  BuildTextField(
                      _remarksController, 'Remarks', TextInputType.text),
                  SizedBox(height: 20),
                  AttachImageButton(
                    onImageSelected: (image) {
                      setState(() {
                        _imageFile = image; // Update state with selected image
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  buildImagePreview(),
                  SizedBox(height: 20),
                  CustomElevatedButton(
                    onPressed: _submitTransaction,
                    buttonText: 'Submit Transaction',
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Show a SnackBar with feedback
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget buildImagePicker() => AttachImageButton(
        onImageSelected: (image) => setState(() => _imageFile = image),
      );

  Widget buildImagePreview() => _imageFile != null
      ? kIsWeb
          ? Image.network(_imageFile!.path, height: 200, width: 200)
          : Image.file(File(_imageFile!.path), height: 200, width: 200)
      : Text('No image selected.');

  Future<void> _submitTransaction() async {
    // Transaction submission logic
    try {
      final user = await AuthService().getCurrentUser();
      if (user == null) return;

      // Check for empty fields
      if (_selectedTransactionType?.isEmpty == true ||
          _selectedSection?.isEmpty == true ||
          _amountController.text.isEmpty ||
          _selectedDate.toString().isEmpty) {
        _showSnackbar('Please fill out Required fields');
        return;
      }

      final transaction = {
        'id': uuid.v4(),
        'type': _selectedTransactionType,
        'section': _selectedSection,
        'date': _selectedDate.toString(),
        'amount': double.parse(_amountController.text),
        'description': _remarksController.text,
        'image': _imageFile?.path,
        'userId': user['uid'],
      };

      final int result =
          await _transactionService.insertTransaction(transaction);

      if (result > 0) {
        _clearForm();
        _showSnackbar('Transaction added successfully');
      } else {
        _showSnackbar('Failed to add Transaction');
      }
    } catch (e) {
      _showSnackbar('Error adding Transaction: $e');
    }
  }

  Future<void> loadTransactionSection() async {
    final user = await AuthService().getCurrentUser();
    if (_selectedTransactionType == 'Income') {
      final incomeTypes =
          await _incomeTypeService.getItemsForUser(user['uid']!);

      setState(() {
        transactionSections.clear();
        transactionSections.addAll(incomeTypes);
      });
    } else if (_selectedTransactionType == 'Expense') {
      final expensesTypes =
          await _expensesTypeService.getItemsForUser(user['uid']!);
      setState(() {
        transactionSections.clear();
        transactionSections.addAll(expensesTypes);
      });
    }
  }

  void _clearForm() {
    _amountController.clear();
    _remarksController.clear();
    _selectedDate = DateTime.now();
    _selectedTransactionType = null;
    _selectedSection = null;
    _imageFile = null;
  }
}
