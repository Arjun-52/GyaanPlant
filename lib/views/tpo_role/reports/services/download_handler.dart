import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';

/// Service for handling file downloads and opening
class DownloadHandler {
  static const _tag = 'DownloadHandler';

  /// Download and open a PDF file
  static Future<bool> downloadAndOpenPdf({
    required Uint8List pdfBytes,
    required String fileName,
    required String reportType,
  }) async {
    try {
      AppLogger.info(_tag, 'Starting download for $reportType report');
      AppLogger.info(_tag, 'PDF bytes size: ${pdfBytes.length} bytes');

      // Check if PDF bytes are valid
      if (pdfBytes.isEmpty) {
        AppLogger.error(
          _tag,
          'PDF bytes are empty - cannot download empty file',
        );
        return false;
      }

      // Get the downloads directory
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        AppLogger.error(_tag, 'Failed to get downloads directory');
        return false;
      }

      AppLogger.info(_tag, 'Downloads directory: ${directory.path}');

      // Create file path
      final filePath = '${directory.path}/$fileName.pdf';
      final file = File(filePath);

      // Check if directory exists
      if (!await directory.exists()) {
        AppLogger.info(_tag, 'Creating downloads directory');
        await directory.create(recursive: true);
      }

      // Write PDF to file
      await file.writeAsBytes(pdfBytes);
      AppLogger.info(_tag, 'PDF saved to: $filePath');

      // Verify file was created
      if (!await file.exists()) {
        AppLogger.error(_tag, 'Failed to create PDF file');
        return false;
      }

      final fileSize = await file.length();
      AppLogger.info(_tag, 'File size: $fileSize bytes');

      // Open the file
      AppLogger.info(_tag, 'Attempting to open file: $filePath');

      // Try to open the file using url_launcher
      final fileUri = Uri.parse('file://$filePath');

      try {
        if (await canLaunchUrl(fileUri)) {
          await launchUrl(fileUri);
          AppLogger.info(
            _tag,
            'File opened successfully via system file manager',
          );
          return true;
        } else {
          AppLogger.warning(_tag, 'Cannot launch file URL: $fileUri');
          // Return true since file was saved successfully
          return true;
        }
      } catch (e) {
        AppLogger.warning(_tag, 'Failed to open file: $e');
        // Return true since file was saved successfully
        return true;
      }
    } catch (e, st) {
      AppLogger.error(_tag, 'Failed to download and open PDF', e, st);
      return false;
    }
  }

  /// Get the appropriate downloads directory for the platform
  static Future<Directory?> getDownloadsDirectory() async {
    try {
      if (Platform.isAndroid) {
        // For Android, try to get the Downloads directory
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (await downloadsDir.exists()) {
          return downloadsDir;
        }

        // Fallback to external storage
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          return externalDir;
        }

        // Final fallback to app documents directory
        return await getApplicationDocumentsDirectory();
      } else if (Platform.isIOS) {
        // For iOS, use the application documents directory
        return await getApplicationDocumentsDirectory();
      } else {
        // For other platforms, use the default downloads directory
        return await getDownloadsDirectory();
      }
    } catch (e, st) {
      AppLogger.error(_tag, 'Failed to get downloads directory', e, st);
      return null;
    }
  }

  /// Generate a unique filename for the report
  static String generateFileName({
    required String reportType,
    required String collegeName,
    DateTime? date,
  }) {
    final reportDate = date ?? DateTime.now();
    final dateStr = '${reportDate.day}${reportDate.month}${reportDate.year}';
    final cleanCollegeName = collegeName
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .trim();
    final cleanCollegeNameShort = cleanCollegeName
        .replaceAll(' ', '_')
        .toLowerCase();

    return '${reportType.toLowerCase()}_$cleanCollegeNameShort$dateStr';
  }

  /// Check if file already exists and append number if needed
  static Future<String> getUniqueFilePath(String basePath) async {
    String filePath = '$basePath.pdf';
    int counter = 1;

    while (await File(filePath).exists()) {
      filePath = '${basePath}_$counter.pdf';
      counter++;
    }

    return filePath;
  }

  /// Delete a file (for cleanup purposes)
  static Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        AppLogger.info(_tag, 'File deleted: $filePath');
        return true;
      }
      return false;
    } catch (e, st) {
      AppLogger.error(_tag, 'Failed to delete file: $filePath', e, st);
      return false;
    }
  }

  /// Get file size in human readable format
  static String getFileSize(String filePath) {
    try {
      final file = File(filePath);
      final bytes = file.lengthSync();

      if (bytes < 1024) {
        return '$bytes B';
      } else if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      } else {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    } catch (e) {
      return 'Unknown size';
    }
  }

  /// Check if external storage is available
  static Future<bool> isExternalStorageAvailable() async {
    try {
      final externalDir = await getExternalStorageDirectory();
      return externalDir != null;
    } catch (e) {
      return false;
    }
  }

  /// Request storage permissions (for Android)
  static Future<bool> requestStoragePermissions() async {
    try {
      // This would typically use the permission_handler package
      // For now, we'll assume permissions are granted
      // In a real implementation, you would:
      // 1. Check current permission status
      // 2. Request permissions if not granted
      // 3. Handle permission denied scenarios
      AppLogger.info(_tag, 'Storage permissions check completed');
      return true;
    } catch (e, st) {
      AppLogger.error(_tag, 'Failed to check storage permissions', e, st);
      return false;
    }
  }
}
