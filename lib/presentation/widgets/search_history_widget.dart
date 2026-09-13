import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/local_storage_service.dart';
import '../providers/user_provider.dart';

class SearchHistoryWidget extends ConsumerWidget {
  final Function(String query, List<String> platforms) onSearchTap;
  final VoidCallback? onClearAll;
  const SearchHistoryWidget({super.key, required this.onSearchTap, this.onClearAll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPrefs = ref.watch(userPreferencesProvider);
    final history = userPrefs.searchHistory;
    if (history.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Ricerche recenti', style: AppTheme.bodySmall.copyWith(color: AppTheme.textMutedColor)),
        if (onClearAll != null) TextButton(onPressed: () { _showClearDialog(context, ref); }, child: Text('Cancella tutto', style: AppTheme.bodySmall.copyWith(color: AppTheme.errorColor))),
      ]),
      const SizedBox(height: 8),
      SizedBox(height: 40, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: history.length, separatorBuilder: (context, index) => const SizedBox(width: 8), itemBuilder: (context, index) {
        final item = history[index];
        return _buildHistoryChip(context, item, () => onSearchTap(item.query, item.platforms));
      })),
    ]);
  }

  Widget _buildHistoryChip(BuildContext context, SearchHistoryItem item, VoidCallback onTap) {
    final dateFormat = DateFormat('dd/MM HH:mm');
    final timeStr = dateFormat.format(item.timestamp);
    return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.textMutedColor.withOpacity(0.2))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.history, size: 14, color: AppTheme.textMutedColor), const SizedBox(width: 6), Text(item.query, style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondaryColor), maxLines: 1, overflow: TextOverflow.ellipsis), const SizedBox(width: 6), Text(timeStr, style: AppTheme.bodySmall.copyWith(color: AppTheme.textMutedColor, fontSize: 10))])));
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (context) => AlertDialog(backgroundColor: AppTheme.surfaceColor, title: const Text('Cancella storico', style: TextStyle(color: AppTheme.textPrimaryColor)), content: const Text('Vuoi cancellare tutte le ricerche recenti?', style: TextStyle(color: AppTheme.textSecondaryColor)), actions: [
      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annulla')),
      TextButton(onPressed: () async { await ref.read(userPreferencesProvider.notifier).clearHistory(); if (context.mounted) Navigator.of(context).pop(); onClearAll?.call(); }, child: const Text('Cancella', style: TextStyle(color: AppTheme.errorColor))),
    ]));
  }
}