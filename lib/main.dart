import 'package:flutter/material.dart';
import 'package:project/providers/set_provider.dart';
import 'package:project/utils/settings_manager.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/activity_provider.dart';

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
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<SettingsManager>.value(
            value: SettingsManager.instance),
        ChangeNotifierProxyProvider<AuthProvider, SetProvider>(
          create: (_) => SetProvider(''),
          update: (_, authProvider, setProvider) {
            final userEmail = authProvider.userEmail ?? '';

            // Initialize only if the userEmail changes or hasn't been initialized yet
            if (setProvider == null || setProvider.userEmail != userEmail) {
              final newProvider = SetProvider(userEmail);
              newProvider.initialize();
              return newProvider;
            }
            return setProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ActivityProvider>(
          create: (_) => ActivityProvider(''),
          update: (_, authProvider, activityProvider) {
            final userEmail = authProvider.userEmail ?? '';

            // Initialize only if the userEmail changes or hasn't been initialized yet
            if (activityProvider == null ||
                activityProvider.userEmail != userEmail) {
              final newProvider = ActivityProvider(userEmail);
              newProvider.initialize();
              return newProvider;
            }

            return activityProvider;
          },
        ),
      ],
      child: Consumer2<AuthProvider, ThemeProvider>(
        builder: (context, authProvider, themeProvider, _) {
          if (authProvider.isSignedIn) {
            // Initialize settings when user signs in
            SettingsManager.instance.load(authProvider.userEmail!).then((_) {
              themeProvider.setTheme(SettingsManager.instance.theme);
            });
          }
          return MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blue, brightness: Brightness.dark),
              useMaterial3: true,
            ),
            themeMode: themeProvider.themeMode,
            home: const LandingScreen(), // updated home widget
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

// New widget to handle auto login
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});
  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool isLoading = true;
  bool isSignedIn = false;

  @override
  void initState() {
    super.initState();
    _attemptAutoLogin();
  }

  Future<void> _attemptAutoLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final account = await authProvider.autoSignIn();
    setState(() {
      isSignedIn = account != null;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return isSignedIn ? const HomeScreen() : const LoginScreen();
  }
}
