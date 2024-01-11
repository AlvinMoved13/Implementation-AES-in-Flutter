import 'package:finance/data/wallet.dart';
import 'package:hive/hive.dart';

part 'add_data.g.dart';

@HiveType(typeId: 1)
class AddData {
  @HiveField(0)
  String name;

  @HiveField(1)
  String amount;

  @HiveField(2)
  String IN;

  @HiveField(3)
  DateTime datetime;

  @HiveField(4)
  String selectedItem;

  @HiveField(5)
  String username;

  @HiveField(6)
  String password;

  AddData(
    this.name,
    this.amount,
    this.IN,
    this.datetime,
    this.selectedItem,
    this.username,
    this.password,
  );

  get category => null;
}
