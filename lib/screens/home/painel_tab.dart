import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/jogo.dart';
import '../../providers/user_session_provider.dart';
import '../../services/campeonato_service.dart';
import '../../theme/theme.dart';

class PainelTab extends StatefulWidget {
  const PainelTab({super.key});

  @override
  State<PainelTab> createState() => _PainelTabState();
}

class _PainelTabState extends State<PainelTab> {
  final CampeonatoService _apiService = CampeonatoService();

  Future<Map<String, dynamic>>? _dadosFuturos;

  @override
  void initState() {
    super.initState();
    _atualizarPainel();
  }

  void _atualizarPainel() {
    setState(() {
      _dadosFuturos = Future.wait([
        _apiService.getUltimoJogo(),
        _apiService.getJogos(),
      ]).then((resultados) {
        return {
          'ultimo': resultados[0] as Jogo?,
          'todos': resultados[1] as List<Jogo>,
        };
      });
    });
  }

  String _getNomeEquipa(int id) {
    switch (id) {
      case 1:
        return "Brasil";
      case 2:
        return "Argentina";
      case 3:
        return "Portugal";
      case 4:
        return "Espanha";
      case 5:
        return "Alemanha";
      case 6:
        return "Marrocos";
      case 7:
        return "França";
      default:
        return "Clube $id";
    }
  }

