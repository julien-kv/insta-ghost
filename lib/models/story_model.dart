import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {
  final String id;
  final String userId;
  final String username;
  final String userProfileImageUrl;
  final String mediaUrl;
  final bool isVideo;
  final List<String> viewers;
  final Timestamp createdAt;
  final Timestamp expiresAt;

  StoryModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.userProfileImageUrl,
    required this.mediaUrl,
    this.isVideo = false,
    this.viewers = const [],
    required this.createdAt,
    required this.expiresAt,
  });

  factory StoryModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return StoryModel(
      id: snapshot.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      userProfileImageUrl: data['userProfileImageUrl'] ?? '',
      mediaUrl: data['mediaUrl'] ?? '',
      isVideo: data['isVideo'] ?? false,
      viewers: List<String>.from(data['viewers'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      expiresAt: data['expiresAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'userProfileImageUrl': userProfileImageUrl,
      'mediaUrl': mediaUrl,
      'isVideo': isVideo,
      'viewers': viewers,
      'createdAt': createdAt,
      'expiresAt': expiresAt,
    };
  }
}