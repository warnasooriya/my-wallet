import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Ensure this package is in your pubspec.yaml
import 'package:myfinanceapp/screens/transaction_screen.dart';
import 'package:myfinanceapp/services/auth_service.dart';
import 'package:myfinanceapp/services/budget_item_service.dart';
import 'package:myfinanceapp/services/expenses_type_service.dart';
import 'package:myfinanceapp/services/income_type_service.dart';
import 'package:myfinanceapp/utils/constants.dart'; // Import for constants like primaryColor
import 'package:myfinanceapp/widgets/BuildDropdownMap.dart';
import 'package:myfinanceapp/widgets/BuildDropdown.dart';
import 'package:myfinanceapp/widgets/BuildElevatedButton.dart';
import 'package:myfinanceapp/widgets/BuildTextButton.dart';
import 'package:myfinanceapp/widgets/BuildTextField.dart'; // For date formatting
import 'package:uuid/uuid.dart';

class BudgetItemScreen extends StatefulWidget {
  final String budgetId;
  final String title;

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
            _buildSectionHeader("Income", Colors.green),
            _buildTransactionList("Income"),
            Divider(color: Colors.grey[300], thickness: 1, height: 5),
            // Expenses Section Heading
            _buildSectionHeader("Expenses", Colors.red),
            _buildTransactionList("Expense"),
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

  Widget _buildSectionHeader(String title, Color color) {
    return Container(
      margin: EdgeInsets.fromLTRB(3, 0, 3, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 9.0),
      color: color,
      child: Row(
        children: [
          Icon(Icons.category, color: Colors.white),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(String type) {
    final filteredTransactions =
        transactions.where((t) => t['type'] == type).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        var transaction = filteredTransactions[index];
        return _buildTransactionCard(transaction, index);
      },
    );
  }

  Widget _buildTransactionCard(Map transaction, int index) {
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
              title: Text('Delete Budget Item'),
              content:
                  Text('Are you sure you want to delete this budget item?'),
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
        child: ListTile(
          onLongPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    TransactionScreen(transaction: transaction),
              ),
            );
          },
          leading: Icon(
            transaction['type'] == 'Income'
                ? Icons.trending_up
                : Icons.trending_down,
            color: transaction['type'] == 'Income' ? Colors.green : Colors.red,
          ),
          title: Text(
            transaction["section_name"],
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(transaction["description"]),
          trailing: Text(
            '${transaction["amount"]}',
            style: TextStyle(
              color:
                  transaction['type'] == 'Income' ? Colors.green : Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
            _buildSummaryItem(
                'Income', totalIncome, Colors.white, Icons.download),
            _buildSummaryItem(
                'Expenses', totalExpenses, Colors.white, Icons.upload),
            _buildSummaryItem('Balance', budget,
                budget >= 0 ? Colors.white : Colors.red, Icons.store),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
      String title, double value, Color color, IconData iconData) {
    return Column(
      children: <Widget>[
        Row(
          children: [
            Icon(iconData, color: color),
            SizedBox(width: 5),
            Text(title, style: TextStyle(fontSize: 16, color: color)),
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
                      onPressed: () =>
                          Navigator.of(context).pop(), // Close the dialog
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
                        loadTransactionSection(
                            setState); // Load section options
                      }),
                      SizedBox(height: 20),
                      BuildDropdownMap(
                        _selectedTransactionType ?? '',
                        'Section',
                        transactionSections,
                        _selectedSection,
                        (newValueSection) {
                          setState(() => _selectedSection = newValueSection);
                        },
                        'id',
                        'name',
                      ),
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
                  onPressed: _addNewBudget, // Add item
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

  Future<void> _deleteTransaction(Map transaction) async {
    try {
      final result = await _budgetItemService.delete(
          transaction['id'], transaction['userId']);
      if (result > 0) {
        _showSnackbar('Budget Item deleted successfully');
        _loadBudgetItems(); // Reload the list after deletion
      } else {
        _showSnackbar('Failed to delete Budget Item');
      }
    } catch (e) {
      _showSnackbar('Error deleting Budget Item: $e');
    }
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
    }
  }

  void _clearForm() {
    _amountController.clear();
    _descriptionController.clear();
  }

  Future<void> _loadBudgetItems() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        final trans = await _budgetItemService.getByUserIdAndBudget(
            user['uid'], widget.budgetId);
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

  // Show a SnackBar with feedback
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
