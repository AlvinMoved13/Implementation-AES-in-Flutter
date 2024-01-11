import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:collection/collection.dart';
import 'package:finance/bloc/authentication/authentication_event.dart';
import 'package:finance/bloc/authentication/authentication_state.dart';
import 'package:finance/data/add_data.dart';
import 'package:finance/widget/aes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final Function(String, AnimatedSnackBarType) showSnackBar;

  AuthenticationBloc({required this.showSnackBar}) : super(Guest()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<RegisterRequested>(_onRegisterRequested);
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthenticationState> emit) async {
    try {
      var box = await Hive.openBox<AddData>('user');

      AddData? user = box.values.firstWhereOrNull(
        (u) =>
            u.username == event.username &&
            checkPassword(u.password, event.password),
      );
      if (event.username == 'admin' && event.password == 'admin') {
        emit(AdminAuthenticated(username: event.username));
        return;
      }
      if (user != null) {
        emit(Authenticated(username: event.username, isAdmin: false));
        showSnackBar('Login successful', AnimatedSnackBarType.success);
      } else {
        emit(Unauthenticated());
        showSnackBar('Login failed: User not found or incorrect password',
            AnimatedSnackBarType.error);
      }
    } catch (e) {
      emit(Unauthenticated());
      showSnackBar('Login failed: ${e.toString()}', AnimatedSnackBarType.error);
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthenticationState> emit) async {
    emit(Unauthenticated());
  }

  Future<void> _onRegisterRequested(
      RegisterRequested event, Emitter<AuthenticationState> emit) async {
    try {
      var box = await Hive.openBox<AddData>('user');
      var existingUser =
          box.values.firstWhereOrNull((u) => u.username == event.username);
      if (existingUser == null) {
        // Hash password dengan salt sebelum menyimpannya.
        final encryptedPassword = AESHelper.encrypt(event.password);
        var newUser = AddData(
          '',
          '0',
          '',
          DateTime.now(),
          '',
          event.username,
          encryptedPassword,
        );
        await box.add(newUser);
        emit(Authenticated(username: event.username, isAdmin: false));
        showSnackBar('Registration successful', AnimatedSnackBarType.success);
      } else {
        emit(Unauthenticated());
        showSnackBar('Registration failed: User already exists',
            AnimatedSnackBarType.error);
      }
    } catch (e) {
      emit(Unauthenticated());
      showSnackBar(
          'Registration failed: ${e.toString()}', AnimatedSnackBarType.error);
    }
  }

  bool checkPassword(String storedPassword, String enteredPassword) {
    // Implementasi pengecekan password dengan hashed dan salt.
    // Contoh: return hash(enteredPassword + salt) == storedPassword;
    return AESHelper.checkPassword(storedPassword, enteredPassword);
  }
}
