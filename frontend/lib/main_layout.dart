import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- БЛОК ИМПОРТОВ: Проверяем каждый путь ---

// Провайдеры и виджеты
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/widgets/app_icons.dart';
import 'package:frontend/app_theme.dart';

// Экраны пользователя
import 'package:frontend/screens/dashboard_screen.dart';
import 'package:frontend/screens/numbers_screen.dart';
import 'package:frontend/screens/profile_screen.dart';

// Экраны администратора
import 'package:frontend/screens/admin_screen.dart';
import 'package:frontend/screens/admin/admin_numbers_screen.dart';
import 'package:frontend/screens/admin/user_list_screen.dart';


class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // Карта экранов для пользователя
  static const List<Widget> _userScreens = <Widget>[
    DashboardScreen(),
    NumbersScreen(),
    ProfileScreen(),
  ];

  // Карта экранов для администратора
  static const List<Widget> _adminScreens = <Widget>[
    AdminScreen(),
    AdminNumbersScreen(),
    UserListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isAdmin = authProvider.isAdmin;

    // Выбираем правильный набор экранов в зависимости от роли
    final List<Widget> screens = isAdmin ? _adminScreens : _userScreens;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Десктопная версия с боковой панелью
        if (constraints.maxWidth > 768) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                  backgroundColor: AppTheme.cardColor,
                  labelType: NavigationRailLabelType.all,
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text("EBU", style: TextStyle(color: AppTheme.primaryColor, fontSize: 28, fontWeight: FontWeight.bold)),
                  ),
                  destinations: isAdmin ? _buildAdminDestinations() : _buildUserDestinations(),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: screens[_selectedIndex]),
              ],
            ),
          );
        }
        
        // Мобильная версия с нижней панелью
        return Scaffold(
          body: screens[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: (isAdmin ? _buildAdminDestinations() : _buildUserDestinations())
                .map((d) => BottomNavigationBarItem(icon: d.icon, label: (d.label as Text).data))
                .toList(),
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            backgroundColor: AppTheme.cardColor,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: AppTheme.secondaryFontColor,
            type: BottomNavigationBarType.fixed,
          ),
        );
      },
    );
  }

  List<NavigationRailDestination> _buildUserDestinations() {
    return const [
      NavigationRailDestination(icon: Icon(AppIcons.bar_chart), label: Text('Дашборд')),
      NavigationRailDestination(icon: Icon(AppIcons.phone), label: Text('Номера')),
      NavigationRailDestination(icon: Icon(AppIcons.user), label: Text('Профиль')),
    ];
  }

  List<NavigationRailDestination> _buildAdminDestinations() {
    return const [
      NavigationRailDestination(icon: Icon(AppIcons.bar_chart), label: Text('Дашборд')),
      NavigationRailDestination(icon: Icon(AppIcons.phone), label: Text('Номера')),
      NavigationRailDestination(icon: Icon(AppIcons.users), label: Text('Юзеры')),
    ];
  }
}