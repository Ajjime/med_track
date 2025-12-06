import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/firestore_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';

// IMPORTANT: Add your generated firebase_options.dart here
// import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  // Use `flutterfire configure` to generate the default options
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform, 
  );

  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();

  runApp(const MediTrackApp());
}

class MediTrackApp extends StatelessWidget {
  const MediTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        Provider<NotificationService>(create: (_) => NotificationService()),
      ],
      child: MaterialApp(
        title: 'MediTrack',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          useMaterial3: true,
          inputDecorationTheme: const InputDecorationTheme(
             filled: true,
             fillColor: Colors.white,
          )
        ),
        home: const HomeScreen(),
      ),
    );
  }
}