import 'package:cloud_firestore/cloud_firestore.dart';

DateTime _readDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}

class UserProfile {
  UserProfile({
    required this.id,
    required this.phoneNumber,
    this.displayName,
    this.anonymousUsername,
    this.avatarUrl,
    this.isPhoneVerified = false,
    this.onboardingComplete = false,
  });

  final String id;
  final String phoneNumber;
  final String? displayName;
  final String? anonymousUsername;
  final String? avatarUrl;
  final bool isPhoneVerified;
  final bool onboardingComplete;

  factory UserProfile.fromMap(String id, Map<String, dynamic> json) {
    return UserProfile(
      id: id,
      phoneNumber: json['phoneNumber'] as String? ?? '',
      displayName: json['displayName'] as String?,
      anonymousUsername: json['anonymousUsername'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'anonymousUsername': anonymousUsername,
      'avatarUrl': avatarUrl,
      'isPhoneVerified': isPhoneVerified,
      'onboardingComplete': onboardingComplete,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class SocietyMembership {
  SocietyMembership({
    required this.id,
    required this.societyId,
    required this.userId,
    required this.societyName,
    required this.societyCode,
    required this.role,
    required this.flatNumber,
    this.wing,
    this.floor,
    this.status = 'ACTIVE',
  });

  final String id;
  final String societyId;
  final String userId;
  final String societyName;
  final String societyCode;
  final String role;
  final String flatNumber;
  final String? wing;
  final int? floor;
  final String status;

  factory SocietyMembership.fromMap(String id, Map<String, dynamic> json) {
    return SocietyMembership(
      id: id,
      societyId: json['societyId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      societyName: json['societyName'] as String? ?? '',
      societyCode: json['societyCode'] as String? ?? '',
      role: json['role'] as String? ?? 'RESIDENT',
      flatNumber: json['flatNumber'] as String? ?? '',
      wing: json['wing'] as String?,
      floor: json['floor'] as int?,
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'societyId': societyId,
      'userId': userId,
      'societyName': societyName,
      'societyCode': societyCode,
      'role': role,
      'flatNumber': flatNumber,
      'wing': wing,
      'floor': floor,
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class Society {
  Society({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.totalFlats,
    this.createdBy,
    this.createdAt,
  });

  final String id;
  final String name;
  final String code;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final int totalFlats;
  final String? createdBy;
  final DateTime? createdAt;

  factory Society.fromMap(String id, Map<String, dynamic> json) {
    return Society(
      id: id,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      totalFlats: json['totalFlats'] as int? ?? 0,
      createdBy: json['createdBy'] as String?,
      createdAt: json['createdAt'] == null ? null : _readDate(json['createdAt']),
    );
  }
}

class MembershipRequest {
  MembershipRequest({
    required this.id,
    required this.userId,
    required this.societyId,
    required this.societyName,
    required this.flatNumber,
    this.wing,
    this.floor,
    this.status = 'PENDING',
    this.userName,
    this.userPhone,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String societyId;
  final String societyName;
  final String flatNumber;
  final String? wing;
  final int? floor;
  final String status;
  final String? userName;
  final String? userPhone;
  final DateTime? createdAt;

  factory MembershipRequest.fromMap(String id, Map<String, dynamic> json) {
    return MembershipRequest(
      id: id,
      userId: json['userId'] as String? ?? '',
      societyId: json['societyId'] as String? ?? '',
      societyName: json['societyName'] as String? ?? '',
      flatNumber: json['flatNumber'] as String? ?? '',
      wing: json['wing'] as String?,
      floor: json['floor'] as int?,
      status: json['status'] as String? ?? 'PENDING',
      userName: json['userName'] as String?,
      userPhone: json['userPhone'] as String?,
      createdAt: json['createdAt'] == null ? null : _readDate(json['createdAt']),
    );
  }
}

class PostAuthor {
  PostAuthor({required this.id, required this.name, this.avatarUrl});

  final String id;
  final String name;
  final String? avatarUrl;

  factory PostAuthor.fromMap(Map<String, dynamic> json) {
    return PostAuthor(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Resident',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'avatarUrl': avatarUrl,
  };
}

class FeedPost {
  FeedPost({
    required this.id,
    required this.threadId,
    required this.threadTitle,
    required this.content,
    required this.postType,
    required this.author,
    required this.createdAt,
    this.isPinned = false,
    this.imageUrls = const [],
    this.reactionCounts = const {},
    this.commentCount = 0,
    this.userReaction,
  });

  final String id;
  final String threadId;
  final String threadTitle;
  final String content;
  final String postType;
  final PostAuthor author;
  final DateTime createdAt;
  final bool isPinned;
  final List<String> imageUrls;
  final Map<String, int> reactionCounts;
  final int commentCount;
  final String? userReaction;

  factory FeedPost.fromMap(String id, Map<String, dynamic> json) {
    return FeedPost(
      id: id,
      threadId: json['threadId'] as String? ?? '',
      threadTitle: json['threadTitle'] as String? ?? '',
      content: json['content'] as String? ?? '',
      postType: json['postType'] as String? ?? 'GENERAL',
      author: PostAuthor.fromMap(
        (json['author'] as Map<String, dynamic>?) ?? {},
      ),
      createdAt: _readDate(json['createdAt']),
      isPinned: json['isPinned'] as bool? ?? false,
      imageUrls: List<String>.from(json['imageUrls'] as List? ?? const []),
      reactionCounts: Map<String, int>.from(
        json['reactionCounts'] as Map? ?? const {},
      ),
      commentCount: json['commentCount'] as int? ?? 0,
      userReaction: json['userReaction'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'threadId': threadId,
      'threadTitle': threadTitle,
      'content': content,
      'postType': postType,
      'author': author.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'isPinned': isPinned,
      'imageUrls': imageUrls,
      'reactionCounts': reactionCounts,
      'commentCount': commentCount,
      'userReaction': userReaction,
    };
  }
}

class ComplaintThread {
  ComplaintThread({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.ownerName,
    required this.createdAt,
    this.postCount = 0,
    this.hasPolls = false,
    this.resolvedAt,
  });

  final String id;
  final String title;
  final String description;
  final String status;
  final String ownerName;
  final DateTime createdAt;
  final int postCount;
  final bool hasPolls;
  final DateTime? resolvedAt;

  factory ComplaintThread.fromMap(String id, Map<String, dynamic> json) {
    return ComplaintThread(
      id: id,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['complaintStatus'] as String? ?? 'OPEN',
      ownerName: json['ownerName'] as String? ?? 'Resident',
      createdAt: _readDate(json['createdAt']),
      postCount: json['postCount'] as int? ?? 0,
      hasPolls: json['hasPolls'] as bool? ?? false,
      resolvedAt: json['resolvedAt'] == null
          ? null
          : _readDate(json['resolvedAt']),
    );
  }
}

class EventItem {
  EventItem({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.eventLocation,
    required this.ownerName,
    this.goingCount = 0,
    this.userRsvp,
    this.isLocked = false,
  });

  final String id;
  final String title;
  final String description;
  final DateTime eventDate;
  final String eventLocation;
  final String ownerName;
  final int goingCount;
  final String? userRsvp;
  final bool isLocked;

  bool get isPast => eventDate.isBefore(DateTime.now());

  factory EventItem.fromMap(String id, Map<String, dynamic> json) {
    return EventItem(
      id: id,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      eventDate: _readDate(json['eventDate']),
      eventLocation: json['eventLocation'] as String? ?? '',
      ownerName: json['ownerName'] as String? ?? 'Resident',
      goingCount: json['goingCount'] as int? ?? 0,
      userRsvp: json['userRsvp'] as String?,
      isLocked: json['isLocked'] as bool? ?? false,
    );
  }
}

class ServiceItem {
  ServiceItem({
    required this.id,
    required this.name,
    required this.category,
    required this.contactName,
    required this.contactPhone,
    this.description,
    this.isVerified = false,
    this.avgRating = 0,
    this.totalReviews = 0,
  });

  final String id;
  final String name;
  final String category;
  final String contactName;
  final String contactPhone;
  final String? description;
  final bool isVerified;
  final double avgRating;
  final int totalReviews;

  factory ServiceItem.fromMap(String id, Map<String, dynamic> json) {
    return ServiceItem(
      id: id,
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'OTHER',
      contactName: json['contactName'] as String? ?? '',
      contactPhone: json['contactPhone'] as String? ?? '',
      description: json['description'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      avgRating: (json['avgRating'] as num? ?? 0).toDouble(),
      totalReviews: json['totalReviews'] as int? ?? 0,
    );
  }
}

class CommitteeMember {
  CommitteeMember({
    required this.id,
    required this.name,
    required this.role,
    required this.flatNumber,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String role;
  final String flatNumber;
  final String? avatarUrl;

  factory CommitteeMember.fromMap(String id, Map<String, dynamic> json) {
    return CommitteeMember(
      id: id,
      name: json['name'] as String? ?? 'Resident',
      role: json['role'] as String? ?? 'RESIDENT',
      flatNumber: json['flatNumber'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}

class PollOptionItem {
  PollOptionItem({
    required this.id,
    required this.text,
    this.voteCount = 0,
    this.percentage = 0,
  });

  final String id;
  final String text;
  final int voteCount;
  final int percentage;

  factory PollOptionItem.fromMap(String id, Map<String, dynamic> json) {
    return PollOptionItem(
      id: id,
      text: json['text'] as String? ?? '',
      voteCount: json['voteCount'] as int? ?? 0,
      percentage: json['percentage'] as int? ?? 0,
    );
  }
}

class PollItem {
  PollItem({
    required this.id,
    required this.question,
    required this.options,
    this.totalVotes = 0,
    this.userVote,
    this.isClosed = false,
    this.endsAt,
  });

  final String id;
  final String question;
  final List<PollOptionItem> options;
  final int totalVotes;
  final String? userVote;
  final bool isClosed;
  final DateTime? endsAt;

  factory PollItem.fromMap(String id, Map<String, dynamic> json) {
    final optionMaps = (json['options'] as List? ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    return PollItem(
      id: id,
      question: json['question'] as String? ?? '',
      options: optionMaps
          .map(
            (option) =>
                PollOptionItem.fromMap(option['id'] as String? ?? '', option),
          )
          .toList(),
      totalVotes: json['totalVotes'] as int? ?? 0,
      userVote: json['userVote'] as String?,
      isClosed: json['isClosed'] as bool? ?? false,
      endsAt: json['endsAt'] == null ? null : _readDate(json['endsAt']),
    );
  }
}

class ThreadDetail {
  ThreadDetail({
    required this.id,
    required this.title,
    required this.type,
    required this.ownerName,
    required this.createdAt,
    this.description,
    this.complaintStatus,
    this.eventDate,
    this.eventLocation,
    this.posts = const [],
    this.polls = const [],
  });

  final String id;
  final String title;
  final String type;
  final String ownerName;
  final DateTime createdAt;
  final String? description;
  final String? complaintStatus;
  final DateTime? eventDate;
  final String? eventLocation;
  final List<FeedPost> posts;
  final List<PollItem> polls;

  factory ThreadDetail.fromMap(
    String id,
    Map<String, dynamic> json, {
    List<FeedPost> posts = const [],
    List<PollItem> polls = const [],
  }) {
    return ThreadDetail(
      id: id,
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? 'NOTICEBOARD',
      ownerName: json['ownerName'] as String? ?? 'Resident',
      createdAt: _readDate(json['createdAt']),
      description: json['description'] as String?,
      complaintStatus: json['complaintStatus'] as String?,
      eventDate: json['eventDate'] == null
          ? null
          : _readDate(json['eventDate']),
      eventLocation: json['eventLocation'] as String?,
      posts: posts,
      polls: polls,
    );
  }
}
