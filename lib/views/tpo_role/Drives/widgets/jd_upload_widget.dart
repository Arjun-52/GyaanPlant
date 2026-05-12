import 'package:flutter/material.dart';
import '../services/file_upload_service.dart';

class JDUploadWidget extends StatelessWidget {
  final String? jdFilePath;
  final VoidCallback onPickFile;

  const JDUploadWidget({
    super.key,
    required this.jdFilePath,
    required this.onPickFile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Job Description (Optional)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final String? filePath = await FileUploadService.pickJDFile();
            if (filePath != null) {
              onPickFile();
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF061A14),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Icon(
                  jdFilePath != null ? Icons.check_circle : Icons.upload_file,
                  color: jdFilePath != null
                      ? const Color(0xFF00C853)
                      : Colors.white.withOpacity(0.7),
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  jdFilePath != null
                      ? FileUploadService.getFileDisplayName(jdFilePath!)
                      : 'Upload JD (PDF/DOC)',
                  style: TextStyle(
                    color: jdFilePath != null
                        ? const Color(0xFF00C853)
                        : Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
