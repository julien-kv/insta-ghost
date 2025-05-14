import 'package:flutter/material.dart';
import 'package:instagram_clone/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Activity'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Following'),
              Tab(text: 'You'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFollowingActivity(),
            _buildYourActivity(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFollowingActivity() {
    // This is a placeholder for the following activity feed
    return ListView.builder(
      padding: const EdgeInsets.only(top: AppTheme.spaceSmall),
      itemCount: 15,
      itemBuilder: (context, index) {
        // Mock activity items
        return _buildActivityItem(
          avatarUrl: '', // Empty string for placeholder
          username: 'user${index + 1}',
          action: index % 3 == 0
            ? 'liked a post'
            : (index % 3 == 1 ? 'commented on a post' : 'started following user${index + 5}'),
          time: '${index + 1}h ago',
          hasImage: index % 2 == 0,
          index: index,
        );
      },
    );
  }
  
  Widget _buildYourActivity() {
    // This is a placeholder for your activity feed
    return ListView.builder(
      padding: const EdgeInsets.only(top: AppTheme.spaceSmall),
      itemCount: 20,
      itemBuilder: (context, index) {
        // Mock activity items
        return _buildActivityItem(
          avatarUrl: '', // Empty string for placeholder
          username: 'user${index + 20}',
          action: index % 4 == 0
            ? 'liked your post'
            : (index % 4 == 1 
                ? 'commented: "Great photo!"' 
                : (index % 4 == 2 
                    ? 'started following you' 
                    : 'mentioned you in a comment')),
          time: '${index + 1}h ago',
          hasImage: index % 3 == 0,
          index: index,
        );
      },
    );
  }
  
  Widget _buildActivityItem({
    required String avatarUrl,
    required String username,
    required String action,
    required String time,
    required bool hasImage,
    required int index,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: avatarUrl.isNotEmpty
            ? NetworkImage(avatarUrl) as ImageProvider
            : const AssetImage('assets/images/default_avatar.png'),
      ),
      title: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black),
          children: [
            TextSpan(
              text: username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: ' $action',
            ),
          ],
        ),
      ),
      subtitle: Text(time),
      trailing: hasImage
          ? Container(
              width: 44,
              height: 44,
              color: Colors.grey[300],
              child: const Icon(Icons.image, color: Colors.grey),
            )
          : null,
    ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.05, end: 0);
  }
}