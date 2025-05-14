import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final String bio;
  final String profileImageUrl;
  final List<String> followers;
  final List<String> following;
  final int postsCount;
  final Timestamp createdAt;
  final bool isPrivate;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    this.bio = '',
    this.profileImageUrl = '',
    this.followers = const [],
    this.following = const [],
    this.postsCount = 0,
    required this.createdAt,
    this.isPrivate = false,
  });

  factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserModel(
      id: snapshot.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      fullName: data['fullName'] ?? '',
      bio: data['bio'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
      followers: List<String>.from(data['followers'] ?? []),
      following: List<String>.from(data['following'] ?? []),
      postsCount: data['postsCount'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      isPrivate: data['isPrivate'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'fullName': fullName,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'followers': followers,
      'following': following,
      'postsCount': postsCount,
      'createdAt': createdAt,
      'isPrivate': isPrivate,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? fullName,
    String? bio,
    String? profileImageUrl,
    List<String>? followers,
    List<String>? following,
    int? postsCount,
    Timestamp? createdAt,
    bool? isPrivate,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      postsCount: postsCount ?? this.postsCount,
      createdAt: createdAt ?? this.createdAt,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }
}