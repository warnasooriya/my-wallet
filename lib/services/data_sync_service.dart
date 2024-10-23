import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfinanceapp/data/db/data_sync_dao.dart';
import 'package:myfinanceapp/services/auth_service.dart';
import 'package:uuid/uuid.dart';

class DataSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DataSyncDao _dataSyncDao = DataSyncDao();
  var uuid = Uuid();
  // Sync local data to Firestore
  Future<void> localDataUploadToFirebase(String userId) async {
    if (userId == null) {
      return;
    }

    var deleteDetections =
        await _dataSyncDao.getTableByUserId('delete_detection', userId);
    await _deleteDataFromFirestore(deleteDetections);

    // Retrieve local data (income types)
    var incomeTypes =
        await _dataSyncDao.getTableByUserId('income_types', userId);
    await _storeDataByCollection('income_types', incomeTypes, 'id');

    var expensesTypes =
        await _dataSyncDao.getTableByUserId('expenses_type', userId);
    await _storeDataByCollection('expenses_type', expensesTypes, 'id');

    var budgets = await _dataSyncDao.getTableByUserId('budget', userId);
    await _storeDataByCollection('budget', budgets, 'id');

    var budgetItems =
        await _dataSyncDao.getTableByUserId('budget_item', userId);
    await _storeDataByCollection('budget_item', budgetItems, 'id');

    var transactions =
        await _dataSyncDao.getTableByUserId('transactions', userId);
    await _storeDataByCollection('transactions', transactions, 'id');

    print('Local data uploaded to Firestore successfully');
  }

  // Store data in Firestore by collection
  Future<void> _storeDataByCollection(String collectionName,
      List<Map<String, dynamic>> data, String keyName) async {
    for (var row in data) {
      String key = row[keyName];

      // Check if the document with the same id exists in Firestore
      var querySnapshot = await _firestore
          .collection(collectionName)
          .where(keyName, isEqualTo: key)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Add new document with a specific document ID
        await _firestore.collection(collectionName).doc(key).set(row);
        print('$collectionName added: $key');
      } else {
        print('$collectionName already exists: $key');
      }
    }
  }

  // Download Firestore data to local DB
  Future<void> firebaseDataDownloadToLocal(String userId) async {
    if (userId == null) {
      return;
    }

    await _storeToLocalDBByTable('income_types', userId);
    await _storeToLocalDBByTable('expenses_type', userId);
    await _storeToLocalDBByTable('budget', userId);
    await _storeToLocalDBByTable('budget_item', userId);
    await _storeToLocalDBByTable('transactions', userId);

    var incomeTypes =
        await _dataSyncDao.getTableByUserId('income_types', userId);

    var expensesTypes =
        await _dataSyncDao.getTableByUserId('expenses_type', userId);
    if (incomeTypes.length == 0) {
      await _insertDefaultIncomeTypes(userId);
    }
    print("Expenses Types Length: ${expensesTypes.length}");
    if (expensesTypes.length == 0) {
      await _insertDefaultExpensesTypes(userId);
    }

    print('Firestore data downloaded to local DB successfully');
  }

  // Store Firestore data to local SQLite by table name
  Future<void> _storeToLocalDBByTable(String tableName, String userId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection(tableName)
        .where('userId', isEqualTo: userId)
        .get();

    // Loop through the data and add it to the local database
    for (var doc in querySnapshot.docs) {
      // Get the entire document data as a map
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Add each Firestore field to the row dynamically
      Map<String, dynamic> row = {'id': doc.id};
      data.forEach((key, value) {
        row[key] = value;
      });

      await _dataSyncDao.insertData(tableName, row);
    }
  }

  Future<void> _deleteDataFromFirestore(
      List<Map<String, dynamic>> deleteDetections) async {
    for (var row in deleteDetections) {
      String tableName = row['table_name'];
      String keyName = row['key_name'];
      String keyValue = row['key_value'];
      String userId = row['userId'];

      // Check if the document with the same id exists in Firestore
      var querySnapshot = await _firestore
          .collection(tableName)
          .where(keyName, isEqualTo: keyValue)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Delete the document with a specific document ID
        await _firestore.collection(tableName).doc(keyValue).delete();
        print('$tableName deleted: $keyValue');
      } else {
        print('$tableName does not exist: $keyValue');
      }
    }
  }

  Future<void> _insertDefaultIncomeTypes(String userId) async {
    List<Map<String, dynamic>> incomeTypes = [
      {
        'id': uuid.v4(),
        'name': 'Salary',
        'description': 'Monthly salary',
        'userId': userId,
      },
      {
        'id': uuid.v4(),
        'name': 'Bonus',
        'description': 'Yearly bonus',
        'userId': userId,
      },
      {
        'id': uuid.v4(),
        'name': 'Interest',
        'description': 'Interest from savings account',
        'userId': userId,
      },
      {
        'id': uuid.v4(),
        'name': 'Dividends',
        'description': 'Dividends from investments',
        'userId': userId,
      },
      {
        'id': uuid.v4(),
        'name': 'Rental Income',
        'description': 'Income from rental property',
        'userId': userId,
      },
    ];

    for (var row in incomeTypes) {
      await _dataSyncDao.insertData('income_types', row);
    }
  }

  Future<void> _insertDefaultExpensesTypes(String userId) async {
    List<Map<String, dynamic>> expensesTypes = [
      {
        'id': uuid.v4(),
        'name': 'Rent',
        'description': 'Monthly rent',
        'userId': userId,
      },
      {
        'id': uuid.v4(),
        'name': 'Utilities',
        'description': 'Electricity, water, gas',
        'userId': userId,
      },
      {
        'id': uuid.v4(),
        'name': 'Groceries',
        'description': 'Monthly groceries',
        'userId': userId,
      },
      {
        'id': uuid.v4(),
        'name': 'Transportation',
        'description': 'Public transport, fuel',
        'userId': userId,
      },
      {
        'id': uuid.v4(),
        'name': 'Insurance',
        'description': 'Health, car, home insurance',
        'userId': userId,
      },
    ];

    for (var row in expensesTypes) {
      print("Inserting Expenses Type: $row");
      await _dataSyncDao.insertData('expenses_type', row);
    }
  }
}
