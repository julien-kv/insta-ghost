import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/controllers/auth_controller.dart';
import 'package:instagram_clone/controllers/profile_controller.dart';
import 'package:instagram_clone/controllers/post_controller.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:instagram_clone/routes/app_pages.dart';
import 'package:instagram_clone/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileScreen extends StatefulWidget {
  final String userId = AuthController.to.firebaseUser.value?.uid ?? '';

  ProfileScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController _profileController = Get.put(ProfileController());
  final PostController _postController = Get.find<PostController>();
  late bool _isCurrentUser;

  @override
  void initState() {
    super.initState();
    _isCurrentUser = AuthController.to.isCurrentUser(widget.userId);
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (_isCurrentUser) {
      _profileController.userProfile.value = AuthController.to.userModel.value;
    } else {
      await _profileController.fetchUserProfile(widget.userId);
    }
    await _postController.fetchUserPosts(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              _profileController.userProfile.value?.username ?? 'Profile',
            )),
        actions: [
          if (_isCurrentUser)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: _showOptions,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: CustomScrollView(
          slivers: [
            // Profile Header
            SliverToBoxAdapter(
              child: Obx(() {
                if (_profileController.isLoading.value && _profileController.userProfile.value == null) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final user = _profileController.userProfile.value;
                if (user == null) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: Text('User not found')),
                  );
                }

                return _buildProfileHeader(user);
              }),
            ),

            // Tab Bar
            SliverPersistentHeader(
              delegate: _ProfileTabBarDelegate(),
              pinned: true,
            ),

            // Posts Grid
            Obx(() {
              if (_postController.isLoading.value) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (_postController.userPosts.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(1),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = _postController.userPosts[index];
                      return GestureDetector(
                        onTap: () {
                          Get.toNamed(Routes.POST_DETAIL, arguments: post);
                        },
                        child: Image.network(
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
                      ).animate().fadeIn(duration: 300.ms);
                    },
                    childCount: _postController.userPosts.length,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spaceSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar, Posts Count, Followers, Following
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 40,
                backgroundImage: user.profileImageUrl.isNotEmpty
                    ? NetworkImage(user.profileImageUrl) as ImageProvider
                    : const AssetImage('assets/images/default_avatar.png'),
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(width: AppTheme.spaceMedium),

              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn('Posts', user.postsCount.toString()),
                    _buildStatColumn('Followers', user.followers.length.toString()),
                    _buildStatColumn('Following', user.following.length.toString()),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spaceSmall),

          // Name & Bio
          Text(
            user.fullName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ).animate().fadeIn(delay: 100.ms),

          if (user.bio.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(user.bio),
            ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: AppTheme.spaceSmall),

          // Action Button (Edit Profile / Follow)
          _isCurrentUser
              ? SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Get.toNamed(Routes.EDIT_PROFILE),
                    child: const Text('Edit Profile'),
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0)
              : Obx(() => SizedBox(
                    width: double.infinity,
                    child: _profileController.isFollowing.value
                        ? OutlinedButton(
                            onPressed: () {
                              _profileController.unfollowUser(user.id);
                            },
                            child: const Text('Following'),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              _profileController.followUser(user.id);
                            },
                            child: const Text('Follow'),
                          ),
                  )).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.neutral600,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildEmptyState() {
    final isCurrentUser = AuthController.to.isCurrentUser(widget.userId);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_camera_outlined,
            size: 80,
            color: AppTheme.neutral400,
          ),
          const SizedBox(height: AppTheme.spaceSmall),
          Text(
            isCurrentUser ? 'Share Your First Photo' : 'No Posts Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.neutral700,
            ),
          ),
          const SizedBox(height: AppTheme.spaceXSmall),
          Text(
            isCurrentUser
                ? 'When you share photos, they will appear on your profile.'
                : 'When this user shares photos, they will appear here.',
            style: TextStyle(
              color: AppTheme.neutral600,
            ),
            textAlign: TextAlign.center,
          ),
          if (isCurrentUser) ...[
            const SizedBox(height: AppTheme.spaceMedium),
            ElevatedButton(
              onPressed: () {
                Get.toNamed(Routes.ADD_POST);
              },
              child: const Text('Share Your First Photo'),
            ),
          ],
        ],
      ),
    ).animate().fadeIn();
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Get.back();
              // TODO: Navigate to settings screen
              Get.snackbar('Coming Soon', 'Settings screen will be available soon');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              Get.back();
              await AuthController.to.signOut();
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileTabBarDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: const TabBar(
        tabs: [
          Tab(icon: Icon(Icons.grid_on)),
          Tab(icon: Icon(Icons.list)),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
