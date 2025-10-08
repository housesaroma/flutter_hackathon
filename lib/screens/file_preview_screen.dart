import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
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
    } else if (attachment.isText) {
      return _buildTextPreview();
    } else if (attachment.isPdf) {
      return _buildPdfInfo(context);
    } else {
      return _buildFileInfo(context);
    }
  }

  Widget _buildPdfInfo(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📄', style: TextStyle(fontSize: 64)),
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
            const Text(
              'PDF документ',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _downloadPdf(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.download),
              label: const Text('Скачать PDF в Downloads'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadPdf(BuildContext context) async {
    try {
      final bytes = fileService.getFileBytes(attachment.fileData);
      if (bytes == null) {
        throw Exception('Не удалось получить данные файла');
      }

      // Получаем папку Downloads
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        throw Exception('Не удалось получить доступ к папке Downloads');
      }

      // Создаем файл в папке Downloads
      final file = File('${directory.path}/${attachment.name}');
      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF сохранен в: ${file.path}'),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(label: 'OK', onPressed: () {}),
        ),
      );

      print('Файл сохранен: ${file.path}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка скачивания: $e'),
          backgroundColor: Colors.red,
        ),
      );
      print('Ошибка: $e');
    }
  }

  // Остальные методы без изменений
  Widget _buildImagePreview() {
    final bytes = fileService.getFileBytes(attachment.fileData);

    if (bytes == null) {
      return const Center(child: Text('Ошибка загрузки изображения'));
    }

    return InteractiveViewer(
      child: Center(child: Image.memory(bytes, fit: BoxFit.contain)),
    );
  }

  Widget _buildTextPreview() {
    final bytes = fileService.getFileBytes(attachment.fileData);
    if (bytes == null) {
      return const Center(child: Text('Ошибка загрузки файла'));
    }

    String textContent;
    try {
      textContent = _decodeText(bytes);
    } catch (e) {
      textContent = 'Ошибка декодирования файла: $e';
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: SelectableText(
          textContent,
          style: const TextStyle(fontSize: 16, fontFamily: 'Monospace'),
        ),
      ),
    );
  }

  String _decodeText(List<int> bytes) {
    try {
      return utf8.decode(bytes);
    } catch (e) {
      try {
        return _decodeWindows1251(bytes);
      } catch (e) {
        try {
          return latin1.decode(bytes);
        } catch (e) {
          return String.fromCharCodes(bytes);
        }
      }
    }
  }

  String _decodeWindows1251(List<int> bytes) {
    const windows1251ToUnicode = [
      0x0402,
      0x0403,
      0x201A,
      0x0453,
      0x201E,
      0x2026,
      0x2020,
      0x2021,
      0x20AC,
      0x2030,
      0x0409,
      0x2039,
      0x040A,
      0x040C,
      0x040B,
      0x040F,
      0x0452,
      0x2018,
      0x2019,
      0x201C,
      0x201D,
      0x2022,
      0x2013,
      0x2014,
      0x0020,
      0x2122,
      0x0459,
      0x203A,
      0x045A,
      0x045C,
      0x045B,
      0x045F,
      0x00A0,
      0x040E,
      0x045E,
      0x0408,
      0x00A4,
      0x0490,
      0x00A6,
      0x00A7,
      0x0401,
      0x00A9,
      0x0404,
      0x00AB,
      0x00AC,
      0x00AD,
      0x00AE,
      0x0407,
      0x00B0,
      0x00B1,
      0x0406,
      0x0456,
      0x0491,
      0x00B5,
      0x00B6,
      0x00B7,
      0x0451,
      0x2116,
      0x0454,
      0x00BB,
      0x0458,
      0x0405,
      0x0455,
      0x0457,
      0x0410,
      0x0411,
      0x0412,
      0x0413,
      0x0414,
      0x0415,
      0x0416,
      0x0417,
      0x0418,
      0x0419,
      0x041A,
      0x041B,
      0x041C,
      0x041D,
      0x041E,
      0x041F,
      0x0420,
      0x0421,
      0x0422,
      0x0423,
      0x0424,
      0x0425,
      0x0426,
      0x0427,
      0x0428,
      0x0429,
      0x042A,
      0x042B,
      0x042C,
      0x042D,
      0x042E,
      0x042F,
      0x0430,
      0x0431,
      0x0432,
      0x0433,
      0x0434,
      0x0435,
      0x0436,
      0x0437,
      0x0438,
      0x0439,
      0x043A,
      0x043B,
      0x043C,
      0x043D,
      0x043E,
      0x043F,
      0x0440,
      0x0441,
      0x0442,
      0x0443,
      0x0444,
      0x0445,
      0x0446,
      0x0447,
      0x0448,
      0x0449,
      0x044A,
      0x044B,
      0x044C,
      0x044D,
      0x044E,
      0x044F,
    ];

    final result = StringBuffer();
    for (int byte in bytes) {
      if (byte >= 0x00 && byte <= 0x7F) {
        result.writeCharCode(byte);
      } else if (byte >= 0xC0 && byte <= 0xFF) {
        final unicodeChar = windows1251ToUnicode[byte - 0xC0];
        result.writeCharCode(unicodeChar);
      } else {
        result.writeCharCode(0xFFFD);
      }
    }
    return result.toString();
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
            if (attachment.isText)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(
                          title: Text(attachment.name),
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                        ),
                        body: _buildTextPreview(),
                      ),
                    ),
                  );
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
