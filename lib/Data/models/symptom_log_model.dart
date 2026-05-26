import 'package:equatable/equatable.dart';

enum PeriodStatus { none, started, ongoing, ended }
enum FlowLevel { none, light, medium, heavy }
enum Mood { calm, anxious, tired, irritable, happy, sad }

/// SymptomLog model representing a single symptom entry
class SymptomLog extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final PeriodStatus periodStatus;
  final FlowLevel flowLevel;
  final int painLevel;
  final Mood mood;
  final List<String> symptoms;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

/// Constructor for SymptomLog
  const SymptomLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.periodStatus,
    required this.flowLevel,
    required this.painLevel,
    required this.mood,
    required this.symptoms,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, userId, date, periodStatus, painLevel];

  // Validation methods (for testing)
  static bool isValidPainLevel(int level) => level >= 0 && level <= 10;
  static bool isValidSymptoms(List<String> symptoms) => symptoms.isNotEmpty;

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'periodStatus': periodStatus.toString().split('.').last,
      'flowLevel': flowLevel.toString().split('.').last,
      'painLevel': painLevel,
      'mood': mood.toString().split('.').last,
      'symptoms': symptoms,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory SymptomLog.fromJson(Map<String, dynamic> json) {
    return SymptomLog(
      id: json['id'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      periodStatus: _parsePeriodStatus(json['periodStatus']),
      flowLevel: _parseFlowLevel(json['flowLevel']),
      painLevel: json['painLevel'],
      mood: _parseMood(json['mood']),
      symptoms: List<String>.from(json['symptoms']),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

/// Helper methods to parse enums from strings
  static PeriodStatus _parsePeriodStatus(String value) {
    return PeriodStatus.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => PeriodStatus.none,
    );
  }

/// Helper method to parse FlowLevel from string
  static FlowLevel _parseFlowLevel(String value) {
    return FlowLevel.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => FlowLevel.none,
    );
  }

/// Helper method to parse Mood from string
  static Mood _parseMood(String value) {
    return Mood.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => Mood.calm,
    );
  }

  // Factory for empty state
  factory SymptomLog.empty(String userId) {
    return SymptomLog(
      id: '',
      userId: userId,
      date: DateTime.now(),
      periodStatus: PeriodStatus.none,
      flowLevel: FlowLevel.none,
      painLevel: 0,
      mood: Mood.calm,
      symptoms: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  // Copy with method
  SymptomLog copyWith({
    String? id,
    String? userId,
    DateTime? date,
    PeriodStatus? periodStatus,
    FlowLevel? flowLevel,
    int? painLevel,
    Mood? mood,
    List<String>? symptoms,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SymptomLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      periodStatus: periodStatus ?? this.periodStatus,
      flowLevel: flowLevel ?? this.flowLevel,
      painLevel: painLevel ?? this.painLevel,
      mood: mood ?? this.mood,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}