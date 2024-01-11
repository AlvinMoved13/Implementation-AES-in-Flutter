import 'package:finance/data/add_data.dart';
import 'package:hive/hive.dart';

part 'wallet.g.dart';

@HiveType(typeId: 0)
class Wallet {
  @HiveField(0)
  String name;

  @HiveField(1)
  String type;

  @HiveField(2)
  List<AddData> transactions;

  Wallet(this.name, this.type, this.transactions);
}
