// lib/services/entertainment_service.dart

import 'package:tmdb_api/tmdb_api.dart';

// --- Data Models ---

class CastMember {
  final int id;
  final String name;
  final String character;
  final String? profileUrl;

  CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profileUrl,
  });
}

class ActorDetails extends CastMember {
  final String? biography;
  final List<EntertainmentItem> knownFor;

  ActorDetails({
    required super.id,
    required super.name,
    super.profileUrl,
    this.biography,
    this.knownFor = const [],
  }) : super(character: '');
}

class EntertainmentItem {
  final int id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String overview;
  final double voteAverage;
  final int voteCount;

  EntertainmentItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    required this.overview,
    required this.voteAverage,
    required this.voteCount,
  });
}

class EntertainmentService {
  static const String _tmdbApiKey = '46c9b3e9418440645f9d7187308c9769';
  static const String _tmdbAccessToken = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0NmM5YjNlOTQxODQ0MDY0NWY5ZDcxODczMDhjOTc2OSIsIm5iZiI6MTc1NTUxNzkzNC4zMzYsInN1YiI6IjY4YTMxM2VlNzM1MWE4YmJjMjAyZDcwNiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.d36QAqjKdNzktLfErbXeOHJDWFEfukmSiHPLMWJzesw';

  late final TMDB _tmdb;
  final String _imageUrlPrefix = 'https://image.tmdb.org/t/p/w500';

  EntertainmentService() {
    _tmdb = TMDB(
      ApiKeys(_tmdbApiKey, _tmdbAccessToken),
      logConfig: const ConfigLogger(showLogs: false, showErrorLogs: true),
    );
  }

  List<EntertainmentItem> _processResults(List results, {bool isMovie = true}) {
    return results.where((item) => item['poster_path'] != null).map((item) {
      return EntertainmentItem(
        id: item['id'],
        title: item[isMovie ? 'title' : 'name'] ?? 'No Title',
        subtitle: item[isMovie ? 'release_date' : 'first_air_date'] != null
            ? 'Release: ${item[isMovie ? 'release_date' : 'first_air_date']}'
            : '',
        imageUrl: '$_imageUrlPrefix${item['poster_path']}',
        overview: item['overview'] ?? 'No overview available.',
        voteAverage: (item['vote_average'] as num?)?.toDouble() ?? 0.0,
        voteCount: item['vote_count'] as int? ?? 0,
      );
    }).toList();
  }
  
  Future<List<CastMember>> getMovieCast(int movieId) async {
    final response = await _tmdb.v3.movies.getCredits(movieId);
    final cast = response['cast'] as List;
    return cast
        .where((c) => c['profile_path'] != null)
        .map((c) => CastMember(
              id: c['id'],
              name: c['name'],
              character: c['character'],
              profileUrl: '$_imageUrlPrefix${c['profile_path']}',
            ))
        .toList();
  }
  
  Future<List<CastMember>> getTvShowCast(int seriesId) async {
    final response = await _tmdb.v3.tv.getCredits(seriesId);
    final cast = response['cast'] as List;
     return cast
        .where((c) => c['profile_path'] != null)
        .map((c) => CastMember(
              id: c['id'],
              name: c['name'],
              character: c['character'],
              profileUrl: '$_imageUrlPrefix${c['profile_path']}',
            ))
        .toList();
  }

  Future<ActorDetails> getActorDetails(int personId) async {
    final personDetails = await _tmdb.v3.people.getDetails(personId);
    final movieCredits = await _tmdb.v3.people.getMovieCredits(personId);
    final knownFor = _processResults(movieCredits['cast'] as List);

    return ActorDetails(
      id: personDetails['id'],
      name: personDetails['name'],
      biography: personDetails['biography'] ?? 'No biography available.',
      profileUrl: personDetails['profile_path'] != null ? '$_imageUrlPrefix${personDetails['profile_path']}' : null,
      knownFor: knownFor,
    );
  }

  // --- Main Fetch Methods (Corrected) ---
  Future<List<EntertainmentItem>> getPopularMovies() async {
    final response = await _tmdb.v3.movies.getPopular();
    return _processResults(response['results'] as List);
  }
  Future<List<EntertainmentItem>> getTopRatedMovies() async {
    final response = await _tmdb.v3.movies.getTopRated();
    return _processResults(response['results'] as List);
  }
  Future<List<EntertainmentItem>> getUpcomingMovies() async {
    final response = await _tmdb.v3.movies.getUpcoming();
    return _processResults(response['results'] as List);
  }
  Future<List<EntertainmentItem>> getNowPlayingMovies() async {
    final response = await _tmdb.v3.movies.getNowPlaying();
    return _processResults(response['results'] as List);
  }
  Future<List<EntertainmentItem>> getPopularTvShows() async {
    final response = await _tmdb.v3.tv.getPopular();
    return _processResults(response['results'] as List, isMovie: false);
  }
  Future<List<EntertainmentItem>> getTopRatedTvShows() async {
    final response = await _tmdb.v3.tv.getTopRated();
    return _processResults(response['results'] as List, isMovie: false);
  }
  Future<List<EntertainmentItem>> getOnTheAirTvShows() async {
    final response = await _tmdb.v3.tv.getOnTheAir();
    return _processResults(response['results'] as List, isMovie: false);
  }
  Future<List<EntertainmentItem>> getAiringTodayTvShows() async {
    final response = await _tmdb.v3.tv.getAiringToday();
    return _processResults(response['results'] as List, isMovie: false);
  }
}