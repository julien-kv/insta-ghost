import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/controllers/auth_controller.dart';
import 'package:instagram_clone/controllers/post_controller.dart';
import 'package:instagram_clone/models/post_model.dart';
import 'package:instagram_clone/routes/app_pages.dart';
import 'package:instagram_clone/theme/app_theme.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_animate/flutter_animate.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final bool showCommentButton;
  
  const PostCard({
    Key? key,
    required this.post,
    this.showCommentButton = true,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final PostController _postController = Get.find<PostController>();
  final RxBool _isLiking = false.obs;
  final RxBool _showLikeAnimation = false.obs;
  
  @override
  Widget build(BuildContext context) {
    final isLiked = widget.post.likes.contains(
      AuthController.to.firebaseUser.value?.uid
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Post Header
        _buildPostHeader(),
        
        // Post Image
        GestureDetector(
          onDoubleTap: _likePost,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  widget.post.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              ),
              
              // Like Animation
              Obx(() => _showLikeAnimation.value
                ? Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 80,
                  ).animate(
                    onComplete: (controller) {
                      _showLikeAnimation.value = false;
                    },
                  ).scale(
                    duration: 200.ms,
                    curve: Curves.easeOutBack,
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.2, 1.2),
                  ).then(
                    duration: 200.ms,
                    curve: Curves.easeInBack,
                  ).scale(
                    begin: const Offset(1.2, 1.2),
                    end: const Offset(1, 1),
                  )
                : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        
        // Action Buttons
        Row(
          children: [
            Obx(() => IconButton(
              icon: isLiked
                ? const Icon(Icons.favorite, color: Colors.red)
                : const Icon(Icons.favorite_border),
              onPressed: _isLiking.value ? null : _likePost,
            )),
            
            if (widget.showCommentButton)
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: () {
                  Get.toNamed(Routes.COMMENTS, arguments: widget.post.id);
                },
              ),
            
            IconButton(
              icon: const Icon(Icons.send_outlined),
              onPressed: () {
                // TODO: Implement share functionality
                Get.snackbar('Coming Soon', 'Share functionality will be available soon');
              },
            ),
            
            const Spacer(),
            
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: () {
                // TODO: Implement bookmark functionality
                Get.snackbar('Coming Soon', 'Save functionality will be available soon');
              },
            ),
          ],
        ),
        
        // Likes Count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceSmall),
          child: Text(
            '${widget.post.likes.length} likes',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        
        // Caption
        if (widget.post.caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceSmall),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color),
                children: [
                  TextSpan(
                    text: widget.post.username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(text: widget.post.caption),
                ],
              ),
            ),
          ),
        
        // Comments Button
        if (widget.post.commentsCount > 0 && widget.showCommentButton)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceSmall),
            child: TextButton(
              onPressed: () {
                Get.toNamed(Routes.COMMENTS, arguments: widget.post.id);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                alignment: Alignment.centerLeft,
              ),
              child: Text(
                'View all ${widget.post.commentsCount} comments',
                style: TextStyle(color: AppTheme.neutral600),
              ),
            ),
          ),
        
        // Timestamp
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceSmall),
          child: Text(
            timeago.format(widget.post.createdAt.toDate()),
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.neutral500,
            ),
          ),
        ),
        
        const SizedBox(height: AppTheme.spaceSmall),
      ],
    );
  }
  
  Widget _buildPostHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceXSmall,
        vertical: AppTheme.spaceXSmall,
      ),
      child: Row(
        children: [
          // User Avatar
          GestureDetector(
            onTap: () {
              Get.toNamed(Routes.PROFILE, arguments: widget.post.userId);
            },
            child: CircleAvatar(
              radius: 16,
              backgroundImage: widget.post.userProfileImageUrl.isNotEmpty
                ? NetworkImage(widget.post.userProfileImageUrl) as ImageProvider
                : const AssetImage('assets/images/default_avatar.png'),
            ),
          ),
          
          const SizedBox(width: AppTheme.spaceXSmall),
          
          // Username and Location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username
                GestureDetector(
                  onTap: () {
                    Get.toNamed(Routes.PROFILE, arguments: widget.post.userId);
                  },
                  child: Text(
                    widget.post.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                
                // Location
                if (widget.post.location.isNotEmpty)
                  Text(
                    widget.post.location,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.neutral600,
                    ),
                  ),
              ],
            ),
          ),
          
          // Options Menu
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showOptionsMenu,
          ),
        ],
      ),
    );
  }
  
  Future<void> _likePost() async {
    _isLiking.value = true;
    _showLikeAnimation.value = true;
    
    await _postController.likePost(widget.post.id);
    
    _isLiking.value = false;
  }
  
  void _showOptionsMenu() {
    final isCurrentUser = AuthController.to.isCurrentUser(widget.post.userId);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCurrentUser)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Post'),
              onTap: () {
                Get.back();
                _showDeleteConfirmation();
              },
            ),
          
          if (!isCurrentUser)
            ListTile(
              leading: const Icon(Icons.block_outlined),
              title: const Text('Not Interested'),
              onTap: () {
                Get.back();
                Get.snackbar('Success', 'You will see fewer posts like this');
              },
            ),
          
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: const Text('Share'),
            onTap: () {
              Get.back();
              // TODO: Implement share functionality
              Get.snackbar('Coming Soon', 'Share functionality will be available soon');
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.link_outlined),
            title: const Text('Copy Link'),
            onTap: () {
              Get.back();
              // TODO: Implement copy link functionality
              Get.snackbar('Success', 'Link copied to clipboard');
            },
          ),
        ],
      ),
    );
  }
  
  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Post?'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _postController.deletePost(widget.post.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}