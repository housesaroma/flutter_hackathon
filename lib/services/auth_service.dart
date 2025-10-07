import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AppUser? _currentUser;
  bool _isLoading = false;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user != null) {
        _currentUser = await _getUserData(user);
        print('✅ User initialized: ${_currentUser?.email}');
      } else {
        print('👤 No user signed in');
      }
    } catch (e) {
      print('❌ Initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AppUser?> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('🔐 Attempting sign in: $email');

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      print('✅ Sign in successful: ${userCredential.user?.email}');
      _currentUser = await _getUserData(userCredential.user!);

      return _currentUser;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase auth error: ${e.code} - ${e.message}');
      throw Exception(_handleAuthError(e));
    } catch (e) {
      print('❌ General auth error: $e');
      throw Exception('Ошибка входа: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AppUser?> signUp({
    required String email,
    required String password,
    required String name,
    required bool isDeputy,
    bool isAdmin = false,
    String? deputyId,
    String? phone,
    String? department,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('📝 Attempting registration: $email');

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = AppUser(
        uid: userCredential.user!.uid,
        email: email.trim(),
        name: name.trim(),
        phone: phone,
        department: department,
        isDeputy: isDeputy,
        isAdmin: isAdmin,
        deputyId: deputyId,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(user.toMap());
      print('✅ User saved to Firestore: $email');

      _currentUser = user;
      return user;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase registration error: ${e.code} - ${e.message}');
      throw Exception(_handleAuthError(e));
    } catch (e) {
      print('❌ General registration error: $e');
      throw Exception('Ошибка регистрации: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AppUser> _getUserData(User firebaseUser) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (doc.exists) {
        print('✅ User data loaded from Firestore');
        return AppUser.fromMap(doc.data()!);
      } else {
        final newUser = AppUser(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'Пользователь',
          isDeputy: false,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(newUser.uid)
            .set(newUser.toMap());
        print('✅ New user created in Firestore');

        return newUser;
      }
    } catch (e) {
      print('❌ Error getting user data: $e');
      return AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: 'Пользователь',
        isDeputy: false,
        createdAt: DateTime.now(),
      );
    }
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Пользователь с таким email уже существует';
      case 'invalid-email':
        return 'Неверный формат email';
      case 'weak-password':
        return 'Пароль слишком слабый. Используйте минимум 6 символов';
      case 'user-not-found':
        return 'Пользователь не найден';
      case 'wrong-password':
        return 'Неверный пароль';
      case 'network-request-failed':
        return 'Ошибка сети. Проверьте подключение к интернету';
      default:
        return 'Произошла ошибка: ${e.message}';
    }
  }

  Future<void> signOut() async {
    print('🚪 Signing out user');
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
