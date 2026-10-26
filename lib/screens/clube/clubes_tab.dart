import 'package:flutter/material.dart';
import '../../models/equipa.dart';
import '../../services/campeonato_service.dart';
import '../../theme/theme.dart';
import 'clube_detalhe_screen.dart';

class ClubesTab extends StatefulWidget {
  const ClubesTab({super.key});

  @override
  State<ClubesTab> createState() => _ClubesTabState();
}

class _ClubesTabState extends State<ClubesTab> {
  final CampeonatoService _apiService = CampeonatoService();
  final TextEditingController _pesquisaController = TextEditingController();

  Future<List<Equipa>>? _futureEquipas;
  String _termoPesquisa = '';

  @override
  void initState() {
    super.initState();
    _carregarEquipas();
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  void _carregarEquipas() {
    setState(() {
      _futureEquipas = _apiService.getEquipas();
    });
  }

  String _getBandeiraEmoji(int id) {
    switch (id) {
      case 1:
        return "🇧🇷";
      case 2:
        return "🇦🇷";
      case 3:
        return "🇵🇹";
      case 4:
        return "🇪🇸";
      case 5:
        return "🇩🇪";
      case 6:
        return "🇲🇦";
      case 7:
        return "🇫🇷";
      default:
        return "🛡️";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<List<Equipa>>(
        future: _futureEquipas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.gradientMid));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text('Erro ao ligar ao servidor: ${snapshot.error}',
                  style: const TextStyle(color: AppColors.liveRed)),
            );
          }

          final todasEquipas = snapshot.data!;
          final equipasFiltradas = _termoPesquisa.isEmpty
              ? todasEquipas
              : todasEquipas
                  .where((e) => e.nome
                      .toLowerCase()
                      .contains(_termoPesquisa.toLowerCase()))
                  .toList();

          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CLUBES INSCRITOS',
                    style: AppTextStyles.sectionTitle),
                const SizedBox(height: 12),

                // Barra de pesquisa
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: TextField(
                    controller: _pesquisaController,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (valor) =>
                        setState(() => _termoPesquisa = valor),
                    decoration: InputDecoration(
                      hintText: 'Pesquisar clube...',
                      hintStyle: const TextStyle(
                          color: AppColors.textMuted, fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.textMuted),
                      suffixIcon: _termoPesquisa.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded,
                                  color: AppColors.textMuted, size: 18),
                              onPressed: () {
                                _pesquisaController.clear();
                                setState(() => _termoPesquisa = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Expanded(
                  child: equipasFiltradas.isEmpty
                      ? Center(
                          child: Text(
                            _termoPesquisa.isEmpty
                                ? 'Nenhum clube registado.'
                                : 'Nenhum clube encontrado para "$_termoPesquisa".',
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount: equipasFiltradas.length,
                          itemBuilder: (context, index) {
                            final eq = equipasFiltradas[index];
                            final int idNumerico = int.tryParse(eq.id) ?? 0;

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color:
                                        Colors.white.withValues(alpha: 0.04)),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                leading: Text(_getBandeiraEmoji(idNumerico),
                                    style: const TextStyle(fontSize: 28)),
                                title: Text(eq.nome,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                      'Vitórias: ${eq.vitorias}  ·  Derrotas: ${eq.derrotas}',
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12)),
                                ),
                                trailing: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: AppColors.textMuted,
                                    size: 16),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            ClubeDetalheScreen(equipa: eq)),
                                  ).then((_) => _carregarEquipas());
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
