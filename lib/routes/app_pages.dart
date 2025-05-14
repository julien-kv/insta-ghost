import 'package:get/get.dart';
import 'package:instagram_clone/screens/auth/login_screen.dart';
import 'package:instagram_clone/screens/auth/signup_screen.dart';
import 'package:instagram_clone/screens/main/main_screen.dart';
import 'package:instagram_clone/screens/notifications/notifications_screen.dart';
import 'package:instagram_clone/screens/post/add_post_screen.dart';
import 'package:instagram_clone/screens/post/comments_screen.dart';
import 'package:instagram_clone/screens/post/post_detail_screen.dart';
import 'package:instagram_clone/screens/profile/edit_profile_screen.dart';
import 'package:instagram_clone/screens/profile/profile_screen.dart';
import 'package:instagram_clone/screens/search/search_screen.dart';
import 'package:instagram_clone/screens/splash/splash_screen.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginScreen(),
    ),
    GetPage(
      name: Routes.SIGNUP,
      page: () => SignupScreen(),
    ),
    GetPage(
      name: Routes.MAIN,
      page: () => const MainScreen(),
    ),
    GetPage(
      name: Routes.EDIT_PROFILE,
      page: () => const EditProfileScreen(),
    ),
    GetPage(
      name: Routes.ADD_POST,
      page: () => const AddPostScreen(),
    ),
    GetPage(
      name: Routes.POST_DETAIL,
      page: () => const PostDetailScreen(),
    ),
    GetPage(
      name: Routes.COMMENTS,
      page: () => const CommentsScreen(),
    ),
    GetPage(
      name: Routes.SEARCH,
      page: () => const SearchScreen(),
    ),
    GetPage(
      name: Routes.NOTIFICATIONS,
      page: () => const NotificationsScreen(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => ProfileScreen(),
    ),
  ];
}
