import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:instagram_clone/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Instagram',
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
