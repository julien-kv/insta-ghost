import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/controllers/search_controller.dart' as ig_search;
import 'package:instagram_clone/theme/app_theme.dart';
import 'package:instagram_clone/widgets/user_tile.dart';
import 'package:instagram_clone/widgets/post_grid.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ig_search.SearchController _searchController = Get.put(ig_search.SearchController());
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchField(),
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        if (_searchController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (_searchController.query.isEmpty) {
          return _buildExploreContent();
        }
        
        if (_searchController.hashtagResults.isNotEmpty) {
          return _buildHashtagResults();
        }
        
        if (_searchController.searchResults.isEmpty) {
          return _buildNoResults();
        }
        
        return ListView.builder(
          itemCount: _searchController.searchResults.length,
          itemBuilder: (context, index) {
            final user = _searchController.searchResults[index];
            return UserTile(user: user)
              .animate()
              .fadeIn(duration: 200.ms, delay: (50 * index).ms)
              .slideY(begin: 0.05, end: 0);
          },
        );
      }),
    );
  }
  
  Widget _buildSearchField() {
    return TextField(
      controller: _textEditingController,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: 'Search',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _textEditingController.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _textEditingController.clear();
                _searchController.clearSearch();
                _focusNode.unfocus();
              },
            )
          : null,
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.light
          ? AppTheme.neutral200
          : AppTheme.neutral800,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (query) {
        if (query.isEmpty) {
          _searchController.clearSearch();
        } else {
          _searchController.searchUsers(query);
        }
      },
      textInputAction: TextInputAction.search,
    );
  }
  
  Widget _buildExploreContent() {
    // Simulated popular posts for the explore section
    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: 30, // A few placeholder items
      itemBuilder: (context, index) {
        // Use a placeholder color that changes based on index
        final colors = [
          Colors.blueGrey,
          Colors.indigo,
          Colors.teal,
          Colors.amber,
          Colors.deepPurple,
        ];
        final color = colors[index % colors.length];
        
        return GestureDetector(
          onTap: () {
            // TODO: Open post detail
            Get.snackbar('Explore', 'This is a placeholder for explore content');
          },
          child: Container(
            color: color.withOpacity(0.7),
            child: Center(
              child: Icon(
                Icons.image,
                color: Colors.white.withOpacity(0.7),
                size: 40,
              ),
            ),
          ),
        ).animate().fadeIn(delay: (30 * index).ms, duration: 300.ms);
      },
    );
  }
  
  Widget _buildHashtagResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.spaceSmall),
          child: Text(
            _searchController.query.value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        Expanded(
          child: PostGrid(posts: _searchController.hashtagResults),
        ),
      ],
    );
  }
  
  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: AppTheme.neutral400,
          ),
          const SizedBox(height: AppTheme.spaceSmall),
          Text(
            'No Results Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.neutral700,
            ),
          ),
          const SizedBox(height: AppTheme.spaceXSmall),
          Text(
            'Try searching for something else',
            style: TextStyle(
              color: AppTheme.neutral600,
            ),
          ),
        ],
      ),
    );
  }
}