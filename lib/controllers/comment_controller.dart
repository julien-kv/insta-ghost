import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:instagram_clone/models/comment_model.dart';
import 'package:instagram_clone/controllers/auth_controller.dart';

class CommentController extends GetxController {
  static CommentController get to => Get.find();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = AuthController.to;
  
  RxList<CommentModel> comments = <CommentModel>[].obs;
  RxBool isLoading = false.obs;
  
  Future<void> fetchComments(String postId) async {
    isLoading.value = true;
    try {
      final QuerySnapshot commentsSnapshot = await _firestore
          .collection('comments')
          .where('postId', isEqualTo: postId)
          .orderBy('createdAt', descending: false)
          .get();
      
      comments.value = commentsSnapshot.docs
          .map((doc) => CommentModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error fetching comments: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> addComment(String postId, String text) async {
    try {
      if (_authController.userModel.value == null) return false;
      
      String commentId = const Uuid().v4();
      CommentModel newComment = CommentModel(
        id: commentId,
        postId: postId,
        userId: _authController.userModel.value!.id,
        username: _authController.userModel.value!.username,
        userProfileImageUrl: _authController.userModel.value!.profileImageUrl,
        text: text,
        createdAt: Timestamp.now(),
      );
      
      // Save comment to Firestore
      await _firestore
          .collection('comments')
          .doc(commentId)
          .set(newComment.toJson());
      
      // Update post's comment count
      await _firestore
          .collection('posts')
          .doc(postId)
          .update({
        'commentsCount': FieldValue.increment(1),
      });
      
      comments.add(newComment);
      return true;
    } catch (e) {
      print('Error adding comment: $e');
      return false;
    }
  }
  
  Future<void> likeComment(String commentId) async {
    try {
      if (_authController.firebaseUser.value == null) return;
      
      final userId = _authController.firebaseUser.value!.uid;
      final commentRef = _firestore.collection('comments').doc(commentId);
      
      final DocumentSnapshot commentSnapshot = await commentRef.get();
      final comment = CommentModel.fromSnapshot(commentSnapshot);
      
      if (comment.likes.contains(userId)) {
        // Unlike comment
        await commentRef.update({
          'likes': FieldValue.arrayRemove([userId]),
        });
        
        // Update comment in comments list
        final index = comments.indexWhere((c) => c.id == commentId);
        if (index != -1) {
          final updatedLikes = [...comment.likes]..remove(userId);
          comments[index] = CommentModel(
            id: comment.id,
            postId: comment.postId,
            userId: comment.userId,
            username: comment.username,
            userProfileImageUrl: comment.userProfileImageUrl,
            text: comment.text,
            likes: updatedLikes,
            createdAt: comment.createdAt,
          );
        }
      } else {
        // Like comment
        await commentRef.update({
          'likes': FieldValue.arrayUnion([userId]),
        });
        
        // Update comment in comments list
        final index = comments.indexWhere((c) => c.id == commentId);
        if (index != -1) {
          final updatedLikes = [...comment.likes, userId];
          comments[index] = CommentModel(
            id: comment.id,
            postId: comment.postId,
            userId: comment.userId,
            username: comment.username,
            userProfileImageUrl: comment.userProfileImageUrl,
            text: comment.text,
            likes: updatedLikes,
            createdAt: comment.createdAt,
          );
        }
      }
    } catch (e) {
      print('Error liking comment: $e');
    }
  }
  
  Future<void> deleteComment(String commentId, String postId) async {
    try {
      if (_authController.firebaseUser.value == null) return;
      
      // Get comment data
      final DocumentSnapshot commentSnapshot = 
          await _firestore.collection('comments').doc(commentId).get();
      
      if (!commentSnapshot.exists) return;
      
      final comment = CommentModel.fromSnapshot(commentSnapshot);
      
      // Check if current user is the comment owner
      if (comment.userId != _authController.firebaseUser.value!.uid) {
        Get.snackbar('Error', 'You can only delete your own comments');
        return;
      }
      
      // Delete comment from Firestore
      await _firestore.collection('comments').doc(commentId).delete();
      
      // Update post's comment count
      await _firestore
          .collection('posts')
          .doc(postId)
          .update({
        'commentsCount': FieldValue.increment(-1),
      });
      
      // Remove comment from comments list
      comments.removeWhere((c) => c.id == commentId);
      
      Get.snackbar('Success', 'Comment deleted successfully');
    } catch (e) {
      print('Error deleting comment: $e');
      Get.snackbar('Error', 'Failed to delete comment');
    }
  }
}