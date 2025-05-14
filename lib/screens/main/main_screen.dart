import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/controllers/auth_controller.dart';
import 'package:instagram_clone/controllers/post_controller.dart';
import 'package:instagram_clone/controllers/story_controller.dart';
import 'package:instagram_clone/routes/app_pages.dart';
import 'package:instagram_clone/screens/home/home_screen.dart';
import 'package:instagram_clone/screens/notifications/notifications_screen.dart';
import 'package:instagram_clone/screens/post/add_post_screen.dart';
import 'package:instagram_clone/screens/profile/profile_screen.dart';
import 'package:instagram_clone/screens/search/search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = [
    HomeScreen(),
    const SearchScreen(),
    const AddPostScreen(),
    const NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

    // Initialize controllers
    Get.put(PostController());
    Get.put(StoryController());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTabTapped(int index) {
    // Special handling for add post
    if (index == 2) {
      if (AuthController.to.userModel.value == null) {
        Get.toNamed(Routes.LOGIN);
        Get.snackbar('Error', 'Please login to create a post');
        return;
      }
      Get.toNamed(Routes.ADD_POST);
      return;
    }

    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 0 ? Icons.home : Icons.home_outlined,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 1 ? Icons.search : Icons.search_outlined,
              ),
              label: 'Search',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined),
              label: 'Add Post',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 3 ? Icons.favorite : Icons.favorite_border_outlined,
              ),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _currentIndex == 4 ? Theme.of(context).primaryColor : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Obx(() {
                  final user = AuthController.to.userModel.value;
                  return CircleAvatar(
                    backgroundImage: user?.profileImageUrl.isNotEmpty == true
                        ? NetworkImage(user!.profileImageUrl) as ImageProvider
                        : const AssetImage('assets/images/default_avatar.png'),
                  );
                }),
              ),
              label: 'Profile',
            ),
          ],
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 1, end: 0),
      ),
    );
  }
}
