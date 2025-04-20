import 'package:personal_tracker/dashbord/task_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Task>> getTasks() async {
    try {
      final response = await _client
          .from('tasks')
          .select()
          .order('created_at', ascending: false);
      return (response as List).map((json) => Task.fromJson(json)).toList();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addTask(String userId, String title, String description) async {
    try {
      await _client.from('tasks').insert({
        'user_id': userId,
        'title': title,
      });
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateTask(String taskId, {String? title, bool? isCompleted, String? description}) async {
    try {
      await _client.from('tasks').update({
        if (title != null) 'title': title,
        if (isCompleted != null) 'is_completed': isCompleted,
      }).eq('id', taskId);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _client.from('tasks').delete().eq('id', taskId);
    } catch (error) {
      rethrow;
    }
  }
}