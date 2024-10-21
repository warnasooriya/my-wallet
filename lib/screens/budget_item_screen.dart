import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/services/message_codec.dart';
import 'package:image_picker/image_picker.dart'; // Ensure this package is in your pubspec.yaml
import 'package:myfinanceapp/screens/transaction_screen.dart';
import 'package:myfinanceapp/services/auth_service.dart';
import 'package:myfinanceapp/services/budget_item_service.dart';
import 'package:myfinanceapp/services/expenses_type_service.dart';
import 'package:myfinanceapp/services/income_type_service.dart';
import 'package:myfinanceapp/utils/constants.dart'; // Import for constants like primaryColor
import 'package:myfinanceapp/widgets/BuildDropdownMap.dart';
import 'package:myfinanceapp/widgets/BuildElevatedButton.dart';
import 'package:myfinanceapp/widgets/BuildTextButton.dart';
import 'package:myfinanceapp/widgets/BuildTextField.dart'; // For date formatting
import 'package:myfinanceapp/widgets/BuildDatePicker.dart';
import 'package:myfinanceapp/widgets/BuildDropdown.dart';
import 'package:uuid/uuid.dart';

class BudgetItemScreen extends StatefulWidget {
  final String budgetId;
  final String title;

  // Constructor with required parameters

  BudgetItemScreen({
    required this.budgetId,
    required this.title,
  });

  @override
  _BudgetItemScreenState createState() => _BudgetItemScreenState();
}

class _BudgetItemScreenState extends State<BudgetItemScreen> {
  final _expensesTypeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final BudgetItemService _budgetItemService = BudgetItemService();
  final ExpensesTypeService _expensesTypeService = ExpensesTypeService();
  final IncomeTypeService _incomeTypeService = IncomeTypeService();
  final AuthService _authService = AuthService();

  DateTime _selectedFromDate = DateTime.now();
  DateTime _selectedToDate = DateTime.now();
  List<Map<String, dynamic>> transactionSections = [];
  List<Map<String, dynamic>> transactions = [];
  double totalIncome = 0;
  double totalExpenses = 0;
  double budget = 0;

  @override
  void initState() {
    super.initState();
    _loadBudgetItems(); // Load the income types when the screen is initialized
  }

  String? _selectedTransactionType;
  String? _selectedSection;
  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var isDarkMode = themeData.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: primaryColor,
        foregroundColor: headerTextColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(totalIncome, totalExpenses, budget),
            // Income Section Heading

