import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_education/core/config/theme/app_colors.dart';
import 'package:project_education/core/utils/shared_widgets/app_button.dart';
import 'package:project_education/core/utils/validators.dart';
import 'package:project_education/feature/authentication/presentaion/bloc/auth_bloc.dart';
import 'package:project_education/feature/authentication/presentaion/bloc/auth_event.dart';
import 'package:project_education/feature/authentication/presentaion/bloc/auth_state.dart';
import 'package:project_education/injection_container.dart';
import 'package:project_education/shared/widgets/app_text_field.dart';
import 'package:project_education/shared/widgets/text_widget.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatefulWidget {
  const _ChangePasswordView();

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            ChangePasswordRequested(newPassword: _passwordController.text),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: const Text('Change Password'),
      ),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AppAuthState>(
          listener: (context, state) {
            if (state is PasswordUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password updated successfully.')),
              );
              Navigator.of(context).pop();
            }
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      label: 'New Password',
                      hint: 'Enter new password',
                      controller: _passwordController,
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 18),

                    AppTextField(
                      label: 'Confirm New Password',
                      hint: 'Repeat new password',
                      controller: _confirmController,
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      validator: (value) =>
                          Validators.confirmPassword(value, _passwordController.text),
                    ),
                    const SizedBox(height: 24),

                    AppButton(
                      text: 'Update Password',
                      isFullWidth: true,
                      isLoading: isLoading,
                      onPressed: () => _submit(context),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}