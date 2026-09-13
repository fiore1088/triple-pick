class MovieModel {
  final int id;
  final String title;
  final String? originalTitle;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double? voteAverage;
  final int? voteCount;
  final String? releaseDate;
  final List<int> genreIds;
  final double? popularity;
  final String? mediaType;
  final String? platformName;
  final int? providerId;
  final String? providerLogoPath;
  final String? watchLink;
  final String? flatrateType;

  const MovieModel({
    required this.id,
    required this.title,
    this.originalTitle, this.overview, this.posterPath, this.backdropPath,
    this.voteAverage, this.voteCount, this.releaseDate,
    this.genreIds = const [], this.popularity, this.mediaType,
    this.platformName, this.providerId, this.providerLogoPath, this.watchLink, this.flatrateType,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? '',
      originalTitle: json['original_title'] ?? json['original_name'],
      overview: json['overview'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'],
      releaseDate: json['release_date'] ?? json['first_air_date'],
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      popularity: (json['popularity'] ?? 0).toDouble(),
      mediaType: json['media_type'],
    );
  }

  factory MovieModel.fromSearchJson(Map<String, dynamic> json, {String? mediaType}) {
    return MovieModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? '',
      originalTitle: json['original_title'] ?? json['original_name'],
      overview: json['overview'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'],
      releaseDate: json['release_date'] ?? json['first_air_date'],
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      popularity: (json['popularity'] ?? 0).toDouble(),
      mediaType: mediaType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 'title': title, 'original_title': originalTitle, 'overview': overview,
      'poster_path': posterPath, 'backdrop_path': backdropPath, 'vote_average': voteAverage,
      'vote_count': voteCount, 'release_date': releaseDate, 'genre_ids': genreIds,
      'popularity': popularity, 'media_type': mediaType,
    };
  }

  MovieModel copyWith({
    int? id, String? title, String? originalTitle, String? overview, String? posterPath,
    String? backdropPath, double? voteAverage, int? voteCount, String? releaseDate,
    List<int>? genreIds, double? popularity, String? mediaType, String? platformName,
    int? providerId, String? providerLogoPath, String? watchLink, String? flatrateType,
  }) {
    return MovieModel(
      id: id ?? this.id, title: title ?? this.title, originalTitle: originalTitle ?? this.originalTitle,
      overview: overview ?? this.overview, posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath, voteAverage: voteAverage ?? this.voteAverage,
      voteCount: voteCount ?? this.voteCount, releaseDate: releaseDate ?? this.releaseDate,
      genreIds: genreIds ?? this.genreIds, popularity: popularity ?? this.popularity,
      mediaType: mediaType ?? this.mediaType, platformName: platformName ?? this.platformName,
      providerId: providerId ?? this.providerId, providerLogoPath: providerLogoPath ?? this.providerLogoPath,
      watchLink: watchLink ?? this.watchLink, flatrateType: flatrateType ?? this.flatrateType,
    );
  }

  int? get year {
    if (releaseDate == null || releaseDate!.isEmpty) return null;
    try { return int.parse(releaseDate!.substring(0, 4)); } catch (_) { return null; }
  }

  String get posterUrl => 'https://image.tmdb.org/t/p/w500$posterPath';
  String get backdropUrl => 'https://image.tmdb.org/t/p/w780$backdropPath';
  bool get hasWatchProvider => platformName != null && watchLink != null;

  @override
  String toString() => 'MovieModel(id: $id, title: $title, platform: $platformName)';
  @override
  bool operator ==(Object other) => identical(this, other) || other is MovieModel && runtimeType == other.runtimeType && id == other.id;
  @override
  int get hashCode => id.hashCode;
}