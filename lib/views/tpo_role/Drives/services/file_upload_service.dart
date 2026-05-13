import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class FileUploadService {
  static Future<String?> pickJDFile() async {
    try {
      // Ensure we're on the correct platform
      if (!kIsWeb) {
        final FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx'],
          allowMultiple: false,
        );

        // Safely check result and extract path
        if (result != null &&
            result.files.isNotEmpty &&
            result.files.first.path != null &&
            result.files.first.path!.isNotEmpty) {
          return result.files.first.path;
        }
      }
      return null;
    } catch (e) {
      debugPrint('File picker error: $e');
      return null;
    }
  }

  static bool isValidJDFile(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    return ['pdf', 'doc', 'docx'].contains(extension);
  }

  static String getFileDisplayName(String filePath) {
    if (filePath.isEmpty) return 'Unknown file';
    return filePath.split('/').last;
  }
}
