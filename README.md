# Система управления мероприятиями

Мобильное приложение для управления мероприятиями депутатов думы города Екатеринбурга и их помощников, построенное на Flutter и Firebase.

## 📋 Описание проекта

Приложение предназначено для организации и планирования мероприятий в организациях с иерархической структурой управления. Система поддерживает три типа пользователей: администраторы, депутаты и сотрудники (помощники депутатов), каждый из которых имеет свои права доступа.

### Основные возможности

- 📅 **Календарь мероприятий** с различными типами событий
- 👥 **Система ролей** (администратор, депутат, сотрудник)
- 🔐 **Безопасная аутентификация** через Firebase Auth
- 📱 **Кроссплатформенность** (iOS, Android, Web)
- 🔄 **Реальное время** синхронизация данных
- 📝 **Управление профилем** пользователя

## 🛠 Стек технологий

- **Frontend:** Flutter 3.x
- **Backend:** Firebase (Auth, Firestore)
- **Архитектура:** Provider pattern
- **Платформы:** iOS, Android, Web, Windows

### Основные зависимости

```yaml
dependencies:
  flutter: sdk
  firebase_auth: ^4.x.x
  cloud_firestore: ^4.x.x
  provider: ^6.x.x
  table_calendar: ^3.x.x
  intl: ^0.x.x
```

## ⚙️ Требования к системе

### Для разработки:
- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Android Studio / VS Code
- Git

### Для пользователей:
- **Android:** Android 10+
- **iOS:** iOS 15.0+
- **Web:** Современные браузеры

## 🚀 Установка и настройка

### 1. Клонирование репозитория
```bash
git clone https://github.com/housesaroma/flutter_hackathon
```

### 2. Установка зависимостей
```bash
flutter pub get
```

### 3. Настройка Firebase

1. Создайте проект в Firebase Console
2. Активируйте Authentication и Firestore Database
3. Добавьте конфигурационные файлы:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
   - `web/firebase-config.js`

### 4. Структура базы данных Firestore
Проект использует две основные коллекции данных: `events` (мероприятия) и `users` (пользователи).

Коллекция `events`

Содержит информацию о мероприятиях.

Поля документа:

| Поле | Тип | Описание |
|------|-----|-----------|
| `createdAt` | number | Временная метка создания записи |
| `createdBy` | string | ID пользователя, создавшего запись |
| `deputyId` | string | ID связанного депутата |
| `description` | string | Описание мероприятия |
| `endTime` | number | Время окончания (timestamp) |
| `location` | string | Место проведения |
| `notes` | string | Дополнительные заметки |
| `startTime` | number | Время начала (timestamp) |
| `title` | string | Название мероприятия |
| `type` | string | Тип мероприятия |
| `updatedAt` | number | Временная метка обновления |

Коллекция `users`

Содержит информацию о пользователях системы.

Поля документа:

| Поле | Тип | Описание |
|------|-----|-----------|
| `id` | string | Уникальный идентификатор пользователя |
| `name` | string | Полное имя пользователя |
| `email` | string | Адрес электронной почты |
| `phone` | string | Номер телефона (может быть пустым) |
| `role` | string | Роль в системе (например, `deputy`) |
| `department` | string | Отдел или департамент |
| `isActive` | boolean | Статус активности аккаунта |
| `lastLogin` | number | Временная метка последнего входа |
| `createdAt` | number | Временная метка создания записи |
| `updatedAt` | number | Временная метка последнего обновления |


### 5. Сборка и запуск

```bash
# Разработка
flutter run

# Сборка для продакшена
flutter build apk --release        # Android
flutter build ios --release        # iOS
flutter build web --release        # Web
```

Развертывание полностью автоматизировано, с использованием лучших практик CI/CD.

## 📱 Функциональность приложения

### Система ролей

#### 🔵 Администратор
- Просмотр всех мероприятий
- Создание/редактирование/удаление мероприятий для любого депутата
- Полный доступ к системе

#### 🟢 Депутат
- Просмотр своих мероприятий
- Создание/редактирование своих мероприятий

#### 🟡 Помощник депутата
- Просмотр мероприятий назначенного депутата
- Только чтение

### Экраны приложения

#### 🔐 Аутентификация
- Вход: Email/пароль с валидацией
- Регистрация: с выбором роли и привязкой к депутату
- Восстановление пароля (запрос у администратора на смену пароля)

#### 📅 Календарь
- Месячный вид, выбор даты
- Цветовая индикация типов
- Детали события

#### ➕ Создание мероприятий
- Форма с валидацией
- Выбор даты/времени, типа, места
- Привязка к депутату

#### 📋 Список мероприятий
- Хронологический список
- Фильтрация по ролям

#### 👤 Профиль
- Редактирование имени, телефона, отдела
- Привязка к депутату (для сотрудников)

### Типы мероприятий

| Тип | Описание |
|-----|----------|
| 🔵 Совещание | Рабочие встречи |
| 🟢 Заседание | Официальные заседания |
| 🟠 Прием | Прием граждан |
| ⚫ Другое | Прочие мероприятия |

## 📁 Структура проекта

