import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/app_provider.dart';
import 'screens/app_shell.dart';
import 'services/firestore_service.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    runApp(_SetupErrorApp(error: e.toString()));
    return;
  }
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(FirestoreService()),
      child: const X3App(),
    ),
  );
}

class X3App extends StatelessWidget {
  const X3App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const AppShell(),
    );
  }
}

class _SetupErrorApp extends StatelessWidget {
  const _SetupErrorApp({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 48, color: AppColors.live),
                const SizedBox(height: 16),
                const Text('Firebase is not configured',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text(
                  'Run `flutterfire configure` in the project root, then restart the app. '
                  'See README.md → Firebase Setup.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 16),
                Text(error,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: AppColors.muted)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
