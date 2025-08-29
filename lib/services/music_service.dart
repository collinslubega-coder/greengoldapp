// lib/services/music_service.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class MusicTrack {
  final int id;
  final String title;
  final String? artist;
  final String storagePath;
  final bool isActive;
  final String? artworkUrl; // ** NEW: Artwork URL **
  String? publicUrl; 

  MusicTrack({
    required this.id,
    required this.title,
    this.artist,
    required this.storagePath,
    required this.isActive,
    this.artworkUrl, // ** NEW: Initialize in constructor **
    this.publicUrl,
  });

  factory MusicTrack.fromJson(Map<String, dynamic> json) {
    return MusicTrack(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      storagePath: json['storage_path'],
      isActive: json['is_active'],
      artworkUrl: json['artwork_url'], // ** NEW: Parse from JSON **
    );
  }
}

class MusicService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  // ** NEW: Method to upload artwork image **
  Future<String> uploadArtworkImage(File imageFile) async {
    try {
      final String fileName = 'artwork_${_uuid.v4()}.jpg';
      // Store artwork in a separate, public bucket for easier access
      final String path = fileName; 
      await _supabase.storage.from('music_artwork').upload(path, imageFile);
      // Return the public URL directly
      return _supabase.storage.from('music_artwork').getPublicUrl(path);
    } catch (e) {
      debugPrint('Error uploading artwork image: $e');
      rethrow;
    }
  }

  Future<List<MusicTrack>> getAllTracks() async {
    final response = await _supabase.from('music_tracks').select().order('created_at');
    return (response as List).map((data) => MusicTrack.fromJson(data)).toList();
  }

  Future<List<MusicTrack>> getActivePlaylist() async {
    final response = await _supabase
        .from('music_tracks')
        .select()
        .eq('is_active', true)
        .order('created_at');

    final tracks = (response as List).map((data) => MusicTrack.fromJson(data)).toList();

    for (var track in tracks) {
      final urlResponse = await _supabase.storage
          .from('music_tracks')
          .createSignedUrl(track.storagePath, 60 * 60); 
      track.publicUrl = urlResponse;
    }
    return tracks;
  }

  Future<void> uploadTrack({
    required File file,
    required String title,
    required String artist,
  }) async {
    final fileExtension = file.path.split('.').last;
    final fileName = '${_uuid.v4()}.$fileExtension';
    final filePath = 'public/$fileName';

    await _supabase.storage.from('music_tracks').upload(filePath, file);

    await _supabase.from('music_tracks').insert({
      'title': title,
      'artist': artist,
      'storage_path': filePath,
    });
  }

  Future<void> toggleTrackActivity(int trackId) async {
    await _supabase.rpc('toggle_track_activity', params: {'track_id_to_toggle': trackId});
  }

  // ** UPDATED: updateTrack now accepts an optional artworkUrl **
  Future<void> updateTrack({
    required int id,
    required String title,
    required String artist,
    String? artworkUrl,
  }) async {
    await _supabase.from('music_tracks').update({
      'title': title,
      'artist': artist,
      'artwork_url': artworkUrl, // Save the new URL
    }).eq('id', id);
  }

  Future<void> deleteTrack(MusicTrack track) async {
    // Also delete artwork if it exists
    if (track.artworkUrl != null) {
      final uri = Uri.parse(track.artworkUrl!);
      final fileName = uri.pathSegments.last;
      await _supabase.storage.from('music_artwork').remove([fileName]);
    }
    await _supabase.storage.from('music_tracks').remove([track.storagePath]);
    await _supabase.from('music_tracks').delete().eq('id', track.id);
  }
}