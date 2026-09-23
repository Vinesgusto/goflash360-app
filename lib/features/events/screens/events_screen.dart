import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../services/event_service.dart';
import 'event_detail_screen.dart';

class EventsScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const EventsScreen({
    super.key,
    required this.user,
  });

  @override
  State<EventsScreen> createState() =>
      _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late final TokenStorage tokenStorage;
  late final ApiClient apiClient;
  late final EventService eventService;

  bool isLoading = true;

  String? errorMessage;

  List<Map<String, dynamic>> events = [];

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

    loadEvents();
  }

  Future<void> loadEvents() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final loadedEvents =
          await eventService.getEvents();

      if (!mounted) {
        return;
      }

      setState(() {
        events = loadedEvents;
      });
    } on DioException catch (error) {
      if (!mounted) {
        return;
      }

      String message =
          'Não foi possível carregar os eventos.';

      if (error.response?.statusCode == 401) {
        message =
            'Sua sessão expirou. Faça login novamente.';
      } else if (error.type ==
          DioExceptionType.connectionError) {
        message =
            'Não foi possível conectar ao servidor.';
      }

      setState(() {
        errorMessage = message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        errorMessage =
            'Ocorreu um erro inesperado.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String getDisplayName() {
    final firstName =
        widget.user['first_name'];

    if (firstName != null &&
        firstName.toString().trim().isNotEmpty) {
      return firstName.toString();
    }

    return widget.user['username']
            ?.toString() ??
        'Usuário';
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

  void openEvent(
    Map<String, dynamic> event,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EventDetailScreen(
          event: event,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Go Flash 360',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed:
                isLoading ? null : loadEvents,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadEvents,

          child: CustomScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),

            slivers: [
              SliverPadding(
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  10,
                ),

                sliver:
                    SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        'Olá, ${getDisplayName()}!',
                        style:
                            const TextStyle(
                          fontSize: 28,
                          fontWeight:
                              FontWeight.w800,
                          color:
                              Color(0xFF181717),
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      const Text(
                        'Selecione um evento para começar.',
                        style: TextStyle(
                          fontSize: 15,
                          color:
                              Color(0xFF777777),
                        ),
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Meus eventos',
                              style:
                                  TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ),

                          if (!isLoading)
                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    Colors.white,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  20,
                                ),
                              ),
                              child: Text(
                                '${events.length}',
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              if (isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child:
                        CircularProgressIndicator(),
                  ),
                )
              else if (errorMessage != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        32,
                      ),
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons
                                .cloud_off_rounded,
                            size: 56,
                            color: Colors.grey,
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          Text(
                            errorMessage!,
                            textAlign:
                                TextAlign.center,
                            style:
                                const TextStyle(
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          ElevatedButton.icon(
                            onPressed:
                                loadEvents,
                            icon: const Icon(
                              Icons
                                  .refresh_rounded,
                            ),
                            label:
                                const Text(
                              'Tentar novamente',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (events.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding:
                          EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Icon(
                            Icons
                                .event_busy_outlined,
                            size: 60,
                            color: Colors.grey,
                          ),

                          SizedBox(
                            height: 16,
                          ),

                          Text(
                            'Nenhum evento encontrado.',
                            style:
                                TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),

                          SizedBox(
                            height: 8,
                          ),

                          Text(
                            'Seus eventos aparecerão aqui.',
                            textAlign:
                                TextAlign.center,
                            style:
                                TextStyle(
                              color:
                                  Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    20,
                    10,
                    20,
                    30,
                  ),

                  sliver:
                      SliverList.separated(
                    itemCount:
                        events.length,

                    separatorBuilder:
                        (_, _) {
                      return const SizedBox(
                        height: 14,
                      );
                    },

                    itemBuilder:
                        (context, index) {
                      final event =
                          events[index];

                      final String name =
                          event['name']
                                  ?.toString() ??
                              'Evento sem nome';

                      final String date =
                          formatDate(
                        event['event_date'],
                      );

                      final bool
                          isActive =
                          event['is_active'] ==
                              true;

                      return Material(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),

                        child: InkWell(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            18,
                          ),

                          onTap: () {
                            openEvent(event);
                          },

                          child: Padding(
                            padding:
                                const EdgeInsets
                                    .all(
                              18,
                            ),

                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,

                                  decoration:
                                      BoxDecoration(
                                    color:
                                        const Color(
                                      0xFFF1F1F1,
                                    ),
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      14,
                                    ),
                                  ),

                                  child:
                                      const Icon(
                                    Icons
                                        .celebration_outlined,
                                    color:
                                        Color(
                                      0xFF181717,
                                    ),
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
                                        name,
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow
                                                .ellipsis,
                                        style:
                                            const TextStyle(
                                          fontSize:
                                              17,
                                          fontWeight:
                                              FontWeight
                                                  .w700,
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 5,
                                      ),

                                      Row(
                                        children: [
                                          const Icon(
                                            Icons
                                                .calendar_today_outlined,
                                            size: 14,
                                            color:
                                                Colors.grey,
                                          ),

                                          const SizedBox(
                                            width: 6,
                                          ),

                                          Text(
                                            date,
                                            style:
                                                const TextStyle(
                                              color:
                                                  Colors.grey,
                                              fontSize:
                                                  13,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(
                                        height: 8,
                                      ),

                                      Text(
                                        isActive
                                            ? 'Ativo'
                                            : 'Inativo',
                                        style:
                                            TextStyle(
                                          fontSize:
                                              12,
                                          fontWeight:
                                              FontWeight
                                                  .w600,
                                          color:
                                              isActive
                                                  ? Colors
                                                      .green
                                                  : Colors
                                                      .grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Icon(
                                  Icons
                                      .chevron_right_rounded,
                                  size: 28,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}