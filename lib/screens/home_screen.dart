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
        backgroundColor: Colors.pink.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          todo == null ? 'Add a Todo for Hajar 💖' : 'Edit Todo for Hajar 💖',
          style: const TextStyle(
            color: Colors.pinkAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: const TextStyle(color: Colors.pinkAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.pinkAccent),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: const TextStyle(color: Colors.pinkAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.pinkAccent),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              if (titleController.text.trim().isEmpty) {
                _showError('Title is required');
                return;
              }

              Navigator.pop(context);

              if (todo == null) {
                await createTodo(
                  titleController.text.trim(),
                  descController.text.trim(),
                );
              } else {
                await updateTodo(
                  todo.id,
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                );
              }
            },
            child: Text(todo == null ? 'Add 💖' : 'Update 💖'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade300,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.pink.shade200,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> createTodo(String title, String description) async {
    try {
      await ApiServices.createTodo(title, description);
      _loadTodos();
      _showSuccess('Todo created for Hajar! 🎀');
    } catch (e) {
      _showError('Failed to create todo: $e');
    }
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
      _showSuccess('Updated Successfully for Hajar! ✨');
    } catch (e) {
      _showError('Failed to update todo');
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await ApiServices.deleteTodo(id);
      _loadTodos();
    } catch (e) {
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
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: const Text(
          'Hajar\'s Todo App 💖',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTodos,
            color: Colors.white,
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.pinkAccent),
              )
            : todos.isEmpty
            ? _buildEmptyState()
            : _buildTodoList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTodoDialog(),
        backgroundColor: Colors.pinkAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 110, color: Colors.pink.shade200),
          const SizedBox(height: 20),
          Text(
            'Hi Hajar, no todos yet!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.pink.shade300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding a cute new task 💖',
            style: TextStyle(color: Colors.pink.shade200),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showTodoDialog(),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add Todo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
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
            color: Colors.pink.shade50,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Transform.scale(
                scale: 1.3,
                child: Checkbox(
                  value: todo.completed,
                  onChanged: (_) => _toggleTodo(todo),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  activeColor: Colors.pinkAccent,
                  checkColor: Colors.white,
                ),
              ),
              title: Text(
                todo.title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.pink.shade900,
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
                          color: Colors.pink.shade400,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.pinkAccent),
                    onPressed: () => _showTodoDialog(todo: todo),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
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
