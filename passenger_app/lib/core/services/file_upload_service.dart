import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class FileUploadService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Upload a file to Supabase Storage and return the public URL
  static Future<String?> uploadFile(File file, String bucketName, {String? folder}) async {
    try {
      print('FileUploadService: Starting upload to bucket: $bucketName');

      // Validate file
      if (!await file.exists()) {
        print('FileUploadService: File does not exist: ${file.path}');
        throw Exception('Selected file does not exist');
      }

      final fileSize = await file.length();
      print('FileUploadService: File size: $fileSize bytes');

      if (fileSize == 0) {
        print('FileUploadService: File is empty');
        throw Exception('Selected file is empty');
      }

      if (fileSize > 10 * 1024 * 1024) { // 10MB limit
        print('FileUploadService: File too large: $fileSize bytes');
        throw Exception('File size exceeds 10MB limit');
      }

      final fileName = path.basename(file.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$fileName';

      // Create the file path
      final filePath = folder != null ? '$folder/$uniqueFileName' : uniqueFileName;
      print('FileUploadService: Uploading to path: $filePath');

      // Check if bucket exists and is accessible
      try {
        final buckets = await Supabase.instance.client.storage.listBuckets();
        final bucketExists = buckets.any((bucket) => bucket.id == bucketName);
        print('FileUploadService: Bucket exists: $bucketExists');

        if (!bucketExists) {
          throw Exception('Storage bucket "$bucketName" does not exist');
        }
      } catch (e) {
        print('FileUploadService: Error checking bucket: $e');
        throw Exception('Cannot access storage bucket: $e');
      }

      // Upload file to Supabase Storage
      print('FileUploadService: Starting upload...');
      await Supabase.instance.client.storage.from(bucketName).upload(
        filePath,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      print('FileUploadService: Upload completed successfully');

      // Get public URL
      final publicUrl = Supabase.instance.client.storage.from(bucketName).getPublicUrl(filePath);
      print('FileUploadService: Public URL: $publicUrl');

      return publicUrl;
    } catch (e, stackTrace) {
      print('FileUploadService: Error uploading file: $e');
      print('FileUploadService: Stack trace: $stackTrace');

      // Provide more specific error messages
      if (e.toString().contains('permission')) {
        throw Exception('Permission denied. Please check bucket permissions.');
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        throw Exception('Network error. Please check your internet connection.');
      } else if (e.toString().contains('storage') && e.toString().contains('not found')) {
        throw Exception('Storage bucket not found. Please check bucket configuration.');
      } else {
        throw Exception('Upload failed: ${e.toString()}');
      }
    }
  }

  /// Upload multiple files and return a map of file names to URLs
  static Future<Map<String, String?>> uploadMultipleFiles(
    Map<String, File> files,
    String bucketName, {
    String? folder
  }) async {
    final Map<String, String?> results = {};

    for (final entry in files.entries) {
      final fileName = entry.key;
      final file = entry.value;

      final url = await uploadFile(file, bucketName, folder: folder);
      results[fileName] = url;
    }

    return results;
  }

  /// Delete a file from Supabase Storage
  static Future<bool> deleteFile(String fileUrl, String bucketName) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;
      final filePath = pathSegments.sublist(pathSegments.indexOf(bucketName) + 1).join('/');

      await Supabase.instance.client.storage.from(bucketName).remove([filePath]);
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }
}
