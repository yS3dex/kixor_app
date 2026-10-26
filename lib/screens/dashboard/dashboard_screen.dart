import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_session_provider.dart';
import '../../theme/theme.dart';
import '../login/login_screen.dart';
import '../home/painel_tab.dart';
import '../clube/clubes_tab.dart';
import '../calendario/calendario_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentTab = 0;
  bool _notificacoesAtivas = true;

  final List<Widget> _tabs = [
    const PainelTab(),
    const ClubesTab(),
    const CalendarioTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

// 📑 BARRA SUPERIOR
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: PopupMenuButton<String>(
          icon: const Icon(Icons.settings, color: Colors.white),
          onSelected: (opcao) {
            if (opcao == 'logout') {
              context.read<UserSessionProvider>().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'perfil',
              child: Text('Configuração de Perfil'),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: Text('Log-out',
                  style: TextStyle(
                      color: AppColors.liveRed, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        title: const Text(
          'KIXOR',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 3.0,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _notificacoesAtivas
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: _notificacoesAtivas
                  ? AppColors.gradientMid
                  : Colors.white, // Feedback visual limpo
            ),
            onPressed: () {
              setState(() => _notificacoesAtivas = !_notificacoesAtivas);
            },
          ),
        ],
      ),

      body: IndexedStack(
        index: _currentTab,
        children: _tabs,
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTab,
          onTap: (index) => setState(() => _currentTab = index),
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.gradientMid,
          unselectedItemColor: AppColors.textMuted,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          unselectedLabelStyle: const TextStyle(fontSize: 10, letterSpacing: 1),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.stacked_bar_chart_sharp),
              label: 'PAINEL',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_outlined),
              label: 'CLUBE',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              label: 'CALENDÁRIO',
            ),
          ],
        ),
      ),
    );
  }
}
