import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/local_storage_service.dart';
import '../providers/user_provider.dart';

class FeedbackWidget extends ConsumerStatefulWidget {
  final int movieId;
  final String movieTitle;
  final VoidCallback? onExclude;
  const FeedbackWidget({super.key, required this.movieId, required this.movieTitle, this.onExclude});
  @override
  ConsumerState<FeedbackWidget> createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends ConsumerState<FeedbackWidget> {
  FeedbackType _currentFeedback = FeedbackType.none;

  @override
  void initState() { super.initState(); _loadFeedback(); }

  void _loadFeedback() {
    final userPrefs = ref.read(userPreferencesProvider);
    setState(() { _currentFeedback = userPrefs.feedback[widget.movieId] ?? FeedbackType.none; });
  }

  Future<void> _toggleFeedback(FeedbackType type) async {
    setState(() { _currentFeedback = _currentFeedback == type ? FeedbackType.none : type; });
    await ref.read(userPreferencesProvider.notifier).saveFeedback(widget.movieId, _currentFeedback);
  }

  Future<void> _excludeTitle() async {
    await ref.read(userPreferencesProvider.notifier).addExcludedTitle(widget.movieId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${widget.movieTitle} escluso dai prossimi consigli'), backgroundColor: AppTheme.secondaryColor, action: SnackBarAction(label: 'Annulla', textColor: AppTheme.textPrimaryColor, onPressed: () async { await ref.read(userPreferencesProvider.notifier).removeExcludedTitle(widget.movieId); })));
    }
    widget.onExclude?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      _buildFeedbackButton(icon: Icons.thumb_up, isActive: _currentFeedback == FeedbackType.like, activeColor: AppTheme.successColor, onPressed: () => _toggleFeedback(FeedbackType.like)),
      const SizedBox(width: 8),
      _buildFeedbackButton(icon: Icons.thumb_down, isActive: _currentFeedback == FeedbackType.dislike, activeColor: AppTheme.errorColor, onPressed: () => _toggleFeedback(FeedbackType.dislike)),
      const SizedBox(width: 8),
      _buildFeedbackButton(icon: Icons.block, isActive: false, activeColor: AppTheme.textMutedColor, onPressed: _excludeTitle, tooltip: 'Non mostrare piu'),
    ]);
  }

  Widget _buildFeedbackButton({required IconData icon, required bool isActive, required Color activeColor, required VoidCallback onPressed, String? tooltip}) {
    return Tooltip(message: tooltip ?? (isActive ? 'Rimuovi feedback' : 'Feedback'), child: Material(color: isActive ? activeColor.withOpacity(0.2) : AppTheme.surfaceColor, borderRadius: BorderRadius.circular(8), child: InkWell(onTap: onPressed, borderRadius: BorderRadius.circular(8), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(border: Border.all(color: isActive ? activeColor : AppTheme.textMutedColor.withOpacity(0.3), width: 1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 18, color: isActive ? activeColor : AppTheme.textMutedColor)))));
  }
}