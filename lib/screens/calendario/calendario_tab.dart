import 'package:flutter/material.dart';
import '../../models/jogo.dart';
import '../../services/campeonato_service.dart';
import '../../theme/theme.dart';

class CalendarioTab extends StatefulWidget {
  const CalendarioTab({super.key});

  @override
  State<CalendarioTab> createState() => _CalendarioTabState();
}

class _CalendarioTabState extends State<CalendarioTab> {
  final CampeonatoService _apiService = CampeonatoService();
  Future<List<Jogo>>? _futureCalendario;

  @override
  void initState() {
    super.initState();
    _futureCalendario = _apiService.getJogos();
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
        return "🏆";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<List<Jogo>>(
        future: _futureCalendario,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.gradientMid));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
                child: Text('Erro ao sincronizar calendário: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.liveRed)));
          }

          final jogosReal = snapshot.data!;

          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CRONOGRAMA DE CONFRONTOS',
                    style: AppTextStyles.sectionTitle),
                const SizedBox(height: 14),
                Expanded(
                  child: jogosReal.isEmpty
                      ? const Center(
                          child: Text('Sem jogos agendados.',
                              style: TextStyle(color: AppColors.textMuted)))
                      : ListView.builder(
                          itemCount: jogosReal.length,
                          itemBuilder: (context, index) {
                            final jogo = jogosReal[index];
                            final bool finalizado =
                                jogo.dataJogo.isBefore(DateTime.now());
                            final String dataFormatada =
                                "${jogo.dataJogo.day.toString().padLeft(2, '0')}/${jogo.dataJogo.month.toString().padLeft(2, '0')} · MUNDIAL";

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: finalizado
                                        ? AppColors.liveRed
                                            .withValues(alpha: 0.15)
                                        : Colors.white.withValues(alpha: 0.03)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: finalizado
                                          ? const Color(0xFF1E1A1A)
                                          : const Color(0xFF1E1E22),
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(dataFormatada,
                                            style: TextStyle(
                                                color: finalizado
                                                    ? AppColors.liveRed
                                                    : AppColors.upcomingBlue,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 11)),
                                        Text(
                                            finalizado
                                                ? '${jogo.golosCasa}  —  ${jogo.golosFora}  ·  FINALIZADO'
                                                : 'AGENDADO',
                                            style: TextStyle(
                                                color: finalizado
                                                    ? AppColors.winnerGreen
                                                    : Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(18),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Text(
                                                      _getBandeiraEmoji(
                                                          jogo.equipaCasa),
                                                      style: const TextStyle(
                                                          fontSize: 18)),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      _getNomeEquipa(
                                                          jogo.equipaCasa),
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                          fontSize: 13),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFF26262A),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6)),
                                                child: Text(
                                                    jogo.fase.toUpperCase(),
                                                    style: const TextStyle(
                                                        color: AppColors
                                                            .textSecondary,
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.w900)),
                                              ),
                                            ),
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      _getNomeEquipa(
                                                          jogo.equipaFora),
                                                      textAlign: TextAlign.end,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                          fontSize: 13),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                      _getBandeiraEmoji(
                                                          jogo.equipaFora),
                                                      style: const TextStyle(
                                                          fontSize: 18)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Divider(
                                                color: Color(0xFF242426),
                                                thickness: 1)),
                                        Row(
                                          children: [
                                            const Icon(
                                                Icons.location_on_outlined,
                                                color: AppColors.textMuted,
                                                size: 14),
                                            const SizedBox(width: 6),
                                            Expanded(
                                                child: Text(jogo.estadio,
                                                    style: const TextStyle(
                                                        color:
                                                            AppColors.textMuted,
                                                        fontSize: 11),
                                                    overflow:
                                                        TextOverflow.ellipsis)),
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                ],
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
