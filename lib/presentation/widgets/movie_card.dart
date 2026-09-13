import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/api_constants.dart';

class MovieCard extends StatelessWidget {
  final int rank;
  final String title;
  final int year;
  final String overview;
  final String posterPath;
  final double voteAverage;
  final String platform;
  final List<String> genres;
  final int runtime;
  final String? watchLink;
  final VoidCallback? onTap;

  const MovieCard({super.key, this.rank = 0, required this.title, required this.year, required this.overview, required this.posterPath, required this.voteAverage, required this.platform, required this.genres, required this.runtime, this.watchLink, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 240,
        decoration: AppTheme.cardDecoration.copyWith(border: rank == 1 ? Border.all(color: AppTheme.primaryColor.withOpacity(0.5), width: 2) : null),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(width: 150, height: 240, child: Stack(fit: StackFit.expand, children: [
              CachedNetworkImage(imageUrl: posterPath.isNotEmpty ? '\${ApiConstants.tmdbImageBaseUrl}\${ApiConstants.tmdbImageMedium}\$posterPath' : '', fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: AppTheme.surfaceColor, child: const Center(child: Icon(Icons.movie, color: AppTheme.textMutedColor, size: 40))),
                errorWidget: (context, url, error) => Container(color: AppTheme.surfaceColor, child: const Center(child: Icon(Icons.error_outline, color: AppTheme.errorColor, size: 40)))),
              Positioned(bottom: 0, left: 0, right: 0, height: 80, child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.9)])))),
              if (rank > 0) Positioned(top: 10, left: 10, child: Container(width: 36, height: 36, decoration: BoxDecoration(color: rank == 1 ? AppTheme.primaryColor : rank == 2 ? AppTheme.secondaryColor : const Color(0xFF6B7280), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 3))]), child: Center(child: Text('\$rank', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))))),
              Positioned(bottom: 10, left: 10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: _getPlatformColor(platform).withOpacity(0.95), borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: _getPlatformColor(platform).withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))]), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(_getPlatformIcon(platform), color: Colors.white, size: 12), const SizedBox(width: 4), Text(platform, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))]))),
            ])),
            Expanded(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(year > 0 ? '\$title (\$year)' : title, style: AppTheme.headlineSmall.copyWith(fontSize: 17), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              Row(children: [
                if (voteAverage > 0) ...[Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), decoration: BoxDecoration(color: AppTheme.warningColor.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.star, color: AppTheme.warningColor, size: 12), const SizedBox(width: 4), Text(voteAverage.toStringAsFixed(1), style: TextStyle(color: AppTheme.warningColor, fontSize: 12, fontWeight: FontWeight.bold))])), const SizedBox(width: 10)],
                if (runtime > 0) ...[Icon(Icons.access_time, color: AppTheme.textMutedColor, size: 14), const SizedBox(width: 4), Text(_formatRuntime(runtime), style: AppTheme.bodySmall)],
              ]),
              const SizedBox(height: 10),
              if (genres.isNotEmpty) Wrap(spacing: 6, runSpacing: 6, children: genres.take(3).map((genre) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppTheme.textMutedColor.withOpacity(0.2))), child: Text(genre, style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 11)))).toList()),
              const SizedBox(height: 10),
              Expanded(child: Text(overview, style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondaryColor, height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis)),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: onTap, icon: Icon(Icons.play_circle_fill, color: Colors.white, size: 18), label: Text('Guarda su \$platform', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)), style: ElevatedButton.styleFrom(backgroundColor: _getPlatformColor(platform), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
            ]))),
          ],
        ),
      ),
    );
  }

  String _formatRuntime(int minutes) { final hours = minutes ~/ 60; final mins = minutes % 60; return hours > 0 ? '\${hours}h \${mins}min' : '\${mins}min'; }

  Color _getPlatformColor(String platform) {
    switch (platform) {
      case 'Netflix': return const Color(0xFFE50914);
      case 'Prime Video': return const Color(0xFF00A8E1);
      case 'Disney+': return const Color(0xFF113CCF);
      case 'Apple TV+': return const Color(0xFF555555);
      case '.now': return const Color(0xFF6B2D8B);
      case 'Infinity': return const Color(0xFFE4002B);
      default: return AppTheme.textSecondaryColor;
    }
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform) {
      case 'Apple TV+': return Icons.apple;
      default: return Icons.play_circle_fill;
    }
  }
}