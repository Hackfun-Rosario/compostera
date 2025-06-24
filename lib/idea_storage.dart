import 'package:hive/hive.dart';

class IdeaStorage {
  static final _box = Hive.box('ideas');

  static Future<void> insertIdea(String titulo, String descripcion, String fecha) async {
    await _box.add({
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha': fecha,
    });
  }

  static List<Map<String, dynamic>> getIdeas() {
    return _box.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList()
        .asMap()
        .entries
        .map((entry) {
      final idea = entry.value;
      idea['id'] = entry.key;
      return idea;
    })
        .toList()
        .reversed
        .toList();
  }

  static Future<void> clearIdeas() async {
    await _box.clear();
  }

  static Future<void> deleteIdeaByID(int id) async {
    await _box.deleteAt(id);
  }
}