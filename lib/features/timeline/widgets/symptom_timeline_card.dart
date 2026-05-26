import 'package:flutter/material.dart';
import 'package:sparkle_lite/Data/models/timeline_item_model.dart';
import 'package:sparkle_lite/Data/models/symptom_log_model.dart';

/// The SymptomTimelineCard is a specialized widget designed to display symptom-related entries in the timeline. It takes a TimelineItem as input, extracts the relevant symptom data, and presents it in a visually appealing card format. The card includes key information such as the date of the entry, an icon representing the type of symptom, the title of the entry, pain level, mood, and a list of symptoms. Additionally, if there are any notes associated with the symptom entry, they are displayed in a subtle manner to provide additional context without overwhelming the user. The design of the SymptomTimelineCard emphasizes clarity and ease of reading, with a structured layout that allows users to quickly grasp the details of their symptom entries at a glance. By using this card format consistently across the timeline, users can easily track their symptoms over time and identify patterns or trends in their health journey.

class SymptomTimelineCard extends StatelessWidget {
  final TimelineItem item;
  final VoidCallback? onTap;
  
  const SymptomTimelineCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final symptomData = item.data['symptom'];
    final symptom = SymptomLog.fromJson(symptomData);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date column
              SizedBox(
                width: 60,
                child: Column(
                  children: [
                    Text(
                      _getDay(item.date),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getMonth(item.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: symptom.painLevel >= 7 
                                ? Colors.red.withOpacity(0.1) 
                                : const Color(0xFF7B61FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Pain: ${symptom.painLevel}/10',
                            style: TextStyle(
                              color: symptom.painLevel >= 7 ? Colors.red : const Color(0xFF7B61FF),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mood: ${symptom.mood.toString().split('.').last}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: symptom.symptoms.take(3).map((s) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          s,
                          style: const TextStyle(fontSize: 11),
                        ),
                      )).toList(),
                    ),
                    if (symptom.notes != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        symptom.notes!,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getDay(DateTime date) {
    return '${date.day}';
  }
  
  String _getMonth(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[date.month - 1];
  }
}