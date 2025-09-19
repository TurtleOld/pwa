import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import '../models/stage.dart';
import 'auth_service.dart';
import 'settings_service.dart';

class TaskService {
  final AuthService _authService = AuthService();
  final SettingsService _settingsService = SettingsService();

  Future<String> _getApiBaseUrl() async {
    return await _settingsService.getApiBaseUrl();
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getTokenInfo();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token['token'] != null) 'Authorization': 'Token ${token['token']}',
    };
  }

  /// Получить все задачи
  Future<List<Task>> getTasks() async {
    try {
      final apiBaseUrl = await _getApiBaseUrl();
      final url = Uri.parse('${apiBaseUrl}tasks');
      final headers = await _getHeaders();

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception(
          'Ошибка загрузки задач: ${response.statusCode} - ${response.body}',
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
      final url = Uri.parse('${apiBaseUrl}stages');
      final headers = await _getHeaders();

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Stage.fromJson(json)).toList();
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
      final url = Uri.parse('${apiBaseUrl}tasks');
      final headers = await _getHeaders();

      final body = {
        'name': name,
        if (description != null) 'description': description,
        if (stage != null) 'stage': stage,
        if (executor != null) 'executor': executor,
        if (labels != null) 'labels': labels,
        if (deadline != null) 'deadline': deadline.toIso8601String(),
      };

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Task.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          'Ошибка создания задачи: ${_parseErrorMessage(errorData)}',
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
      final url = Uri.parse('${apiBaseUrl}tasks/$taskId');
      final headers = await _getHeaders();

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (description != null) body['description'] = description;
      if (stage != null) body['stage'] = stage;
      if (executor != null) body['executor'] = executor;
      if (labels != null) body['labels'] = labels;
      if (deadline != null) body['deadline'] = deadline.toIso8601String();
      if (state != null) body['state'] = state;

      final response = await http.patch(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Task.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          'Ошибка обновления задачи: ${_parseErrorMessage(errorData)}',
        );
      }
    } catch (e) {
      throw Exception('Ошибка обновления задачи: $e');
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      final apiBaseUrl = await _getApiBaseUrl();
      final url = Uri.parse('${apiBaseUrl}tasks/$taskId');
      final headers = await _getHeaders();

      final response = await http.delete(url, headers: headers);

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
      final url = Uri.parse('${apiBaseUrl}tasks/$taskId');
      final headers = await _getHeaders();

      final body = {'stage': newStageId};

      final response = await http.patch(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Task.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          'Ошибка перемещения задачи: ${_parseErrorMessage(errorData)}',
        );
      }
    } catch (e) {
      throw Exception('Ошибка перемещения задачи: $e');
    }
  }

  Future<void> updateTaskOrder(int taskId, int newOrder) async {
    try {
      final apiBaseUrl = await _getApiBaseUrl();
      final url = Uri.parse('${apiBaseUrl}tasks/$taskId');
      final headers = await _getHeaders();

      final body = {'order': newOrder};

      final response = await http.patch(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка обновления порядка: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка обновления порядка: $e');
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
}
