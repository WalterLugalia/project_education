import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_education/core/config/route/app_routes.dart';
import 'package:project_education/core/config/theme/app_colors.dart';
import 'package:project_education/core/utils/shared_widgets/app_button.dart';
import 'package:project_education/core/utils/validators.dart';
import 'package:project_education/feature/authentication/presentaion/bloc/auth_bloc.dart';
import 'package:project_education/feature/authentication/presentaion/bloc/auth_event.dart';
import 'package:project_education/feature/authentication/presentaion/bloc/auth_state.dart'   show AuthState, AuthSuccess, AuthFailure, AuthLoading;
import 'package:project_education/feature/authentication/presentaion/widgets/app_social_button.dart';
import 'package:project_education/feature/authentication/presentaion/widgets/auth_bottom_prompt.dart';
import 'package:project_education/feature/authentication/presentaion/widgets/auth_divider.dart';
import 'package:project_education/injection_container.dart';
import 'package:project_education/shared/widgets/app_text_field.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                          child: Image.asset(
                'assets/logo.png',
                width: 130,
                height: 150,
              ),
                        ),
                        const SizedBox(width: 10),
                        textSubHeadingWidget(
                text: 'LearnSHelf',
              )
                      ],
                    ),
                    const SizedBox(height: 32),

                    textHeadingWidget(text: 'Welcome back'),
                    const SizedBox(height: 8),
                    textSubHeadingWidget(text: 'Pick up where your curiosity left off.'),
                    const SizedBox(height: 28),

                    AppSocialButton(
                      label: 'Continue with Google',
                      icon: Icons.g_mobiledata,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Google sign-in coming soon')),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    AppSocialButton(
                      label: 'Continue with GitHub',
                      icon: Icons.code,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('GitHub sign-in coming soon')),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    const AuthDivider(label: 'OR CONTINUE WITH EMAIL'),
                    const SizedBox(height: 24),

                    AppTextField(
                      label: 'Email address',
                      hint: 'you@example.com',
                      controller: _emailController,
                      prefixIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 18),

                    AppTextField(
                      label: 'Password',
                      hint: 'Enter your password',
                      controller: _passwordController,
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      validator: Validators.password,
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

                    AuthBottomPrompt(
                      promptText: "Don't have an account? ",
                      actionText: 'Sign Up',
                      onActionTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.signUp),
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