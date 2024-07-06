import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mood_tracker/features/settings/repos/screen_config_repository.dart';
import 'package:mood_tracker/features/settings/view_models/screen_config_view_model.dart';
import 'package:mood_tracker/firebase_options.dart';
import 'package:mood_tracker/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase Initialize
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final preferences = await SharedPreferences.getInstance();
  final repository = ScreenConfigRepository(preferences);

  runApp(
    ProviderScope(
      overrides: [
        screenConfigProvider
            .overrideWith(() => ScreenConfigViewModel(repository))
      ],
      child: const MoodTracker(),
    ),
  );
}

class MoodTracker extends ConsumerWidget {
  const MoodTracker({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: ref.watch(routerProvider),
      title: 'Mood Tracker',
      themeMode: ref.watch(screenConfigProvider).dark
          ? ThemeMode.dark
          : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
