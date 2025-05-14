import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:instagram_clone/models/story_model.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:instagram_clone/controllers/auth_controller.dart';
import 'dart:io';

class StoryController extends GetxController {
  static StoryController get to => Get.find();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthController _authController = AuthController.to;
  
  RxList<Map<String, dynamic>> userStories = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchAllStories();
  }
  
  Future<void> fetchAllStories() async {
    isLoading.value = true;
    try {
      if (_authController.userModel.value == null) return;
      
      List<String> followingIds = _authController.userModel.value!.following;
      followingIds.add(_authController.userModel.value!.id); // Include user's own stories
      
      // Get all users that have stories
      List<Map<String, dynamic>> stories = [];
      
      for (String userId in followingIds) {
        // Get user data
        final DocumentSnapshot userDoc = 
            await _firestore.collection('users').doc(userId).get();
        
        if (!userDoc.exists) continue;
        
        final UserModel user = UserModel.fromSnapshot(userDoc);
        
        // Get user's stories from the last 24 hours
        final Timestamp twentyFourHoursAgo = 
            Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 24)));
        
        final QuerySnapshot storiesSnapshot = await _firestore
            .collection('stories')
            .where('userId', isEqualTo: userId)
            .where('createdAt', isGreaterThan: twentyFourHoursAgo)
            .orderBy('createdAt', descending: false)
            .get();
        
        if (storiesSnapshot.docs.isEmpty) continue;
        
        final List<StoryModel> userStoriesList = storiesSnapshot.docs
            .map((doc) => StoryModel.fromSnapshot(doc))
            .toList();
        
        // Add to stories list
        stories.add({
          'user': user,
          'stories': userStoriesList,
        });
      }
      
      userStories.value = stories;
    } catch (e) {
      print('Error fetching stories: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> createStory(File media, {bool isVideo = false}) async {
    isLoading.value = true;
    try {
      if (_authController.userModel.value == null) return false;
      
      // Upload media
      String fileName = '${const Uuid().v4()}${isVideo ? '.mp4' : '.jpg'}';
      Reference ref = _storage.ref().child('stories').child(fileName);
      
      UploadTask uploadTask = ref.putFile(media);
      TaskSnapshot snapshot = await uploadTask;
      
      String mediaUrl = await snapshot.ref.getDownloadURL();
      
      // Create story
      String storyId = const Uuid().v4();
      DateTime expiresAt = DateTime.now().add(const Duration(hours: 24));
      
      StoryModel newStory = StoryModel(
        id: storyId,
        userId: _authController.userModel.value!.id,
        username: _authController.userModel.value!.username,
        userProfileImageUrl: _authController.userModel.value!.profileImageUrl,
        mediaUrl: mediaUrl,
        isVideo: isVideo,
        createdAt: Timestamp.now(),
        expiresAt: Timestamp.fromDate(expiresAt),
      );
      
      // Save story to Firestore
      await _firestore
          .collection('stories')
          .doc(storyId)
          .set(newStory.toJson());
      
      // Refresh stories
      await fetchAllStories();
      
      return true;
    } catch (e) {
      print('Error creating story: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> viewStory(String storyId) async {
    try {
      if (_authController.firebaseUser.value == null) return;
      
      final userId = _authController.firebaseUser.value!.uid;
      
      await _firestore
          .collection('stories')
          .doc(storyId)
          .update({
        'viewers': FieldValue.arrayUnion([userId]),
      });
      
      // Update local story model
      for (int i = 0; i < userStories.length; i++) {
        final userStoryData = userStories[i];
        final List<StoryModel> stories = userStoryData['stories'];
        
        for (int j = 0; j < stories.length; j++) {
          if (stories[j].id == storyId) {
            if (!stories[j].viewers.contains(userId)) {
              final updatedViewers = [...stories[j].viewers, userId];
              stories[j] = StoryModel(
                id: stories[j].id,
                userId: stories[j].userId,
                username: stories[j].username,
                userProfileImageUrl: stories[j].userProfileImageUrl,
                mediaUrl: stories[j].mediaUrl,
                isVideo: stories[j].isVideo,
                viewers: updatedViewers,
                createdAt: stories[j].createdAt,
                expiresAt: stories[j].expiresAt,
              );
            }
            break;
          }
        }
      }
    } catch (e) {
      print('Error viewing story: $e');
    }
  }
  
  Future<void> deleteStory(String storyId) async {
    try {
      if (_authController.firebaseUser.value == null) return;
      
      // Get story data
      final DocumentSnapshot storySnapshot = 
          await _firestore.collection('stories').doc(storyId).get();
      
      if (!storySnapshot.exists) return;
      
      final story = StoryModel.fromSnapshot(storySnapshot);
      
      // Check if current user is the story owner
      if (story.userId != _authController.firebaseUser.value!.uid) {
        Get.snackbar('Error', 'You can only delete your own stories');
        return;
      }
      
      // Delete story from Firestore
      await _firestore.collection('stories').doc(storyId).delete();
      
      // Delete story media from storage
      final Reference mediaRef = _storage.refFromURL(story.mediaUrl);
      await mediaRef.delete();
      
      // Refresh stories
      await fetchAllStories();
      
      Get.snackbar('Success', 'Story deleted successfully');
    } catch (e) {
      print('Error deleting story: $e');
      Get.snackbar('Error', 'Failed to delete story');
    }
  }
}