import 'package:enefty_icons/enefty_icons.dart';
import 'package:finance/data/add_data.dart';
import 'package:finance/data/wallet.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<void> _openBoxFuture;
  late Box<Wallet> walletBox;
  late Wallet activeWallet;
  final TextEditingController _walletNameController = TextEditingController();

  late double income;
  late double expense;

  @override
  void initState() {
    super.initState();
    _openBoxFuture = hiveOpenBox();
  }

  void setActiveWallet([String walletName = 'Personal']) {
    var wallets = walletBox.values.toList();
    activeWallet = wallets.firstWhere(
      (w) => w.name == walletName,
      orElse: () => Wallet('Personal', 'personal', []),
    );
  }

  Future<void> hiveOpenBox() async {
    walletBox = await Hive.openBox<Wallet>('wallets');
    await Hive.openBox<AddData>('data');
    setActiveWallet(); // Set default wallet
    final transactions = Hive.box<AddData>('data').values.toList();
    income = calculateTotal(transactions, 'Income');
    expense = calculateTotal(transactions, 'Expense');
  }

  IconData getIconForCategory(String category) {
    switch (category) {
      case 'shopping':
        return EneftyIcons.shopping_cart_outline;
      case 'Transfer':
        return EneftyIcons.convert_card_outline;
      case 'transportation':
        return EneftyIcons.bus_bold;
      case 'Education':
        return EneftyIcons.teacher_outline;
      default:
        return EneftyIcons.arrow_square_down_bold;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _openBoxFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return buildHomePage();
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  double calculateTotal(List<AddData> transactions, String type) {
    return transactions.where((t) => t.IN == type).fold(
        0.0, (sum, current) => sum + (double.tryParse(current.amount) ?? 0.0));
  }

  Widget buildHomePage() {
    final transactions = Hive.box<AddData>('data').values.toList();
    double totalBalance = transactions.fold(0.0, (sum, item) {
      double amount = double.tryParse(item.amount) ?? 0.0;
      return sum + (item.IN == 'Income' ? amount : -amount);
    });

    return Scaffold(
      backgroundColor: Color(0xff1DA1F2).withOpacity(0.0),
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Container(
            width: 376.0, // Width in logical pixels
            height: 206.0, // Height in logical pixels
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Color(0xff1DA1F2), Color(0xff7360DF)],
              ),
            ),
            child: Column(
              children: <Widget>[
                Text(
                  'Total Balance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '\$$totalBalance',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildCard(
                  'Income', income, EneftyIcons.export_bold, Colors.green),
              _buildCard(
                  'Expense', expense, EneftyIcons.import_bold, Colors.red),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                AddData transaction = transactions[index];
                IconData icon = getIconForCategory(transaction.selectedItem);

                return Card(
                  color: Color(0xFFFBFBFB),
                  elevation: 1,
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    leading: Icon(icon),
                    title: Text(transaction.name),
                    subtitle: Text('\$${transaction.amount}'),
                    trailing: Text(
                      DateFormat('hh:mm a').format(transaction.datetime),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, double amount, IconData icon, Color color) {
    return Card(
      elevation: 2.0,
      child: Container(
        width: 150,
        padding: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Icon(icon, size: 30, color: color),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, color: color),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWalletDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Wallet'),
          content: TextField(
            controller: _walletNameController,
            decoration: InputDecoration(hintText: "Wallet Name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () async {
                if (_walletNameController.text.isNotEmpty) {
                  await createNewWallet(_walletNameController.text, 'personal');
                  Navigator.of(context).pop();
                  setState(() {});
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> createNewWallet(String walletName, String walletType) async {
    var newWallet = Wallet(walletName, walletType, []);
    var walletBox = Hive.box<Wallet>('wallets');
    await walletBox.add(newWallet);
    setActiveWallet(walletName);
  }
}
