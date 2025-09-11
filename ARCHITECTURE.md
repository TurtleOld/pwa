# Архитектура Task Manager PWA

## Общая структура

```
Task Manager PWA
├── Authentication Layer
│   ├── AuthService (заглушка)
│   ├── User Model
│   └── SecureStorage
├── UI Layer
│   ├── LoginScreen
│   ├── HomeScreen
│   └── AuthWrapper
├── Theme Layer
│   ├── AppColors (Django совместимые)
│   └── AppTheme (Light/Dark)
└── Navigation
    └── Route Management
```

## Поток данных

```
1. Запуск приложения
   ↓
2. AuthWrapper проверяет авторизацию
   ↓
3a. Если НЕ авторизован → LoginScreen
   ↓
3b. Если авторизован → HomeScreen
   ↓
4. LoginScreen → AuthService.login() → SecureStorage
   ↓
5. Успешная авторизация → HomeScreen
   ↓
6. HomeScreen → AuthService.logout() → LoginScreen
```

## Компоненты

### AuthService
- **Назначение**: Управление авторизацией
- **Функции**:
  - `login()` - Авторизация (заглушка)
  - `logout()` - Выход из системы
  - `isAuthenticated()` - Проверка статуса
  - `getCurrentUser()` - Получение данных пользователя
  - Валидация полей

### User Model
- **Поля**: id, username, email, firstName, lastName, token
- **Методы**: fromJson, toJson, copyWith

### LoginScreen
- **Функции**:
  - Валидация полей ввода
  - Обработка ошибок
  - Индикатор загрузки
  - Переключение видимости пароля

### HomeScreen
- **Функции**:
  - Отображение информации о пользователе
  - Статистика задач (заглушка)
  - Быстрые действия (заглушка)
  - Кнопка выхода

### Theme System
- **AppColors**: Цветовая палитра из Django проекта
- **AppTheme**: Светлая и темная темы
- **Адаптивность**: Автоматическое переключение темы

## Безопасность

- **SecureStorage**: Безопасное хранение токенов
- **Валидация**: Клиентская валидация полей
- **Очистка данных**: При выходе из системы

## Будущие улучшения

- [ ] Интеграция с Django REST API
- [ ] JWT токены
- [ ] Refresh токены
- [ ] Офлайн режим
- [ ] Push уведомления
