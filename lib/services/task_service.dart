import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/stage.dart';
import 'auth_service.dart';
import 'settings_service.dart';

class TaskService {
  final AuthService _authService = AuthService();
  final SettingsService _settingsService = SettingsService();
  late final Dio _dio;

  TaskService() {
    _dio = Dio();
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.sendTimeout = const Duration(seconds: 10);
  }

  Future<String> _getApiBaseUrl() async {
    return await _settingsService.getApiBaseUrl();
  }

  Future<Map<String, dynamic>> _getHeaders() async {
    final token = await _authService.getTokenInfo();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token['token'] != null) 'Authorization': 'Token ${token['token']}',
    };
  }

  Future<Task?> getTaskById(int taskId) async {
    try {
      final apiBaseUrl = await _getApiBaseUrl();
      final url = '${apiBaseUrl}tasks/$taskId';
      final headers = await _getHeaders();

      final response = await _dio.get(url, options: Options(headers: headers));

      if (response.statusCode == 200) {
        final task = Task.fromJson(response.data);
        return task;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Получить все задачи
  Future<List<Task>> getTasks() async {
    try {
      final apiBaseUrl = await _getApiBaseUrl();
      final url = '${apiBaseUrl}tasks';
      final headers = await _getHeaders();

      final response = await _dio.get(url, options: Options(headers: headers));

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final tasks = data.map((json) => Task.fromJson(json)).toList();
        return tasks;
      } else {
        throw Exception(
          'Ошибка загрузки задач: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e) {
      throw Exception('Ошибка получения задач: $e');
    }
  }

  /// Получить все этапы
  Future<List<Stage>> getStages() async {
    try {
      final apiBaseUrl = await _getApiBaseUrl();
      final url = '${apiBaseUrl}stages';
      final headers = await _getHeaders();

      final response = await _dio.get(url, options: Options(headers: headers));

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final stages = data.map((json) => Stage.fromJson(json)).toList();
        return stages;
      } else {
        // Если нет отдельного API для этапов, создаем дефолтные
        return _getDefaultStages();
      }
    } catch (e) {
      // В случае ошибки возвращаем дефолтные этапы
      return _getDefaultStages();
    }
  }

  /// Создать новую задачу
  Future<Task> createTask({
    required String name,
    String? description,
    int? stage,
    int? executor,
    List<int>? labels,
    DateTime? deadline,
  }) async {
    try {
      final apiBaseUrl = await _getApiBaseUrl();
      final url = '${apiBaseUrl}tasks';
      final headers = await _getHeaders();

      final body = {
        'name': name,
        if (description != null) 'description': description,
        if (stage != null) 'stage': stage,
        if (executor != null) 'executor': executor,
        if (labels != null) 'labels': labels,
        if (deadline != null) 'deadline': deadline.toIso8601String(),
      };

      final response = await _dio.post(
        url,
        data: body,
        options: Options(headers: headers),
      );

      if (response.statusCode == 201) {
        return Task.fromJson(response.data);
      } else {
        throw Exception(
          'Ошибка создания задачи: ${_parseErrorMessage(response.data)}',
        );
      }
    } catch (e) {
      throw Exception('Ошибка создания задачи: $e');
    }
  }

  Future<Task> updateTask({
    required int taskId,
    String? name,
    String? description,
    int? stage,
    int? executor,
    List<int>? labels,
    DateTime? deadline,
    bool? state,
  }) async {
    try {
      final apiBaseUrl = await _getApiBaseUrl();
      final url = '${apiBaseUrl}tasks/$taskId';
      final headers = await _getHeaders();

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (description != null) body['description'] = description;
      if (stage != null) body['stage'] = stage;
      if (executor != null) body['executor'] = executor;
      if (labels != null) body['labels'] = labels;
      if (deadline != null) body['deadline'] = deadline.toIso8601String();
      if (state != null) body['state'] = state;

      Response response;
      try {
        response = await _dio.post(
          '$url/update',
          data: body,
          options: Options(headers: headers),
        );
      } catch (e) {
        // В случае сетевой ошибки пробуем перечитать задачу
        final fallback = await getTaskById(taskId);
        if (fallback != null) return fallback;
        rethrow;
      }

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        if (response.data != null) {
          try {
            return Task.fromJson(response.data);
          } catch (e) {
            // Если не удалось распарсить ответ, но статус 200, попробуем получить задачу по ID
            final fallback = await getTaskById(taskId);
            if (fallback != null) {
              return fallback;
            }
            throw Exception('Ошибка парсинга ответа сервера: $e');
          }
        }
        final fallback = await getTaskById(taskId);
        if (fallback != null) return fallback;
        throw Exception('Пустой ответ сервера');
      } else {
        throw Exception(
          'Ошибка обновления задачи: ${_parseErrorMessage(response.data)}',
        );
      }
    } catch (e) {
      throw Exception('Ошибка обновления задачи: $e');
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      final apiBaseUrl = await _getApiBaseUrl();
      final url = '${apiBaseUrl}tasks/$taskId';
      final headers = await _getHeaders();

      final response = await _dio.post(
        '$url/delete',
        options: Options(headers: headers),
      );

      if (response.statusCode != 204) {
        throw Exception('Ошибка удаления задачи: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка удаления задачи: $e');
    }
  }

  Future<Task> moveTaskToStage(int taskId, int newStageId) async {
    try {
      final apiBaseUrl = await _getApiBaseUrl();
      final url = '${apiBaseUrl}tasks/$taskId';
      final headers = await _getHeaders();

      final body = {'stage': newStageId};

      Response response;
      try {
        // Используем POST запрос на /update endpoint
        response = await _dio.post(
          '$url/update',
          data: body,
          options: Options(headers: headers),
        );
      } catch (e) {
        // Сетевая ошибка: проверим, не обновилась ли задача на сервере
        try {
          final maybe = await getTaskById(taskId);
          if (maybe != null) {
            if (maybe.stage == newStageId) {
              return maybe;
            }
          }
        } catch (fallbackError) {
          // Ignore fallback errors
        }
        rethrow;
      }

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        if (response.data != null) {
          try {
            final task = Task.fromJson(response.data);
            return task;
          } catch (e) {
            // Если не удалось распарсить ответ, но статус 200, попробуем получить задачу по ID
            final fallback = await getTaskById(taskId);
            if (fallback != null) {
              return fallback;
            }
            throw Exception('Ошибка парсинга ответа сервера: $e');
          }
        }
        final maybe = await getTaskById(taskId);
        if (maybe != null) {
          return maybe;
        }
        throw Exception('Пустой ответ сервера');
      } else {
        try {
          throw Exception(
            'Ошибка перемещения задачи: ${_parseErrorMessage(response.data)}',
          );
        } catch (e) {
          throw Exception(
            'Ошибка сервера: ${response.statusCode} - ${response.data}',
          );
        }
      }
    } catch (e) {
      // Улучшенная обработка ошибок
      if (e.toString().contains('Ошибка парсинга ответа сервера') ||
          e.toString().contains('Пустой ответ сервера')) {
        // Это не сетевая ошибка, а проблема с ответом сервера
        try {
          final fallback = await getTaskById(taskId);
          if (fallback != null && fallback.stage == newStageId) {
            return fallback;
          }
        } catch (fallbackError) {}
      }

      final errorMessage = _getNetworkErrorMessage(e);
      throw Exception('Ошибка перемещения задачи: $errorMessage');
    }
  }

  Future<void> updateTaskOrder(int taskId, int newOrder) async {
    try {
      final apiBaseUrl = await _getApiBaseUrl();
      final url = '${apiBaseUrl}tasks/$taskId';
      final headers = await _getHeaders();

      final body = {'order': newOrder};

      final response = await _dio.post(
        '$url/update',
        data: body,
        options: Options(headers: headers),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка обновления порядка: ${response.statusCode}');
      }
    } catch (e) {
      final errorMessage = _getNetworkErrorMessage(e);
      throw Exception('Ошибка обновления порядка: $errorMessage');
    }
  }

  Future<List<Task>> getTasksByStage(int stageId) async {
    try {
      final allTasks = await getTasks();
      return allTasks.where((task) => task.stage == stageId).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    } catch (e) {
      throw Exception('Ошибка получения задач по этапу: $e');
    }
  }

  Future<Map<String, int>> getTaskStats() async {
    try {
      final tasks = await getTasks();
      final stats = <String, int>{
        'total': tasks.length,
        'active': tasks.where((t) => !t.state).length,
        'completed': tasks.where((t) => t.state).length,
        'overdue': tasks.where((t) => t.isOverdue).length,
      };

      final stages = await getStages();
      for (final stage in stages) {
        final stageTasks = tasks.where((t) => t.stage == stage.id).length;
        stats['stage_${stage.name}'] = stageTasks;
      }

      return stats;
    } catch (e) {
      throw Exception('Ошибка получения статистики: $e');
    }
  }

  List<Stage> _getDefaultStages() {
    return [
      Stage(id: 1, name: 'to_do', order: 1),
      Stage(id: 2, name: 'in_progress', order: 2),
      Stage(id: 3, name: 'review', order: 3),
      Stage(id: 4, name: 'done', order: 4),
    ];
  }

  String _parseErrorMessage(Map<String, dynamic> errorData) {
    if (errorData.containsKey('non_field_errors')) {
      final errors = errorData['non_field_errors'] as List<dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        return errors.first.toString();
      }
    }

    if (errorData.containsKey('name')) {
      final errors = errorData['name'] as List<dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        return 'Название: ${errors.first}';
      }
    }

    if (errorData.containsKey('detail')) {
      return errorData['detail'].toString();
    }

    if (errorData.containsKey('error')) {
      return errorData['error'].toString();
    }

    return 'Неизвестная ошибка';
  }

  /// Получить понятное сообщение об ошибке сети
  String _getNetworkErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('failed to fetch') ||
        errorStr.contains('network error')) {
      return 'Нет подключения к серверу. Проверьте интернет-соединение.';
    }

    if (errorStr.contains('clientexception')) {
      return 'Ошибка сети. Задача может быть перемещена.';
    }

    if (errorStr.contains('connection refused') ||
        errorStr.contains('connection timed out')) {
      return 'Сервер недоступен. Попробуйте позже.';
    }

    if (errorStr.contains('cors')) {
      return 'Ошибка CORS. Проверьте настройки сервера.';
    }

    if (errorStr.contains('0.0.0.0')) {
      return 'Неправильный адрес сервера (0.0.0.0 недоступен из браузера)';
    }

    if (errorStr.contains('ошибка парсинга ответа сервера')) {
      return 'Ошибка обработки ответа сервера. Задача может быть перемещена.';
    }

    if (errorStr.contains('пустой ответ сервера')) {
      return 'Сервер вернул пустой ответ. Задача может быть перемещена.';
    }

    return error.toString();
  }
}
