import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:js/js.dart' as js;
import '../providers/auth_provider.dart';
import '../app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

@js.JS('Telegram.WebApp')
class TelegramWebApp {
  external static String get initData;
  external static void ready();
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initAuth());
  }

  void _initAuth() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Получаем текущий URL
    final uri = Uri.base;
    // Ищем в нем параметр ?token=...
    final String? loginToken = uri.queryParameters['token'];

    if (loginToken != null && loginToken.isNotEmpty) {
      // Если токен есть, передаем его в AuthProvider
      authProvider.loginWithOneTimeToken(loginToken);
    } else {
      // Если токена нет, вход невозможен
      authProvider.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircularProgressIndicator(color: AppTheme.primaryColor),
          SizedBox(height: 24),
          Text("EBU RENT", style: TextStyle(color: AppTheme.secondaryFontColor, fontSize: 20, fontWeight: FontWeight.bold))
        ]),
      ),
    );
  }
}