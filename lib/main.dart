import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'screens/project_hub_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D1117),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ProviderScope(child: BuilderPostApp()));
}

class BuilderPostApp extends StatelessWidget {
  const BuilderPostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BuilderPost AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const ProjectHubScreen(),
    );
  }
}
