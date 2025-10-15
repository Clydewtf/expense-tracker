part of 'user_bloc.dart';


abstract class UserEvent {}

class LoadUser extends UserEvent {}

class UpdateCurrency extends UserEvent {
  final String currency;
  UpdateCurrency(this.currency);
}