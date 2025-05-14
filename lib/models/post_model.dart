import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String username;
  final String userProfileImageUrl;
  final String imageUrl;
  final String caption;
  final List<String> likes;
  final int commentsCount;
  final List<String> hashtags;
  final List<String> mentions;
  final Timestamp createdAt;
  final String location;

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.userProfileImageUrl,
    required this.imageUrl,
    this.caption = '',
    this.likes = const [],
    this.commentsCount = 0,
    this.hashtags = const [],
    this.mentions = const [],
    required this.createdAt,
    this.location = '',
  });

  factory PostModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return PostModel(
      id: snapshot.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      userProfileImageUrl: data['userProfileImageUrl'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      caption: data['caption'] ?? '',
      likes: List<String>.from(data['likes'] ?? []),
      commentsCount: data['commentsCount'] ?? 0,
      hashtags: List<String>.from(data['hashtags'] ?? []),
      mentions: List<String>.from(data['mentions'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      location: data['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'userProfileImageUrl': userProfileImageUrl,
      'imageUrl': imageUrl,
      'caption': caption,
      'likes': likes,
      'commentsCount': commentsCount,
      'hashtags': hashtags,
      'mentions': mentions,
      'createdAt': createdAt,
      'location': location,
    };
  }

  PostModel copyWith({
    String? id,
    String? userId,
    String? username,
    String? userProfileImageUrl,
    String? imageUrl,
    String? caption,
    List<String>? likes,
    int? commentsCount,
    List<String>? hashtags,
    List<String>? mentions,
    Timestamp? createdAt,
    String? location,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userProfileImageUrl: userProfileImageUrl ?? this.userProfileImageUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      likes: likes ?? this.likes,
      commentsCount: commentsCount ?? this.commentsCount,
      hashtags: hashtags ?? this.hashtags,
      mentions: mentions ?? this.mentions,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
    );
  }
}