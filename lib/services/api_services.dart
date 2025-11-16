// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:todo_app/models/todo.dart';

// class ApiServices {
//   static const String baseURL = 'https://server-for-todo.vercel.app/api/todos';
//   //get all todos
//   static Future<List<Todo>> getTodos() async {
//     try {
//       final response = await http.get(Uri.parse(baseURL));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final List<dynamic> todoJson = data['data'];
//         return todoJson.map((json) => Todo.fromMap(json)).toList();
//       } else {
//         throw Exception('Failed to load todos');
//       }
//     } catch (e) {
//       throw Exception(e.toString());
//     }
//   }

//   //create todo
//   static Future<Todo> createTodo(String title, String description) async {
//     try {
//       final response = await http.post(
//         Uri.parse(baseURL),
//         headers: {'content-type': 'application/json'},
//         body: json.encode({'title': title, 'description': description}),
//       );
//       if (response.statusCode == 201) {
//         final data = json.decode(response.body);
//         return Todo.fromMap(data['data']);
//       } else {
//         throw Exception('Failed to create Todo');
//       }
//     } catch (e) {
//       throw Exception(e.toString());
//     }
//   }

//   //update todo
//   static Future<Todo> updateTodo(
//     String id, {
//     String? title,
//     String? description,
//     bool? completed,
//   }) async {
//     try {
//       final body = <String, dynamic>{};
//       if (title != null) body['title'] = title;
//       if (description != null) body['description'] = description;
//       if (completed != null) body['completed'] = completed;
//       final response = await http.put(
//         Uri.parse('$baseURL/$id'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(body),
//       );
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final updatedTodo = data['data'];
//         return Todo.fromMap(updatedTodo);
//       } else {
//         throw Exception('Failed to update Todo');
//       }
//     } catch (e) {
//       throw Exception(e.toString());
//     }
//   }

//   //delete todo
//   static Future<Todo> deleteTodo(String id) async {
//     try {
//       final response = await http.delete(Uri.parse('$baseURL/$id'));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         return Todo.fromMap(data['data']);
//       } else {
//         throw Exception('Failed to delete');
//       }
//     } catch (e) {
//       throw Exception(e.toString());
//     }
//   }

//   //toggle todo
//   static Future<Todo> toggleTodo(String id, bool currentStatus) async {
//     return updateTodo(id, completed: !currentStatus);
//   }
// }
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:todo_app/models/todo.dart';

class ApiServices {
  static const baseURL = 'https://server-for-todo-production.up.railway.app/api/todos';
  //get all todos
  static Future<List<Todo>> getTodos() async {
    try {
      final response = await http.get(Uri.parse(baseURL));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> todoJson = data['data'];
        return todoJson.map((json) => Todo.fromMap(json)).toList();
      } else {
        throw Exception('Failed to get todos');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  //create todo
  static Future<Todo> createTodo(String title, String description) async {
    try {
      final response = await http.post(
        Uri.parse(baseURL),
        headers: {'content-type': 'application/json'},
        body: json.encode({'title': title, 'description': description}),
      );
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final jsonData = data['data'];
        return Todo.fromMap(jsonData);
      } else {
        throw Exception("Failed to create Todo");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  //update todo
  static Future<Todo> updateTodo(
    String id, {
    String? title,
    String? description,
    bool? completed,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (completed != null) body['completed'] = completed;
      final response = await http.put(
        Uri.parse('$baseURL/$id'),
        headers: {'content-type': 'application/json'},
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final jsonData = data['data'];
        return Todo.fromMap(jsonData);
      } else {
        throw Exception('Failed to update todo');
      }
    } catch (e) {
      throw Exception('Failed to update todo ${e.toString()}');
    }
  }

  //delete todo
  static Future<Todo> deleteTodo(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseURL/$id'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final jsonData = data['data'];
        return Todo.fromMap(jsonData);
      } else {
        throw Exception('Failed to delete');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  //toggle todo
  static Future<Todo> toggleTodo(String id, bool currentStatus) async {
    return updateTodo(id, completed: !currentStatus);
  }
}
