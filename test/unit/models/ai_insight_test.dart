import 'package:flutter_test/flutter_test.dart';
import 'package:sparkle_lite/core/services/mock_ai_service.dart';
import 'package:sparkle_lite/Data/models/symptom_log_model.dart';

/// This test suite focuses on ensuring that the AI Insight generation logic is safe and does not produce any diagnostic conclusions. It verifies that the insights are educational, provide appropriate guidance, and always include a disclaimer about not being a diagnosis. The tests cover various scenarios, including high pain levels, empty symptoms, and the generation of doctor questions, to ensure that the AI Insight remains a helpful tool without overstepping into medical advice.
/// Note: These tests are designed to validate the behavior of the AI Insight generation logic and should be run in an environment where the MockAIService is properly implemented to return consistent results for the given inputs.
/// To run these tests, ensure that the MockAIService is set up to return insights that do not contain any diagnostic language and always include a disclaimer. The tests will check for the presence of safe guidance and the absence of any diagnostic terms in the generated insights.
void main() {
  group('AI Insight - Safety Tests (No Diagnosis)', () {
    test('AI insight does not contain diagnosis for high pain', () {
      final symptoms = [
        SymptomLog(
          id: '1',
          userId: 'user1',
          date: DateTime.now(),
          periodStatus: PeriodStatus.ongoing,
          flowLevel: FlowLevel.medium,
          painLevel: 9,
          mood: Mood.anxious,
          symptoms: ['Cramps', 'Severe pain'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final insight = MockAIService.generateInsight(symptoms);
      final summary = insight['summary'] as String;
      final guidance = insight['careGuidance'] as String;

      
      expect(summary.toLowerCase().contains('pcos'), false);
      expect(summary.toLowerCase().contains('pregnant'), false);
      expect(summary.toLowerCase().contains('cancer'), false);
      expect(summary.toLowerCase().contains('diagnosis'), false);
      
  
      expect(guidance.toLowerCase().contains('doctor') || 
             guidance.toLowerCase().contains('healthcare'), true);
    });

    test('AI insight always includes disclaimer', () {
      final symptoms = [
        SymptomLog(
          id: '1',
          userId: 'user1',
          date: DateTime.now(),
          periodStatus: PeriodStatus.none,
          flowLevel: FlowLevel.none,
          painLevel: 0,
          mood: Mood.calm,
          symptoms: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final insight = MockAIService.generateInsight(symptoms);
      final disclaimer = insight['disclaimer'] as String;

      expect(disclaimer.contains('not a diagnosis'), true);
      expect(disclaimer.contains('does not replace medical advice'), true);
    });

    test('Empty symptoms insight is educational, not diagnostic', () {
      final insight = MockAIService.generateInsight([]);
      final summary = insight['summary'] as String;
      final questions = insight['doctorQuestions'] as List;

      expect(summary.contains('haven\'t logged') || 
             summary.contains('Start tracking'), true);
      expect(summary.toLowerCase().contains('diagnosis'), false);
      expect(questions.isNotEmpty, true);
    });

    test('AI insight generates doctor questions', () {
      final symptoms = [
        SymptomLog(
          id: '1',
          userId: 'user1',
          date: DateTime.now(),
          periodStatus: PeriodStatus.ongoing,
          flowLevel: FlowLevel.heavy,
          painLevel: 7,
          mood: Mood.irritable,
          symptoms: ['Cramps', 'Bloating', 'Fatigue'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final insight = MockAIService.generateInsight(symptoms);
      final questions = insight['doctorQuestions'] as List;

      expect(questions.length, greaterThanOrEqualTo(1));
      expect(questions[0].toString().isNotEmpty, true);
    });
  });
}