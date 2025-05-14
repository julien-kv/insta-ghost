import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/controllers/auth_controller.dart';
import 'package:instagram_clone/routes/app_pages.dart';
import 'package:instagram_clone/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RxBool _isLoading = false.obs;
  final RxBool _obscurePassword = true.obs;
  
  LoginScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppTheme.spaceLarge),
                
                // Logo
                Text(
                  'Instagram',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Billabong',
                    fontSize: 50,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 600.ms).slide(),
                
                const SizedBox(height: AppTheme.spaceLarge),
                
                // Email Field
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: AppTheme.spaceSmall),
                
                // Password Field
                Obx(() => TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword.value 
                        ? Icons.visibility_outlined 
                        : Icons.visibility_off_outlined),
                      onPressed: () => _obscurePassword.value = !_obscurePassword.value,
                    ),
                  ),
                  obscureText: _obscurePassword.value,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(),
                )).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: AppTheme.spaceMedium),
                
                // Login Button
                Obx(() => ElevatedButton(
                  onPressed: _isLoading.value ? null : _login,
                  child: _isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Log In'),
                )).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.9, 0.9)),
                
                const SizedBox(height: AppTheme.spaceSmall),
                
                // Forgot Password
                TextButton(
                  onPressed: () {
                    // TODO: Implement forgot password
                    Get.snackbar('Coming Soon', 'Reset password feature will be available soon');
                  },
                  child: const Text('Forgot Password?'),
                ).animate().fadeIn(delay: 500.ms),
                
                const SizedBox(height: AppTheme.spaceLarge),
                
                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceSmall),
                      child: Text(
                        'OR',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: AppTheme.neutral600,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ).animate().fadeIn(delay: 600.ms),
                
                const SizedBox(height: AppTheme.spaceLarge),
                
                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed(Routes.SIGNUP),
                      child: const Text('Sign Up'),
                    ),
                  ],
                ).animate().fadeIn(delay: 700.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields');
      return;
    }
    
    _isLoading.value = true;
    
    final success = await AuthController.to.loginWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text,
    );
    
    _isLoading.value = false;
    
    if (success) {
      Get.offAllNamed(Routes.MAIN);
    }
  }
}