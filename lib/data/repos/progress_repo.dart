import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase.dart';
import '../models/measurement.dart';

const _photoBucket = 'progress-photos';

final progressRepoProvider = Provider<ProgressRepo>((ref) => ProgressRepo());

/// Data-laag voor progress_measurements + progress_photos, met dezelfde
/// queries en storage-paden als KlantVoortgang.tsx.
class ProgressRepo {
  Future<Map<String, List<MeasurePoint>>> fetchMeasurements(
      String userId) async {
    final rows = await supabase
        .from('progress_measurements')
        .select('measure_key, value, measured_at')
        .eq('user_id', userId)
        .order('measured_at', ascending: true);
    final grouped = <String, List<MeasurePoint>>{};
    for (final row in rows) {
      final key = row['measure_key'] as String;
      (grouped[key] ??= []).add(MeasurePoint(
        DateTime.parse(row['measured_at'] as String),
        (row['value'] as num).toDouble(),
      ));
    }
    return grouped;
  }

  /// Meerdere waardes in één keer opslaan (zelfde measured_at).
  Future<void> addMeasurements(
      String userId, Map<String, double> values) async {
    if (values.isEmpty) return;
    final measuredAt = DateTime.now().toUtc().toIso8601String();
    await supabase.from('progress_measurements').insert([
      for (final e in values.entries)
        {
          'user_id': userId,
          'measure_key': e.key,
          'value': e.value,
          'measured_at': measuredAt,
        },
    ]);
  }

  Future<Map<String, List<PhotoItem>>> fetchPhotos(String userId) async {
    final rows = await supabase
        .from('progress_photos')
        .select('id, photo_key, storage_path, created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: true);
    final paths = [for (final r in rows) r['storage_path'] as String];
    final urlByPath = <String, String>{};
    if (paths.isNotEmpty) {
      final signed = await supabase.storage
          .from(_photoBucket)
          // ignore: deprecated_member_use
          .createSignedUrls(paths, 60 * 60);
      for (var i = 0; i < signed.length && i < paths.length; i++) {
        urlByPath[paths[i]] = signed[i].signedUrl;
      }
    }
    final result = <String, List<PhotoItem>>{
      for (final (key, _) in photoCategories) key: [],
    };
    for (final r in rows) {
      final key = r['photo_key'] as String;
      if (!result.containsKey(key)) continue;
      final path = r['storage_path'] as String;
      result[key]!.add(PhotoItem(
        id: r['id'] as String,
        path: path,
        url: urlByPath[path] ?? '',
      ));
    }
    return result;
  }

  /// Upload naar {user_id}/{photo_key}/{ts}-{rand}.{ext} — zelfde pad-
  /// structuur als de React-app (vereist door de storage-RLS-policies).
  Future<PhotoItem> addPhoto({
    required String userId,
    required String photoKey,
    required Uint8List bytes,
    required String ext,
    String contentType = 'image/jpeg',
  }) async {
    final rand = _randomSuffix();
    final path =
        '$userId/$photoKey/${DateTime.now().millisecondsSinceEpoch}-$rand.$ext';
    await supabase.storage.from(_photoBucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: false),
        );
    final row = await supabase
        .from('progress_photos')
        .insert({
          'user_id': userId,
          'photo_key': photoKey,
          'storage_path': path,
        })
        .select('id')
        .single();
    final signed = await supabase.storage
        .from(_photoBucket)
        .createSignedUrl(path, 60 * 60);
    return PhotoItem(id: row['id'] as String, path: path, url: signed);
  }

  String _randomSuffix() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rnd = math.Random();
    return List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
  }
}
