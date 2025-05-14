import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/controllers/auth_controller.dart';
import 'package:instagram_clone/routes/app_pages.dart';
import 'package:instagram_clone/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize AuthController here
    final authController = Get.put(AuthController(), permanent: true);

    // Add a delay to show splash screen and then check auth state
    Future.delayed(const Duration(seconds: 2), () {
      if (authController.firebaseUser.value != null) {
        Get.offAllNamed(Routes.MAIN);
      } else {
        Get.offAllNamed(Routes.LOGIN);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'instaghost',
              style: TextStyle(
                fontFamily: 'Billabong',
                fontSize: 50,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            )
                .animate()
                .fadeIn(duration: 800.ms)
                .then(delay: 200.ms)
                .slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
            const SizedBox(height: AppTheme.spaceLarge),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ).animate().fadeIn(delay: 800.ms).scale(delay: 800.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
