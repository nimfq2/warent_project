// Этот файл решает, что показывать: SplashScreen или MainLayout
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './providers/auth_provider.dart';
import './app_theme.dart';
import './main_layout.dart';
import './splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => AuthProvider(),
      child: MaterialApp(
        title: 'Warent',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: Consumer<AuthProvider>(
          builder: (ctx, auth, _) {
            switch (auth.state) {
              case AuthState.authenticated: return const MainLayout();
              case AuthState.unauthenticated: return const Scaffold(body: Center(child: Text("Ошибка входа.")));
              default: return const SplashScreen();
            }
          },
        ),
      ),
    );
  }
}