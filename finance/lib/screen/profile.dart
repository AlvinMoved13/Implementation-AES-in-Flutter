import 'package:finance/bloc/authentication/authentication_state.dart';
import 'package:finance/loginregister/login.dart';
import 'package:finance/loginregister/register.dart';
import 'package:finance/widget/authcontroller.dart';
import 'package:finance/widget/authentication_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return _buildLoggedInView(context, state.username);
          } else {
            return _buildLoggedOutView(context);
          }
        },
      ),
    );
  }

  Widget _buildLoggedInView(BuildContext context, String username) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Welcome, $username',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ElevatedButton(onPressed: () {}, child: Text('Rate App')),
          ElevatedButton(onPressed: () {}, child: Text('Remove Ads')),
          ElevatedButton(
            onPressed: () {
              final AuthController authController = Get.find();
              authController.logOut();
              Get.offAll(() => LoginScreen());
            },
            child: Text('Log Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedOutView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(child: Image.asset('images/animate.gif')),
        SizedBox(height: 24),
        _buildLoginButton(context),
        SizedBox(height: 20),
        _buildRegisterButton(context),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => LoginScreen()));
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
              side: BorderSide(color: Color(0xff1DA1F2), width: 2.0),
            ),
          ),
          child: Text('Log In', style: TextStyle(color: Color(0xff1DA1F2))),
        ),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        child: OutlinedButton(
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => RegisterScreen()));
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: Color(0xff1DA1F2),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            side: BorderSide(width: 2.0, color: Color(0xff1DA1F2)),
          ),
          child: Text('Create Account', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
