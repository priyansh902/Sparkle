
import 'package:sparkle_lite/core/interfaces/storage_interface.dart';

/// A mock storage service for testing and development purposes.
/// This simulates storage operations using SharedPreferences for persistence and in-memory caching for performance.
/// TODO: Implement more robust error handling and validation logic.
/// TODO: Add support for batch operations and more complex queries in the future.


class MockStorageService implements StorageInterface {
  // In-memory mock storage
  final Map<String, String> _mockFiles = {};
  
  @override
  Future<String?> uploadFile({
    required String path,
    required String userId,
    required String fileName,
    required List<int> bytes,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Create mock URL
    final mockUrl = 'mock://storage/$userId/$fileName';
    _mockFiles[mockUrl] = '${bytes.length}';
    
    return mockUrl;
  }
  
  @override
  Future<void> deleteFile(String fileUrl) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockFiles.remove(fileUrl);
  }
  
  @override
  Future<String> getFileUrl(String path) async {
    return 'mock://storage/$path';
  }
}