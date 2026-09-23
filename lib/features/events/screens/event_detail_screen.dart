import 'package:flutter/material.dart';
import '../../camera/screens/camera_screen.dart';
import 'edit_event_config_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventDetailScreen({
    super.key,
    required this.event,
  });

  @override
  State<EventDetailScreen> createState() =>
      _EventDetailScreenState();
}

class _EventDetailScreenState
    extends State<EventDetailScreen> {
  late Map<String, dynamic> event;

  @override
  void initState() {
    super.initState();

    event = Map<String, dynamic>.from(
      widget.event,
    );

    if (widget.event['config'] is Map) {
      event['config'] =
          Map<String, dynamic>.from(
        widget.event['config'],
      );
    }
  }

  String formatDate(dynamic value) {
    if (value == null ||
        value.toString().isEmpty) {
      return 'Data não informada';
    }

    try {
      final date =
          DateTime.parse(value.toString());

      final day =
          date.day.toString().padLeft(2, '0');

      final month =
          date.month.toString().padLeft(2, '0');

      final year = date.year.toString();

      return '$day/$month/$year';
    } catch (_) {
      return value.toString();
    }
  }

  String formatSpeed(dynamic value) {
    if (value == null) {
      return '-';
    }

    final speed =
        double.tryParse(value.toString());

    if (speed == null) {
      return value.toString();
    }

    return '${speed.toStringAsFixed(2)}x';
  }

  Future<void> editConfig() async {
    if (event['config'] is! Map) {
      return;
    }

    final currentConfig =
        Map<String, dynamic>.from(
      event['config'],
    );

    final result =
        await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            EditEventConfigScreen(
          eventName:
              event['name']?.toString() ??
                  'Evento',
          config: currentConfig,
        ),
      ),
    );

    if (result is Map) {
      setState(() {
        event['config'] =
            Map<String, dynamic>.from(
          result,
        );
      });

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Configuração salva com sucesso!',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String eventName =
        event['name']?.toString() ?? 'Evento';

    final String eventDate =
        formatDate(
      event['event_date'],
    );

    final bool isActive =
        event['is_active'] == true;

    final Map<String, dynamic>? config =
        event['config'] is Map
            ? Map<String, dynamic>.from(
                event['config'],
              )
            : null;

    final dynamic recordingDuration =
        config?['recording_duration'];

    final dynamic startSpeed =
        config?['start_speed'];

    final dynamic middleSpeed =
        config?['middle_speed'];

    final dynamic endSpeed =
        config?['end_speed'];

    final bool reverse =
        config?['reverse'] == true;

    final bool boomerang =
        config?['boomerang'] == true;

    final String resolution =
        config?['resolution']
                ?.toString() ??
            '-';

    final String fps =
        config?['fps']?.toString() ?? '-';

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFFF5F5F5),
        surfaceTintColor:
            Colors.transparent,
        elevation: 0,

        title: const Text(
          'Evento',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),

        actions: [
          TextButton.icon(
            onPressed:
                config == null
                    ? null
                    : editConfig,
            icon: const Icon(
              Icons.edit_outlined,
            ),
            label: const Text(
              'Editar',
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            32,
          ),

          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 600,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,

                children: [
                  Container(
                    padding:
                        const EdgeInsets.all(
                      22,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                        22,
                      ),
                    ),

                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Container(
                          width: 58,
                          height: 58,

                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFF1F1F1,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              16,
                            ),
                          ),

                          child: const Icon(
                            Icons
                                .celebration_outlined,
                            size: 30,
                          ),
                        ),

                        const SizedBox(
                          width: 16,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              Text(
                                eventName,
                                style:
                                    const TextStyle(
                                  fontSize: 23,
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                ),
                              ),

                              const SizedBox(
                                height: 7,
                              ),

                              Row(
                                children: [
                                  const Icon(
                                    Icons
                                        .calendar_today_outlined,
                                    size: 15,
                                    color:
                                        Colors.grey,
                                  ),

                                  const SizedBox(
                                    width: 7,
                                  ),

                                  Text(
                                    eventDate,
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 11,
                            vertical: 6,
                          ),

                          decoration:
                              BoxDecoration(
                            color: isActive
                                ? const Color(
                                    0xFFE8F5E9,
                                  )
                                : const Color(
                                    0xFFEEEEEE,
                                  ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),
                          ),

                          child: Text(
                            isActive
                                ? 'Ativo'
                                : 'Inativo',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight
                                      .w700,
                              color: isActive
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  const Text(
                    'Configuração do vídeo',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  if (config == null)
                    Container(
                      padding:
                          const EdgeInsets.all(
                        22,
                      ),
                      decoration:
                          BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),
                      ),
                      child: const Text(
                        'Este evento não possui configuração.',
                        textAlign:
                            TextAlign.center,
                      ),
                    )
                  else
                    Container(
                      padding:
                          const EdgeInsets.all(
                        20,
                      ),

                      decoration:
                          BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),
                      ),

                      child: Column(
                        children: [
                          _ConfigRow(
                            icon: Icons
                                .timer_outlined,
                            title: 'Duração',
                            value:
                                '$recordingDuration segundos',
                          ),

                          const Divider(
                            height: 28,
                          ),

                          _ConfigRow(
                            icon: Icons
                                .speed_rounded,
                            title:
                                'Velocidade inicial',
                            value:
                                formatSpeed(
                              startSpeed,
                            ),
                          ),

                          const Divider(
                            height: 28,
                          ),

                          _ConfigRow(
                            icon: Icons
                                .speed_rounded,
                            title:
                                'Velocidade do meio',
                            value:
                                formatSpeed(
                              middleSpeed,
                            ),
                          ),

                          const Divider(
                            height: 28,
                          ),

                          _ConfigRow(
                            icon: Icons
                                .speed_rounded,
                            title:
                                'Velocidade final',
                            value:
                                formatSpeed(
                              endSpeed,
                            ),
                          ),

                          const Divider(
                            height: 28,
                          ),

                          _ConfigRow(
                            icon: Icons
                                .replay_rounded,
                            title: 'Reverse',
                            value: reverse
                                ? 'Ativado'
                                : 'Desativado',
                          ),

                          const Divider(
                            height: 28,
                          ),

                          _ConfigRow(
                            icon: Icons
                                .all_inclusive_rounded,
                            title:
                                'Boomerang',
                            value: boomerang
                                ? 'Ativado'
                                : 'Desativado',
                          ),

                          const Divider(
                            height: 28,
                          ),

                          _ConfigRow(
                            icon: Icons
                                .high_quality_outlined,
                            title: 'Resolução',
                            value: resolution,
                          ),

                          const Divider(
                            height: 28,
                          ),

                          _ConfigRow(
                            icon: Icons
                                .movie_outlined,
                            title: 'FPS',
                            value: fps,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(
                    height: 34,
                  ),

                  SizedBox(
                    height: 68,

                    child:
                        ElevatedButton.icon(
                      onPressed:
                        !isActive || config == null
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => CameraScreen(
                                      event: event,
                                    ),
                                  ),
                                );
                              },

                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            const Color(
                          0xFF181717,
                        ),
                        foregroundColor:
                            Colors.white,
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            18,
                          ),
                        ),
                      ),

                      icon: const Icon(
                        Icons
                            .videocam_rounded,
                        size: 28,
                      ),

                      label: const Text(
                        'GRAVAR',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  const Text(
                    'O vídeo utilizará automaticamente as configurações deste evento.',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfigRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ConfigRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,

          decoration: BoxDecoration(
            color:
                const Color(0xFFF3F3F3),
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),

          child: Icon(
            icon,
            size: 21,
            color:
                const Color(0xFF181717),
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(width: 12),

        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ],
    );
  }
}