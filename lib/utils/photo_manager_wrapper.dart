import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class PhotoManagerWrapper {
  static final PhotoManagerWrapper _instance = PhotoManagerWrapper._internal();
  factory PhotoManagerWrapper() => _instance;
  PhotoManagerWrapper._internal();

  final ImagePicker _picker = ImagePicker();

  // Fallback to image_picker if photo_manager has issues
  Future<File?> pickImage({bool camera = false}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: camera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  Future<List<File>> pickMultiImage() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: 70,
      );

      return pickedFiles.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick images: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return [];
    }
  }

  Future<File?> pickVideo() async {
    try {
      final XFile? pickedFile = await _picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick video: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }
}
