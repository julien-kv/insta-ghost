import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/controllers/comment_controller.dart';
import 'package:instagram_clone/controllers/auth_controller.dart';
import 'package:instagram_clone/theme/app_theme.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_animate/flutter_animate.dart';

class CommentList extends StatelessWidget {
  final String postId;
  
  const CommentList({
    Key? key,
    required this.postId,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final CommentController controller = Get.find<CommentController>();
    
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (controller.comments.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: AppTheme.neutral400,
              ),
              const SizedBox(height: AppTheme.spaceSmall),
              Text(
                'No Comments Yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neutral700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Be the first to comment',
                style: TextStyle(
                  color: AppTheme.neutral600,
                ),
              ),
            ],
          ),
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.only(top: AppTheme.spaceSmall),
        itemCount: controller.comments.length,
        itemBuilder: (context, index) {
          final comment = controller.comments[index];
          final isLiked = comment.likes.contains(
            AuthController.to.firebaseUser.value?.uid
          );
          final isAuthor = comment.userId == AuthController.to.firebaseUser.value?.uid;
          
          return ListTile(
            leading: CircleAvatar(
              radius: 16,
              backgroundImage: comment.userProfileImageUrl.isNotEmpty
                ? NetworkImage(comment.userProfileImageUrl) as ImageProvider
                : const AssetImage('assets/images/default_avatar.png'),
            ),
            title: Row(
              children: [
                Text(
                  comment.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  timeago.format(comment.createdAt.toDate()),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.neutral500,
                  ),
                ),
              ],
            ),
            subtitle: Text(comment.text),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: isLiked
                    ? const Icon(Icons.favorite, size: 16, color: Colors.red)
                    : const Icon(Icons.favorite_border, size: 16),
                  onPressed: () {
                    controller.likeComment(comment.id);
                  },
                ),
                if (comment.likes.isNotEmpty)
                  Text(
                    '${comment.likes.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.neutral600,
                    ),
                  ),
                if (isAuthor)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16),
                    onPressed: () {
                      _showDeleteConfirmation(context, comment.id);
                    },
                  ),
              ],
            ),
          ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.05, end: 0);
        },
      );
    });
  }
  
  void _showDeleteConfirmation(BuildContext context, String commentId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Comment?'),
        content: const Text('Are you sure you want to delete this comment? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.find<CommentController>().deleteComment(commentId, postId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}