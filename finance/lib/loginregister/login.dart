import 'package:finance/bloc/authentication/authentication_event.dart';
import 'package:finance/bloc/authentication/authentication_state.dart';
import 'package:finance/loginregister/admin.dart';
import 'package:finance/loginregister/register.dart';
import 'package:finance/main.dart';
import 'package:finance/widget/authcontroller.dart';
import 'package:finance/widget/authentication_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false; // Gunakan final di sini

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is Authenticated) {
            final authController = Get.find<AuthController>();
            authController.logIn(_usernameController.text.trim());
            final navigationController = Get.find<NavigationController>();
            navigationController.changePage(0);
            Get.offAll(() => MainApp());

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Login berhasil sebagai ${state.username}')));
          } else if (state is AdminAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => AdminPage()),
            );
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Login berhasil sebagai admin.')));
          } else if (state is Unauthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    Text('Login Gagal. Silakan periksa kredensial Anda.')));
          }
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Implementasi dari AddPage
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    labelText: 'Username', // Ganti label sesuai kebutuhan
                    labelStyle: TextStyle(
                      fontSize: 17,
                      color: Colors.grey.shade500,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        width: 2,
                        color: Color(0xffC5C5C5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        width: 2,
                        color: Color(0xff1DA1F2),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    labelText: 'Password', // Ganti label sesuai kebutuhan
                    labelStyle: TextStyle(
                      fontSize: 17,
                      color: Colors.grey.shade500,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        width: 2,
                        color: Color(0xffC5C5C5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        width: 2,
                        color: Color(0xff1DA1F2),
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_passwordVisible,
                ),
              ),
              SizedBox(height: 16),

              GestureDetector(
                onTap: () {
                  context.read<AuthenticationBloc>().add(
                        LoginRequested(
                          username: _usernameController.text.trim(),
                          password: _passwordController.text.trim(),
                        ),
                      );
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color(0xff1DA1F2),
                  ),
                  width: 120,
                  height: 50,
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: Text.rich(
                  TextSpan(
                    text: 'Don t have an account?',
                    children: [
                      TextSpan(
                        text: 'Register here',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
