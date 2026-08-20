import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_education/core/config/theme/app_colors.dart';
import 'bloc/profile_bloc.dart';
import 'bloc/profile_event.dart';
import 'bloc/profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _websiteController;
  late TextEditingController _locationController;
  Timer? _usernameDebounce;
  bool _initialized = false;

  @override
  void dispose() {
    _usernameDebounce?.cancel();
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _initControllers(ProfileLoaded state) {
    if (_initialized) return;
    _nameController = TextEditingController(text: state.profile.fullName);
    _usernameController = TextEditingController(text: state.profile.username);
    _bioController = TextEditingController(text: state.profile.bio);
    _websiteController = TextEditingController(text: state.profile.website);
    _locationController = TextEditingController(text: state.profile.location);
    _initialized = true;
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512);
    if (image != null) {
      context.read<ProfileBloc>().add(ProfileAvatarChangeRequested(image.path));
    }
  }

  void _save(BuildContext context) {
    context.read<ProfileBloc>().add(ProfileUpdateRequested(
          fullName: _nameController.text.trim(),
          username: _usernameController.text.trim(),
          bio: _bioController.text.trim(),
          website: _websiteController.text.trim(),
          location: _locationController.text.trim(),
        ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        title: const Text('Edit Profile'),
        actions: [
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is! ProfileLoaded) return const SizedBox.shrink();
              return TextButton(
                onPressed: state.isSaving ? null : () => _save(context),
                child: Text('Save', style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w600)),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is! ProfileLoaded) return const Center(child: CircularProgressIndicator());
            _initControllers(state);

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: Colors.white.withOpacity(0.06),
                        backgroundImage: state.profile.avatarUrl != null ? NetworkImage(state.profile.avatarUrl!) : null,
                        child: state.profile.avatarUrl == null ? Icon(Icons.person, size: 40, color: AppColors.textBodyColor) : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _pickImage(context),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primaryColor,
                            child: const Icon(Icons.camera_alt, size: 15, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(child: Text('Change photo', style: TextStyle(color: AppColors.primaryColor, fontSize: 13))),
                const SizedBox(height: 24),

                _FieldLabel('Full Name'),
                TextField(controller: _nameController, style: TextStyle(color: AppColors.textPrimaryColor), decoration: _decoration()),
                const SizedBox(height: 16),

                _FieldLabel('Username'),
                TextField(
                  controller: _usernameController,
                  style: TextStyle(color: AppColors.textPrimaryColor),
                  decoration: _decoration(suffix: state.usernameAvailable == null
                      ? null
                      : Icon(state.usernameAvailable! ? Icons.check_circle : Icons.error, size: 18,
                          color: state.usernameAvailable! ? Colors.greenAccent : Colors.redAccent)),
                  onChanged: (value) {
                    _usernameDebounce?.cancel();
                    _usernameDebounce = Timer(const Duration(milliseconds: 500), () {
                      context.read<ProfileBloc>().add(ProfileUsernameCheckRequested(value));
                    });
                  },
                ),
                const SizedBox(height: 16),

                _FieldLabel('Email'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    Expanded(child: Text(state.userEmail ?? '', style: TextStyle(color: AppColors.textBodyColor))),
                    Icon(Icons.lock_outline, size: 15, color: AppColors.textBodyColor),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Email can\'t be changed here', style: TextStyle(color: AppColors.textBodyColor, fontSize: 11)),
                ),
                const SizedBox(height: 16),

                _FieldLabel('Bio'),
                TextField(controller: _bioController, maxLines: 3, style: TextStyle(color: AppColors.textPrimaryColor), decoration: _decoration()),
                const SizedBox(height: 16),

                _FieldLabel('Website'),
                TextField(controller: _websiteController, style: TextStyle(color: AppColors.textPrimaryColor), decoration: _decoration()),
                const SizedBox(height: 16),

                _FieldLabel('Location'),
                TextField(controller: _locationController, style: TextStyle(color: AppColors.textPrimaryColor), decoration: _decoration()),
              ],
            );
          },
        ),
      ),
    );
  }

  InputDecoration _decoration({Widget? suffix}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffix,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: TextStyle(color: AppColors.textPrimaryColor, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}