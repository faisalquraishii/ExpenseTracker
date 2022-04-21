// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, sized_box_for_whitespace, deprecated_member_use
import 'dart:io';
import 'package:flutter/services.dart';

import './widgets/chart.dart';
import './widgets/new_transaction.dart';
import './models/transaction.dart';
import './widgets/transaction_list.dart';
import 'package:flutter/material.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations(
  //   [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  // );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expenses',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Colors.amber,
        fontFamily: 'Quicksand',
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  // late String titleInput;

  final List<Transaction> _userTransactions = [
    // Transaction(
    //   id: 't1',
    //   title: 'New Shoes',
    //   amount: 279,
    //   date: DateTime.now(),
    // ),
    // Transaction(
    //   id: 't2',
    //   title: 'Weekly Groceries',
    //   amount: 150,
    //   date: DateTime.now(),
    // ),
  ];

  bool _showChart = false;

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
  }

  @override
   void didChangeAppLifecycleState(AppLifecycleState state) {
     print(state);

   }

  @override
   void dispose() {
     WidgetsBinding.instance?.removeObserver(this);
     super.dispose();

   }

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(DateTime.now().subtract(Duration(days: 7)));
    }).toList();
  }

  void _addNewTransaction(
      String txTitle, double txAmount, DateTime chosenDate) {
    final newTx = Transaction(
      title: txTitle,
      amount: txAmount,
      date: chosenDate,
      id: DateTime.now().toString(),
    );

    setState(() {
      _userTransactions.add(newTx);
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return GestureDetector(
            onTap: () {},
            child: NewTransaction(_addNewTransaction),
            behavior: HitTestBehavior.opaque,
          );
        });
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  List<Widget> _buildLandscapeContent(MediaQueryData mediaQuery, AppBar appBar, Widget txListWidget) {
    return [ Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Show Chart',
          style: TextStyle(fontSize: 20),
        ),
        Switch.adaptive(
            value: _showChart,
            onChanged: (val) {
              setState(() {
                _showChart = val;
              });
            })
      ],
    ), 
    _showChart
     ? Container(
       height: (mediaQuery.size.height - appBar.preferredSize.height - mediaQuery.padding.top) * 0.7,
       child: Chart(_recentTransactions))
      : txListWidget
    ];
  }

  List<Widget> _buildPortraitContent(MediaQueryData mediaQuery, AppBar appBar, Widget txListWidget) {
    return [ Container(
      height: (mediaQuery.size.height -
              appBar.preferredSize.height -
              mediaQuery.padding.top) *
          0.2,
      child: Chart(_recentTransactions),
    ), txListWidget ];
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final appBar = AppBar(
      title: Text(
        'Personal Expenses',
        style: TextStyle(fontFamily: 'OpenSans'),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => _startAddNewTransaction(context),
        ),
      ],
    );
    final txListWidget = Container(
      height: (mediaQuery.size.height -
              appBar.preferredSize.height -
              mediaQuery.padding.top) *
          0.8,
      child: TransactionList(_userTransactions, _deleteTransaction),
    );

    return Scaffold(
      appBar: appBar,
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        // crossAxisAlignment: CrossAxisAlignment.start,
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          if (isLandscape) ..._buildLandscapeContent(mediaQuery, appBar, txListWidget),
          if (!isLandscape) ..._buildPortraitContent(mediaQuery, appBar, txListWidget),
        ],
      ),
      floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () => _startAddNewTransaction(context),
            ),
    );
  }
}
