import 'package:finance/bloc/authentication/authentication_event.dart';
import 'package:finance/bloc/authentication/authentication_state.dart';
import 'package:finance/data/add_data.dart';
import 'package:finance/loginregister/login.dart';
import 'package:finance/screen/profile.dart';
import 'package:finance/widget/aes.dart';
import 'package:finance/widget/authentication_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool _isEncrypted = false;
  List<Map<String, String>> _encryptedData = [];

  void _toggleEncryption() {
    setState(() {
      _isEncrypted = !_isEncrypted;
      if (_isEncrypted) {
        final box = Hive.box<AddData>('data');
        final dataList = box.values.toList();
        _encryptedData = dataList
            .map((data) => {
                  'name': AESHelper.encrypt(data.name),
                  'amount': AESHelper.encrypt(data.amount),
                  'IN': AESHelper.encrypt(data.IN),
                  'date': AESHelper.encrypt(data.datetime.toString()),
                  'selectedItem': AESHelper.encrypt(data.selectedItem),
                  'username': AESHelper.encrypt(data.username),
                })
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Hive.openBox<AddData>('data'),
      builder: (BuildContext context, AsyncSnapshot<Box<AddData>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final Box<AddData> dataBox = snapshot.data!;
            final dataList = dataBox.values.toList();
            return BlocListener<AuthenticationBloc, AuthenticationState>(
              listener: (context, state) {
                if (state is Unauthenticated) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
              child: Scaffold(
                appBar: AppBar(
                  title: Text('Admin Data Table'),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(
                          _isEncrypted ? Icons.lock_outline : Icons.lock_open),
                      onPressed: _toggleEncryption,
                    ),
                    IconButton(
                      icon: Icon(Icons.exit_to_app),
                      onPressed: () {
                        BlocProvider.of<AuthenticationBloc>(context)
                            .add(LogoutRequested());
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => ProfilePage()));
                      },
                    ),
                  ],
                ),
                body: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const <DataColumn>[
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Amount')),
                        DataColumn(label: Text('IN')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Selected Item')),
                        DataColumn(label: Text('Username')),
                      ],
                      rows: _isEncrypted
                          ? _encryptedData.map((encryptedData) {
                              return DataRow(
                                cells: <DataCell>[
                                  DataCell(
                                      Text(encryptedData['name'] ?? 'Error')),
                                  DataCell(
                                      Text(encryptedData['amount'] ?? 'Error')),
                                  DataCell(
                                      Text(encryptedData['IN'] ?? 'Error')),
                                  DataCell(
                                      Text(encryptedData['date'] ?? 'Error')),
                                  DataCell(Text(encryptedData['selectedItem'] ??
                                      'Error')),
                                  DataCell(Text(
                                      encryptedData['username'] ?? 'Error')),
                                ],
                              );
                            }).toList()
                          : dataList.map((data) {
                              return DataRow(
                                cells: <DataCell>[
                                  DataCell(Text(data.name)),
                                  DataCell(Text(data.amount)),
                                  DataCell(Text(data.IN)),
                                  DataCell(Text(data.datetime.toString())),
                                  DataCell(Text(data.selectedItem)),
                                  DataCell(Text(data.username)),
                                ],
                              );
                            }).toList(),
                    ),
                  ),
                ),
              ),
            );
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
