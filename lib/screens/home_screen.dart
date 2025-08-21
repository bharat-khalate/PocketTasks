import 'package:pocketnotes/models/task.dart';
import 'package:pocketnotes/state/task_store.dart';
import 'package:pocketnotes/widgets/task_progress_indicator.dart';
import 'package:pocketnotes/utils.dart/constants.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final TaskStore store;
  const HomeScreen({required this.store});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController addController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  String? addError;

  @override
  void dispose() {
    addController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _handleAdd() async {
    final title = addController.text.trim();
    if (title.isEmpty) {
      setState(() => addError = 'Please enter a task');
      return;
    }
    setState(() => addError = null);
    final created = await widget.store.addTask(title);
    addController.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${created.title}"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            final index = widget.store.tasks.indexWhere(
              (t) => t.id == created.id,
            );
            if (index != -1) {
              final removed = await widget.store.removeById(created.id);
              if (removed != null) {
                await widget.store.insertAt(index, removed);
              }
            }
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final tasks = store.visibleTasks;
    final total = store.tasks.length;
    final completed = store.completedCount;

    return Scaffold(
      backgroundColor: 
          Color(0xFF290559),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  TaskProgressIndicator(
                    completed: completed,
                    total: total,
                    size: 52,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'PocketTasks',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: addController,
                      style: TextStyle(color: Color(inputTextColor)),
                      decoration: InputDecoration(
                        hintText: 'Add Task',
                        errorText: addError,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        filled: true,
                        fillColor: Color(inputFieldColor),
                        hintStyle: TextStyle(color: Color(inputTextColor).withOpacity(0.7)),
                      ),
                      onSubmitted: (_) => _handleAdd(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _handleAdd,
                    style: FilledButton.styleFrom(
                      backgroundColor: Color(buttonColor),
                      foregroundColor: Color(buttonTextColor),
                      padding: const EdgeInsets.symmetric(vertical:21 , horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: searchController,
                style: TextStyle(color: Color(inputTextColor)),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Color(inputTextColor)),
                  hintText: 'Search',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  filled: true,
                  fillColor: Color(inputFieldColor),
                  hintStyle: TextStyle(color: Color(inputTextColor).withOpacity(0.7)),
                ),
                onChanged: store.setQueryDebounced,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: store.filter == TaskFilter.all,
                    onSelected: (_) => store.setFilter(TaskFilter.all),
                    backgroundColor: Color(chipBgColor),
                    selectedColor: Color(chipBgColor),
                    labelStyle: TextStyle(
                      color: store.filter == TaskFilter.all 
                          ? Color(primaryTextColor) 
                          : Color(unselectedChipColor),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('Active'),
                    selected: store.filter == TaskFilter.active,
                    onSelected: (_) => store.setFilter(TaskFilter.active),
                    backgroundColor: Color(chipBgColor),
                    selectedColor: Color(chipBgColor),
                    labelStyle: TextStyle(
                      color: store.filter == TaskFilter.active 
                          ? Color(primaryTextColor) 
                          : Color(unselectedChipColor),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('Done'),
                    selected: store.filter == TaskFilter.done,
                    onSelected: (_) => store.setFilter(TaskFilter.done),
                    backgroundColor: Color(chipBgColor),
                    selectedColor: Color(chipBgColor),
                    labelStyle: TextStyle(
                      color: store.filter == TaskFilter.done 
                          ? Color(primaryTextColor) 
                          : Color(unselectedChipColor),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Dismissible(
                      key: ValueKey(task.id),
                      background: Container(
                        color: Colors.red.shade200,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(Icons.delete, color: Colors.red.shade700),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red.shade200,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(Icons.delete, color: Colors.red.shade700),
                      ),
                      onDismissed: (direction) async {
                        final originalIndex = store.tasks.indexWhere(
                          (t) => t.id == task.id,
                        );
                        final removed = await store.removeById(task.id);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Deleted "${task.title}"'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () async {
                                if (removed != null) {
                                  await store.insertAt(originalIndex, removed);
                                }
                              },
                            ),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: Icon(
                          task.done
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: task.done ? Colors.greenAccent : null,
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.done
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        onTap: () async {
                          await store.toggleTask(task.id);
                          if (!mounted) return;
                          final nowDone = store.tasks
                              .firstWhere((t) => t.id == task.id)
                              .done;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                nowDone ? 'Marked done' : 'Marked active',
                              ),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () async {
                                  await store.toggleTask(task.id);
                                },
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
