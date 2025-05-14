import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:instagram_clone/models/post_model.dart';

class SearchController extends GetxController {
  static SearchController get to => Get.find();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  RxList<UserModel> searchResults = <UserModel>[].obs;
  RxList<PostModel> hashtagResults = <PostModel>[].obs;
  RxBool isLoading = false.obs;
  RxString query = ''.obs;
  
  Future<void> searchUsers(String searchQuery) async {
    if (searchQuery.isEmpty) {
      searchResults.clear();
      return;
    }
    
    query.value = searchQuery;
    isLoading.value = true;
    
    try {
      // If query starts with #, search for hashtags
      if (searchQuery.startsWith('#')) {
        await _searchHashtags(searchQuery);
        return;
      }
      
      final searchLower = searchQuery.toLowerCase();
      
      // Search for users where username or fullName contains the query
      final QuerySnapshot usersSnapshot = await _firestore
          .collection('users')
          .get();
      
      List<UserModel> results = [];
      
      for (var doc in usersSnapshot.docs) {
        final user = UserModel.fromSnapshot(doc);
        if (user.username.toLowerCase().contains(searchLower) || 
            user.fullName.toLowerCase().contains(searchLower)) {
          results.add(user);
        }
      }
      
      searchResults.value = results;
      hashtagResults.clear();
    } catch (e) {
      print('Error searching users: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> _searchHashtags(String hashtag) async {
    try {
      final QuerySnapshot postsSnapshot = await _firestore
          .collection('posts')
          .where('hashtags', arrayContains: hashtag)
          .orderBy('createdAt', descending: true)
          .get();
      
      hashtagResults.value = postsSnapshot.docs
          .map((doc) => PostModel.fromSnapshot(doc))
          .toList();
      
      searchResults.clear();
    } catch (e) {
      print('Error searching hashtags: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  void clearSearch() {
    query.value = '';
    searchResults.clear();
    hashtagResults.clear();
  }
}