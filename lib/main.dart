import 'package:flutter/material.dart';
import 'package:project/providers/question_provider.dart';
import 'package:project/providers/set_provider.dart';
import 'screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyAppInit());
}

class MyAppInit extends StatelessWidget {
  MyAppInit({super.key});
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return const MyApp();
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AuthProvider: The root provider for authentication
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Both QuestionProvider and SetProvider depend on AuthProvider
        ChangeNotifierProxyProvider<AuthProvider, QuestionProvider>(
          create: (_) => QuestionProvider(''),
          update: (_, authProvider, questionProvider) =>
              QuestionProvider(authProvider.userEmail ?? ''),
        ),
        ChangeNotifierProxyProvider<AuthProvider, SetProvider>(
          create: (_) => SetProvider(''),
          update: (_, authProvider, setProvider) =>
              SetProvider(authProvider.userEmail ?? ''),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}