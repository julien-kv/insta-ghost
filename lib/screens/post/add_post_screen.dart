import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/controllers/auth_controller.dart';
import 'package:instagram_clone/controllers/post_controller.dart';
import 'package:instagram_clone/routes/app_pages.dart';
import 'package:instagram_clone/theme/app_theme.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final PostController _postController = Get.find<PostController>();
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final RxBool _isLoading = false.obs;
  File? _image;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() {
    if (AuthController.to.userModel.value == null) {
      Get.offAllNamed(Routes.LOGIN);
      Get.snackbar('Error', 'Please login to create a post');
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _createPost() async {
    if (_image == null) {
      Get.snackbar('Error', 'Please select an image');
      return;
    }

    _isLoading.value = true;

    final success = await _postController.createPost(
      _image!,
      _captionController.text.trim(),
      location: _locationController.text.trim(),
    );

    _isLoading.value = false;

    if (success) {
      Get.back();
      Get.snackbar('Success', 'Post created successfully');
    } else {
      Get.snackbar('Error', 'Failed to create post');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() => TextButton(
                onPressed: _isLoading.value || _image == null ? null : _createPost,
                child: _isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Share'),
              )),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image Preview
            _image == null
                ? GestureDetector(
                    onTap: () => _showImagePickerModal(),
                    child: Container(
                      height: 300,
                      width: double.infinity,
                      color: AppTheme.neutral200,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 80,
                            color: AppTheme.neutral600,
                          ),
                          SizedBox(height: AppTheme.spaceSmall),
                          Text(
                            'Tap to select an image',
                            style: TextStyle(
                              color: AppTheme.neutral700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(),
                    ),
                  )
                : Stack(
                    children: [
                      Image.file(
                        _image!,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ).animate().fadeIn(),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _image = null;
                          }),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

            // Caption & Location
            Padding(
              padding: const EdgeInsets.all(AppTheme.spaceSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Caption Field
                  TextField(
                    controller: _captionController,
                    decoration: const InputDecoration(
                      hintText: 'Write a caption...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    maxLines: 5,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                  ),

                  const Divider(),

                  // Location Field
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      hintText: 'Add location',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                        color: AppTheme.neutral600,
                      ),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Camera/Gallery Buttons
            if (_image == null)
              Padding(
                padding: const EdgeInsets.all(AppTheme.spaceSmall),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPickerButton(
                      icon: Icons.camera_alt_outlined,
                      label: 'Camera',
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                    _buildPickerButton(
                      icon: Icons.photo_library_outlined,
                      label: 'Gallery',
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withOpacity(0.1),
            ),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.spaceSmall),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
