import 'package:equatable/equatable.dart';


/// Represents a user in the Sparkle app, with all relevant profile information.
enum LifeStage {
  generalWellness,
  periodTracking,
  fertilityPlanning,
  pregnancy,
  postpartum,
  menopause,
}

enum CycleStatus {
  regular,
  irregular,
  notSure,
  notApplicable,
}

class UserModel extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? nickname;
  final String? ageRange;
  final LifeStage? lifeStage;
  final CycleStatus? cycleStatus;
  final List<String> conditions;
  final List<String> medications;
  final bool privacyHideDashboardDetails;
  final bool privacyGenericNotifications;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.nickname,
    this.ageRange,
    this.lifeStage,
    this.cycleStatus,
    this.conditions = const [],
    this.medications = const [],
    this.privacyHideDashboardDetails = false,
    this.privacyGenericNotifications = true,
    required this.createdAt,
    this.updatedAt,
  });
  
  @override
  List<Object?> get props => [id, email, name];
  
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? nickname,
    String? ageRange,
    LifeStage? lifeStage,
    CycleStatus? cycleStatus,
    List<String>? conditions,
    List<String>? medications,
    bool? privacyHideDashboardDetails,
    bool? privacyGenericNotifications,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      ageRange: ageRange ?? this.ageRange,
      lifeStage: lifeStage ?? this.lifeStage,
      cycleStatus: cycleStatus ?? this.cycleStatus,
      conditions: conditions ?? this.conditions,
      medications: medications ?? this.medications,
      privacyHideDashboardDetails: privacyHideDashboardDetails ?? this.privacyHideDashboardDetails,
      privacyGenericNotifications: privacyGenericNotifications ?? this.privacyGenericNotifications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  // For empty/initial state
  factory UserModel.empty(String userId) {
    return UserModel(
      id: userId,
      email: '',
      name: '',
      createdAt: DateTime.now(),
    );
  }
  
  String get displayName => nickname ?? name;
  
  bool get hasCompletedProfile {
    return name.isNotEmpty && 
           ageRange != null && 
           ageRange!.isNotEmpty &&
           lifeStage != null;
  }
}