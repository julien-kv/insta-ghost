import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/models/post_model.dart';
import 'package:instagram_clone/routes/app_pages.dart';

class PostGrid extends StatelessWidget {
  final List<PostModel> posts;
  
  const PostGrid({
    Key? key,
    required this.posts,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return GestureDetector(
          onTap: () {
            Get.toNamed(Routes.POST_DETAIL, arguments: post);
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                post.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  );
                },
              ),
              
              // Show like and comment count overlay
              if (post.likes.isNotEmpty || post.commentsCount > 0)
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Row(
                    children: [
                      if (post.likes.isNotEmpty)
                        _buildCountIndicator(
                          Icons.favorite_rounded,
                          post.likes.length.toString(),
                        ),
                      
                      const SizedBox(width: 6),
                      
                      if (post.commentsCount > 0)
                        _buildCountIndicator(
                          Icons.chat_bubble_rounded,
                          post.commentsCount.toString(),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildCountIndicator(IconData icon, String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 2),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}