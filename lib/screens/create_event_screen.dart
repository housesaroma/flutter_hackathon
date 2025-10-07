import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/event_service.dart';
import '../services/auth_service.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';

class CreateEventScreen extends StatefulWidget {
  final DateTime selectedDate;

  const CreateEventScreen({super.key, required this.selectedDate});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final EventService _eventService = EventService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _notesController;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  EventType _selectedType = EventType.meeting;
  String? _selectedDeputyId;
  bool _isLoading = false;

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
