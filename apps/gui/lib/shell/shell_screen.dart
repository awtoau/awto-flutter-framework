import 'package:flutter/material.dart';
import '../features/counter/view/counter_screen.dart';
import '../features/todo/view/todo_screen.dart';
import '../features/fetch/view/fetch_screen.dart';
import '../features/timer/view/timer_screen.dart';
import '../features/ports/view/port_map_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({Key? key}) : super(key: key);

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    CounterScreen(),
    TodoScreen(),
    FetchScreen(),
    TimerScreen(),
    PortMapScreen(),
  ];

  static const List<String> _labels = [
    'Counter',
    'Todo',
    'Fetch',
    'Timer',
    'Ports',
  ];

  static const List<IconData> _icons = [
    Icons.add_circle,
    Icons.checklist,
    Icons.cloud_download,
    Icons.timer,
    Icons.usb,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: List.generate(
          _labels.length,
          (index) => NavigationDestination(
            icon: Icon(_icons[index]),
            label: _labels[index],
          ),
        ),
      ),
    );
  }
}
