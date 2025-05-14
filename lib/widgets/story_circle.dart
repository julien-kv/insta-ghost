import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/controllers/story_controller.dart' as story_controller;
import 'package:instagram_clone/models/story_model.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:instagram_clone/theme/app_theme.dart';
import 'package:story_view/story_view.dart';

class StoryCircle extends StatelessWidget {
  final UserModel user;
  final List<StoryModel> stories;
  final bool hasUnseenStories;

  const StoryCircle({
    super.key,
    required this.user,
    required this.stories,
    required this.hasUnseenStories,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openStory(context),
      child: Column(
        children: [
          // Story Circle
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: hasUnseenStories
                  ? const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.secondaryColor,
                        AppTheme.accentColor,
                      ],
                    )
                  : null,
              border: hasUnseenStories ? null : Border.all(color: AppTheme.neutral300, width: 1),
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundImage: user.profileImageUrl.isNotEmpty
                  ? NetworkImage(user.profileImageUrl) as ImageProvider
                  : const AssetImage('assets/images/default_avatar.png'),
            ),
          ),

          const SizedBox(height: 4),

          // Username
          Text(
            user.username.length > 10 ? '${user.username.substring(0, 8)}...' : user.username,
            style: const TextStyle(
              fontSize: 12,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  void _openStory(BuildContext context) {
    final StoryController storyController = StoryController();
    final controller = Get.find<story_controller.StoryController>();

    final List<StoryItem> storyItems = stories.map((story) {
      if (story.isVideo) {
        return StoryItem.pageVideo(
          story.mediaUrl,
          controller: storyController,
          duration: const Duration(seconds: 10),
        );
      } else {
        return StoryItem.pageImage(
          url: story.mediaUrl,
          controller: storyController,
        );
      }
    }).toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return Scaffold(
            body: StoryView(
              storyItems: storyItems,
              controller: storyController,
              repeat: false,
              onComplete: () {
                Navigator.pop(context);
              },
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) {
                  Navigator.pop(context);
                }
              },
              onStoryShow: (storyItem, int index) {
                final index = storyItems.indexOf(storyItem);
                if (index >= 0 && index < stories.length) {
                  controller.viewStory(stories[index].id);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
