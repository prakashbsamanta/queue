import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:path_provider/path_provider.dart';
import 'core/theme.dart';
import 'data/models/course.dart';
import 'data/models/video.dart';
import 'data/models/session.dart';
import 'ui/auth/auth_wrapper.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize Hive
  await Hive.initFlutter(); // Uses path_provider internally usually, or works on web/desktop

  // Register Adapters
  Hive.registerAdapter(VideoAdapter());
  Hive.registerAdapter(CourseAdapter());
  Hive.registerAdapter(SessionAdapter());

  // Open Boxes
  await Hive.openBox<Course>('courses');
  await Hive.openBox<Session>('sessions');
  await Hive.openBox('settings');

  runApp(const ProviderScope(child: FlowStateApp()));
}

class FlowStateApp extends StatelessWidget {
  const FlowStateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Queue',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthWrapper(),
    );
  }
}
