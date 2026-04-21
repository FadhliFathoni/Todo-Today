import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_today/model/TodoModel.dart';

class HiveService {
  final _initialOpen = 'initial-open';
  final _keyTodoToday = 'todo-today';
  final _keyHistoryToday = 'history-today';

  Future<void> init() async {
    await Hive.initFlutter();
  }

  Future<void> openBoxes() async {
    try {
      if (!Hive.isBoxOpen(_initialOpen)) {
        await Hive.openBox<bool>(_initialOpen);
      }

      if (!Hive.isBoxOpen(_keyTodoToday)) {
        if (!Hive.isAdapterRegistered(0)) {
          Hive.registerAdapter(TodoModelAdapter());
        }
        await Hive.openBox<TodoModel>(_keyTodoToday);
      }
      if (!Hive.isBoxOpen(_keyHistoryToday)) {
        await Hive.openBox<TodoModel>(_keyHistoryToday);
      }
    } catch (e) {
      print('Hive openBoxes error: $e');
      // Retry once on lock contention
      if (e.toString().contains('lock failed')) {
        await Future.delayed(const Duration(milliseconds: 500));
        await openBoxes();
      }
    }
  }

  /// Pastikan box sudah terbuka sebelum baca/tulis (mis. startup gagal sekali).
  Future<void> ensureBoxesOpen() async {
    if (!Hive.isBoxOpen(_keyTodoToday) ||
        !Hive.isBoxOpen(_keyHistoryToday)) {
      await openBoxes();
    }
  }

  List<TodoModel>? getTodoToday() {
    if (!Hive.isBoxOpen(_keyTodoToday)) return null;
    final box = Hive.box<TodoModel>(_keyTodoToday);
    return box.values.toList();
  }

  Future<void> initTodoToday(List<TodoModel> todos) async {
    await ensureBoxesOpen();
    if (!Hive.isBoxOpen(_keyTodoToday)) return;
    final box = Hive.box<TodoModel>(_keyTodoToday);
    await box.clear();
    for (var todo in todos) {
      await box.put(todo.id, todo);
    }
  }

  List<TodoModel>? getHistoryToday() {
    if (!Hive.isBoxOpen(_keyHistoryToday)) return null;
    final box = Hive.box<TodoModel>(_keyHistoryToday);
    return box.values.toList();
  }

  Future<void> initHistoryToday(List<TodoModel> todos) async {
    await ensureBoxesOpen();
    if (!Hive.isBoxOpen(_keyHistoryToday)) return;
    final box = Hive.box<TodoModel>(_keyHistoryToday);
    await box.clear();
    for (var todo in todos) {
      await box.put(todo.id, todo);
    }
  }

  Future<void> clearTodo() async {
    await ensureBoxesOpen();
    if (!Hive.isBoxOpen(_keyTodoToday)) return;
    await Hive.box<TodoModel>(_keyTodoToday).clear();
  }

  Future<void> clearHistory() async {
    await ensureBoxesOpen();
    if (!Hive.isBoxOpen(_keyHistoryToday)) return;
    await Hive.box<TodoModel>(_keyHistoryToday).clear();
  }

  Future<void> clearAll() async {
    await ensureBoxesOpen();
    if (!Hive.isBoxOpen(_keyTodoToday) ||
        !Hive.isBoxOpen(_keyHistoryToday)) {
      return;
    }
    await Hive.box<TodoModel>(_keyTodoToday).clear();
    await Hive.box<TodoModel>(_keyHistoryToday).clear();
  }
}
