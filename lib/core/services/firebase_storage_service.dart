import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../interfaces/storage_interface.dart';

class FirebaseStorageService implements StorageInterface {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<String?> uploadFile({
    required String path,
    required String userId,
    required String fileName,
    required List<int> bytes,
  }) async {
    try {
      // Convert List<int> to Uint8List
      final Uint8List uint8List = Uint8List.fromList(bytes);
      
      final storagePath = 'users/$userId/$path/$fileName';
      final ref = _storage.ref().child(storagePath);
      
      await ref.putData(uint8List);
      final downloadUrl = await ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  @override
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      print('Delete error: $e');
    }
  }

  @override
  Future<String> getFileUrl(String path) async {
    final ref = _storage.ref().child(path);
    return await ref.getDownloadURL();
  }
}