  String _getBandeiraEquipa(int id) {
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

  void _abrirEdicaoPlacar(Jogo jogo) {
    final TextEditingController casaController =
        TextEditingController(text: jogo.golosCasa.toString());
    final TextEditingController foraController =
        TextEditingController(text: jogo.golosFora.toString());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: Text('Modificar Resultado (ID: ${jogo.idJogo})',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: TextField(
                controller: casaController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration:
                    InputDecoration(labelText: _getNomeEquipa(jogo.equipaCasa)),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('X',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.gradientMid)),
            ),
            Expanded(
              child: TextField(
                controller: foraController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration:
                    InputDecoration(labelText: _getNomeEquipa(jogo.equipaFora)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar',
                  style: TextStyle(color: AppColors.textMuted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gradientMid),
            onPressed: () async {
              final int novosGolosCasa =
                  int.tryParse(casaController.text) ?? jogo.golosCasa;
              final int novosGolosFora =
                  int.tryParse(foraController.text) ?? jogo.golosFora;

              Navigator.pop(context);

              try {
                await _apiService.atualizarPlacar(
                    jogo.idJogo, novosGolosCasa, novosGolosFora);
                _notificar('Resultado sincronizado com sucesso no SQL Server!');
                _atualizarPainel();
              } catch (e) {
                _notificar('Erro ao atualizar na API: $e', erro: true);
              }
            },
            child: const Text('Confirmar',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  void _notificar(String msg, {bool erro = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: erro ? AppColors.liveRed : AppColors.surfaceElevated));
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<UserSessionProvider>().isAdmin;

    return FutureBuilder<Map<String, dynamic>>(
      future: _dadosFuturos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.gradientMid));
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // 🌟 Corrigido aqui!
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_rounded,
                      size: 48, color: AppColors.liveRed),
                  const SizedBox(height: 12),
                  const Text('Falha de ligação ao ecossistema KIXOR.',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 6),
                  Text(
                      snapshot.error?.toString() ??
                          'Verifique se o backend REST está online.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _atualizarPainel,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surfaceElevated),
                    child: const Text('Tentar Novamente',
                        style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),
          );
        }

        final dados = snapshot.data!;
        final Jogo? ultimoJogo = dados['ultimo'];
        final List<Jogo> todosOsJogos = (dados['todos'] as List<Jogo>)
            .where((j) => j.dataJogo.isAfter(DateTime.now()))
            .toList();

        return RefreshIndicator(
          onRefresh: () async => _atualizarPainel(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ÚLTIMO JOGO
                _buildHeaderSeccao('ÚLTIMO JOGO REALIZADO', AppColors.liveRed),
                const SizedBox(height: 10),
                if (ultimoJogo != null)
                  _buildCardUltimoJogo(ultimoJogo, isAdmin)
                else
                  _buildAvisoVazio(
                      'Nenhum jogo finalizado registado na base de dados.'),

                const SizedBox(height: 24),

                // PRÓXIMO JOGO
                _buildHeaderSeccao(
                    'PRÓXIMO JOGO DO TORNEIO', AppColors.upcomingBlue),
                const SizedBox(height: 10),
                _buildCardProximoJogo(),

                const SizedBox(height: 24),

                // JOGOS DA SEMANA
                _buildHeaderSeccao(
                    'JOGOS DA SEMANA (AGENDADOS)', AppColors.textMuted),
                const SizedBox(height: 10),
                if (todosOsJogos.isEmpty)
                  _buildAvisoVazio(
                      'Não existem confrontos agendados para esta semana.')
                else
                  _buildListaJogosSemana(todosOsJogos, isAdmin),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSeccao(String titulo, Color corPonto) {
    return Row(
      children: [
        Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: corPonto, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2),
        ),
      ],
    );
  }

  Widget _buildCardUltimoJogo(Jogo jogo, bool isAdmin) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Container(
                height: 2.5,
                width: double.infinity,
                decoration:
                    const BoxDecoration(gradient: AppGradients.primary)),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('🏁 TEMPO FINAL',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11)),
                      Text(jogo.estadio,
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBlocoEquipa(jogo.equipaCasa),
                      Row(
                        children: [
                          Text('${jogo.golosCasa}',
                              style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  fontFamily: 'monospace')),
                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14),
                              child: Text('—',
                                  style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 20))),
                          Text('${jogo.golosFora}',
                              style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  fontFamily: 'monospace')),
                        ],
                      ),
                      _buildBlocoEquipa(jogo.equipaFora),
                    ],
                  ),
                  if (isAdmin) ...[
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C1612),
                        side: const BorderSide(color: Color(0xFF5A261A)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.edit,
                          size: 12, color: AppColors.gradientMid),
                      label: const Text('EDITAR PLACAR',
                          style: TextStyle(
                              color: AppColors.gradientMid,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                      onPressed: () => _abrirEdicaoPlacar(jogo),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardProximoJogo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('HOJE · 02:18',
                  style: TextStyle(
                      color: AppColors.upcomingBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
              Text('MetLife Stadium',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBlocoEquipa(3),
              Column(
                children: [
                  const Text('VS',
                      style: TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        gradient: AppGradients.primary,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text('Fase de Grupos',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  )
                ],
              ),
              _buildBlocoEquipa(4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListaJogosSemana(List<Jogo> jogos, bool isAdmin) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: jogos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final j = jogos[index];

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              Text(_getBandeiraEquipa(j.equipaCasa),
                  style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _getShortName(_getNomeEquipa(j.equipaCasa)),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('VS',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: AppColors.textSecondary)),
                  ),
                  if (isAdmin) ...[
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () => _abrirEdicaoPlacar(j),
                      child: const Text('LANÇAR',
                          style: TextStyle(
                              color: AppColors.gradientMid,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5)),
                    )
                  ]
                ],
              ),
              Expanded(
                child: Text(
                  _getShortName(_getNomeEquipa(j.equipaFora)),
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Text(_getBandeiraEquipa(j.equipaFora),
                  style: const TextStyle(fontSize: 22)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBlocoEquipa(int id) {
    return Column(
      children: [
        Text(_getBandeiraEquipa(id), style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 6),
        Text(_getNomeEquipa(id),
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
      ],
    );
  }

  Widget _buildAvisoVazio(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Text(msg,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          textAlign: TextAlign.center),
    );
  }

  String _getShortName(String name) {
    if (name.length > 10) return "${name.substring(0, 8)}..";
    return name;
  }
}
