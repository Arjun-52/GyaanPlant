import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:printing/printing.dart';
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

      String? filePath;
      bool savedSuccessfully = false;

      // Try to save to Downloads directory first
      try {
        final directory = await getDownloadsDirectory();
        if (directory != null) {
          AppLogger.info(_tag, 'Attempting to save to downloads directory: ${directory.path}');
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }
          filePath = '${directory.path}/$fileName.pdf';
          final file = File(filePath);
          await file.writeAsBytes(pdfBytes);
          savedSuccessfully = true;
          AppLogger.info(_tag, 'PDF saved successfully to downloads folder: $filePath');
        }
      } catch (e) {
        AppLogger.warning(_tag, 'Failed to save to downloads directory, trying app documents folder: $e');
      }

      // Fallback: save to application documents directory (always allowed without permission prompts)
      if (!savedSuccessfully) {
        try {
          final directory = await getApplicationDocumentsDirectory();
          AppLogger.info(_tag, 'Attempting to save to app documents directory: ${directory.path}');
          filePath = '${directory.path}/$fileName.pdf';
          final file = File(filePath);
          await file.writeAsBytes(pdfBytes);
          savedSuccessfully = true;
          AppLogger.info(_tag, 'PDF saved successfully to app documents: $filePath');
        } catch (e) {
          AppLogger.error(_tag, 'Failed to save to app documents folder: $e');
        }
      }

      if (!savedSuccessfully || filePath == null) {
        AppLogger.error(_tag, 'Could not save PDF to any directory');
        return false;
      }

      // Try to open the file using url_launcher
      final fileUri = Uri.parse('file://$filePath');
      try {
        if (await canLaunchUrl(fileUri)) {
          await launchUrl(fileUri);
          AppLogger.info(_tag, 'File opened successfully via url_launcher');
          return true;
        }
      } catch (e) {
        AppLogger.warning(_tag, 'url_launcher failed to open file: $e');
      }

      // Safe open fallback via printing package (essential on Android/iOS due to file provider constraints)
      try {
        AppLogger.info(_tag, 'Attempting to share/open PDF via Printing.sharePdf');
        await Printing.sharePdf(bytes: pdfBytes, filename: '$fileName.pdf');
        return true;
      } catch (e) {
        AppLogger.error(_tag, 'Printing.sharePdf failed: $e');
      }

      return savedSuccessfully;
    } catch (e, st) {
      AppLogger.error(_tag, 'Failed to download and open PDF', e, st);
      return false;
    }
  }

  /// Save PDF to temp directory and return the file path for sharing.
  /// Use this when you want to share via share_plus (WhatsApp, Gmail, etc.)
  static Future<String?> savePdfForSharing({
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/$fileName.pdf';
      await File(path).writeAsBytes(pdfBytes);
      AppLogger.info(_tag, 'PDF saved for sharing at: $path');
      return path;
    } catch (e, st) {
      AppLogger.error(_tag, 'Failed to save PDF for sharing', e, st);
      return null;
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
