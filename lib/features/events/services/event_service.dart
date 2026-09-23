import '../../../core/api/api_client.dart';

class EventService {
  final ApiClient apiClient;

  EventService({
    required this.apiClient,
  });

  Future<List<Map<String, dynamic>>> getEvents() async {
    final response = await apiClient.dio.get(
      'events/',
    );

    final data = response.data;

    if (data is List) {
      return data
          .map(
            (event) => Map<String, dynamic>.from(event),
          )
          .toList();
    }

    if (data is Map && data['results'] is List) {
      return (data['results'] as List)
          .map(
            (event) => Map<String, dynamic>.from(event),
          )
          .toList();
    }

    return [];
  }

  Future<Map<String, dynamic>> updateEventConfig({
    required dynamic configId,
    required int recordingDuration,
    required double startSpeed,
    required double middleSpeed,
    required double endSpeed,
    required bool reverse,
    required bool boomerang,
    required String resolution,
    required int fps,
  }) async {
    final response = await apiClient.dio.patch(
      'event-configs/$configId/',
      data: {
        'recording_duration': recordingDuration,
        'start_speed': startSpeed.toStringAsFixed(2),
        'middle_speed': middleSpeed.toStringAsFixed(2),
        'end_speed': endSpeed.toStringAsFixed(2),
        'reverse': reverse,
        'boomerang': boomerang,
        'resolution': resolution,
        'fps': fps,
      },
    );

    return Map<String, dynamic>.from(
      response.data,
    );
  }
}