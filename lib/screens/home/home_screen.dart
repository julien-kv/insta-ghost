import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/controllers/post_controller.dart';
import 'package:instagram_clone/controllers/story_controller.dart';
import 'package:instagram_clone/widgets/post_card.dart';
import 'package:instagram_clone/widgets/story_circle.dart';
import 'package:instagram_clone/theme/app_theme.dart';
import 'package:instagram_clone/models/story_model.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatelessWidget {
  final PostController _postController = Get.find<PostController>();
  final StoryController _storyController = Get.find<StoryController>();
  
  HomeScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Instagram',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontFamily: 'Billabong',
            fontSize: 32,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.send_outlined),
            onPressed: () {
              // TODO: Direct messages screen
              Get.snackbar('Coming Soon', 'Direct messages will be available soon');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _postController.fetchPosts();
          await _storyController.fetchAllStories();
        },
        child: CustomScrollView(
          slivers: [
            // Stories
            SliverToBoxAdapter(
              child: Obx(() {
                if (_storyController.isLoading.value) {
                  return const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                
                return _storyController.userStories.isEmpty
                  ? const SizedBox.shrink()
                  : _buildStories();
              }),
            ),
            
            // Divider
            const SliverToBoxAdapter(
              child: Divider(height: 1),
            ),
            
            // Posts
            Obx(() {
              if (_postController.isLoading.value) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              
              if (_postController.posts.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(),
                );
              }
              
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = _postController.posts[index];
                    return PostCard(post: post).animate().fadeIn(duration: 300.ms);
                  },
                  childCount: _postController.posts.length,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStories() {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: AppTheme.spaceSmall),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemCount: _storyController.userStories.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> userStoryData = _storyController.userStories[index];
          UserModel user = userStoryData['user'];
          List<StoryModel> stories = userStoryData['stories'];
          
          // Check if any story is not viewed
          bool hasUnseenStories = stories.any((story) => 
            !story.viewers.contains(user.id));
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: StoryCircle(
              user: user,
              stories: stories,
              hasUnseenStories: hasUnseenStories,
            ),
          ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.2, end: 0);
        },
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: AppTheme.neutral400,
          ),
          const SizedBox(height: AppTheme.spaceSmall),
          Text(
            'No Posts Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.neutral700,
            ),
          ),
          const SizedBox(height: AppTheme.spaceXSmall),
          Text(
            'Follow other users to see their posts here',
            style: TextStyle(
              color: AppTheme.neutral600,
            ),
          ),
          const SizedBox(height: AppTheme.spaceMedium),
          ElevatedButton(
            onPressed: () {
              Get.toNamed('/search');
            },
            child: const Text('Discover People'),
          ),
        ],
      ),
    );
  }
}