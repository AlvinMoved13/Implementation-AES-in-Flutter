import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:finance/data/add_data.dart';
import 'package:finance/screen/add.dart';
import 'package:finance/screen/history.dart';
import 'package:finance/screen/home.dart';
import 'package:finance/screen/profile.dart';
import 'package:finance/screen/statistic.dart';
import 'package:finance/widget/authcontroller.dart';
import 'package:finance/widget/authentication_bloc.dart';
import 'package:finance/widget/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

final FirebaseFirestore firestore = FirebaseFirestore.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory =
      await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  Hive.registerAdapter(WalletAdapter());
  Hive.registerAdapter(AddDataAdapter());

  await Hive.openBox<AddData>('data');

  Get.put(NavigationController());
  Get.put(AuthController());

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthenticationBloc>(
      create: (context) => AuthenticationBloc(
          showSnackBar: (String message, AnimatedSnackBarType type) {}),
      child: GetMaterialApp(
        title: 'finance',
        home: MainApp(),
      ),
    );
  }
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController = Get.find();
    return Scaffold(
      body: PageView(
        controller: navigationController.pageController,
        children: [
          HomePage(),
          StatisticPage(),
          AddPage(),
          HistoryPage(),
          ProfilePage(),
        ],
        onPageChanged: (index) {
          navigationController.changePage(index);
        },
      ),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            items: navigationController.items,
            currentIndex: navigationController.currentIndex.value,
            onTap: (index) {
              navigationController.changePage(index);
              navigationController.pageController.jumpToPage(index);
            },
            type: BottomNavigationBarType.fixed,
            unselectedItemColor: Colors.grey.shade300,
            selectedItemColor: Colors.black87,
            showUnselectedLabels: false,
            showSelectedLabels: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedLabelStyle: const TextStyle(fontSize: 12),
          )),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController = Get.find();
    return Obx(() => BottomNavigationBar(
          items: navigationController.items,
          currentIndex: navigationController.currentIndex.value,
          onTap: navigationController.changePage,
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: Colors.grey.shade300,
          selectedItemColor: Colors.black87,
          showUnselectedLabels: false,
          showSelectedLabels: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedLabelStyle: const TextStyle(fontSize: 12),
        ));
  }
}

class NavigationController extends GetxController {
  var currentIndex = 0.obs;
  late PageController pageController;

  final List<BottomNavigationBarItem> items = [
    BottomNavigationBarItem(
        icon: Icon(EneftyIcons.bank_outline), label: 'Home'),
    BottomNavigationBarItem(
        icon: Icon(EneftyIcons.diagram_outline), label: 'Statistic'),
    BottomNavigationBarItem(
        icon: Icon(EneftyIcons.add_square_outline), label: 'Add'),
    BottomNavigationBarItem(
        icon: Icon(EneftyIcons.money_time_bold), label: 'History'),
    BottomNavigationBarItem(
        icon: Icon(EneftyIcons.profile_bold), label: 'Profile'),
  ];

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: currentIndex.value);
  }

  @override
  void onReady() {
    super.onReady();
    ever(currentIndex, handlePageChange);
  }

  void handlePageChange(int index) {
    if (pageController.hasClients) {
      pageController.jumpToPage(index);
    }
  }

  void changePage(int index) {
    if (currentIndex.value != index) {
      currentIndex.value = index;
      pageController.jumpToPage(index);
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

void showSnackBar(
    BuildContext context, String message, AnimatedSnackBarType type) {
  AnimatedSnackBar.rectangle(
    message,
    '',
    type: type,
    brightness: Brightness.light,
  ).show(context);
}
