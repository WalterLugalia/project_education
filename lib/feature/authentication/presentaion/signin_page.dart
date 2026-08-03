import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_education/core/config/route/app_routes.dart';
import 'package:project_education/core/config/theme/app_colors.dart';
import 'package:project_education/core/utils/shared_widgets/app_button.dart';
import 'package:project_education/feature/authentication/presentaion/bloc/auth_bloc.dart';
import 'package:project_education/feature/authentication/presentaion/bloc/auth_event.dart';
import 'package:project_education/feature/authentication/presentaion/bloc/auth_state.dart' show AuthState, AuthSuccess, AuthFailure, AuthLoading;
import 'package:project_education/injection_container.dart';
import 'package:project_education/shared/widgets/text_widget.dart';


class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: const _SignInView(),
    );
  }
}

class _SignInView extends StatefulWidget {
  const _SignInView();

  @override
  State<_SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<_SignInView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            SignInRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              // TODO: replace with your actual post-login destination
              Navigator.of(context).pushReplacementNamed(AppRoutes.home);
            }
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'L',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Learnly',
                          style: TextStyle(
                            color: AppColors.textPrimaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    textHeadingWidget(text: 'Welcome back'),
                    const SizedBox(height: 8),
                    textSubHeadingWidget(text: 'Pick up where your curiosity left off.'),
                    const SizedBox(height: 28),

                    _SocialButton(
                      label: 'Continue with Google',
                      icon: Icons.g_mobiledata,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Google sign-in coming soon')),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _SocialButton(
                      label: 'Continue with GitHub',
                      icon: Icons.code,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('GitHub sign-in coming soon')),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.textBodyColor.withOpacity(0.3))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'OR CONTINUE WITH EMAIL',
                            style: TextStyle(
                              color: AppColors.textBodyColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: AppColors.textBodyColor.withOpacity(0.3))),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Text('Email address', style: TextStyle(color: AppColors.textPrimaryColor, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      style: TextStyle(color: AppColors.textPrimaryColor),
                      decoration: InputDecoration(
                        hintText: 'you@example.com',
                        prefixIcon: const Icon(Icons.mail_outline),
                        filled: true,
                        fillColor: AppColors.backgroundColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 18),

                    Text('Password', style: TextStyle(color: AppColors.textPrimaryColor, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      validator: _validatePassword,
                      style: TextStyle(color: AppColors.textPrimaryColor),
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        filled: true,
                        fillColor: AppColors.backgroundColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: wire up forgot-password flow
                        },
                        child: Text('Forgot password?', style: TextStyle(color: AppColors.primaryColor)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    AppButton(
                      text: 'Sign In',
                      isFullWidth: true,
                      isLoading: isLoading,
                      onPressed: () => _submit(context),
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: AppColors.textBodyColor),
                          children: [
                            const TextSpan(text: "Don't have an account? "),
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w600),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context).pushReplacementNamed(AppRoutes.signUp);
                                },
                            ),
                          ],
                        ),
                      ),
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

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.textPrimaryColor),
        label: Text(
          label,
          style: TextStyle(color: AppColors.textPrimaryColor, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.textBodyColor.withOpacity(0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}