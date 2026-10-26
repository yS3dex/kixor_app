import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_strings.dart';
import '../../providers/user_session_provider.dart';
import '../../services/campeonato_service.dart';
import '../../theme/theme.dart';
import '../../widgets/gradient_border_container.dart';
import '../../widgets/gradient_button.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final CampeonatoService _authService = CampeonatoService();

  bool _senhaOculta = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usuarioController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _processarLogin() async {
    final email = _usuarioController.text.trim();
    final senha = _senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      _notificar(AppStrings.erroCamposVazios, erro: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final utilizador = await _authService.login(email, senha);

      UserRole papelDeterminado = UserRole.visitante;
      if (email.toLowerCase() == 'admin@admin.com') {
        papelDeterminado = UserRole.admin;
      } else if (utilizador.idPerfil == 1) {
        papelDeterminado = UserRole.admin;
      } else if (utilizador.idPerfil == 2) {
        papelDeterminado = UserRole.treinador;
      }

      if (!mounted) return;

      context.read<UserSessionProvider>().loginComo(
            papelDeterminado,
            equipaId: utilizador.idEquipa?.toString(),
          );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (e) {
      _notificar(e.toString(), erro: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _entrarComoVisitante() {
    context.read<UserSessionProvider>().loginComo(UserRole.visitante);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  void _notificar(String texto, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: erro ? AppColors.liveRed : AppColors.surfaceElevated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logótipo KIXOR
                Image.asset(
                  'assets/images/Kixor_logoSF.png',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 8),
                const Text(
                  AppStrings.slogan,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3.0,
                  ),
                ),
                const SizedBox(height: 48),

                GradientBorderContainer(
                  child: TextField(
                    controller: _usuarioController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: AppStrings.loginUsuario,
                      prefixIcon: Icon(Icons.person_outline,
                          color: AppColors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                GradientBorderContainer(
                  child: TextField(
                    controller: _senhaController,
                    obscureText: _senhaOculta,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: AppStrings.loginSenha,
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: AppColors.textSecondary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _senhaOculta
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () =>
                            setState(() => _senhaOculta = !_senhaOculta),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                GradientButton(
                  label: AppStrings.loginEntrar,
                  isLoading: _isLoading,
                  onPressed: _processarLogin,
                ),
                const SizedBox(height: 24),

                TextButton(
                  onPressed: _entrarComoVisitante,
                  child: const Text(
                    AppStrings.loginVisitante,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
