import 'package:flutter/material.dart';
import 'shell/shell_screen.dart';

class AwtoGuiApp extends StatelessWidget {
  const AwtoGuiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Awto Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const ShellScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
