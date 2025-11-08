import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Singleton instance
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  // Get environment variables passed via --dart-define or fallback error
  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  // Initialize Supabase client once (should be called in main)
  static Future<void> initialize() async {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
          'SUPABASE_URL and SUPABASE_ANON_KEY must be defined via --dart-define.');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: false,
    );
  }

  // Get the Supabase client instance
  SupabaseClient get client => Supabase.instance.client;

  // Check connection by simple query
  Future<bool> isConnected() async {
    try {
      final response = await client.from('user_profiles').select('id').limit(1);
      return response != null;
    } catch (_) {
      return false;
    }
  }

  // Health check helper
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final startTime = DateTime.now();
      await client.from('user_profiles').select('id').limit(1);
      final endTime = DateTime.now();
      final responseTime = endTime.difference(startTime).inMilliseconds;

      return {
        'status': 'healthy',
        'response_time_ms': responseTime,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (error) {
      return {
        'status': 'unhealthy',
        'error': error.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  // Generic insert
  Future<List<dynamic>> insertRow(
      String table, Map<String, dynamic> data) async {
    try {
      final response = await client.from(table).insert(data).select();
      return response;
    } catch (error) {
      throw Exception('Insert failed for table $table: $error');
    }
  }

  // Generic select with filters, order, limit
  Future<List<dynamic>> selectRows(
  String table, {
  String columns = '*',
  Map<String, dynamic>? filters,
  String? orderBy,
  bool ascending = true,
  int? limit,
}) async {
  try {
    PostgrestFilterBuilder query = client.from(table).select(columns);

    if (filters != null && filters.isNotEmpty) {
      filters.forEach((column, value) {
        query = query.eq(column, value);
      });
    }

    PostgrestTransformBuilder transformedQuery = query;

    if (orderBy != null) {
      transformedQuery = transformedQuery.order(orderBy, ascending: ascending);
    }

    if (limit != null) {
      transformedQuery = transformedQuery.limit(limit);
    }

    final response = await transformedQuery;
    return response;
  } catch (error) {
    throw Exception('Select failed for table $table: $error');
  }
}

  // Generic update
  Future<List<dynamic>> updateRow(
    String table,
    Map<String, dynamic> data,
    String column,
    dynamic value,
  ) async {
    try {
      final response =
          await client.from(table).update(data).eq(column, value).select();
      return response;
    } catch (error) {
      throw Exception('Update failed for table $table: $error');
    }
  }

  // Generic delete
  Future<List<dynamic>> deleteRow(
    String table,
    String column,
    dynamic value,
  ) async {
    try {
      final response =
          await client.from(table).delete().eq(column, value).select();
      return response;
    } catch (error) {
      throw Exception('Delete failed for table $table: $error');
    }
  }

  // Realtime subscription helper
  RealtimeChannel subscribeToTable(
    String table, {
    String event = '*',
    required void Function(Map<String, dynamic>, [String?]) callback,
  }) {
    final channel = client.channel('public:$table')
  .on(
    RealtimeListenTypes.postgresChanges,
    ChannelFilter(event: event, schema: 'public', table: table),
    (payload, [ref]) => callback(payload, ref),
  );

channel.subscribe();

return channel;

  }

  // Unsubscribe helper
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await client.removeChannel(channel);
  }
}
  