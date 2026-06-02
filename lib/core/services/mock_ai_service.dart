import 'package:sparkle_lite/Data/models/ai_insight_model.dart';
import 'package:sparkle_lite/Data/models/symptom_log_model.dart';

/// Mock AI service that generates insights based on symptom logs. This is a safe, non-diagnostic implementation meant for demonstration and testing purposes.
/// It analyzes symptom patterns and provides general observations and suggestions without making any medical claims or diagnoses.
/// The insights are generated based on simple heuristics and patterns in the symptom data, such as frequency of certain symptoms, pain levels, and timing in relation to the menstrual cycle.
/// This service is designed to be easily replaceable with a more sophisticated AI implementation in the future, while ensuring that it never provides diagnostic information or medical advice.

class MockAIService {
  //  Never provides diagnosis, only observations and suggestions
  
  static Map<String, dynamic> generateInsight(List<SymptomLog> symptoms) {
    if (symptoms.isEmpty) {
      return _getEmptyInsight();
    }
    
    final highPainSymptoms = symptoms.where((s) => s.painLevel >= 7).toList();
    final irregularBleedingSymptoms = symptoms.where((s) => 
      s.symptoms.contains('Irregular bleeding') || 
      s.symptoms.contains('Spotting')
    ).toList();
    final recentSymptoms = symptoms.take(30).toList();
    final hasMultipleSymptoms = recentSymptoms.length >= 5;
    
    String summary = _generateSummary(symptoms, highPainSymptoms, irregularBleedingSymptoms);
    String possiblePattern = _generatePattern(symptoms, irregularBleedingSymptoms);
    String careGuidance = _generateGuidance(highPainSymptoms, irregularBleedingSymptoms);
    List<String> doctorQuestions = _generateQuestions(symptoms, highPainSymptoms, irregularBleedingSymptoms);
    
    return {
      'summary': summary,
      'possiblePattern': possiblePattern,
      'careGuidance': careGuidance,
      'doctorQuestions': doctorQuestions,
      'disclaimer': AIInsight.safeDisclaimer,
      'symptomsAnalyzed': symptoms.map((s) => _getSymptomSummary(s)).toList(),
      'symptomsCount': symptoms.length,
    };
  }
  
  static Map<String, dynamic> _getEmptyInsight() {
    return {
      'summary': "You haven't logged any symptoms yet. Start tracking to receive personalized insights about your health patterns.",
      'possiblePattern': "No data available for pattern analysis.",
      'careGuidance': "Log your daily symptoms, period, and mood to get helpful insights for your doctor visits.",
      'doctorQuestions': [
        "What symptoms should I be tracking?",
        "How often should I log my health data?",
        "What is considered normal for my age and lifestyle?"
      ],
      'disclaimer': AIInsight.safeDisclaimer,
      'symptomsAnalyzed': [],
      'symptomsCount': 0,
    };
  }
  
  static String _generateSummary(
    List<SymptomLog> symptoms,
    List<SymptomLog> highPainSymptoms,
    List<SymptomLog> irregularBleedingSymptoms,
  ) {
    final periodSymptoms = symptoms.where((s) => s.periodStatus != PeriodStatus.none).toList();
    
    if (highPainSymptoms.isNotEmpty && irregularBleedingSymptoms.isNotEmpty) {
      return "Your recent logs show a pattern of recurring pain (level ${highPainSymptoms.first.painLevel}/10) and irregular bleeding. This combination of symptoms may be worth discussing with a healthcare provider.";
    }
    
    if (highPainSymptoms.isNotEmpty) {
      return "You've reported ${highPainSymptoms.length} instance(s) of high pain level (7+ out of 10). Persistent or severe pain is something to mention to your doctor.";
    }
    
    if (irregularBleedingSymptoms.isNotEmpty) {
      return "Your logs show irregular bleeding or spotting on ${irregularBleedingSymptoms.length} occasion(s). Tracking these occurrences can help your doctor understand your cycle patterns.";
    }
    
    if (periodSymptoms.isNotEmpty) {
      return "You've been tracking your cycle regularly. Your symptoms appear to follow a pattern around your period days. This information is valuable for understanding your menstrual health.";
    }
    
    if (symptoms.length >= 10) {
      return "You've been consistently tracking your symptoms for ${symptoms.length} entries. This data provides good insight into your health patterns over time.";
    }
    
    return "You've logged ${symptoms.length} symptom record(s). Continue tracking to see patterns and prepare better for healthcare discussions.";
  }
  
