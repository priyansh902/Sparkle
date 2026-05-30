import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkle_lite/core/constants/app_constants.dart';
import 'package:sparkle_lite/Data/models/health_record_model.dart';
import 'package:sparkle_lite/providers/record_provider.dart';
import 'package:sparkle_lite/shared/widgets/empty_state_widget.dart';
import 'package:sparkle_lite/shared/widgets/loading_widget.dart';

/// Screen that displays a list of health records with filtering and search capabilities
/// Allows users to view, filter, search, and delete their health records. Tapping a record navigates to the detail screen.
/// Features:
/// - Search bar for filtering records by title or doctor name
/// - Filter chips for filtering by record type (Lab Report, Prescription, etc.)
/// - Swipe to delete with confirmation dialog
/// - Empty state when no records are available
/// - Loading state while fetching records.
class RecordsListScreen extends ConsumerStatefulWidget {
  const RecordsListScreen({super.key});

  @override
  ConsumerState<RecordsListScreen> createState() => _RecordsListScreenState();
}

class _RecordsListScreenState extends ConsumerState<RecordsListScreen> {
  RecordType? _selectedFilter;
  String _searchQuery = '';
  
  List<HealthRecord> get _filteredRecords {
    final records = ref.watch(recordProvider).records;
    
    return records.where((record) {
      if (_selectedFilter != null && record.recordType != _selectedFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        return record.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (record.doctorName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final recordState = ref.watch(recordProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Records'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {
              context.push(AppConstants.routeUploadRecord);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search records...',
                hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: _buildBody(context, ref, recordState, isDark),
    );
  }
  
  Widget _buildBody(BuildContext context, WidgetRef ref, RecordState state, bool isDark) {
    if (state.isLoading) {
      return const LoadingWidget(message: 'Loading records...');
    }
    
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.error!, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(recordProvider.notifier).loadRecords(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (state.records.isEmpty) {
      return EmptyStateWidget(
        title: 'No Health Records',
        message: 'Upload lab reports, prescriptions, and other health documents',
        buttonText: 'Upload First Record',
        onButtonPressed: () {
          context.push(AppConstants.routeUploadRecord);
        },
        icon: Icons.folder_outlined,
      );
    }
    
    return Column(
      children: [
        // Filter chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedFilter == null,
                  onSelected: (_) {
                    setState(() {
                      _selectedFilter = null;
                    });
                  },
                  selectedColor: const Color(0xFF7B61FF).withOpacity(0.2),
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  labelStyle: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
                const SizedBox(width: 8),
                ...RecordType.values.map((type) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(type.displayName),
                      selected: _selectedFilter == type,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = selected ? type : null;
                        });
                      },
                      selectedColor: const Color(0xFF7B61FF).withOpacity(0.2),
                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                      labelStyle: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        
        // Records list
        Expanded(
          child: _filteredRecords.isEmpty
              ? Center(
                  child: Text(
                    _searchQuery.isNotEmpty 
                        ? 'No matching records found' 
                        : 'No records of this type',
                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredRecords.length,
                  itemBuilder: (context, index) {
                    final record = _filteredRecords[index];
                    return _buildRecordCard(context, ref, record, isDark);
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildRecordCard(BuildContext context, WidgetRef ref, HealthRecord record, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? Colors.grey[850] : Colors.white,
      child: Dismissible(
        key: Key(record.id),
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Record'),
              content: const Text('Are you sure you want to delete this record?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
          
          if (confirmed == true) {
            await ref.read(recordProvider.notifier).deleteRecord(record.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Record deleted')),
              );
            }
          }
        },
        child: InkWell(
          onTap: () {
            context.push('${AppConstants.routeRecordDetail}?id=${record.id}');
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7B61FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(record.recordType.icon, color: const Color(0xFF7B61FF)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${record.recordType.displayName} • ${_formatDate(record.recordDate)}',
                        style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
                      ),
                      if (record.doctorName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Dr. ${record.doctorName}',
                          style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: isDark ? Colors.grey[600] : Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}