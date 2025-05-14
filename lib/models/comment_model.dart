import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String username;
  final String userProfileImageUrl;
  final String text;
  final List<String> likes;
  final Timestamp createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.username,
    required this.userProfileImageUrl,
    required this.text,
    this.likes = const [],
    required this.createdAt,
  });

  factory CommentModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return CommentModel(
      id: snapshot.id,
      postId: data['postId'] ?? '',
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      userProfileImageUrl: data['userProfileImageUrl'] ?? '',
      text: data['text'] ?? '',
      likes: List<String>.from(data['likes'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'username': username,
      'userProfileImageUrl': userProfileImageUrl,
      'text': text,
      'likes': likes,
      'createdAt': createdAt,
    };
  }
}