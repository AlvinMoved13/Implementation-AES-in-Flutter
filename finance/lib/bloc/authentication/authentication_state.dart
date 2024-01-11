import 'package:equatable/equatable.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object?> get props => [];
}

class Unauthenticated extends AuthenticationState {}

class Authenticated extends AuthenticationState {
  final String username;

  Authenticated({required this.username, required bool isAdmin});
}

class Guest extends AuthenticationState {}

class AdminAuthenticated extends AuthenticationState {
  final String username;

  AdminAuthenticated({required this.username});

  @override
  List<Object> get props => [username];
}
