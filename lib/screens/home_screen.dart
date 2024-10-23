import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:myfinanceapp/data/dto/DashbardResponseDto.dart';
import 'package:myfinanceapp/main.dart';
import 'package:myfinanceapp/services/auth_service.dart';
import 'package:myfinanceapp/services/transaction_service.dart';
import 'package:myfinanceapp/utils/constants.dart';
import 'package:graphic/graphic.dart';
import 'package:myfinanceapp/widgets/BuildBarChart.dart';
import 'package:myfinanceapp/widgets/BuildRoseChart.dart';

import '../widgets/MyDrawer.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  final AuthService _authService = AuthService();
  final TransactionService _transactionService = TransactionService();

  final Random random = Random();
  List<Map> barAnimData = [];
  List<Map<String, dynamic>> expenses = [];
  List<Map<String, dynamic>> income = [];
  List<Map<String, dynamic>> invomeVsExpenses = [];

  List<List> scatterAnimData = [];
  DashbardResponseDto summeryData = DashbardResponseDto(
      totalIncome: 0.00,
      totalExpenses: 0.00,
      totalBalance: 0.00,
      totalBudget: 0.00,
      expensesList: [],
      incomeList: [],
      incomeVsExpensesList: []);
  double saving = 0.00;

  @override
  void initState() {
    super.initState();
    _initializeChartData();
  }

  @override
  Future<void> _initializeChartData() async {
    final user = await _authService.getCurrentUser();
    String? userId = user['uid'];
    var sumData = await _transactionService.getDataForDashbord(userId!);
    List<Map<String, dynamic>> expensesList =
        List<Map<String, dynamic>>.from(sumData.expensesList);

    List<Map<String, dynamic>> incomeList =
        List<Map<String, dynamic>>.from(sumData.incomeList);

    List<Map<String, dynamic>> incomeVsExpensesList =
        List<Map<String, dynamic>>.from(sumData.incomeVsExpensesList);

    for (var element in sumData.expensesList) {
      expensesList.add({'value': element['value'], 'name': element['name']});
    }
    for (var element in sumData.incomeList) {
      incomeList.add({'value': element['value'], 'name': element['name']});
    }

    for (var element in sumData.incomeVsExpensesList) {
      incomeVsExpensesList.add({
        'category': element['category'],
        'value': element['value'],
        'type': element['type']
      });
    }

    setState(() {
      summeryData = sumData;
      expenses = expensesList;
      income = incomeList;
      invomeVsExpenses = incomeVsExpensesList;
    });
  }

  @override
  void didPopNext() {
    // Called when coming back to this page (e.g., after navigating away)
    print('Returned to this page');
    _initializeChartData();
  }

  @override
  void dispose() {
    // Unsubscribe when the page is destroyed
    routeObserver.unsubscribe(this);
    super.dispose();
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

  Widget _buildChartCard(Widget chart, String title) {
    return Card(
        // elevation: 8,
        margin: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, const Color.fromARGB(212, 255, 255, 255)],
              stops: [0, 1],
              begin: AlignmentDirectional(0.94, -1),
              end: AlignmentDirectional(-0.94, 1),
            ),
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(1),
                child: Text(
                  title,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
              // SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 200,
                child: chart,
              ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var isDarkMode = themeData.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('My Wallet'),
        backgroundColor: primaryColor,
        foregroundColor: headerTextColor,
      ),
      drawer: MyDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: _buildBalanceTile(
                      'Income',
                      summeryData.totalIncome,
                      Icon(
                        Icons.account_balance_wallet,
                        color: Colors.green[700],
                        size: 40,
                      ),
                      Colors.white as Color),
                ),
                Expanded(
                  child: _buildBalanceTile(
                      'Expenses',
                      summeryData.totalExpenses,
                      Icon(
                        Icons.inbox,
                        color: Colors.red[700],
                        size: 40,
                      ),
                      Colors.white as Color),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildBalanceTile(
                      'Savings',
                      summeryData.totalBalance,
                      Icon(
                        Icons.account_balance,
                        color: const Color.fromARGB(255, 196, 9, 202),
                        size: 40,
                      ),
                      Colors.white as Color),
                ),
                Expanded(
                  child: _buildBalanceTile(
                      'Budget',
                      summeryData.totalBudget,
                      Icon(
                        Icons.account_balance_wallet,
                        color: const Color.fromARGB(255, 116, 16, 205),
                        size: 40,
                      ),
                      Colors.white as Color),
                ),
              ],
            ),
            // Generated code for this Column Widget...
            Row(
              children: [
                Expanded(
                  child: _buildChartCard(BuildRoseChart(expenses), 'Expenses'),
                ),
                Expanded(
                  child: _buildChartCard(BuildRoseChart(income), 'Income'),
                ),
              ],
            ),
            // _buildChartCard(BuildRoseChart(roseData), 'Expenses'),
            _buildChartCard(
                BuildBarChart(invomeVsExpenses), 'Income vs Expenses'),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceTile(label, double value, icon, Color color) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              color: Color(0x4B1A1F24),
              offset: Offset(
                0.0,
                2,
              ),
            )
          ],
          gradient: LinearGradient(
            colors: [primaryColor, color],
            stops: [0, 1],
            begin: AlignmentDirectional(0.94, -1),
            end: AlignmentDirectional(-0.94, 1),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Column(
            children: <Widget>[
              SizedBox.fromSize(
                size: Size.fromHeight(20),
              ),
              ListTile(
                title: Text(label,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Text(
                  value.toStringAsFixed(2),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                leading: icon,
              ),
              SizedBox.fromSize(
                size: Size.fromHeight(20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingBillsTile() {
    return ListTile(
      title:
          Text('Upcoming Bills', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('\$200 due on 15th Nov'),
      leading: Icon(Icons.calendar_today, color: primaryColor),
    );
  }
}
