import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:instagram_clone/models/post_model.dart';
import 'package:instagram_clone/controllers/auth_controller.dart';
import 'dart:io';

class PostController extends GetxController {
  static PostController get to => Get.find();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthController _authController = AuthController.to;
  
  RxList<PostModel> posts = <PostModel>[].obs;
  RxList<PostModel> userPosts = <PostModel>[].obs;
  RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }
  
  Future<void> fetchPosts() async {
    isLoading.value = true;
    try {
      if (_authController.userModel.value == null) return;
      
      List<String> followingIds = _authController.userModel.value!.following;
      followingIds.add(_authController.userModel.value!.id); // Include user's own posts
      
      final QuerySnapshot postsSnapshot = await _firestore
          .collection('posts')
          .where('userId', whereIn: followingIds.isEmpty ? [''] : followingIds)
          .orderBy('createdAt', descending: true)
          .get();
      
      posts.value = postsSnapshot.docs
          .map((doc) => PostModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error fetching posts: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> fetchUserPosts(String userId) async {
    isLoading.value = true;
    try {
      final QuerySnapshot postsSnapshot = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      userPosts.value = postsSnapshot.docs
          .map((doc) => PostModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error fetching user posts: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<String?> uploadImage(File image) async {
    try {
      final String fileName = '${const Uuid().v4()}.jpg';
      final Reference ref = _storage.ref().child('posts').child(fileName);
      
      // Compress image before uploading
      final UploadTask uploadTask = ref.putFile(image);
      final TaskSnapshot snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
  
  Future<bool> createPost(File image, String caption, {String? location}) async {
    isLoading.value = true;
    try {
      if (_authController.userModel.value == null) return false;
      
      // Extract hashtags and mentions
      List<String> hashtags = _extractHashtags(caption);
      List<String> mentions = _extractMentions(caption);
      
      // Upload image
      String? imageUrl = await uploadImage(image);
      if (imageUrl == null) return false;
      
      // Create post
      String postId = const Uuid().v4();
      PostModel newPost = PostModel(
        id: postId,
        userId: _authController.userModel.value!.id,
        username: _authController.userModel.value!.username,
        userProfileImageUrl: _authController.userModel.value!.profileImageUrl,
        imageUrl: imageUrl,
        caption: caption,
        hashtags: hashtags,
        mentions: mentions,
        createdAt: Timestamp.now(),
        location: location ?? '',
      );
      
      // Save post to Firestore
      await _firestore
          .collection('posts')
          .doc(postId)
          .set(newPost.toJson());
      
      // Update user's post count
      await _firestore
          .collection('users')
          .doc(_authController.userModel.value!.id)
          .update({
        'postsCount': FieldValue.increment(1),
      });
      
      // Add post to posts list
      posts.insert(0, newPost);
      
      return true;
    } catch (e) {
      print('Error creating post: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> likePost(String postId) async {
    try {
      if (_authController.firebaseUser.value == null) return;
      
      final userId = _authController.firebaseUser.value!.uid;
      final postRef = _firestore.collection('posts').doc(postId);
      
      final DocumentSnapshot postSnapshot = await postRef.get();
      final post = PostModel.fromSnapshot(postSnapshot);
      
      if (post.likes.contains(userId)) {
        // Unlike post
        await postRef.update({
          'likes': FieldValue.arrayRemove([userId]),
        });
        
        // Update post in posts list
        final index = posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          final updatedLikes = [...post.likes]..remove(userId);
          posts[index] = post.copyWith(likes: updatedLikes);
        }
      } else {
        // Like post
        await postRef.update({
          'likes': FieldValue.arrayUnion([userId]),
        });
        
        // Update post in posts list
        final index = posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          final updatedLikes = [...post.likes, userId];
          posts[index] = post.copyWith(likes: updatedLikes);
        }
      }
    } catch (e) {
      print('Error liking post: $e');
    }
  }
  
  Future<void> deletePost(String postId) async {
    try {
      if (_authController.firebaseUser.value == null) return;
      
      // Get post data first to get the image URL
      final DocumentSnapshot postSnapshot = 
          await _firestore.collection('posts').doc(postId).get();
      
      if (!postSnapshot.exists) return;
      
      final post = PostModel.fromSnapshot(postSnapshot);
      
      // Check if current user is the post owner
      if (post.userId != _authController.firebaseUser.value!.uid) {
        Get.snackbar('Error', 'You can only delete your own posts');
        return;
      }
      
      // Delete post from Firestore
      await _firestore.collection('posts').doc(postId).delete();
      
      // Delete post image from storage
      final Reference imageRef = _storage.refFromURL(post.imageUrl);
      await imageRef.delete();
      
      // Update user's post count
      await _firestore
          .collection('users')
          .doc(_authController.firebaseUser.value!.uid)
          .update({
        'postsCount': FieldValue.increment(-1),
      });
      
      // Remove post from posts list
      posts.removeWhere((p) => p.id == postId);
      userPosts.removeWhere((p) => p.id == postId);
      
      Get.snackbar('Success', 'Post deleted successfully');
    } catch (e) {
      print('Error deleting post: $e');
      Get.snackbar('Error', 'Failed to delete post');
    }
  }
  
  List<String> _extractHashtags(String text) {
    final RegExp hashtagRegExp = RegExp(r'#(\w+)');
    final Iterable<Match> matches = hashtagRegExp.allMatches(text);
    return matches.map((match) => '#${match.group(1)}').toList();
  }
  
  List<String> _extractMentions(String text) {
    final RegExp mentionRegExp = RegExp(r'@(\w+)');
    final Iterable<Match> matches = mentionRegExp.allMatches(text);
    return matches.map((match) => '@${match.group(1)}').toList();
  }
}