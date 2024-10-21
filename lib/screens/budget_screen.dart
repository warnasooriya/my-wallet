import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/services/message_codec.dart';
import 'package:image_picker/image_picker.dart'; // Ensure this package is in your pubspec.yaml
import 'package:myfinanceapp/main.dart';
import 'package:myfinanceapp/screens/budget_item_screen.dart';
import 'package:myfinanceapp/services/auth_service.dart';
import 'package:myfinanceapp/services/budget_service.dart';
import 'package:myfinanceapp/utils/constants.dart'; // Import for constants like primaryColor
import 'package:myfinanceapp/widgets/BuildElevatedButton.dart';
import 'package:myfinanceapp/widgets/BuildTextButton.dart';
import 'package:myfinanceapp/widgets/BuildTextField.dart'; // For date formatting
import 'package:myfinanceapp/widgets/BuildDatePicker.dart';
import 'package:myfinanceapp/widgets/BuildDropdown.dart';
import 'package:uuid/uuid.dart';

class BudgetScreen extends StatefulWidget {
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> with RouteAware {
  final _expensesTypeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nameController = TextEditingController();
  DateTime _selectedFromDate = DateTime.now();
  DateTime _selectedToDate = DateTime.now();
  BudgetService _budgetService = BudgetService();
  List<Map<String, dynamic>> transactions = [];
  var uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _loadBudgets(); // Load the income types when the screen is initialized
  }

  @override
  void didPopNext() {
    // Called when coming back to this page (e.g., after navigating away)
    print('Returned to this page');
    _loadBudgets();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Subscribe this page to the RouteObserver if ModalRoute is not null
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    // Unsubscribe when the page is destroyed
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var isDarkMode = themeData.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Budget'),
        backgroundColor: primaryColor,
        foregroundColor: headerTextColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ...transactions
                .map((transaction) => Container(
                        child: InkWell(
                      onTap: () {
                        viewBudgetDetailsAdding(
                            transaction["id"], transaction["title"]);
                        // You can perform any action here when the card is tapped
                      },
                      child: Card(
                        color: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.zero, // Removes rounded corners
                        ),
                        margin:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        transaction["title"].toString(),
                                        style: TextStyle(
                                            color: Colors.blue[900],
                                            fontSize: 20),
                                        softWrap: true,
                                        // Enables wrapping of text
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      children: [
                                        Image.asset(
                                          'assets/${transaction['imageUrl'].toString()}.png', // Your app logo here
                                          width: 80,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Icon(
                                              Icons.calendar_month_rounded,
                                              color: Colors.green[900],
                                            ),
                                            Text(
                                              ' ${transaction["startDate"].toString().substring(0, 10)}',
                                              style: TextStyle(
                                                  color: Colors.green[900],
                                                  fontSize: 16),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 25),
                                        Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Icon(
                                                Icons.calendar_month_rounded,
                                                color: Colors.orange[900],
                                              ),
                                              Text(
                                                ' ${transaction["enddate"].toString().substring(0, 10)}',
                                                style: TextStyle(
                                                    color: Colors.orange[900],
                                                    fontSize: 16),
                                              ),
                                            ])
                                      ],
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: const Color.fromARGB(255, 151, 153,
                                      155), // Color of the divider
                                  height:
                                      30, // Space above and below the divider
                                  thickness: 1, // Thickness of the divider
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          'Income',
                                          style: TextStyle(
                                              color: Colors.blue[450],
                                              fontSize: 14),
                                        ),
                                        Text(
                                          '${transaction["totaincome"] == null ? 0.00 : transaction["totaincome"]?.toStringAsFixed(2)}',
                                          style: TextStyle(
                                              color: Colors.blue[450],
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          'Expenses',
                                          style: TextStyle(
                                              color: Colors.red[900],
                                              fontSize: 14),
                                        ),
                                        Text(
                                          '${transaction["totalexpenses"] == null ? 0.00 : transaction["totalexpenses"].toStringAsFixed(2)}',
                                          style: TextStyle(
                                              color: Colors.red[900],
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          'Balance',
                                          style: TextStyle(
                                              color: Colors.green[900],
                                              fontSize: 14),
                                        ),
                                        Text(
                                          '${transaction.isEmpty ? 0.00 : ((transaction["totaincome"] ?? 0) - (transaction["totalexpenses"] ?? 0)).toStringAsFixed(2)}',
                                          style: TextStyle(
                                              color: Colors.green[900],
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            )),
                      ),
                    )))
                .toList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        tooltip: 'Add New Budget',
        child: Icon(Icons.add),
      ),
    );
  }

  void viewBudgetDetailsAdding(String budgetId, String title) {
    // Handle transaction submission logic
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BudgetItemScreen(
                  budgetId: budgetId,
                  title: title,
                )));
  }

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          title: Text('Add New Budget'),
          content: Container(
            padding: EdgeInsets.all(20), // Control space inside the dialog
            width: double.maxFinite, // Expands the dialog width to the maximum
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  BuildTextField(
                    _nameController,
                    'Budget Title',
                    TextInputType.text,
                  ),
                  DatePickerWidget(
                    selectedDate: _selectedFromDate,
                    onDateChanged: (newDate) {
                      setState(() {
                        _selectedFromDate = newDate;
                      });
                    },
                    label: "Start Date",
                  ),
                  SizedBox(height: 10),
                  DatePickerWidget(
                    selectedDate: _selectedToDate,
                    onDateChanged: (newDate) {
                      setState(() {
                        _selectedToDate = newDate;
                      });
                    },
                    label: "End Date",
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            CustomElevatedButton(
              onPressed: _addNewBudget,
              buttonText: 'Create Budget',
            ),
          ],
        );
      },
    );
  }

  // Show a SnackBar with feedback
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  getImageId(int length) {
    int id = length + 1;
    int imageId = id % 10;
    return imageId;
  }

  Future<void> _addNewBudget() async {
    if (_nameController.text.isNotEmpty &&
        _selectedFromDate.toString().isNotEmpty &&
        _selectedToDate.toString().isNotEmpty) {
      try {
        final user = await AuthService().getCurrentUser();
        if (user == null) return;

        final budget = {
          "id": uuid.v4(),
          "userId": user['uid'],
          "title": _nameController.text,
          "startDate": _selectedFromDate.toString(),
          "enddate": _selectedToDate.toString(),
          "imageUrl": getImageId(transactions.length),
        };

        int result = await _budgetService.insert(budget);

        if (result > 0) {
          _clearForm();
          _loadBudgets(); // Reload the list after adding
          _showSnackbar('Budget  added successfully');
        } else {
          _showSnackbar('Failed to add Budget');
        }
      } catch (e) {
        _showSnackbar('Error adding Budget: $e');
      }
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  void _clearForm() {
    _nameController.clear();
    _selectedFromDate = DateTime.now();
    _selectedToDate = DateTime.now();
  }

  Future<void> _loadBudgets() async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user != null) {
        final trans = await _budgetService.getByUserId(user['uid']);
        setState(() {
          transactions = List.from(trans); // Create a modifiable list
        });
      }
    } catch (e) {
      print('Error loading Budget: $e');
    }
  }
}
