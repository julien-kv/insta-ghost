import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/controllers/auth_controller.dart';
import 'package:instagram_clone/routes/app_pages.dart';
import 'package:instagram_clone/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SignupScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final RxBool _isLoading = false.obs;
  final RxBool _obscurePassword = true.obs;
  
  SignupScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppTheme.spaceSmall),
                
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
                
                const SizedBox(height: AppTheme.spaceMedium),
                
                Text(
                  'Sign up to see photos and videos from your friends.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms),
                
                const SizedBox(height: AppTheme.spaceMedium),
                
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
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: AppTheme.spaceSmall),
                
                // Full Name Field
                TextField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    hintText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textInputAction: TextInputAction.next,
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: AppTheme.spaceSmall),
                
                // Username Field
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    hintText: 'Username',
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
                
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
                  onSubmitted: (_) => _signup(),
                )).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: AppTheme.spaceSmall),
                
                // Privacy Policy Text
                Text(
                  'By signing up, you agree to our Terms, Privacy Policy and Cookies Policy.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 700.ms),
                
                const SizedBox(height: AppTheme.spaceMedium),
                
                // Sign Up Button
                Obx(() => ElevatedButton(
                  onPressed: _isLoading.value ? null : _signup,
                  child: _isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Sign Up'),
                )).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.9, 0.9)),
                
                const SizedBox(height: AppTheme.spaceLarge),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => Get.offNamed(Routes.LOGIN),
                      child: const Text('Log In'),
                    ),
                  ],
                ).animate().fadeIn(delay: 900.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _signup() async {
    if (_emailController.text.isEmpty || 
        _passwordController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _fullNameController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields');
      return;
    }
    
    if (_passwordController.text.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters');
      return;
    }
    
    _isLoading.value = true;
    
    final success = await AuthController.to.createUserWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text,
      _usernameController.text.trim(),
      _fullNameController.text.trim(),
    );
    
    _isLoading.value = false;
    
    if (success) {
      Get.offAllNamed(Routes.MAIN);
    }
  }
}