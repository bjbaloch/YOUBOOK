import 'dart:io';
import 'package:path/path.dart' as path;

class FileUploadService {
  static Future<String?> uploadFile(File file, String bucketName, {String? folder}) async {
    try {
      if (!await file.exists()) throw Exception('Selected file does not exist');
      final fileSize = await file.length();
      if (fileSize == 0) throw Exception('Selected file is empty');
      if (fileSize > 10 * 1024 * 1024) throw Exception('File size exceeds 10MB limit');

      final fileName = path.basename(file.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$fileName';
      final filePath = folder != null ? '$folder/$uniqueFileName' : uniqueFileName;

      // TODO: Restore Supabase Storage upload when connecting backend
      print('FileUploadService: Upload skipped in UI-only mode. Path would be: $filePath');
      return null;
    } catch (e) {
      print('FileUploadService: Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, String?>> uploadMultipleFiles(
    Map<String, File> files,
    String bucketName, {
    String? folder,
  }) async {
    final Map<String, String?> results = {};
    for (final entry in files.entries) {
      results[entry.key] = await uploadFile(entry.value, bucketName, folder: folder);
    }
    return results;
  }

  static Future<bool> deleteFile(String fileUrl, String bucketName) async {
    // TODO: Restore Supabase Storage delete when connecting backend
    return true;
  }
}
