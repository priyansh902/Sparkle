import 'package:flutter_test/flutter_test.dart';
import 'package:sparkle_lite/data/models/symptom_log_model.dart';

/// This test suite focuses on validating the SymptomLog model's data integrity, including pain level validation, symptoms validation, JSON serialization/deserialization, and the functionality of the copyWith method. The tests ensure that the model correctly handles valid and invalid inputs for pain levels and symptoms, accurately converts to and from JSON format, and allows for proper copying of instances with modified fields. These tests are essential for maintaining the reliability of the SymptomLog model as it is a core component of the application's data management.
/// Note: To run these tests, ensure that the SymptomLog model is implemented with the necessary validation logic and JSON serialization methods. The tests will check for expected outcomes based on the defined behavior of the model, such as valid pain levels being between 0 and 10, and symptoms not being empty. Additionally, the copyWith method should allow for creating modified copies of SymptomLog instances without altering the original instance.
/// The tests cover a range of scenarios, including edge cases for pain levels and symptoms, to ensure that the SymptomLog model behaves as expected under various conditions. This comprehensive testing approach helps to identify any potential issues early in the development process and ensures that the model remains robust and reliable for use in the application.

void main() {
  group('SymptomLog Model Tests', () {
    test('Pain level validation - valid values', () {
      expect(SymptomLog.isValidPainLevel(0), true);
      expect(SymptomLog.isValidPainLevel(5), true);
      expect(SymptomLog.isValidPainLevel(10), true);
    });

    test('Pain level validation - invalid values', () {
      expect(SymptomLog.isValidPainLevel(-1), false);
      expect(SymptomLog.isValidPainLevel(11), false);
      expect(SymptomLog.isValidPainLevel(100), false);
    });

    test('Symptoms validation - valid', () {
      expect(SymptomLog.isValidSymptoms(['Cramps', 'Headache']), true);
      expect(SymptomLog.isValidSymptoms(['Bloating']), true);
    });

    test('Symptoms validation - invalid', () {
      expect(SymptomLog.isValidSymptoms([]), false);
    });

    test('SymptomLog toJson conversion', () {
      final symptom = SymptomLog(
        id: 'test_001',
        userId: 'user_123',
        date: DateTime(2024, 1, 15),
        periodStatus: PeriodStatus.ongoing,
        flowLevel: FlowLevel.medium,
        painLevel: 6,
        mood: Mood.tired,
        symptoms: ['Cramps', 'Fatigue'],
        notes: 'Feeling exhausted',
        createdAt: DateTime(2024, 1, 15, 10, 30),
        updatedAt: DateTime(2024, 1, 15, 10, 30),
      );

      final json = symptom.toJson();

      expect(json['id'], 'test_001');
      expect(json['userId'], 'user_123');
      expect(json['painLevel'], 6);
      expect(json['symptoms'], ['Cramps', 'Fatigue']);
    });

    test('SymptomLog fromJson conversion', () {
      final json = {
        'id': 'test_002',
        'userId': 'user_456',
        'date': '2024-01-20T00:00:00.000',
        'periodStatus': 'started',
        'flowLevel': 'light',
        'painLevel': 3,
        'mood': 'calm',
        'symptoms': ['Headache'],
        'notes': null,
        'createdAt': '2024-01-20T09:00:00.000',
        'updatedAt': '2024-01-20T09:00:00.000',
      };

      final symptom = SymptomLog.fromJson(json);

      expect(symptom.id, 'test_002');
      expect(symptom.userId, 'user_456');
      expect(symptom.painLevel, 3);
      expect(symptom.periodStatus, PeriodStatus.started);
      expect(symptom.flowLevel, FlowLevel.light);
      expect(symptom.mood, Mood.calm);
    });

    test('Empty symptom factory', () {
      final emptySymptom = SymptomLog.empty('user_789');

      expect(emptySymptom.userId, 'user_789');
      expect(emptySymptom.id, '');
      expect(emptySymptom.painLevel, 0);
      expect(emptySymptom.periodStatus, PeriodStatus.none);
    });

    test('CopyWith method works correctly', () {
      final original = SymptomLog(
        id: 'test_003',
        userId: 'user_123',
        date: DateTime(2024, 1, 15),
        periodStatus: PeriodStatus.none,
        flowLevel: FlowLevel.none,
        painLevel: 2,
        mood: Mood.happy,
        symptoms: [],
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      final updated = original.copyWith(
        painLevel: 8,
        mood: Mood.anxious,
        symptoms: ['Cramps', 'Pain'],
      );

      expect(updated.painLevel, 8);
      expect(updated.mood, Mood.anxious);
      expect(updated.symptoms, ['Cramps', 'Pain']);
      expect(updated.id, original.id);
    });
  });
}