  static String _generatePattern(
    List<SymptomLog> symptoms,
    List<SymptomLog> irregularBleedingSymptoms,
  ) {
    final periodSymptoms = symptoms.where((s) => s.periodStatus != PeriodStatus.none).toList();
    final painPattern = symptoms.where((s) => s.painLevel >= 5).toList();
    
    if (painPattern.length >= 3) {
      return "Recurring moderate to severe pain appears in your logs, often associated with your cycle.";
    }
    
    if (irregularBleedingSymptoms.isNotEmpty) {
      return "Irregular bleeding or spotting has been noted outside your regular cycle pattern.";
    }
    
    if (periodSymptoms.isNotEmpty) {
      return "Your symptoms show variation around your menstrual cycle dates.";
    }
    
    return "Continue tracking to identify patterns in your symptoms and cycle.";
  }
  
  static String _generateGuidance(
    List<SymptomLog> highPainSymptoms,
    List<SymptomLog> irregularBleedingSymptoms,
  ) {
    if (highPainSymptoms.isNotEmpty && irregularBleedingSymptoms.isNotEmpty) {
      return "Consider scheduling a conversation with a gynecologist to discuss the combination of pain and irregular bleeding you've been experiencing. Bring your symptom log to the appointment.";
    }
    
    if (highPainSymptoms.isNotEmpty) {
      return "If you're experiencing severe pain that affects your daily activities, it may be helpful to consult with a healthcare provider. Your symptom log can help them understand your experience.";
    }
    
    if (irregularBleedingSymptoms.isNotEmpty) {
      return "Irregular bleeding can have many causes. A healthcare provider can help determine if further evaluation is needed. Track any additional changes you notice.";
    }
    
    return "Continue maintaining your health log. This information is valuable for routine check-ups and understanding your body's patterns.";
  }
  
  static List<String> _generateQuestions(
    List<SymptomLog> symptoms,
    List<SymptomLog> highPainSymptoms,
    List<SymptomLog> irregularBleedingSymptoms,
  ) {
    List<String> questions = [];
    
    if (highPainSymptoms.isNotEmpty) {
      questions.add("Could my recurring pain be related to my cycle or another condition?");
      questions.add("What pain management options are appropriate for my situation?");
    }
    
    if (irregularBleedingSymptoms.isNotEmpty) {
      questions.add("What could be causing irregular bleeding or spotting?");
      questions.add("Should I schedule any tests to investigate this further?");
    }
    
    if (symptoms.length >= 10) {
      questions.add("Based on my symptom logs, do you see any concerning patterns?");
      questions.add("What additional symptoms should I be tracking?");
    }
    
    if (questions.isEmpty) {
      questions.add("Is my symptom pattern within normal range for my age?");
      questions.add("What should I watch for that would warrant a follow-up visit?");
      questions.add("How can I best prepare for my next appointment?");
    }
    
    // Limit to 3-4 questions
    return questions.take(4).toList();
  }
  
  static String _getSymptomSummary(SymptomLog symptom) {
    final dateStr = '${symptom.date.month}/${symptom.date.day}';
    final symptomsList = symptom.symptoms.take(2).join(', ');
    return '$dateStr: ${symptom.mood.toString().split('.').last}, pain ${symptom.painLevel}/10 - $symptomsList';
  }
}
