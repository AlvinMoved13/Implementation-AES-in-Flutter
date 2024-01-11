import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:finance/data/add_data.dart';
import 'package:finance/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  DateTime date = DateTime.now();
  String? selectedItem;
  String? selctedItemi;
  String? selectedItemi;
  final TextEditingController describeController = TextEditingController();
  FocusNode ex = FocusNode();
  final TextEditingController amount_c = TextEditingController();
  FocusNode amount_ = FocusNode();
  final box = Hive.box<AddData>('data');
  final List<String> _item = [
    "Shopping",
    "Food and Ingredient",
    "Transportation",
    "Transfer",
    "Insurance & Health",
    "Education",
    "Entertainment & Lifestyle",
    "Clothing and Self-Care",
    "Saving & Investment",
    "Dept & Credit",
    "Donation & Charity",
    "Other",
  ];
  final List<String> _itemei = ['Income', "Expense"];
  bool _isButtonDisabled = true;

  @override
  void initState() {
    super.initState();
    ex.addListener(() {
      setState(() {});
    });
    amount_.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            background_container(context),
            Positioned(
              top: 120,
              child: main_container(),
            ),
          ],
        ),
      ),
    );
  }

  Container main_container() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      height: 550,
      width: 340,
      child: Column(
        children: [
          SizedBox(height: 50),
          category(),
          SizedBox(height: 30),
          describeField(),
          SizedBox(height: 30),
          amount(),
          SizedBox(height: 30),
          How(),
          SizedBox(height: 30),
          date_time(),
          Spacer(),
          save(),
          SizedBox(height: 25),
        ],
      ),
    );
  }

  GestureDetector save() {
    return GestureDetector(
      onTap: _saveData,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color(0xff1DA1F2),
        ),
        width: 120,
        height: 50,
        child: Text(
          'Save',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  void _saveData() {
    try {
      var add = AddData(
        describeController.text, // Nama
        amount_c.text.isNotEmpty ? amount_c.text : '0', // Amount
        selectedItemi ?? 'Income', // IN atau inOut
        date, // datetime
        selectedItem ?? 'shopping', // selectedItem
        'usercategory', // Tambahkan usercategory
        'password', // Tambahkan password
      );

      box.add(add).then((_) {
        // Navigate to the HomePage or refresh it to show the new transaction
        final NavigationController navigationController = Get.find();
        navigationController
            .changePage(0); // Assuming '0' is the index of HomePage
        navigationController.pageController.jumpToPage(0);
      });

      // Tampilkan snackbar sukses
      AnimatedSnackBar.rectangle(
        'Data berhasil ditambahkan',
        'Data telah sukses disimpan',
        type: AnimatedSnackBarType.success,
        brightness: Brightness.light,
      ).show(context);
    } catch (e) {
      // Tampilkan snackbar error
      AnimatedSnackBar.rectangle(
        'Terjadi kesalahan',
        'Gagal menyimpan data: $e',
        type: AnimatedSnackBarType.error,
        brightness: Brightness.light,
      ).show(context);
    }
  }

  Widget date_time() {
    return Container(
      alignment: Alignment.bottomLeft,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 2, color: Color(0xffC5C5C5))),
      width: 300,
      child: TextButton(
        onPressed: () async {
          DateTime? newDate = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100));
          if (newDate == Null) return;
          setState(() {
            date = newDate!;
          });
        },
        child: Text(
          'Date : ${date.year} / ${date.day} / ${date.month}',
          style: TextStyle(
            fontSize: 15,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Padding How() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 2,
            color: Color(0xffC5C5C5),
          ),
        ),
        child: DropdownButton<String>(
          value: selectedItemi,
          onChanged: (value) {
            setState(() {
              selectedItemi = value!;
            });
          },
          items: _itemei.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: <Widget>[
                  Icon(
                    item == 'Income'
                        ? EneftyIcons.arrow_square_up_bold
                        : EneftyIcons.arrow_square_down_bold,
                    color: item == 'Income' ? Colors.green : Colors.red,
                  ),
                  SizedBox(width: 10),
                  Text(
                    item,
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }).toList(),
          hint: Text(
            'value',
            style: TextStyle(color: Colors.grey),
          ),
          isExpanded: true,
        ),
      ),
    );
  }

  Padding amount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        keyboardType: TextInputType.number,
        focusNode: amount_,
        controller: amount_c,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          labelText: 'amount',
          labelStyle: TextStyle(fontSize: 17, color: Colors.grey.shade500),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 2, color: Color(0xffC5C5C5))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 2, color: Color(0xff1DA1F2))),
        ),
      ),
    );
  }

  Widget describeField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          TextField(
            focusNode: ex,
            controller: describeController,
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              labelText: 'describe',
              labelStyle: TextStyle(fontSize: 17, color: Colors.grey.shade500),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(width: 2, color: Color(0xffC5C5C5))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(width: 2, color: Color(0xff1DA1F2))),
            ),
          ),
        ],
      ),
    );
  }

  Widget saveButton() {
    return GestureDetector(
      onTap: _isButtonDisabled ? null : _saveData,
      child: Opacity(
        opacity: _isButtonDisabled ? 0.5 : 1,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Color(0xff1DA1F2),
          ),
          width: 120,
          height: 50,
          child: Text(
            'Save',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 17,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    describeController.dispose();
    amount_c.dispose();
    ex.dispose();
    amount_.dispose();
    super.dispose();
  }

  Padding category() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 2,
            color: Color(0xffC5C5C5),
          ),
        ),
        child: DropdownButton<String>(
          value: selectedItem,
          onChanged: ((value) {
            setState(() {
              selectedItem = value!;
            });
          }),
          items: _item.map((e) {
            IconData icon =
                getIconForCategory(e); // Menggunakan fungsi yang sama
            return DropdownMenuItem<String>(
              child: Container(
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Icon(icon),
                    SizedBox(width: 10),
                    Text(
                      e,
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
              ),
              value: e,
            );
          }).toList(),
          selectedItemBuilder: (BuildContext context) => _item.map((e) {
            IconData icon =
                getIconForCategory(e); // Menggunakan fungsi yang sama
            return Row(
              children: [Icon(icon), SizedBox(width: 5), Text(e)],
            );
          }).toList(),
          hint: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'category',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          dropdownColor: Colors.white,
          isExpanded: true,
          underline: Container(),
        ),
      ),
    );
  }

  IconData getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'shopping':
        return EneftyIcons.shopping_cart_outline;
      case 'food and ingredient':
        return EneftyIcons.box_outline;
      case 'transportation':
        return EneftyIcons.bus_bold;
      case 'transfer':
        return EneftyIcons.convert_card_outline;
      case 'insurance & health':
        return EneftyIcons.heart_circle_bold;
      case 'education':
        return EneftyIcons.teacher_bold;
      case 'entertainment & lifestyle':
        return EneftyIcons.music_play_bold;
      case 'clothing and self-care':
        return EneftyIcons.magicpen_outline;
      case 'saving & investment':
        return EneftyIcons.receipt_discount_outline;
      case 'dept & credit':
        return EneftyIcons.card_outline;
      case 'donation & charity':
        return EneftyIcons.people_outline;
      case 'other':
        return EneftyIcons.stickynote_outline;
      default:
        return EneftyIcons.note_remove_outline;
    }
  }

  Column background_container(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 240,
          decoration: BoxDecoration(
            color: Color(0xff1DA1F2),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 40),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
