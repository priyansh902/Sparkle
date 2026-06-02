import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sparkle_lite/Data/models/health_record_model.dart';
import 'package:sparkle_lite/providers/auth_provider.dart';
import 'package:sparkle_lite/providers/record_provider.dart';
import 'package:sparkle_lite/shared/widgets/primary_button.dart';
import 'package:sparkle_lite/shared/widgets/form_text_field.dart';

/// Screen for uploading a new health record
/// TODO: Implement actual file upload and storage
/// TODO: Add error handling and validation for file types and sizes
/// TODO: Integrate with backend to save record details and file URL

class UploadRecordScreen extends ConsumerStatefulWidget {
  const UploadRecordScreen({super.key});

  @override
  ConsumerState<UploadRecordScreen> createState() => _UploadRecordScreenState();
}

class _UploadRecordScreenState extends ConsumerState<UploadRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _doctorNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  RecordType _selectedType = RecordType.other;
  DateTime _selectedDate = DateTime.now();
  String? _selectedFileName;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _doctorNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'txt'],
      );
      
      if (result != null) {
        setState(() {
          _selectedFileName = result.files.first.name;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected: $_selectedFileName')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error picking file')),
      );
    }
  }

  Future<void> _saveRecord() async {
    if (_formKey.currentState!.validate()) {
      final authState = ref.read(authProvider);
      final userId = authState.user?.id;
      
      if (userId == null) return;
      
      final newRecord = HealthRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        title: _titleController.text.trim(),
        recordType: _selectedType,
        recordDate: _selectedDate,
        doctorName: _doctorNameController.text.isEmpty ? null : _doctorNameController.text,
        fileUrl: _selectedFileName != null ? 'mock://records/$_selectedFileName' : null,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final success = await ref.read(recordProvider.notifier).addRecord(newRecord);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Health record uploaded successfully!')),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordState = ref.watch(recordProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Health Record'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                    hint: 'e.g., Blood Test Report',
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
                    hint: 'Dr. Name',
                  ),
                  const SizedBox(height: 16),
                  
                  // File Upload
                  Text(
                    'Attach File',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickFile,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                        color: isDark ? Colors.grey[800] : Colors.grey[50],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _selectedFileName == null ? Icons.cloud_upload : Icons.check_circle,
                            size: 48,
                            color: _selectedFileName == null ? Colors.grey : const Color(0xFF7B61FF),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedFileName ?? 'Tap to select file',
                            style: TextStyle(
                              color: _selectedFileName == null ? (isDark ? Colors.grey[500] : Colors.grey[600]) : const Color(0xFF7B61FF),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Supports: PDF, JPG, PNG, TXT',
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Notes (Optional)
                  FormTextField(
                    controller: _notesController,
                    label: 'Notes (Optional)',
                    prefixIcon: Icons.note_outlined,
                    hint: 'Add any additional notes...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  
                  PrimaryButton(
                    text: recordState.isSaving ? 'Uploading...' : 'Upload Record',
                    onPressed: _saveRecord,
                    isLoading: recordState.isSaving,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (recordState.isSaving)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}