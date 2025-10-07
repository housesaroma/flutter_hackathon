import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EventService _eventService = EventService();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _departmentController;

  bool _isEditing = false;
  bool _isLoading = false;
  bool _dataLoaded = false;
  String? _phone;
  String? _department;
  String? _selectedDeputyId;
  List<AppUser> _deputies = [];
  bool _deputiesLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _departmentController = TextEditingController();

    _loadUserData();
    _loadDeputies();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data();
          setState(() {
            _phone = data?['phone'] ?? '';
            _department = data?['department'] ?? '';
            _selectedDeputyId = data?['deputyId'];
          });
        }
      }

      final authService = Provider.of<AuthService>(context, listen: false);
      final appUser = authService.currentUser;

      _nameController.text = appUser?.name ?? '';
      _emailController.text = appUser?.email ?? '';
      _phoneController.text = _phone ?? '';
      _departmentController.text = _department ?? '';

      setState(() {
        _dataLoaded = true;
      });
    } catch (e) {
      print('Ошибка загрузки данных: $e');
      setState(() {
        _dataLoaded = true;
      });
    }
  }

  Future<void> _loadDeputies() async {
    if (_deputies.isNotEmpty) return;

    setState(() => _deputiesLoading = true);

    try {
      final deputiesStream = _eventService.getDeputies();
      final deputies = await deputiesStream.first;

      setState(() {
        _deputies = deputies;
        _deputiesLoading = false;
      });
    } catch (e) {
      print('Ошибка загрузки депутатов: $e');
      setState(() => _deputiesLoading = false);
    }
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _loadUserData(); // Сброс значений при отмене
      }
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Пользователь не авторизован');

      final updateData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'department': _departmentController.text.trim().isEmpty
            ? null
            : _departmentController.text.trim(),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      // Если выбран депутат и пользователь не депутат, добавляем deputyId
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;

      if (!currentUser!.isDeputy && _selectedDeputyId != null) {
        updateData['deputyId'] = _selectedDeputyId;
      } else if (!currentUser.isDeputy &&
          _selectedDeputyId == null &&
          currentUser.deputyId != null) {
        // Если убрали привязку к депутату
        updateData['deputyId'] = null;
      }

      await _firestore.collection('users').doc(user.uid).update(updateData);

      // Обновляем локальные данные
      await authService.initialize();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Профиль успешно обновлен'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() => _isEditing = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка сохранения: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
  }

  String? _getCurrentDeputyName() {
    if (_selectedDeputyId == null) return null;
    final deputy = _deputies.firstWhere(
      (d) => d.uid == _selectedDeputyId,
      orElse: () => AppUser(
        uid: '',
        name: '',
        email: '',
        isDeputy: true,
        createdAt: DateTime.now(),
      ),
    );
    return deputy.name.isEmpty ? null : deputy.name;
  }

  Widget _buildDeputySection(AppUser user) {
    // Показываем только для сотрудников аппарата
    if (user.isDeputy) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Прикрепленный депутат',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 8),

        if (!_isEditing) ...[
          // Режим просмотра
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _selectedDeputyId != null && _getCurrentDeputyName() != null
                ? Text(
                    _getCurrentDeputyName()!,
                    style: const TextStyle(fontSize: 16),
                  )
                : const Text(
                    'Не прикреплен',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
          ),
        ] else ...[
          // Режим редактирования
          _deputiesLoading
              ? const Center(child: CircularProgressIndicator())
              : _deputies.isEmpty
              ? const Text(
                  'Депутаты не найдены',
                  style: TextStyle(color: Colors.grey),
                )
              : DropdownButtonFormField<String>(
                  value: _selectedDeputyId,
                  decoration: InputDecoration(
                    labelText: 'Выберите депутата',
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Color(0xFF2E7D32),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF2E7D32),
                        width: 2,
                      ),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Не прикреплен'),
                    ),
                    ..._deputies.map((deputy) {
                      return DropdownMenuItem<String>(
                        value: deputy.uid,
                        child: Text(deputy.name),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedDeputyId = value;
                    });
                  },
                  validator: (value) {
                    // Валидация не обязательна, так как прикрепление к депутату не обязательно
                    return null;
                  },
                ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (!_dataLoaded || user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Профиль'),
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEditing,
              tooltip: 'Редактировать профиль',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildProfileHeader(user),
              const SizedBox(height: 24),

              // Секция прикрепленного депутата
              _buildDeputySection(user),

              _buildProfileForm(user),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AppUser user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
          child: const Icon(Icons.person, size: 50, color: Color(0xFF2E7D32)),
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Chip(
          label: Text(
            user.isDeputy ? 'Депутат' : 'Сотрудник аппарата',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF2E7D32),
        ),
        if (!user.isDeputy &&
            _selectedDeputyId != null &&
            _getCurrentDeputyName() != null) ...[
          const SizedBox(height: 8),
          Chip(
            label: Text(
              'Помощник: ${_getCurrentDeputyName()!}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            backgroundColor: Colors.blue,
          ),
        ],
      ],
    );
  }

  Widget _buildProfileForm(AppUser user) {
    return Column(
      children: [
        _buildFormField(
          label: 'ФИО',
          controller: _nameController,
          icon: Icons.person,
          enabled: _isEditing,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Введите ФИО';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildFormField(
          label: 'Email',
          controller: _emailController,
          icon: Icons.email,
          enabled: false,
        ),
        const SizedBox(height: 16),
        _buildFormField(
          label: 'Телефон',
          controller: _phoneController,
          icon: Icons.phone,
          enabled: _isEditing,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildFormField(
          label: 'Отдел/Комиссия',
          controller: _departmentController,
          icon: Icons.work,
          enabled: _isEditing,
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
        ),
        enabled: enabled,
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isEditing) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : _toggleEditing,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2E7D32),
                side: const BorderSide(color: Color(0xFF2E7D32)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Отмена'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
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
                  : const Text('Сохранить'),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _logout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 20),
            SizedBox(width: 8),
            Text('Выйти из системы'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    super.dispose();
  }
}
