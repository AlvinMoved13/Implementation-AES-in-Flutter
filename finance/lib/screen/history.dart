import 'package:collection/collection.dart';
import 'package:finance/data/add_data.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _CirclePainter extends BoxPainter {
  final Color color;
  final double radius;

  _CirclePainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    Paint _paint = Paint();
    _paint.color = color;
    _paint.isAntiAlias = true;
    _paint.style =
        PaintingStyle.fill; // Menggunakan fill untuk menggambar lingkaran

    final Offset circleOffset =
        Offset(configuration.size!.width / 2 - radius / 2, 40);
    canvas.drawCircle(offset + circleOffset, radius, _paint);
  }
}

class CircleTabIndicator extends Decoration {
  final Color color;
  final double radius;
  final double strokeWidth;

  CircleTabIndicator(
      {required this.color, required this.radius, this.strokeWidth = 4});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CirclePainter(
      color: color,
      radius: radius,
    );
  }
}

Color _getColorForCategory(String? category) {
  if (category == null) {
    return Colors.grey; // Default color if the category is null
  }
  switch (category.toLowerCase()) {
    case 'Shopping':
      return Colors.green;
    case 'Food and Ingredient':
      return Colors.blue;
    case 'Transportation':
      return Colors.orange;
    case 'Transfer':
      return Colors.red;
    case 'Insurance & Health':
      return Colors.teal;
    case 'Education':
      return Colors.brown;
    case 'Entertainment & Lifestyle':
      return Colors.indigo;
    case 'Clothing and Self-Care':
      return Colors.pink;
    case 'Saving & Investment':
      return Colors.amber;
    case 'Dept & Credit':
      return Colors.deepPurple;
    case 'Donation & Charity':
      return Colors.lime;
    case 'Other':
      return Colors.purple;
    default:
      return Colors.grey;
  }
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<AddData>>(
      valueListenable: Hive.box<AddData>('data').listenable(),
      builder: (context, box, _) {
        final transactions = box.values.toList().cast<AddData>();
        return Scaffold(
          appBar: AppBar(
            title: Text('History'),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Daily'),
                Tab(text: 'Month'),
                Tab(text: 'Year'),
              ],
              indicator: CircleTabIndicator(
                  color: Color(0xff1DA1F2),
                  radius: 4), // Adjust the radius for the size of the dot
              indicatorSize:
                  TabBarIndicatorSize.tab, // The size of the indicator
              labelColor: Colors
                  .black, // Ganti dengan warna font tab yang dipilih (selected)
              unselectedLabelColor: Colors.grey,
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              buildHistory(transactions, HistoryType.Daily),
              buildHistory(transactions, HistoryType.Month),
              buildHistory(transactions, HistoryType.Year),
            ],
          ),
        );
      },
    );
  }

  Widget buildHistory(List<AddData> transactions, HistoryType type) {
    Map<dynamic, List<AddData>> groupedTransactions =
        groupTransactionsByType(transactions, type);

    return ListView.builder(
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        var key = groupedTransactions.keys.elementAt(index);
        var transactionList = groupedTransactions[key]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                formatDateTitle(key, type),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ...transactionList
                .map((transaction) => Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 5.0,
                          height: double.infinity,
                          color: _getColorForCategory(transaction.selectedItem),
                        ),
                        title: Text(transaction.name),
                        subtitle: Text('\$${transaction.amount}'),
                        trailing: Text(
                          DateFormat('MMM dd').format(transaction.datetime),
                        ),
                      ),
                    ))
                .toList(),
          ],
        );
      },
    );
  }

  Map<dynamic, List<AddData>> groupTransactionsByType(
      List<AddData> transactions, HistoryType type) {
    switch (type) {
      case HistoryType.Daily:
        return groupBy(transactions,
            (AddData t) => DateFormat('yyyy-MM-dd').format(t.datetime));
      case HistoryType.Month:
        return groupBy(transactions,
            (AddData t) => DateFormat('yyyy-MM').format(t.datetime));
      case HistoryType.Year:
        return groupBy(
            transactions, (AddData t) => DateFormat('yyyy').format(t.datetime));
    }
  }

  String formatDateTitle(dynamic key, HistoryType type) {
    switch (type) {
      case HistoryType.Daily:
        return DateFormat('MMM dd, yyyy').format(DateTime.parse(key));
      case HistoryType.Month:
        return DateFormat('MMMM yyyy').format(DateTime.parse(key + '-01'));
      case HistoryType.Year:
        return 'Year $key';
    }
  }
}

enum HistoryType { Daily, Month, Year }
