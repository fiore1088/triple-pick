import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../providers/user_provider.dart';

class ExcludedTitlesWidget extends ConsumerWidget {
  final VoidCallback? onTitleRemoved;
  const ExcludedTitlesWidget({super.key, this.onTitleRemoved});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPrefs = ref.watch(userPreferencesProvider);
    final excludedIds = userPrefs.excludedTitles;
    if (excludedIds.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Titoli esclusi (${excludedIds.length})', style: AppTheme.bodySmall.copyWith(color: AppTheme.textMutedColor)),
        TextButton(onPressed: () => _showClearDialog(context, ref), child: Text('Ripristina tutti', style: AppTheme.bodySmall.copyWith(color: AppTheme.secondaryColor))),
      ]),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: excludedIds.map((movieId) => _buildExcludedChip(context, ref, movieId)).toList()),
    ]);
  }

  Widget _buildExcludedChip(BuildContext context, WidgetRef ref, int movieId) {
    return Chip(label: Text('Film #$movieId', style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12)), deleteIcon: const Icon(Icons.close, size: 16, color: AppTheme.textMutedColor), onDeleted: () async { await ref.read(userPreferencesProvider.notifier).removeExcludedTitle(movieId); onTitleRemoved?.call(); }, backgroundColor: AppTheme.surfaceColor, side: BorderSide(color: AppTheme.errorColor.withOpacity(0.3)));
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (context) => AlertDialog(backgroundColor: AppTheme.surfaceColor, title: const Text('Ripristina esclusioni', style: TextStyle(color: AppTheme.textPrimaryColor)), content: const Text('Vuoi rimuovere tutti i titoli esclusi?', style: TextStyle(color: AppTheme.textSecondaryColor)), actions: [
      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annulla')),
      TextButton(onPressed: () async { await ref.read(userPreferencesProvider.notifier).clearExclusions(); if (context.mounted) Navigator.of(context).pop(); }, child: const Text('Ripristina', style: TextStyle(color: AppTheme.secondaryColor))),
    ]));
  }
}