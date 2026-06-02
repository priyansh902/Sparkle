/// This file defines the abstract interface for storage operations, such as uploading and deleting files.
/// This allows for different implementations (e.g., Firebase Storage, local storage) without changing the
/// app logic. The interface includes methods for uploading files, deleting files, and retrieving file URLs.


abstract class StorageInterface {
  Future<String?> uploadFile({
    required String path,
    required String userId,
    required String fileName,
    required List<int> bytes,
  });
  
  Future<void> deleteFile(String fileUrl);
  Future<String> getFileUrl(String path);
}