            Container(
              margin: EdgeInsets.fromLTRB(3, 0, 3, 0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 9.0),
              color: const Color.fromARGB(
                  255, 22, 150, 110), // Light green background
              child: Row(
                children: [
                  Icon(Icons.upload,
                      color: const Color.fromARGB(
                          255, 254, 255, 255)), // Income icon
                  SizedBox(width: 8),
                  Text('Income',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 255, 255, 255))),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount:
                  transactions.where((t) => t['type'] == 'Income').length,
              itemBuilder: (context, index) {
                var transaction = transactions
                    .where((t) => t['type'] == 'Income')
                    .toList()[index];
                return _buildTransactionCard(transaction);
              },
            ),
            Divider(color: Colors.grey[300], thickness: 1, height: 5),
            // Expenses Section Heading
            Container(
              margin: EdgeInsets.fromLTRB(3, 0, 3, 0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 9.0),
              color: const Color.fromARGB(
                  255, 237, 59, 59), // Light red background
              child: Row(
                children: [
                  Icon(Icons.download,
                      color: const Color.fromARGB(
                          255, 255, 255, 255)), // Expenses icon
                  SizedBox(width: 8),
                  Text('Expenses',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 255, 255, 255))),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount:
                  transactions.where((t) => t['type'] == 'Expense').length,
              itemBuilder: (context, index) {
                var transaction = transactions
                    .where((t) => t['type'] == 'Expense')
                    .toList()[index];
                return _buildTransactionCard(transaction);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        tooltip: 'Add Budget Item',
        child: Icon(Icons.add),
      ),
    );
  }

  void viewBudgetDetailsAdding(int transactionId) {
    // Handle transaction submission logic
    print('transId: ${transactionId}');
  }

  Widget _buildTransactionCard(Map transaction) {
    return Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Builder(
          builder: (context) => ListTile(
            onLongPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TransactionScreen(transaction: transaction),
                ),

                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => TransactionScreen(transaction: transaction),
                //   ),
              );
            },
            leading: Icon(
              transaction['type'] == 'Income'
                  ? Icons.trending_up
                  : Icons.trending_down,
              color: transaction['type'] == 'Income'
                  ? const Color.fromARGB(255, 15, 106, 18)
                  : Colors.red,
            ),
            title: Text(
              transaction["section_name"],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(transaction["description"]),
            trailing: Text(
              '${transaction["amount"]}',
              style: TextStyle(
                color: transaction['type'] == 'Income'
                    ? const Color.fromARGB(255, 31, 153, 37)
                    : Colors.red[700],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ));
  }

  Widget _buildSummaryCard(
      double totalIncome, double totalExpenses, double budget) {
    return Card(
      color: primaryColor,
      elevation: 0,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildSummaryItem(
                ' Income',
                totalIncome,
                const Color.fromARGB(255, 255, 255, 255),
                Icon(Icons.download,
                    color: const Color.fromARGB(255, 255, 255, 255))),
            _buildSummaryItem(
                ' Expenses',
                totalExpenses,
                const Color.fromARGB(255, 255, 255, 255),
                Icon(
                  Icons.upload,
                  color: Color.fromARGB(255, 255, 255, 255),
                )),
            _buildSummaryItem(
              ' Savings',
              budget,
              budget >= 0
                  ? const Color.fromARGB(255, 255, 255, 255)
                  : const Color.fromARGB(255, 255, 253, 253),
              Icon(Icons.store, color: Color.fromARGB(255, 255, 255, 255)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, double value, Color color, Icon icon) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Row(
          children: [
            icon,
            Text(title,
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                )),
          ],
        ),
        Text('${value.toStringAsFixed(2)}',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              actionsAlignment: MainAxisAlignment.center,
              title: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Center(child: Text('Add Budget Item')),
                  ),
                  Positioned(
                    right: 0.0,
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                    ),
                  ),
                ],
              ),
              content: Container(
                padding: EdgeInsets.all(20),
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      BuildDropdown('Type', ['Income', 'Expense'],
                          _selectedTransactionType, (newValue) {
                        setState(() => _selectedTransactionType = newValue);
                        loadTransactionSection(setState); // Pass the setState
                      }),
                      SizedBox(height: 20),
                      BuildDropdownMap(
                          _selectedTransactionType ?? '',
                          'Section',
                          transactionSections,
                          _selectedSection, (newValueSection) {
                        setState(() => _selectedSection = newValueSection);
                      }, 'id', 'name'),
                      SizedBox(height: 10),
                      BuildTextField(
                          _amountController, 'Amount', TextInputType.number,
                          isNumberOnly: true),
                      SizedBox(height: 10),
                      BuildTextField(_descriptionController, "Description",
                          TextInputType.text),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                CustomElevatedButton(
                  onPressed: _addNewBudget, // Your existing function
                  buttonText: 'Add Item',
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> loadTransactionSection(StateSetter dialogSetState) async {
    final user = await _authService.getCurrentUser();
    String? userId = user['uid'];
    if (_selectedTransactionType == "Income") {
      final incomeTypes = await _incomeTypeService.getItemsForUser(userId!);
      dialogSetState(() {
        transactionSections = List.from(incomeTypes);
        _selectedSection = null;
      });
    } else if (_selectedTransactionType == "Expense") {
      final expensesTypes = await _expensesTypeService.getItemsForUser(userId!);
      dialogSetState(() {
        transactionSections = List.from(expensesTypes);
        _selectedSection = null;
      });
    }
  }

  getImageId(int length) {
    int id = length + 1;
    int imageId = id % 10;
    return imageId;
  }

  // Show a SnackBar with feedback
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _addNewBudget() async {
    if (_amountController.text.isNotEmpty &&
        _selectedFromDate.toString().isNotEmpty &&
        _selectedToDate.toString().isNotEmpty) {
      try {
        final user = await AuthService().getCurrentUser();
        if (user == null) return;

        final budgetItem = {
          "id": Uuid().v4(),
          "userId": user['uid'],
          "type": _selectedTransactionType,
          "section": _selectedSection,
          "amount": _amountController.text,
          "description": _descriptionController.text,
          "budgetId": widget.budgetId,
        };
        final result = await _budgetItemService.insert(budgetItem);
        if (result > 0) {
          _clearForm();
          _loadBudgetItems(); // Reload the list after adding
          _showSnackbar('Budget Item added successfully');
        } else {
          _showSnackbar('Failed to add Budget Item');
        }
      } catch (e) {
        _showSnackbar('Error adding Budget Item: $e');
      }

      // Navigator.of(context).pop(); // Close the dialog
    }
  }

  void _clearForm() {
    _amountController.clear();
    _descriptionController.clear();
    // _selectedSection = null;
  }

  Future<void> _loadBudgetItems() async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user != null) {
        final trans = await _budgetItemService.getByUserIdAndBudget(
            user['uid'], widget.budgetId);
        print(trans);
        setState(() {
          transactions = List.from(trans); // Create a modifiable list
          totalIncome = transactions
              .where((transaction) => transaction['type'] == 'Income')
              .fold(0, (sum, item) => sum + item['amount']);

          totalExpenses = transactions
              .where((transaction) => transaction['type'] == 'Expense')
              .fold(0, (sum, item) => sum + item['amount']);
          budget = totalIncome - totalExpenses;
        });
      }
    } catch (e) {
      print('Error loading Budget: $e');
    }
  }
}
