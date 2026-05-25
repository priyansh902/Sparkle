
import 'package:equatable/equatable.dart';

/// Represents a symptom log entry for a user, capturing details about their menstrual cycle, symptoms, and mood.
enum PeriodStatus {
  none,
  started,
  ongoing,
  ended,
} 

enum FlowLevel {
  none,
  light,
  medium,
  heavy,
}

enum Mood {
  calm,
  anxious,
  tired,
  irritable,
  happy,
  sad,
}


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

/// Creates a new instance of [SymptomLog] with the provided parameters.
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

/// Returns a list of properties that are used to determine equality between instances of [SymptomLog].
  @override
  List<Object?> get props => [
        id,
        userId,
        date,
        periodStatus,
        painLevel,
      ];

  /// Validates the pain level to ensure it is within the acceptable range of 0 to 10.
  static bool isValidPainLevel(int level) {
    return level >= 0 && level <= 10;
  }

/// Validates that the list of symptoms is not empty, ensuring that at least one symptom is logged.
  static void validateSymptomLog(List<String> symptoms) => symptoms.isNotEmpty;

/// Factory constructor to create an empty [SymptomLog] instance with default values for a given user ID.
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

}