```
lib/
├── models/
│   ├── user_model.dart
│   └── event_model.dart
├── services/
│   ├── auth_service.dart
│   └── event_service.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── calendar_screen.dart
│   ├── create_event_screen.dart
│   ├── events_screen.dart
│   ├── profile_screen.dart
│   ├── main_screen.dart
│   └── splash_screen.dart
└── main.dart


test/
└── widget_tests /
    └── login_screen_test.dart
```

## 🔧 Архитектура

Приложение использует **Provider pattern** для управления состоянием и разделения ответственности:
- **AuthService** — аутентификация и профиль пользователя
- **EventService** — CRUD по мероприятиям с проверкой прав
- **Models** — типизированные сущности
- **Screens** — UI слой

Диаграмма:
```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   Screens   │────│   Services   │────│  Firebase   │
│     (UI)    │    │ (Business)   │    │ (Backend)   │
└─────────────┘    └──────────────┘    └─────────────┘
       │                   │                   │
       │            ┌─────────────┐            │
       └────────────│   Models    │────────────┘
                    │   (Data)    │
                    └─────────────┘
```

## ⚡ Эффективность

Применены подходы для снижения задержек и экономии ресурсов:
- **Потоковые обновления** через `authStateChanges()` и `snapshots()` для реактивной подгрузки без опроса БД (минимум сетевых вызовов)
- **Серверная фильтрация и сортировка** (`where`, `orderBy`) — выборка только релевантных событий по ролям и дате
- **Узкие запросы по дате** (границы дня и индексация `startTime`) для уменьшения объема данных
- **Минимизация пересылки** — использование `millisecondsSinceEpoch` и компактных моделей
- **Локальная валидация форм** и ранние возвраты для предотвращения лишних запросов



## 🔒 Безопасность

В приложении реализованы четкие ограничения на уровне бизнес-логики и предполагаемых правил Firestore:
- **Администратор:** полный доступ
- **Депутат:** доступ только к событиям
- **Сотрудник:** доступ только к событиям депутата, к которому привязан сотрудник
- **Создание/редактирование:** запреты на изменение после создания, удаление только автором события (если не администратор)


У каждой роли есть правила, которые ограничивают её:
```
service cloud.firestore {
  match /databases/{database}/documents {
    // Разрешить создание пользователей при регистрации
    match /users/{userId} {
      allow create: if request.auth != null && request.auth.uid == userId;
      allow read, update: if request.auth != null && 
        (request.auth.uid == userId || isAdmin());
      allow delete: if isAdmin();
    }
    // Чтение мероприятий
    match /events/{eventId} {
      allow read, write: if request.auth != null && 
        (isAdmin()  isDeputy()  isAssistantForEvent(eventId));
      // Помощники могут создавать только для своего депутата
      allow create: if request.auth != null && 
        (isAdmin()  isDeputy()  canCreateForDeputy());
    }
    // Чтение списка пользователей (для выбора депутатов)
    match /users/{userId} {
      allow read: if request.auth != null && 
        (request.auth.uid == userId  isAdmin()  canReadDeputies());
    }
    // Вспомогательные функции
    function isAdmin() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    function isDeputy() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isDeputy == true;
    }
    function isAssistant() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isDeputy == false;
    }
    function getAssistantDeputyId() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.deputyId;
    }
    function isAssistantForEvent(eventId) {
      let event = get(/databases/$(database)/documents/events/$(eventId));
      return isAssistant() && event.data.deputyId == getAssistantDeputyId();
    }
    function canCreateForDeputy() {
      return isAssistant() && request.resource.data.deputyId == getAssistantDeputyId();
    }
    // Разрешить чтение депутатов для помощников
    function canReadDeputies() {
      let userDoc = get(/databases/$(database)/documents/users/$(request.auth.uid));
      let targetDoc = get(/databases/$(database)/documents/users/$(userId));
      // Помощники могут читать только депутатов
      return userDoc.data.isDeputy == false && targetDoc.data.isDeputy == true;
    }
  }
}
```

## 🛡 Практики безопасности клиента
- Валидация всех форм и ограничение ролей в UI
- Скрытие административных функций для не-админов
- Обработка ошибок FirebaseAuthException с безопасными сообщениями
- Использование HTTPS, запрет хранения секретов в клиенте

## 🧪 Тестирование

Для тестирования были написаны widget тесты и интеграционный тест.

Widget тесты располагаются в папке `test\widget_tests`
Интеграционный тест находится в папке `test\integration_tests`


## 🧭 Админка (Firebase Console)

- **Authentication:** управление пользователями, сброс паролей, проверка статусов
- **Firestore:** просмотр/редактирование коллекций `users` и `events`, настройка индексов и правил
- **Storage/Hosting (опционально):** хранение медиа и деплой web-версии
- Рекомендуется ограничить доступ к консоли через IAM и создавать отдельные роли для оператора контента

## 📈 Производительность
- Реактивные стримы вместо ручного опроса
- Серверные фильтры и сортировки
- Индексы в БД

## 🎨 UI/UX
- Material Design 3, адаптивная верстка, доступность для Android
- Cupertino Design, адаптивная верстка, доступность для iOS

## 📝 Демо-данные
Депутат:
- Email: 
- Пароль: 

Сотрудник:
- Email: 
- Пароль: 


## 👨‍💻 Авторы
- Главный разработчик — @housesaroma

**Версия:** 1.0.0  
**Последнее обновление:** Октябрь 2025
