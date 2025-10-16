import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';

part 'user_event.dart';
part 'user_state.dart';


class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc({required this.userRepository}) : super(UserInitial()) {
    on<LoadUser>(_onLoadUser);
    on<UpdateCurrency>(_onUpdateCurrency);
  }

  Future<void> _onLoadUser(LoadUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final user = await userRepository.fetchCurrentUser();
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError('Failed to load user: $e'));
    }
  }

  Future<void> _onUpdateCurrency(UpdateCurrency event, Emitter<UserState> emit) async {
    if (state is! UserLoaded) return;

    final currentUser = (state as UserLoaded).user;
    emit(UserLoading());
    try {
      final updatedUser = await userRepository.updateCurrency(event.currency);
      emit(UserLoaded(updatedUser));
    } catch (e) {
      emit(UserError('Failed to update currency: $e'));
      emit(UserLoaded(currentUser));
    }
  }
}