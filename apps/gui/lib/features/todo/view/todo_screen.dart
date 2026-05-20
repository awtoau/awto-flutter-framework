import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/todo_bloc.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TodoBloc(),
      child: const _TodoView(),
    );
  }
}

class _TodoView extends StatefulWidget {
  const _TodoView({Key? key}) : super(key: key);

  @override
  State<_TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends State<_TodoView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Demo'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Add a new todo...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        context.read<TodoBloc>().add(AddTodo(value));
                        _controller.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  heroTag: 'add_todo',
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      context.read<TodoBloc>().add(AddTodo(_controller.text));
                      _controller.clear();
                    }
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<TodoBloc, TodoState>(
              builder: (context, state) {
                if (state is TodoInitial) {
                  return const Center(
                    child: Text('No todos yet. Add one above!'),
                  );
                }

                if (state is TodoLoaded) {
                  if (state.todos.isEmpty) {
                    return const Center(
                      child: Text('No todos yet. Add one above!'),
                    );
                  }

                  return ListView.builder(
                    itemCount: state.todos.length,
                    itemBuilder: (context, index) {
                      final todo = state.todos[index];
                      return ListTile(
                        leading: Checkbox(
                          value: todo.completed,
                          onChanged: (_) {
                            context.read<TodoBloc>().add(ToggleTodo(todo.id));
                          },
                        ),
                        title: Text(
                          todo.title,
                          style: TextStyle(
                            decoration: todo.completed
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            context.read<TodoBloc>().add(RemoveTodo(todo.id));
                          },
                        ),
                      );
                    },
                  );
                }

                if (state is TodoError) {
                  return Center(
                    child: Text('Error: ${state.message}'),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
