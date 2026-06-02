import 'package:equatable/equatable.dart';

enum Relationship {
  spouse,
  child,
  parent,
  sibling,
  other,
}

extension RelationshipExtension on Relationship {
  String get displayName {
    switch (this) {
      case Relationship.spouse:
        return 'Spouse/Partner';
      case Relationship.child:
        return 'Child';
      case Relationship.parent:
        return 'Parent';
      case Relationship.sibling:
        return 'Sibling';
      case Relationship.other:
        return 'Other';
    }
  }
}

class FamilyMember extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String nickname;
  final Relationship relationship;
  final String ageRange;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const FamilyMember({
    required this.id,
    required this.userId,
    required this.name,
    required this.nickname,
    required this.relationship,
    required this.ageRange,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, userId, name, relationship];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'nickname': nickname,
      'relationship': relationship.toString().split('.').last,
      'ageRange': ageRange,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      nickname: json['nickname'],
      relationship: _parseRelationship(json['relationship']),
      ageRange: json['ageRange'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  static Relationship _parseRelationship(String value) {
    return Relationship.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => Relationship.other,
    );
  }
  
  String get displayName => nickname.isNotEmpty ? nickname : name;
}