import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/services/message_codec.dart';
import 'package:image_picker/image_picker.dart'; // Ensure this package is in your pubspec.yaml
import 'package:myfinanceapp/screens/transaction_screen.dart';
import 'package:myfinanceapp/services/auth_service.dart';
import 'package:myfinanceapp/services/budget_item_service.dart';
import 'package:myfinanceapp/services/expenses_type_service.dart';
import 'package:myfinanceapp/services/income_type_service.dart';
import 'package:myfinanceapp/services/transaction_service.dart';
import 'package:myfinanceapp/utils/constants.dart'; // Import for constants like primaryColor
import 'package:myfinanceapp/widgets/BuildDropdownMap.dart';
import 'package:myfinanceapp/widgets/BuildElevatedButton.dart';
import 'package:myfinanceapp/widgets/BuildTextButton.dart';
import 'package:myfinanceapp/widgets/BuildTextField.dart'; // For date formatting
import 'package:myfinanceapp/widgets/BuildDatePicker.dart';
import 'package:myfinanceapp/widgets/BuildDropdown.dart';
import 'package:uuid/uuid.dart';

class TransactionHistoryScreen extends StatefulWidget {
  @override
  _TransactionHistoryScreenState createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final _expensesTypeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final TransactionService _transactionService = TransactionService();
  final ExpensesTypeService _expensesTypeService = ExpensesTypeService();
  final IncomeTypeService _incomeTypeService = IncomeTypeService();

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
    _selectedFromDate = DateTime.now().subtract(Duration(days: 30));
    _selectedToDate = DateTime.now();
    _loadTransactions(); // Load the income types when the screen is initialized
  }

  String? _selectedTransactionType;
  String? _selectedSection;
  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var isDarkMode = themeData.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
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
            transactions.isEmpty
                ? Center(
                    child: Text(
                      'No records found for the selected period',
                      style: TextStyle(
                          fontSize: 14,
                          color: const Color.fromARGB(255, 143, 142, 142)),
                    ),
                  )
                : ListView.builder(
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
            transactions.isEmpty
                ? Center(
                    child: Text(
                      'No records found for the selected period',
                      style: TextStyle(
                          fontSize: 14,
                          color: const Color.fromARGB(255, 143, 142, 142)),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: transactions
                        .where((t) => t['type'] == 'Expense')
                        .length,
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
        tooltip: 'Fiter Transactions',
        child: Icon(Icons.filter_alt),
      ),
    );
  }

  void viewBudgetDetailsAdding(int transactionId) {
    // Handle transaction submission logic
    print('transId: ${transactionId}');
  }

  Widget _buildTransactionCard(Map transaction) {
    return Dismissible(
      key: Key(transaction['id']),
      direction: DismissDirection.endToStart, // Swipe to delete
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Delete Transaction'),
              content:
                  Text('Are you sure you want to delete this transaction?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // Cancel
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true), // Confirm
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        _deleteTransaction(transaction);
      },
      child: Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Builder(
            builder: (context) => ListTile(
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
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(transaction["description"]),
                  trailing: Column(children: [
                    Text(
                      '${transaction?["date"].toString().substring(0, 10)}',
                      style: TextStyle(
                        color: transaction['type'] == 'Income'
                            ? const Color.fromARGB(255, 31, 153, 37)
                            : Colors.red[700],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${transaction["amount"].toStringAsFixed(2)}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: transaction['type'] == 'Income'
                            ? const Color.fromARGB(255, 31, 153, 37)
                            : Colors.red[700],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]),
                )),
      ),
    );
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
            Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Row(
                  children: [
                    Icon(Icons.date_range,
                        color: const Color.fromARGB(255, 255, 255, 255)),
                    Text(' ${_selectedFromDate.toString().substring(0, 10)}',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ],
                ),
              ],
            ),
            Text(' To  ',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                )),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Row(
                  children: [
                    Icon(Icons.date_range,
                        color: const Color.fromARGB(255, 255, 255, 255)),
                    Text(' ${_selectedToDate.toString().substring(0, 10)}',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ],
                ),
              ],
            )
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
                    child: Center(child: Text('Filter Transactions')),
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
                      DatePickerWidget(
                        selectedDate: _selectedFromDate,
                        onDateChanged: (newDate) {
                          setState(() {
                            _selectedFromDate = newDate;
                          });
                        },
                        label: "From ",
                      ),
                      SizedBox(height: 5),
                      DatePickerWidget(
                        selectedDate: _selectedToDate,
                        onDateChanged: (newDate) {
                          setState(() {
                            _selectedToDate = newDate;
                          });
                        },
                        label: "To ",
                      ),
                      SizedBox(height: 10),
                      CustomElevatedButton(
                        onPressed: _filter,
                        buttonText: 'Filter Transactions',
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _filter() {
    _loadTransactions();
    Navigator.of(context).pop(); // Close the dialog
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

  void _clearForm() {
    _amountController.clear();
    _descriptionController.clear();
    _selectedTransactionType = null;
    _selectedSection = null;
  }

  Future<void> _deleteTransaction(Map transaction) async {
    try {
      final result = await _transactionService.delete(
          transaction['id'], transaction['userId']);
      if (result > 0) {
        _showSnackbar('Transaction deleted successfully');
        _loadTransactions(); // Reload the list after deletion
      } else {
        _showSnackbar('Failed to delete Transaction');
      }
    } catch (e) {
      _showSnackbar('Error deleting Transaction: $e');
    }
  }

  Future<void> _loadTransactions() async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user != null) {
        final trans = await _transactionService.getByUserIdAndPeriod(
            user['uid']!,
            _selectedFromDate.toString(),
            _selectedToDate.toString());
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
