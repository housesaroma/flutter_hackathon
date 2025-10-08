import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/file_service.dart';

class FilePreviewScreen extends StatelessWidget {
  final EventAttachment attachment;
  final FileService fileService;

  const FilePreviewScreen({
    super.key,
    required this.attachment,
    required this.fileService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(attachment.name),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: _buildPreview(context),
    );
  }

  Widget _buildPreview(BuildContext context) {
    if (attachment.isImage) {
      return _buildImagePreview();
    } else {
      return _buildFileInfo(context);
    }
  }

  Widget _buildImagePreview() {
    final bytes = fileService.getFileBytes(attachment.fileData);

    if (bytes == null) {
      return const Center(child: Text('Ошибка загрузки изображения'));
    }

    return InteractiveViewer(
      child: Center(child: Image.memory(bytes, fit: BoxFit.contain)),
    );
  }

  Widget _buildFileInfo(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(attachment.fileIcon, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              attachment.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              fileService.getFileSizeString(attachment.size),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              _getFileTypeDescription(attachment.mimeType),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Для текстовых файлов можно добавить просмотр
                if (attachment.isText) {
                  _showTextContent(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Просмотр доступен только для изображений и текстовых файлов',
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.visibility),
              label: const Text('Просмотреть содержимое'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTextContent(BuildContext context) {
    final bytes = fileService.getFileBytes(attachment.fileData);
    if (bytes != null) {
      final textContent = String.fromCharCodes(bytes);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(attachment.name),
          content: SingleChildScrollView(child: Text(textContent)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ],
        ),
      );
    }
  }

  String _getFileTypeDescription(String mimeType) {
    if (mimeType.startsWith('image/')) {
      return 'Изображение';
    } else if (mimeType == 'application/pdf') {
      return 'PDF документ';
    } else if (mimeType.contains('text')) {
      return 'Текстовый файл';
    } else {
      return 'Файл';
    }
  }
}
