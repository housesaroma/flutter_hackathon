import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/event_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../services/file_service.dart';

class CreateEventScreen extends StatefulWidget {
  final DateTime selectedDate;

  const CreateEventScreen({super.key, required this.selectedDate});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final EventService _eventService = EventService();
  final FileService _fileService = FileService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _notesController;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  EventType _selectedType = EventType.meeting;
  String? _selectedDeputyId;
  bool _isLoading = false;

  // Файлы
  List<EventAttachment> _attachments = [];
  bool _isAddingFiles = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
    _notesController = TextEditingController();

    _selectedDate = widget.selectedDate;
    _selectedTime = TimeOfDay.fromDateTime(widget.selectedDate);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Добавление файлов
  Future<void> _addFiles() async {
    setState(() => _isAddingFiles = true);

    try {
      final files = await _fileService.pickFiles();
      if (files != null) {
        for (final file in files) {
          final attachment = await _fileService.createAttachment(file);
          setState(() {
            _attachments.add(attachment);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка добавления файлов: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isAddingFiles = false);
    }
  }

  // Удаление файла
  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;

      String deputyId;

      if (currentUser!.isDeputy) {
        deputyId = currentUser.uid;
      } else if (currentUser.isAdmin) {
        if (_selectedDeputyId == null) {
          throw Exception('Выберите депутата');
        }
        deputyId = _selectedDeputyId!;
      } else {
        if (currentUser.deputyId == null) {
          throw Exception('Помощник не привязан к депутату');
        }
        deputyId = currentUser.deputyId!;
      }

      final eventDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      await _eventService.createEvent(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dateTime: eventDateTime,
        location: _locationController.text.trim(),
        deputyId: deputyId,
        type: _selectedType,
        notes: _notesController.text.trim(),
        attachments: _attachments,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Мероприятие успешно создано'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка создания мероприятия: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать мероприятие'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (currentUser?.isAdmin == true) ...[
                _buildDeputySelector(),
                const SizedBox(height: 16),
              ],

              _buildFormField(
                label: 'Название мероприятия',
                controller: _titleController,
                icon: Icons.event,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название мероприятия';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildFormField(
                label: 'Описание',
                controller: _descriptionController,
                icon: Icons.description,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите описание мероприятия';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildTypeSelector(),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(child: _buildDateField()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTimeField()),
                ],
              ),
              const SizedBox(height: 16),

              _buildFormField(
                label: 'Местоположение',
                controller: _locationController,
                icon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите местоположение';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Секция прикрепления файлов
              _buildAttachmentsSection(),
              const SizedBox(height: 16),

              _buildFormField(
                label: 'Дополнительные заметки (необязательно)',
                controller: _notesController,
                icon: Icons.note,
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              _buildCreateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Прикрепленные файлы',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 8),

        // Кнопка добавления файлов
        OutlinedButton.icon(
          onPressed: _isAddingFiles ? null : _addFiles,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF2E7D32),
            side: const BorderSide(color: Color(0xFF2E7D32)),
            minimumSize: const Size(double.infinity, 50),
          ),
          icon: _isAddingFiles
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.attach_file),
          label: _isAddingFiles
              ? const Text('Добавление файлов...')
              : const Text('Добавить файлы (JPG, PNG, PDF, TXT)'),
        ),

        // Список прикрепленных файлов
        if (_attachments.isNotEmpty) ...[
          const SizedBox(height: 12),
          ..._attachments.asMap().entries.map((entry) {
            final index = entry.key;
            final attachment = entry.value;
            return _buildAttachmentItem(attachment, index);
          }).toList(),
        ],
      ],
    );
  }

  Widget _buildAttachmentItem(EventAttachment attachment, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(
          attachment.fileIcon,
          style: const TextStyle(fontSize: 20),
        ),
        title: Text(
          attachment.name,
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _fileService.getFileSizeString(attachment.size),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
          onPressed: () => _removeAttachment(index),
        ),
        dense: true,
      ),
    );
  }

  // Остальные методы (_buildDeputySelector, _buildTypeSelector, и т.д.)
  // остаются без изменений из вашего кода
  Widget _buildDeputySelector() {
    return StreamBuilder<List<AppUser>>(
      stream: _eventService.getDeputies(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('Депутаты не найдены');
        }

        final deputies = snapshot.data!;

        return DropdownButtonFormField<String>(
          value: _selectedDeputyId,
          decoration: InputDecoration(
            labelText: 'Депутат',
            prefixIcon: const Icon(Icons.person, color: Color(0xFF2E7D32)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: deputies.map((deputy) {
            return DropdownMenuItem<String>(
              value: deputy.uid,
              child: Text(deputy.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedDeputyId = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Выберите депутата';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildTypeSelector() {
    return DropdownButtonFormField<EventType>(
      value: _selectedType,
      decoration: InputDecoration(
        labelText: 'Тип мероприятия',
        prefixIcon: const Icon(Icons.category, color: Color(0xFF2E7D32)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: EventType.values.map((type) {
        return DropdownMenuItem<EventType>(
          value: type,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: type.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(type.displayName),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedType = value;
          });
        }
      },
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Дата',
          prefixIcon: const Icon(
            Icons.calendar_today,
            color: Color(0xFF2E7D32),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    return InkWell(
      onTap: () => _selectTime(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Время',
          prefixIcon: const Icon(Icons.access_time, color: Color(0xFF2E7D32)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          _selectedTime.format(context),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _createEvent,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text('Создать мероприятие'),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
