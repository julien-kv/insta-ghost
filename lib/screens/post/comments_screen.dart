import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/controllers/comment_controller.dart';
import 'package:instagram_clone/theme/app_theme.dart';
import 'package:instagram_clone/widgets/comment_list.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  late String postId;
  final CommentController _commentController = Get.put(CommentController());
  final TextEditingController _commentTextController = TextEditingController();
  final RxBool _isPostingComment = false.obs;

  @override
  void initState() {
    super.initState();
    postId = Get.arguments as String;
    _commentController.fetchComments(postId);
  }

  @override
  void dispose() {
    _commentTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Comments'),
        ),
        body: Column(children: [
          Expanded(
            child: CommentList(postId: postId),
          ),

          // Comment Input
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceSmall,
              vertical: AppTheme.spaceXSmall,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentTextController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: _commentTextController,
                  builder: (context, value, child) => Obx(
                    () => TextButton(
                      onPressed: _isPostingComment.value || _commentTextController.text.isEmpty
                          ? null
                          : _postComment,
                      child: _isPostingComment.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text('Post',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _commentTextController.text.isEmpty
                                    ? AppTheme.neutral400
                                    : AppTheme.primaryColor,
                              )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]));
  }

  Future<void> _postComment() async {
    if (_commentTextController.text.isEmpty) return;

    _isPostingComment.value = true;

    final success = await _commentController.addComment(
      postId,
      _commentTextController.text.trim(),
    );

    _isPostingComment.value = false;

    if (success) {
      _commentTextController.clear();
    }
  }
}
