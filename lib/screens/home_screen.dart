import 'package:flutter/material.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/services/api_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Todo> todos = [];
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    setState(() => isLoading = true);
    try {
      final fetchedTodos = await ApiServices.getTodos();
      setState(() {
        todos = fetchedTodos;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        _showError('Failed to load todos: $e');
      });
    }
  }

  void _showTodoDialog({Todo? todo}) {
    final titleController = TextEditingController(text: todo?.title ?? '');
    final descController = TextEditingController(text: todo?.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(todo == null ? 'Add Todo' : 'Edit Todo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) {
                _showError('Title is required');
                return;
              }

              Navigator.pop(context);

              if (todo == null) {
                // Create new todo
                await createTodo(
                  titleController.text.trim(),
                  descController.text.trim(),
                );
              } else {
                // Update existing todo
                await updateTodo(
                  todo.id,
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                );
              }
            },
            child: Text(todo == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> createTodo(String title, String description) async {
    try {
      await ApiServices.createTodo(title, description);
      _loadTodos();
      _showSuccess('Todo created!');
    } catch (e) {
      _showError('Failed to create todo: $e');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.greenAccent),
    );
  }

  Future<void> updateTodo(
    String id, {
    String? title,
    String? description,
    bool? completed,
  }) async {
    try {
      await ApiServices.updateTodo(
        id,
        title: title,
        description: description,
        completed: completed,
      );
      _loadTodos();
      _showSuccess('Updated Successfully!');
    } catch (e) {
      _showError('Failed to update todo');
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await ApiServices.deleteTodo(id);
      _loadTodos();
    } on Exception catch (e) {
      _showError('Failed to delete todo $e');
    }
  }

  Future<void> _toggleTodo(Todo todo) async {
    try {
      await ApiServices.toggleTodo(todo.id, todo.completed);
      _loadTodos();
    } catch (e) {
      _showError('Failed to toggle todo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Todo App',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTodos),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : todos.isEmpty
            ? _buildEmptyState()
            : _buildTodoList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTodoDialog(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 110, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text(
            'No todos yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding a new task',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showTodoDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Todo'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Checkbox(
                value: todo.completed,
                onChanged: (_) => _toggleTodo(todo),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              title: Text(
                todo.title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  decoration: todo.completed
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              subtitle: todo.description.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        todo.description,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showTodoDialog(todo: todo),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteTodo(todo.id),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
