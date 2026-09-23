import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../services/event_service.dart';

class EditEventConfigScreen extends StatefulWidget {
  final String eventName;
  final Map<String, dynamic> config;

  const EditEventConfigScreen({
    super.key,
    required this.eventName,
    required this.config,
  });

  @override
  State<EditEventConfigScreen> createState() =>
      _EditEventConfigScreenState();
}

class _EditEventConfigScreenState
    extends State<EditEventConfigScreen> {
  late final TokenStorage tokenStorage;
  late final ApiClient apiClient;
  late final EventService eventService;

  late double recordingDuration;

  late double startSpeed;
  late double middleSpeed;
  late double endSpeed;

  late bool reverse;
  late bool boomerang;

  late String resolution;
  late int fps;

  bool isSaving = false;

  final List<String> resolutions = [
    '720x1280',
    '1080x1920',
  ];

  final List<int> fpsOptions = [
    30,
    60,
  ];

  @override
  void initState() {
    super.initState();

    tokenStorage = TokenStorage();

    apiClient = ApiClient(
      tokenStorage: tokenStorage,
    );

    eventService = EventService(
      apiClient: apiClient,
    );

    recordingDuration =
        double.tryParse(
          widget.config['recording_duration'].toString(),
        ) ??
        10;

    startSpeed =
        double.tryParse(
          widget.config['start_speed'].toString(),
        ) ??
        1.0;

    middleSpeed =
        double.tryParse(
          widget.config['middle_speed'].toString(),
        ) ??
        0.5;

    endSpeed =
        double.tryParse(
          widget.config['end_speed'].toString(),
        ) ??
        1.0;

    reverse = widget.config['reverse'] == true;

    boomerang = widget.config['boomerang'] == true;

    resolution =
        widget.config['resolution']?.toString() ??
        '1080x1920';

    fps =
        int.tryParse(
          widget.config['fps'].toString(),
        ) ??
        60;

    if (!resolutions.contains(resolution)) {
      resolutions.add(resolution);
    }

    if (!fpsOptions.contains(fps)) {
      fpsOptions.add(fps);
      fpsOptions.sort();
    }
  }

  String formatSpeed(double value) {
    return '${value.toStringAsFixed(2)}x';
  }

  Future<void> saveConfig() async {
    final configId = widget.config['id'];

    if (configId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível identificar a configuração deste evento.',
          ),
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final updatedConfig =
          await eventService.updateEventConfig(
        configId: configId,
        recordingDuration:
            recordingDuration.round(),
        startSpeed: startSpeed,
        middleSpeed: middleSpeed,
        endSpeed: endSpeed,
        reverse: reverse,
        boomerang: boomerang,
        resolution: resolution,
        fps: fps,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(
        updatedConfig,
      );
    } on DioException catch (error) {
      if (!mounted) {
        return;
      }

      String message =
          'Não foi possível salvar a configuração.';

      if (error.response?.statusCode == 400) {
        message =
            'Alguma configuração enviada é inválida.';
      } else if (error.response?.statusCode == 401) {
        message =
            'Sua sessão expirou. Faça login novamente.';
      } else if (error.type ==
          DioExceptionType.connectionError) {
        message =
            'Não foi possível conectar ao servidor.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ocorreu um erro inesperado.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        surfaceTintColor: Colors.transparent,
        elevation: 0,

        title: const Text(
          'Editar configuração',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            40,
          ),

          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,

                children: [
                  Text(
                    widget.eventName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Estas configurações serão usadas nos próximos vídeos deste evento.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 28),

                  _SectionCard(
                    title: 'Gravação',
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,

                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Duração da gravação',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ),

                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFF1F1F1,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                  12,
                                ),
                              ),
                              child: Text(
                                '${recordingDuration.round()} s',
                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),

                        Slider(
                          value: recordingDuration,
                          min: 3,
                          max: 15,
                          divisions: 12,
                          label:
                              '${recordingDuration.round()} segundos',
                          onChanged: isSaving
                              ? null
                              : (value) {
                                  setState(() {
                                    recordingDuration =
                                        value;
                                  });
                                },
                        ),

                        const Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Text(
                              '3 s',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '15 s',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  _SectionCard(
                    title: 'Velocidade',
                    child: Column(
                      children: [
                        _SpeedSlider(
                          title: 'Início',
                          value: startSpeed,
                          onChanged: isSaving
                              ? null
                              : (value) {
                                  setState(() {
                                    startSpeed = value;
                                  });
                                },
                        ),

                        const SizedBox(height: 22),

                        _SpeedSlider(
                          title: 'Meio',
                          value: middleSpeed,
                          onChanged: isSaving
                              ? null
                              : (value) {
                                  setState(() {
                                    middleSpeed = value;
                                  });
                                },
                        ),

                        const SizedBox(height: 22),

                        _SpeedSlider(
                          title: 'Fim',
                          value: endSpeed,
                          onChanged: isSaving
                              ? null
                              : (value) {
                                  setState(() {
                                    endSpeed = value;
                                  });
                                },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  _SectionCard(
                    title: 'Efeitos',
                    child: Column(
                      children: [
                        SwitchListTile.adaptive(
                          contentPadding:
                              EdgeInsets.zero,
                          title: const Text(
                            'Reverse',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                          subtitle: const Text(
                            'Reproduz o movimento também em sentido inverso.',
                          ),
                          value: reverse,
                          onChanged: isSaving
                              ? null
                              : (value) {
                                  setState(() {
                                    reverse = value;
                                  });
                                },
                        ),

                        const Divider(),

                        SwitchListTile.adaptive(
                          contentPadding:
                              EdgeInsets.zero,
                          title: const Text(
                            'Boomerang',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                          subtitle: const Text(
                            'Cria um efeito contínuo de ida e volta.',
                          ),
                          value: boomerang,
                          onChanged: isSaving
                              ? null
                              : (value) {
                                  setState(() {
                                    boomerang = value;
                                  });
                                },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  _SectionCard(
                    title: 'Qualidade',
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,

                      children: [
                        const Text(
                          'Resolução',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        DropdownButtonFormField<String>(
                          initialValue: resolution,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor:
                                const Color(
                              0xFFF5F5F5,
                            ),
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                14,
                              ),
                              borderSide:
                                  BorderSide.none,
                            ),
                          ),
                          items: resolutions
                              .map(
                                (value) =>
                                    DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                          onChanged: isSaving
                              ? null
                              : (value) {
                                  if (value == null) {
                                    return;
                                  }

                                  setState(() {
                                    resolution = value;
                                  });
                                },
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'FPS',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        DropdownButtonFormField<int>(
                          initialValue: fps,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor:
                                const Color(
                              0xFFF5F5F5,
                            ),
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                14,
                              ),
                              borderSide:
                                  BorderSide.none,
                            ),
                          ),
                          items: fpsOptions
                              .map(
                                (value) =>
                                    DropdownMenuItem(
                                  value: value,
                                  child: Text(
                                    '$value FPS',
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: isSaving
                              ? null
                              : (value) {
                                  if (value == null) {
                                    return;
                                  }

                                  setState(() {
                                    fps = value;
                                  });
                                },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    height: 58,
                    child: ElevatedButton(
                      onPressed:
                          isSaving ? null : saveConfig,

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF181717),
                        foregroundColor:
                            Colors.white,
                        disabledBackgroundColor:
                            const Color(0xFF181717),
                        disabledForegroundColor:
                            Colors.white,
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),
                        ),
                      ),

                      child: isSaving
                          ? const SizedBox(
                              width: 23,
                              height: 23,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'SALVAR CONFIGURAÇÃO',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight:
                                    FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
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

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,

        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 18),

          child,
        ],
      ),
    );
  }
}

class _SpeedSlider extends StatelessWidget {
  final String title;
  final double value;
  final ValueChanged<double>? onChanged;

  const _SpeedSlider({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,

      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 6,
              ),

              decoration: BoxDecoration(
                color: const Color(0xFFF1F1F1),
                borderRadius:
                    BorderRadius.circular(10),
              ),

              child: Text(
                '${value.toStringAsFixed(2)}x',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),

        Slider(
          value: value.clamp(0.10, 2.00),
          min: 0.10,
          max: 2.00,
          divisions: 19,
          label:
              '${value.toStringAsFixed(2)}x',
          onChanged: onChanged,
        ),

        const Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0.10x',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
            Text(
              '1.00x',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
            Text(
              '2.00x',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}