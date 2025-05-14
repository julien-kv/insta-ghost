import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:instagram_clone/controllers/auth_controller.dart';
import 'dart:io';

class ProfileController extends GetxController {
  static ProfileController get to => Get.find();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthController _authController = AuthController.to;
  
  Rx<UserModel?> userProfile = Rx<UserModel?>(null);
  RxBool isLoading = false.obs;
  RxBool isFollowing = false.obs;
  
  Future<void> fetchUserProfile(String userId) async {
    isLoading.value = true;
    try {
      final DocumentSnapshot userDoc = 
          await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        userProfile.value = UserModel.fromSnapshot(userDoc);
        
        // Check if current user is following this profile
        if (_authController.userModel.value != null) {
          isFollowing.value = _authController.userModel.value!.following.contains(userId);
        }
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<String?> uploadProfileImage(File image) async {
    try {
      if (_authController.firebaseUser.value == null) return null;
      
      final String userId = _authController.firebaseUser.value!.uid;
      final String fileName = '${userId}_${const Uuid().v4()}.jpg';
      final Reference ref = _storage.ref().child('profile_images').child(fileName);
      
      // If user already has a profile image, delete it
      if (_authController.userModel.value?.profileImageUrl.isNotEmpty == true) {
        try {
          final Reference oldImageRef = 
              _storage.refFromURL(_authController.userModel.value!.profileImageUrl);
          await oldImageRef.delete();
        } catch (e) {
          print('Error deleting old profile image: $e');
        }
      }
      
      // Upload new image
      final UploadTask uploadTask = ref.putFile(image);
      final TaskSnapshot snapshot = await uploadTask;
      
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Update user profile
      await _authController.updateUserProfile(profileImageUrl: downloadUrl);
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }
  
  Future<void> followUser(String userId) async {
    try {
      if (_authController.firebaseUser.value == null) return;
      
      final currentUserId = _authController.firebaseUser.value!.uid;
      
      // Update current user's following list
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .update({
        'following': FieldValue.arrayUnion([userId]),
      });
      
      // Update target user's followers list
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'followers': FieldValue.arrayUnion([currentUserId]),
      });
      
      // Update local user model
      if (_authController.userModel.value != null) {
        final updatedFollowing = [..._authController.userModel.value!.following, userId];
        _authController.userModel.value = _authController.userModel.value!.copyWith(
          following: updatedFollowing,
        );
      }
      
      // Update viewed profile
      if (userProfile.value != null) {
        final updatedFollowers = [...userProfile.value!.followers, currentUserId];
        userProfile.value = userProfile.value!.copyWith(
          followers: updatedFollowers,
        );
      }
      
      isFollowing.value = true;
    } catch (e) {
      print('Error following user: $e');
    }
  }
  
  Future<void> unfollowUser(String userId) async {
    try {
      if (_authController.firebaseUser.value == null) return;
      
      final currentUserId = _authController.firebaseUser.value!.uid;
      
      // Update current user's following list
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .update({
        'following': FieldValue.arrayRemove([userId]),
      });
      
      // Update target user's followers list
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'followers': FieldValue.arrayRemove([currentUserId]),
      });
      
      // Update local user model
      if (_authController.userModel.value != null) {
        final updatedFollowing = [..._authController.userModel.value!.following]
          ..remove(userId);
        _authController.userModel.value = _authController.userModel.value!.copyWith(
          following: updatedFollowing,
        );
      }
      
      // Update viewed profile
      if (userProfile.value != null) {
        final updatedFollowers = [...userProfile.value!.followers]
          ..remove(currentUserId);
        userProfile.value = userProfile.value!.copyWith(
          followers: updatedFollowers,
        );
      }
      
      isFollowing.value = false;
    } catch (e) {
      print('Error unfollowing user: $e');
    }
  }
}