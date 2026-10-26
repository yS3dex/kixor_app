import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/equipa.dart';
import '../../models/jogador.dart';
import '../../providers/user_session_provider.dart';
import '../../services/campeonato_service.dart';
import '../../theme/theme.dart';

class ClubeDetalheScreen extends StatefulWidget {
  final Equipa equipa;
  const ClubeDetalheScreen({super.key, required this.equipa});

  @override
  State<ClubeDetalheScreen> createState() => _ClubeDetalheScreenState();
}

class _ClubeDetalheScreenState extends State<ClubeDetalheScreen> {
  final CampeonatoService _apiService = CampeonatoService();
  Future<Equipa>? _futureDetalhe;

  static const List<String> _posicoes = [
    'Guarda-Redes',
    'Defesa',
    'Médio',
    'Avançado',
    'Ala',
    'Pivô',
  ];

  @override
  void initState() {
    super.initState();
    _carregarPlantel();
  }

  void _carregarPlantel() {
    setState(() {
      _futureDetalhe = _apiService.getEquipaPorId(widget.equipa.id);
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
      default:
        return "🛡️";
    }
  }

  void _abrirAdicionarJogador(bool permissaoEscrita) {
    if (!permissaoEscrita) return;

    final nomeController = TextEditingController();
    final camisolaController = TextEditingController();
    String posicaoSelecionada = _posicoes.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          title: const Text('Adicionar Jogador',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Nome do Jogador',
                    labelStyle: TextStyle(color: AppColors.textSecondary)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: camisolaController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Número da Camisola',
                    labelStyle: TextStyle(color: AppColors.textSecondary)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: posicaoSelecionada,
                dropdownColor: AppColors.surfaceElevated,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Posição',
                    labelStyle: TextStyle(color: AppColors.textSecondary)),
                items: _posicoes
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setStateDialog(() => posicaoSelecionada = val);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar',
                    style: TextStyle(color: AppColors.textMuted))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gradientMid),
              onPressed: () async {
                final nome = nomeController.text.trim();
                final camisola =
                    int.tryParse(camisolaController.text.trim()) ?? 0;

                if (nome.isEmpty || camisola == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Preenche o nome e o número da camisola.'),
                      backgroundColor: AppColors.liveRed));
                  return;
                }

                Navigator.pop(ctx);

                final novoJogador = Jogador(
                  id: '',
                  nome: nome,
                  numeroCamisola: camisola,
                  posicao: posicaoSelecionada,
                );

                try {
                  await _apiService.criarJogador(
                      novoJogador, int.parse(widget.equipa.id));
                  _carregarPlantel();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Jogador adicionado com sucesso!'),
                        backgroundColor: AppColors.winnerGreen));
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Erro: $e'),
                        backgroundColor: AppColors.liveRed));
                  }
                }
              },
              child: const Text('Adicionar',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminarJogador(Jogador jogador) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Eliminar Jogador',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
            'Tens a certeza que queres eliminar ${jogador.nome} (#${jogador.numeroCamisola})?',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar',
                  style: TextStyle(color: AppColors.textMuted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.liveRed),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _apiService.eliminarJogador(jogador.id);
                _carregarPlantel();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('${jogador.nome} eliminado.'),
                      backgroundColor: AppColors.surfaceElevated));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Erro: $e'),
                      backgroundColor: AppColors.liveRed));
                }
              }
            },
            child: const Text('Eliminar',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _abrirEdicaoEstatisticas(Jogador jogador) {
    final TextEditingController principalController = TextEditingController(
      text: jogador.isGuardaRedes
          ? jogador.defesasComSucesso.toString()
          : jogador.golos.toString(),
    );
    final TextEditingController secundariaController = TextEditingController(
      text: jogador.isGuardaRedes
          ? jogador.defesasFalhadas.toString()
          : jogador.rematesFalhados.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: Text('Estatísticas · ${jogador.nome}',
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: principalController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  labelText:
                      jogador.isGuardaRedes ? 'Defesas com Sucesso' : 'Golos',
                  labelStyle: const TextStyle(color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: secundariaController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  labelText: jogador.isGuardaRedes
                      ? 'Defesas Falhadas'
                      : 'Remates Falhados',
                  labelStyle: const TextStyle(color: AppColors.textSecondary)),
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
              Navigator.pop(context);

              final g = jogador.isGuardaRedes
                  ? 0
                  : (int.tryParse(principalController.text) ?? jogador.golos);
              final rf = jogador.isGuardaRedes
                  ? 0
                  : (int.tryParse(secundariaController.text) ??
                      jogador.rematesFalhados);
              final dc = jogador.isGuardaRedes
                  ? (int.tryParse(principalController.text) ??
                      jogador.defesasComSucesso)
                  : 0;
              final df = jogador.isGuardaRedes
                  ? (int.tryParse(secundariaController.text) ??
                      jogador.defesasFalhadas)
                  : 0;

              try {
                await _apiService.atualizarEstatisticasJogador(jogador.id, {
                  'id': int.tryParse(jogador.id) ?? 0,
                  'nome': jogador.nome,
                  'numeroCamisola': jogador.numeroCamisola,
                  'posicao': jogador.posicao,
                  'golos': g,
                  'rematesFalhados': rf,
                  'defesasComSucesso': dc,
                  'defesasFalhadas': df,
                  'id_equipa': int.tryParse(widget.equipa.id) ?? 0,
                });
                _carregarPlantel();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Erro ao sincronizar: $e'),
                      backgroundColor: AppColors.liveRed));
                }
              }
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<UserSessionProvider>();
    final bool permissaoEscrita = session.isAdmin ||
        (session.isTreinador && session.equipaId == widget.equipa.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 15),
          label: const Text(
            'Voltar para clubes',
            style: TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      floatingActionButton: permissaoEscrita
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.gradientMid,
              icon: const Icon(Icons.person_add_rounded, color: Colors.white),
              label: const Text('Adicionar Jogador',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () => _abrirAdicionarJogador(permissaoEscrita),
            )
          : null,
      body: FutureBuilder<Equipa>(
        future: _futureDetalhe,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.gradientMid));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
                child: Text('Erro ao ler jogadores: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.liveRed)));
          }

          final equipaReal = snapshot.data!;
          final idNum = int.tryParse(equipaReal.id) ?? 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho da equipa
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: AppColors.surface,
                child: Row(
                  children: [
                    Text(_getBandeiraEmoji(idNum),
                        style: const TextStyle(fontSize: 48)),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(equipaReal.nome,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(
                          permissaoEscrita
                              ? '🔓 Privilégios de Escrita Concedidos'
                              : '🔒 Apenas Consulta',
                          style: TextStyle(
                              color: permissaoEscrita
                                  ? AppColors.winnerGreen
                                  : AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        )
                      ],
                    )
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(left: 20.0, top: 20.0, bottom: 8.0),
                child: Text('PLANTEL', style: AppTextStyles.sectionTitle),
              ),

              Expanded(
                child: equipaReal.jogadores.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.group_off_rounded,
                                color: AppColors.textMuted, size: 40),
                            const SizedBox(height: 10),
                            const Text('Sem jogadores registados.',
                                style: TextStyle(color: AppColors.textMuted)),
                            if (permissaoEscrita) ...[
                              const SizedBox(height: 8),
                              const Text('Usa o botão abaixo para adicionar.',
                                  style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12)),
                            ]
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: equipaReal.jogadores.length,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 4),
                        itemBuilder: (context, index) {
                          final atleta = equipaReal.jogadores[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                          color: Color(0xFF242426),
                                          shape: BoxShape.circle),
                                      child: Text('#${atleta.numeroCamisola}',
                                          style: const TextStyle(
                                              color: AppColors.gradientMid,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11)),
                                    ),
                                    const SizedBox(width: 14),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(atleta.nome,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                        Text(atleta.posicao.toUpperCase(),
                                            style: const TextStyle(
                                                color: AppColors.textMuted,
                                                fontSize: 10)),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        if (atleta.isGuardaRedes) ...[
                                          Text(
                                              'Defesas: ${atleta.defesasComSucesso}',
                                              style: const TextStyle(
                                                  color: AppColors.winnerGreen,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12)),
                                          Text(
                                              'Sofridos: ${atleta.defesasFalhadas}',
                                              style: const TextStyle(
                                                  color: AppColors.liveRed,
                                                  fontSize: 11)),
                                        ] else ...[
                                          Text('Golos: ${atleta.golos}',
                                              style: const TextStyle(
                                                  color: AppColors.winnerGreen,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12)),
                                          Text(
                                              'Falhas: ${atleta.rematesFalhados}',
                                              style: const TextStyle(
                                                  color: AppColors.textMuted,
                                                  fontSize: 11)),
                                        ]
                                      ],
                                    ),
                                    if (permissaoEscrita) ...[
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined,
                                            color: AppColors.textSecondary,
                                            size: 18),
                                        tooltip: 'Editar estatísticas',
                                        onPressed: () =>
                                            _abrirEdicaoEstatisticas(atleta),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            color: AppColors.liveRed,
                                            size: 18),
                                        tooltip: 'Eliminar jogador',
                                        onPressed: () =>
                                            _confirmarEliminarJogador(atleta),
                                      ),
                                    ]
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
