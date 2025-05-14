import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:instagram_clone/routes/app_pages.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Rx<User?> firebaseUser = Rx<User?>(null);
  Rx<UserModel?> userModel = Rx<UserModel?>(null);
  
  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
  }
  
  _setInitialScreen(User? user) async {
    if (user == null) {
      Get.offAllNamed(Routes.LOGIN);
    } else {
      await _fetchUserData(user.uid);
      Get.offAllNamed(Routes.MAIN);
    }
  }
  
  Future<void> _fetchUserData(String uid) async {
    try {
      final DocumentSnapshot userDoc = 
          await _firestore.collection('users').doc(uid).get();
      
      if (userDoc.exists) {
        userModel.value = UserModel.fromSnapshot(userDoc);
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }
  
  Future<bool> createUserWithEmailAndPassword(
    String email, 
    String password, 
    String username,
    String fullName,
  ) async {
    try {
      // Check if username is already taken
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      
      if (usernameQuery.docs.isNotEmpty) {
        Get.snackbar('Error', 'Username is already taken');
        return false;
      }
      
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        // Create user in Firestore
        UserModel newUser = UserModel(
          id: userCredential.user!.uid,
          email: email,
          username: username,
          fullName: fullName,
          createdAt: Timestamp.now(),
        );
        
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(newUser.toJson());
            
        userModel.value = newUser;
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return false;
    }
  }
  
  Future<bool> loginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        await _fetchUserData(userCredential.user!.uid);
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return false;
    }
  }
  
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      userModel.value = null;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
  
  Future<void> updateUserProfile({
    String? username,
    String? fullName,
    String? bio,
    String? profileImageUrl,
  }) async {
    try {
      if (firebaseUser.value == null || userModel.value == null) return;
      
      Map<String, dynamic> updateData = {};
      
      if (username != null && username.isNotEmpty) {
        // Check if username is already taken
        if (username != userModel.value!.username) {
          final usernameQuery = await _firestore
              .collection('users')
              .where('username', isEqualTo: username)
              .get();
          
          if (usernameQuery.docs.isNotEmpty) {
            Get.snackbar('Error', 'Username is already taken');
            return;
          }
        }
        updateData['username'] = username;
      }
      
      if (fullName != null && fullName.isNotEmpty) {
        updateData['fullName'] = fullName;
      }
      
      if (bio != null) {
        updateData['bio'] = bio;
      }
      
      if (profileImageUrl != null) {
        updateData['profileImageUrl'] = profileImageUrl;
      }
      
      if (updateData.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(firebaseUser.value!.uid)
            .update(updateData);
            
        await _fetchUserData(firebaseUser.value!.uid);
        
        Get.snackbar('Success', 'Profile updated successfully');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
  
  bool isCurrentUser(String userId) {
    return firebaseUser.value?.uid == userId;
  }
}