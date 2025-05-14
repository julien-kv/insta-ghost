import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/controllers/auth_controller.dart';
import 'package:instagram_clone/controllers/profile_controller.dart';
import 'package:instagram_clone/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileController _profileController = Get.find<ProfileController>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final RxBool _isLoading = false.obs;
  File? _profileImage;
  
  @override
  void initState() {
    super.initState();
    _setInitialValues();
  }
  
  void _setInitialValues() {
    final user = AuthController.to.userModel.value;
    if (user != null) {
      _nameController.text = user.fullName;
      _usernameController.text = user.username;
      _bioController.text = user.bio;
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }
  
  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty || _usernameController.text.isEmpty) {
      Get.snackbar('Error', 'Name and username are required');
      return;
    }
    
    _isLoading.value = true;
    
    try {
      // Upload profile image if selected
      if (_profileImage != null) {
        await _profileController.uploadProfileImage(_profileImage!);
      }
      
      // Update profile info
      await AuthController.to.updateUserProfile(
        fullName: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        bio: _bioController.text.trim(),
      );
      
      Get.back();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() => IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading.value ? null : _saveProfile,
          )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceSmall),
        child: Column(
          children: [
            // Profile Picture
            Center(
              child: Stack(
                children: [
                  Obx(() {
                    final user = AuthController.to.userModel.value;
                    
                    return CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!) as ImageProvider
                        : (user?.profileImageUrl.isNotEmpty == true
                            ? NetworkImage(user!.profileImageUrl) as ImageProvider
                            : const AssetImage('assets/images/default_avatar.png')),
                    );
                  }),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.add_a_photo,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spaceMedium),
            
            // Form Fields
            _buildFormField(
              controller: _nameController,
              label: 'Name',
              hint: 'Enter your full name',
              icon: Icons.person,
            ),
            
            _buildFormField(
              controller: _usernameController,
              label: 'Username',
              hint: 'Enter your username',
              icon: Icons.alternate_email,
            ),
            
            _buildFormField(
              controller: _bioController,
              label: 'Bio',
              hint: 'Tell something about yourself',
              icon: Icons.info_outline,
              maxLines: 4,
            ),
            
            const SizedBox(height: AppTheme.spaceLarge),
            
            // Save Button
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading.value ? null : _saveProfile,
                child: _isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save Profile'),
              ),
            )),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon),
            ),
            maxLines: maxLines,
          ),
        ],
      ),
    );
  }
}