import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'routing/app_router.dart';
import 'theme/app_theme.dart';

class RiftsApp extends StatefulWidget {
  const RiftsApp({super.key});

  @override
  State<RiftsApp> createState() => _RiftsAppState();
}

class _RiftsAppState extends State<RiftsApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter(_toggleTheme);
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'RIFTS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}
