import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'screens/project_hub_screen.dart';
import 'screens/api_key_screen.dart';
import 'services/key_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D1117),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  final hasKey = await KeyStorageService.getKey() != null;
  runApp(ProviderScope(child: BuilderPostApp(hasKey: hasKey)));
}

class BuilderPostApp extends StatelessWidget {
  final bool hasKey;
  const BuilderPostApp({super.key, required this.hasKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BuilderPost AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: hasKey ? const ProjectHubScreen() : const ApiKeyScreen(),
    );
  }
}
