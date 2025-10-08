import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_application_1/models/event_model.dart';
import 'package:mime_type/mime_type.dart';

class FileService {
  // Выбор файлов с ограничением по размеру (до 500KB)
  Future<List<PlatformFile>?> pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'txt'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        // Проверяем размер файлов
        for (final file in result.files) {
          if (file.size > 500 * 1024) {
            // 500KB лимит
            throw Exception(
              'Файл "${file.name}" слишком большой. Максимальный размер: 500KB',
            );
          }
        }
        return result.files;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Конвертация файла в base64
  Future<String> fileToBase64(PlatformFile file) async {
    try {
      if (file.path == null) throw Exception('Путь к файлу не найден');

      final fileObj = File(file.path!);
      List<int> bytes = await fileObj.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      throw Exception('Ошибка чтения файла: $e');
    }
  }

  // Создание EventAttachment из PlatformFile
  Future<EventAttachment> createAttachment(PlatformFile file) async {
    try {
      final base64Data = await fileToBase64(file);
      final mimeType = mime(file.name) ?? 'application/octet-stream';
      final fileExtension = file.name.split('.').last.toLowerCase();

      return EventAttachment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: file.name,
        size: file.size,
        mimeType: mimeType,
        uploadedAt: DateTime.now(),
        fileData: base64Data,
        fileExtension: fileExtension,
      );
    } catch (e) {
      throw Exception('Ошибка создания вложения: $e');
    }
  }

  // Получение размера файла в читаемом формате
  String getFileSizeString(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1048576) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    }
  }

  // Декодирование base64 для отображения
  Uint8List? getFileBytes(String base64Data) {
    try {
      return base64Decode(base64Data);
    } catch (e) {
      return null;
    }
  }
}
