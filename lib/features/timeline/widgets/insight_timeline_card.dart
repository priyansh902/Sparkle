import 'package:flutter/material.dart';
import 'package:sparkle_lite/Data/models/timeline_item_model.dart';
import 'package:sparkle_lite/Data/models/ai_insight_model.dart';

/// The InsightTimelineCard is a specialized widget designed to display AI-generated insights in the timeline. It takes a TimelineItem as input, extracts the relevant insight data, and presents it in a visually appealing card format. The card includes key information such as the date of the entry, an icon representing the type of insight, the title of the entry, a summary of the insight, and an indication of how many symptoms were analyzed to generate the insight. The design of the InsightTimelineCard emphasizes clarity and ease of reading, with a structured layout that allows users to quickly grasp the details of their insights at a glance. By using this card format consistently across the timeline, users can easily track their insights over time and identify patterns or trends in their health journey.

class InsightTimelineCard extends StatelessWidget {
  final TimelineItem item;
  final VoidCallback? onTap;
  
  const InsightTimelineCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final insightData = item.data['insight'];
    final insight = AIInsight.fromJson(insightData);
    
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
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      insight.summary.length > 100 
                          ? '${insight.summary.substring(0, 100)}...' 
                          : insight.summary,
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ECDC4).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Analyzed ${insight.symptomsCount} symptoms',
                        style: const TextStyle(
                          color: Color(0xFF4ECDC4),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Icon(Icons.chevron_right, color: Colors.grey[400]),
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