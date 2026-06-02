import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkle_lite/Data/models/health_record_model.dart';
import 'package:sparkle_lite/providers/record_provider.dart';
import 'package:sparkle_lite/shared/widgets/loading_widget.dart';
import 'package:sparkle_lite/shared/widgets/primary_button.dart';
import 'package:sparkle_lite/shared/widgets/form_text_field.dart';

/// Screen for viewing and editing details of a specific health record.
/// This screen allows users to view the details of a health record, including the title, type, date, associated doctor, notes, and any attached files. Users can also edit the record details or delete the record from this screen.
/// The screen uses the RecordProvider to fetch and manage the health record data, and it provides a user-friendly interface for interacting with the record details. It also includes error handling and loading states for a smooth user experience.
/// TODO: Implement actual file viewing functionality for attached documents in production. Currently, it shows a mock file viewer with a placeholder icon and filename.
/// TODO: Add more fields to the health record details in the future, such as location of doctor visit, prescription details, or lab results summary, depending on the record type. The UI should be flexible to accommodate these additional fields without major changes.

class RecordDetailScreen extends ConsumerStatefulWidget {
  const RecordDetailScreen({super.key, required this.recordId});
  final String recordId;

  @override
  ConsumerState<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends ConsumerState<RecordDetailScreen> {
  HealthRecord? _record;
  bool _isLoading = true;
  bool _isEditing = false;
  
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _doctorNameController;
  late TextEditingController _notesController;
  late RecordType _selectedType;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadRecord();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _doctorNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadRecord() {
    final record = ref.read(recordProvider.notifier).getRecordById(widget.recordId);
    if (record != null) {
      _record = record;
      _initializeControllers();
      setState(() => _isLoading = false);
    } else {
      setState(() => _isLoading = false);
    }
  }
  
  void _initializeControllers() {
    _titleController = TextEditingController(text: _record!.title);
    _doctorNameController = TextEditingController(text: _record!.doctorName ?? '');
    _notesController = TextEditingController(text: _record!.notes ?? '');
    _selectedType = _record!.recordType;
    _selectedDate = _record!.recordDate;
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _initializeControllers();
      }
    });
  }

  Future<void> _saveEdit() async {
    if (_formKey.currentState!.validate()) {
      final updatedRecord = _record!.copyWith(
        title: _titleController.text.trim(),
        recordType: _selectedType,
        recordDate: _selectedDate,
        doctorName: _doctorNameController.text.isEmpty ? null : _doctorNameController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
      
      final success = await ref.read(recordProvider.notifier).updateRecord(updatedRecord);
      
      if (success && mounted) {
        setState(() {
          _record = updatedRecord;
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record updated successfully!')),
        );
      }
    }
  }

  Future<void> _deleteRecord() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this record? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
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
      final success = await ref.read(recordProvider.notifier).deleteRecord(widget.recordId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record deleted')),
        );
        context.pop();
      }
    }
  }

  void _viewFile() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.picture_as_pdf, color: Colors.red),
            SizedBox(width: 8),
            Text('File Preview'),
          ],
        ),
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.description, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _record!.fileUrl?.split('/').last ?? 'document.pdf',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This is a mock file viewer.\nIn production, this would show the actual file content.',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Download started (mock)')),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B61FF),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Loading record details...'),
      );
    }
    
    if (_record == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Record Details')),
        body: const Center(child: Text('Record not found')),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Record' : 'Record Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!_isEditing) ...[
            IconButton(
              icon: Icon(Icons.edit, color: isDark ? Colors.white : Colors.black87),
              onPressed: _toggleEditMode,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteRecord,
            ),
          ] else ...[
            IconButton(
              icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black87),
              onPressed: _toggleEditMode,
            ),
          ],
        ],
      ),
      body: _isEditing ? _buildEditForm(isDark) : _buildViewMode(isDark),
    );
  }
  
  Widget _buildViewMode(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type icon
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF7B61FF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _record!.recordType.icon,
                size: 50,
                color: const Color(0xFF7B61FF),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          Center(
            child: Text(
              _record!.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          
          // Type
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF7B61FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _record!.recordType.displayName,
                style: const TextStyle(
                  color: Color(0xFF7B61FF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Details card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: isDark ? Colors.grey[850] : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Date',
                    _formatDate(_record!.recordDate),
                    isDark,
                  ),
                  const Divider(),
                  _buildDetailRow(
                    Icons.label,
                    'Type',
                    _record!.recordType.displayName,
                    isDark,
                  ),
                  if (_record!.doctorName != null) ...[
                    const Divider(),
                    _buildDetailRow(
                      Icons.person,
                      'Doctor',
                      _record!.doctorName!,
                      isDark,
                    ),
                  ],
                  if (_record!.hasFile) ...[
                    const Divider(),
                    _buildDetailRow(
                      Icons.attach_file,
                      'Attachment',
                      _record!.fileUrl!.split('/').last,
                      isDark,
                      isAction: true,
                      onTap: _viewFile,
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          if (_record!.notes != null) ...[
            const SizedBox(height: 24),
            Text(
              'Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: isDark ? Colors.grey[850] : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _record!.notes!,
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], height: 1.5),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Created at info
          Center(
            child: Text(
              'Created on ${_formatDateTime(_record!.createdAt)}',
              style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildEditForm(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            FormTextField(
              controller: _titleController,
              label: 'Record Title',
              prefixIcon: Icons.title,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Record Type
            Text(
              'Record Type',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<RecordType>(
              value: _selectedType,
              decoration: InputDecoration(
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
              ),
              dropdownColor: isDark ? Colors.grey[800] : Colors.white,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              items: RecordType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(type.icon, size: 20, color: const Color(0xFF7B61FF)),
                      const SizedBox(width: 8),
                      Text(type.displayName, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value ?? RecordType.other;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today, color: Color(0xFF7B61FF)),
              title: Text('Record Date', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              subtitle: Text(
                _selectedDate.toString().split(' ')[0],
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Doctor Name (Optional)
            FormTextField(
              controller: _doctorNameController,
              label: 'Doctor Name (Optional)',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            
            // Notes
            FormTextField(
              controller: _notesController,
              label: 'Notes (Optional)',
              prefixIcon: Icons.note_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _toggleEditMode,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey[400]!),
                    ),
                    child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PrimaryButton(
                    text: 'Save Changes',
                    onPressed: _saveEdit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(IconData icon, String label, String value, bool isDark, {
    bool isAction = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: isAction ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF7B61FF)),
            const SizedBox(width: 16),
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: isAction 
                      ? const Color(0xFF7B61FF) 
                      : (isDark ? Colors.grey[400] : Colors.grey[700]),
                  fontWeight: isAction ? FontWeight.w600 : null,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            if (isAction)
              Icon(Icons.chevron_right, size: 20, color: isDark ? Colors.grey[600] : Colors.grey[400]),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
  
  String _formatDateTime(DateTime date) {
    return '${date.month}/${date.day}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}