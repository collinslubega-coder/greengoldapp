// lib/screens/profile/views/components/featured_track_player.dart

import 'package:flutter/material.dart';
import 'package:green_gold/components/network_image_with_loader.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/services/music_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:home_widget/home_widget.dart';

class FeaturedTrackPlayer extends StatefulWidget {
  const FeaturedTrackPlayer({super.key});

  @override
  State<FeaturedTrackPlayer> createState() => _FeaturedTrackPlayerState();
}

class _FeaturedTrackPlayerState extends State<FeaturedTrackPlayer> with WidgetsBindingObserver {
  final MusicService _musicService = MusicService();
  late AudioPlayer _audioPlayer;
  Future<List<MusicTrack>>? _playlistFuture;

  @override
  void initState() {
    super.initState();
    _audioPlayer = Provider.of<AudioPlayer>(context, listen: false);
    
    WidgetsBinding.instance.addObserver(this);
    _playlistFuture = _loadAndPreparePlaylist();

    _audioPlayer.playerStateStream.listen((_) => _updateWidget());
    _audioPlayer.sequenceStateStream.listen((_) => _updateWidget());
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _savePlayerState();
    }
  }

  Future<void> _updateWidget() async {
    final mediaItem = _audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
    await HomeWidget.saveWidgetData<String>('track_title', mediaItem?.title ?? "Select a Song");
    await HomeWidget.saveWidgetData<String>('track_artist', mediaItem?.artist ?? "Green Gold");
    await HomeWidget.saveWidgetData<String>('artwork_url', mediaItem?.artUri?.toString() ?? '');
    await HomeWidget.updateWidget(name: 'MusicWidgetProvider', iOSName: 'MusicWidgetProvider');
  }

  Future<List<MusicTrack>> _loadAndPreparePlaylist() async {
    try {
      final playlist = await _musicService.getActivePlaylist();
      if (playlist.isNotEmpty) {
        final audioSources = playlist
            .where((track) => track.publicUrl != null)
            .map((track) => AudioSource.uri(
                  Uri.parse(track.publicUrl!),
                  tag: MediaItem(
                    id: track.id.toString(),
                    title: track.title,
                    artist: track.artist ?? 'Unknown Artist',
                    artUri: track.artworkUrl != null ? Uri.parse(track.artworkUrl!) : null,
                  ),
                ))
            .toList();
        
        if (audioSources.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          final lastIndex = prefs.getInt('lastTrackIndex') ?? 0;
          final lastPosition = Duration(milliseconds: prefs.getInt('lastTrackPosition') ?? 0);

          if (_audioPlayer.audioSource == null) {
              await _audioPlayer.setAudioSource(
                ConcatenatingAudioSource(children: audioSources),
                initialIndex: lastIndex,
                initialPosition: lastPosition,
                preload: false,
              );
              _audioPlayer.setLoopMode(LoopMode.all);
          }
        }
      }
      return playlist;
    } catch (e) {
      debugPrint("Error loading playlist: $e");
      return [];
    }
  }

  Future<void> _savePlayerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastTrackIndex', _audioPlayer.currentIndex ?? 0);
    await prefs.setInt('lastTrackPosition', _audioPlayer.position.inMilliseconds);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _savePlayerState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MusicTrack>>(
      future: _playlistFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(padding: EdgeInsets.all(defaultPadding), child: Text("Loading Vibe...")),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink(); 
        }
        
        return Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Today's Vibe", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: defaultPadding),
                StreamBuilder<SequenceState?>(
                  stream: _audioPlayer.sequenceStateStream,
                  builder: (context, snapshot) {
                    final state = snapshot.data;
                    if (state?.sequence.isEmpty ?? true) return const SizedBox.shrink();
                    final mediaItem = state!.currentSource!.tag as MediaItem;
                    return Row(
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: NetworkImageWithLoader(mediaItem.artUri?.toString(), radius: 8),
                        ),
                        const SizedBox(width: defaultPadding),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(mediaItem.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(mediaItem.artist ?? 'Unknown Artist', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                ),
                const SizedBox(height: 8),
                StreamBuilder<PlayerState>(
                  stream: _audioPlayer.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final playing = playerState?.playing ?? false;
                    final processingState = playerState?.processingState;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous),
                          onPressed: _audioPlayer.hasPrevious ? _audioPlayer.seekToPrevious : null,
                        ),
                        if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering)
                          const SizedBox(width: 48, height: 48, child: Center(child: CircularProgressIndicator()))
                        else
                          IconButton(
                            iconSize: 48,
                            icon: Icon(playing ? Icons.pause_circle_filled : Icons.play_circle_filled),
                            onPressed: () => playing ? _audioPlayer.pause() : _audioPlayer.play(),
                          ),
                        IconButton(
                          icon: const Icon(Icons.skip_next),
                          onPressed: _audioPlayer.hasNext ? _audioPlayer.seekToNext : null,
                        ),
                      ],
                    );
                  }
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}