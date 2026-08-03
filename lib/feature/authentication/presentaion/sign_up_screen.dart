import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_education/core/config/route/app_routes.dart';
import 'package:project_education/core/config/theme/app_colors.dart';
import 'package:project_education/core/utils/shared_widgets/app_button.dart';
import 'package:project_education/feature/authentication/presentaion/bloc/auth_bloc.dart';
import 'package:project_education/feature/authentication/presentaion/bloc/auth_event.dart';
import 'package:project_education/feature/authentication/presentaion/bloc/auth_state.dart';
import 'package:project_education/injection_container.dart';
import 'package:project_education/shared/widgets/text_widget.dart';


enum _PasswordStrength { empty, weak, fair, good, strong }

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: const _SignUpView(),
    );
  }
}

class _SignUpView extends StatefulWidget {
  const _SignUpView();

  @override
  State<_SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<_SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  _PasswordStrength _strength = _PasswordStrength.empty;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updateStrength);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_updateStrength);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updateStrength() {
    final value = _passwordController.text;
    _PasswordStrength next;

    if (value.isEmpty) {
      next = _PasswordStrength.empty;
    } else {
      int score = 0;
      if (value.length >= 6) score++;
      if (value.length >= 10) score++;
      if (RegExp(r'[A-Z]').hasMatch(value)) score++;
      if (RegExp(r'[0-9]').hasMatch(value)) score++;
      if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) score++;

      if (score <= 1) {
        next = _PasswordStrength.weak;
      } else if (score == 2) {
        next = _PasswordStrength.fair;
      } else if (score <= 4) {
        next = _PasswordStrength.good;
      } else {
        next = _PasswordStrength.strong;
      }
    }

    if (next != _strength) {
      setState(() => _strength = next);
    }
  }

  String? _validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) return 'First name is required';
    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Last name is required';
    return null;
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

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  void _submit(BuildContext context) {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms of Service and Privacy Policy')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            SignUpRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
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
              // TODO: replace with your actual post-signup destination
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
                    textHeadingWidget(text: 'Create account'),
                    const SizedBox(height: 8),
                    textSubHeadingWidget(text: 'Start your learning journey today.'),
                    const SizedBox(height: 24),

                    _SocialButton(
                      label: 'Continue with Google',
                      icon: Icons.g_mobiledata,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Google sign-up coming soon')),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _SocialButton(
                      label: 'Continue with GitHub',
                      icon: Icons.code,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('GitHub sign-up coming soon')),
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
                            'OR SIGN UP WITH EMAIL',
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

                    // First name / Last name
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _LabeledField(
                            label: 'First Name',
                            child: TextFormField(
                              controller: _firstNameController,
                              validator: _validateFirstName,
                              style: TextStyle(color: AppColors.textPrimaryColor),
                              decoration: _fieldDecoration(hint: 'Alex', prefixIcon: Icons.person_outline),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _LabeledField(
                            label: 'Last Name',
                            child: TextFormField(
                              controller: _lastNameController,
                              validator: _validateLastName,
                              style: TextStyle(color: AppColors.textPrimaryColor),
                              decoration: _fieldDecoration(hint: 'Johnson'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    _LabeledField(
                      label: 'Email address',
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        style: TextStyle(color: AppColors.textPrimaryColor),
                        decoration: _fieldDecoration(hint: 'you@example.com', prefixIcon: Icons.mail_outline),
                      ),
                    ),
                    const SizedBox(height: 18),

                    _LabeledField(
                      label: 'Password',
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: _validatePassword,
                        style: TextStyle(color: AppColors.textPrimaryColor),
                        decoration: _fieldDecoration(
                          hint: 'Create a password',
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _PasswordStrengthMeter(strength: _strength),
                    const SizedBox(height: 18),

                    _LabeledField(
                      label: 'Confirm Password',
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        validator: _validateConfirmPassword,
                        style: TextStyle(color: AppColors.textPrimaryColor),
                        decoration: _fieldDecoration(
                          hint: 'Repeat your password',
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Terms checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: Checkbox(
                            value: _agreedToTerms,
                            onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
                            activeColor: AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(color: AppColors.textBodyColor, fontSize: 13),
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w600),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // TODO: open Terms of Service
                                    },
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w600),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // TODO: open Privacy Policy
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    AppButton(
                      text: 'Create Account',
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
                            const TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Sign In',
                              style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w600),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context).pushReplacementNamed(AppRoutes.signInScreen);
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

  InputDecoration _fieldDecoration({
    required String hint,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.backgroundColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.textPrimaryColor, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _PasswordStrengthMeter extends StatelessWidget {
  final _PasswordStrength strength;

  const _PasswordStrengthMeter({required this.strength});

  int get _filledSegments {
    switch (strength) {
      case _PasswordStrength.empty:
        return 0;
      case _PasswordStrength.weak:
        return 1;
      case _PasswordStrength.fair:
        return 2;
      case _PasswordStrength.good:
        return 3;
      case _PasswordStrength.strong:
        return 4;
    }
  }

  Color get _color {
    switch (strength) {
      case _PasswordStrength.empty:
        return Colors.transparent;
      case _PasswordStrength.weak:
        return Colors.redAccent;
      case _PasswordStrength.fair:
        return Colors.orangeAccent;
      case _PasswordStrength.good:
        return Colors.lightBlueAccent;
      case _PasswordStrength.strong:
        return Colors.greenAccent;
    }
  }

  String get _label {
    switch (strength) {
      case _PasswordStrength.empty:
        return '';
      case _PasswordStrength.weak:
        return 'Weak';
      case _PasswordStrength.fair:
        return 'Fair';
      case _PasswordStrength.good:
        return 'Good';
      case _PasswordStrength.strong:
        return 'Strong';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (strength == _PasswordStrength.empty) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: Row(
            children: List.generate(4, (index) {
              final filled = index < _filledSegments;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index == 3 ? 0 : 4),
                  height: 4,
                  decoration: BoxDecoration(
                    color: filled ? _color : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 10),
        Text(_label, style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _SocialButton({required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.textPrimaryColor),
        label: Text(label, style: TextStyle(color: AppColors.textPrimaryColor, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.textBodyColor.withOpacity(0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}