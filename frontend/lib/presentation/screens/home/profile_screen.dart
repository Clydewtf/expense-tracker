import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/user/user_bloc.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  final List<String> currencies = const ['USD', 'EUR', 'RUB'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<UserBloc, UserState>(
          listener: (context, state) {
            if (state is UserError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is UserLoaded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Currency updated')),
              );
            }
          },
          builder: (context, state) {
            if (state is UserLoading || state is UserInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is UserLoaded) {
              String? selectedCurrency = state.user.defaultCurrency;

              return Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedCurrency,
                    items: currencies
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        context.read<UserBloc>().add(UpdateCurrency(value));
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Base Currency'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthLogoutRequested());
                      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Logout'),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}