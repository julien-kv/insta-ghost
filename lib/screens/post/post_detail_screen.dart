import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/controllers/post_controller.dart';
import 'package:instagram_clone/controllers/comment_controller.dart';
import 'package:instagram_clone/models/post_model.dart';
import 'package:instagram_clone/widgets/post_card.dart';
import 'package:instagram_clone/widgets/comment_list.dart';
import 'package:instagram_clone/theme/app_theme.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({Key? key}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late PostModel post;
  final CommentController _commentController = Get.put(CommentController());
  final TextEditingController _commentTextController = TextEditingController();
  final RxBool _isPostingComment = false.obs;
  
  @override
  void initState() {
    super.initState();
    post = Get.arguments as PostModel;
    _commentController.fetchComments(post.id);
  }
  
  @override
  void dispose() {
    _commentTextController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
      ),
      body: Column(
        children: [
          // Post Card
          PostCard(
            post: post,
            showCommentButton: false,
          ),
          
          const Divider(height: 1),
          
          // Comments Section
          Expanded(
            child: CommentList(postId: post.id),
          ),
          
          // Comment Input
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceSmall,
              vertical: AppTheme.spaceXSmall,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentTextController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                  ),
                ),
                Obx(() => TextButton(
                  onPressed: _isPostingComment.value || _commentTextController.text.isEmpty
                    ? null
                    : _postComment,
                  child: _isPostingComment.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Text('Post', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _commentTextController.text.isEmpty
                        ? AppTheme.neutral400
                        : AppTheme.primaryColor,
                    )),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _postComment() async {
    if (_commentTextController.text.isEmpty) return;
    
    _isPostingComment.value = true;
    
    final success = await _commentController.addComment(
      post.id,
      _commentTextController.text.trim(),
    );
    
    _isPostingComment.value = false;
    
    if (success) {
      _commentTextController.clear();
      
      // Update post comments count in UI
      final updatedPost = post.copyWith(
        commentsCount: post.commentsCount + 1,
      );
      setState(() {
        post = updatedPost;
      });
      
      // Also update in the posts list
      final postController = Get.find<PostController>();
      final postIndex = postController.posts.indexWhere((p) => p.id == post.id);
      if (postIndex != -1) {
        postController.posts[postIndex] = updatedPost;
      }
    }
  }
}