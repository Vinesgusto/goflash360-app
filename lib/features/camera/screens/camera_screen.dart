import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const CameraScreen({super.key, required this.event});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? cameraController;

  bool isInitializing = true;
  bool isRecording = false;

  String? errorMessage;

  int countdown = 0;
  int recordingSecondsLeft = 0;

  Timer? countdownTimer;
  Timer? recordingTimer;

  Map<String, dynamic>? get config {
    if (widget.event['config'] is Map) {
      return Map<String, dynamic>.from(widget.event['config']);
    }

    return null;
  }

  int get recordingDuration {
    final value = config?['recording_duration'];

    return int.tryParse(value?.toString() ?? '') ?? 10;
  }

  @override
  void initState() {
    super.initState();

    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        setState(() {
          errorMessage = 'Nenhuma câmera foi encontrada neste dispositivo.';
          isInitializing = false;
        });

        return;
      }

      CameraDescription selectedCamera = cameras.first;

      for (final camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          selectedCamera = camera;
          break;
        }
      }

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        cameraController = controller;
        isInitializing = false;
      });
    } on CameraException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        errorMessage =
            'Não foi possível iniciar a câmera: ${error.description ?? error.code}';

        isInitializing = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        errorMessage = 'Não foi possível iniciar a câmera.';
        isInitializing = false;
      });
    }
  }

  Future<void> startCountdown() async {
    if (cameraController == null ||
        !cameraController!.value.isInitialized ||
        isRecording ||
        countdown > 0) {
      return;
    }

    setState(() {
      countdown = 3;
    });

    countdownTimer?.cancel();

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (countdown > 1) {
        setState(() {
          countdown--;
        });

        return;
      }

      timer.cancel();

      setState(() {
        countdown = 0;
      });

      await startRecording();
    });
  }

  Future<void> startRecording() async {
    final controller = cameraController;

    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isRecordingVideo) {
      return;
    }

    try {
      await controller.startVideoRecording();

      if (!mounted) {
        return;
      }

      setState(() {
        isRecording = true;
        recordingSecondsLeft = recordingDuration;
      });

      recordingTimer?.cancel();

      recordingTimer = Timer.periodic(const Duration(seconds: 1), (
        timer,
      ) async {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (recordingSecondsLeft > 1) {
          setState(() {
            recordingSecondsLeft--;
          });

          return;
        }

        timer.cancel();

        setState(() {
          recordingSecondsLeft = 0;
        });

        await stopRecording();
      });
    } on CameraException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao iniciar gravação: ${error.description ?? error.code}',
          ),
        ),
      );
    }
  }

  Future<void> stopRecording() async {
    final controller = cameraController;

    if (controller == null || !controller.value.isRecordingVideo) {
      return;
    }

    recordingTimer?.cancel();

    try {
      final XFile video = await controller.stopVideoRecording();

      if (!mounted) {
        return;
      }

      setState(() {
        isRecording = false;
        recordingSecondsLeft = 0;
      });

      await showRecordingFinished(video);
    } on CameraException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isRecording = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao finalizar gravação: ${error.description ?? error.code}',
          ),
        ),
      );
    }
  }

  Future<void> showRecordingFinished(XFile video) async {
    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 64,
                  color: Colors.green,
                ),

                const SizedBox(height: 16),

                const Text(
                  'Gravação concluída!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 8),

                Text(
                  '${recordingDuration}s gravados com sucesso.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 8),

                Text(
                  video.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF181717),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'NOVA GRAVAÇÃO',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    recordingTimer?.cancel();

    cameraController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventName = widget.event['name']?.toString() ?? 'Evento';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (isInitializing)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            else if (errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.videocam_off_rounded,
                        color: Colors.white,
                        size: 60,
                      ),

                      const SizedBox(height: 20),

                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            errorMessage = null;
                            isInitializing = true;
                          });

                          initializeCamera();
                        },
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              )
            else if (cameraController != null)
              Center(child: CameraPreview(cameraController!)),

            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: isRecording || countdown > 0
                          ? null
                          : () {
                              Navigator.of(context).pop();
                            },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      eventName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  if (isRecording)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'GRAVANDO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            if (countdown > 0)
              Container(
                color: Colors.black.withValues(alpha: 0.30),
                child: Center(
                  child: Text(
                    '$countdown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 120,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),

            if (isRecording)
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '$recordingSecondsLeft',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),

            if (!isInitializing && errorMessage == null)
              Positioned(
                bottom: 28,
                left: 20,
                right: 20,
                child: Column(
                  children: [
                    if (!isRecording && countdown == 0)
                      Text(
                        'Gravação automática: ${recordingDuration}s',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                    const SizedBox(height: 14),

                    GestureDetector(
                      onTap: isRecording || countdown > 0
                          ? null
                          : startCountdown,
                      child: Container(
                        width: 86,
                        height: 86,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isRecording
                                ? Colors.red.shade700
                                : Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isRecording
                                ? Icons.stop_rounded
                                : Icons.videocam_rounded,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
