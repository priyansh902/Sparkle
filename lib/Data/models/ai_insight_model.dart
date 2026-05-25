

import 'package:equatable/equatable.dart';

/// Represents an AI-generated insight based on user health data.
class AIInsight extends Equatable {
  final String id;
  final String userId;
  final String summary;
  final String possiblePattern;
  final String careGuidance;
  final List<String> doctorQuestions;
  final String disclaimer;
  final DateTime createdAt;

  const AIInsight({
    required this.id,
    required this.userId,
    required this.summary,
    required this.possiblePattern,
    required this.careGuidance,
    required this.doctorQuestions,
    required this.disclaimer,
    required this.createdAt,
  });

 /// A standard disclaimer to be included with all AI insights.
  static const String safeDisclaimer = 
      "This is not a diagnosis and does not replace medical advice.";
      
  
  @override
  List<Object?> get props => [id, userId, createdAt];
}