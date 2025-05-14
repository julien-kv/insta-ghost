import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/controllers/auth_controller.dart';
import 'package:instagram_clone/controllers/profile_controller.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:instagram_clone/routes/app_pages.dart';
import 'package:instagram_clone/theme/app_theme.dart';

class UserTile extends StatelessWidget {
  final UserModel user;
  
  const UserTile({
    Key? key,
    required this.user,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isCurrentUser = AuthController.to.isCurrentUser(user.id);
    final isFollowing = AuthController.to.userModel.value?.following.contains(user.id) ?? false;
    
    return ListTile(
      leading: GestureDetector(
        onTap: () {
          Get.toNamed(Routes.PROFILE, arguments: user.id);
        },
        child: CircleAvatar(
          backgroundImage: user.profileImageUrl.isNotEmpty
            ? NetworkImage(user.profileImageUrl) as ImageProvider
            : const AssetImage('assets/images/default_avatar.png'),
        ),
      ),
      title: GestureDetector(
        onTap: () {
          Get.toNamed(Routes.PROFILE, arguments: user.id);
        },
        child: Text(
          user.username,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      subtitle: Text(user.fullName),
      trailing: isCurrentUser
        ? OutlinedButton(
            onPressed: () {
              Get.toNamed(Routes.PROFILE, arguments: user.id);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              minimumSize: const Size(80, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Profile'),
          )
        : OutlinedButton(
            onPressed: () {
              final profileController = Get.find<ProfileController>();
              
              if (isFollowing) {
                profileController.unfollowUser(user.id);
              } else {
                profileController.followUser(user.id);
              }
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              minimumSize: const Size(80, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: isFollowing ? null : AppTheme.primaryColor,
              foregroundColor: isFollowing ? null : Colors.white,
            ),
            child: Text(isFollowing ? 'Following' : 'Follow'),
          ),
    );
  }
}