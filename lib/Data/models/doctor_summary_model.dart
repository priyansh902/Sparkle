import 'package:equatable/equatable.dart';

class DoctorSummary extends Equatable {
  final String id;
  final String userId;
  final String summaryText;
  final List<String> questionsForDoctor;
  final List<String> recentSymptoms;
  final List<String> recentRecords;
  final List<String> currentMedications;
  final String notes;
  final DateTime generatedDate;
  final DateTime createdAt;

  const DoctorSummary({
    required this.id,
    required this.userId,
    required this.summaryText,
    required this.questionsForDoctor,
    required this.recentSymptoms,
    required this.recentRecords,
    required this.currentMedications,
    required this.notes,
    required this.generatedDate,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, generatedDate];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'summaryText': summaryText,
      'questionsForDoctor': questionsForDoctor,
      'recentSymptoms': recentSymptoms,
      'recentRecords': recentRecords,
      'currentMedications': currentMedications,
      'notes': notes,
      'generatedDate': generatedDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DoctorSummary.fromJson(Map<String, dynamic> json) {
    return DoctorSummary(
      id: json['id'],
      userId: json['userId'],
      summaryText: json['summaryText'],
      questionsForDoctor: List<String>.from(json['questionsForDoctor']),
      recentSymptoms: List<String>.from(json['recentSymptoms']),
      recentRecords: List<String>.from(json['recentRecords']),
      currentMedications: List<String>.from(json['currentMedications']),
      notes: json['notes'],
      generatedDate: DateTime.parse(json['generatedDate']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}