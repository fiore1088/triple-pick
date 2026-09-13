import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../providers/user_provider.dart';
import '../widgets/search_history_widget.dart';
import 'result_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  final Set<String> _selectedPlatforms = {'Netflix', 'Prime Video', 'Disney+'};

  @override
  void initState() { super.initState(); _loadPlatforms(); }

  void _loadPlatforms() {
    final userPrefs = ref.read(userPreferencesProvider);
    setState(() { _selectedPlatforms = Set.from(userPrefs.selectedPlatforms); });
  }

  @override
  void dispose() { _searchController.dispose(); _searchFocusNode.dispose(); super.dispose(); }

  void _togglePlatform(String platform) {
    setState(() { if (_selectedPlatforms.contains(platform)) { _selectedPlatforms.remove(platform); } else { _selectedPlatforms.add(platform); } });
    ref.read(userPreferencesProvider.notifier).updatePlatforms(_selectedPlatforms.toList());
  }

  void _performSearch([String? query]) {
    final searchText = query ?? _searchController.text.trim();
    if (searchText.isEmpty || _selectedPlatforms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(searchText.isEmpty ? 'Scrivi cosa vuoi guardare' : 'Seleziona almeno una piattaforma'), backgroundColor: AppTheme.errorColor));
      return;
    }
    setState(() { _isSearching = true; if (query != null) { _searchController.text = query; } });
    ref.read(userPreferencesProvider.notifier).addToHistory(query: searchText, platforms: _selectedPlatforms.toList());
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ResultScreen(query: searchText, platforms: _selectedPlatforms.toList()))).then((_) { setState(() { _isSearching = false; }); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('TriplePick', style: AppTheme.headlineLarge.copyWith(fontSize: 28, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => _showSettings(context), icon: const Icon(Icons.settings, color: AppTheme.textSecondaryColor)),
                ]),
                const SizedBox(height: 8),
                Text('Cosa vuoi guardare stasera?', style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondaryColor)),
                const SizedBox(height: 24),
                TextField(controller: _searchController, focusNode: _searchFocusNode, style: AppTheme.bodyLarge, maxLines: 3, minLines: 1, decoration: AppTheme.inputDecoration('Es: "Un thriller psicologico non troppo violento"'), onSubmitted: (_) => _performSearch()),
                const SizedBox(height: 16),
                SearchHistoryWidget(onSearchTap: (query, platforms) { setState(() { _selectedPlatforms = Set.from(platforms); }); _performSearch(query); }),
                const SizedBox(height: 24),
                Text('Le tue piattaforme', style: AppTheme.headlineSmall.copyWith(fontSize: 16)),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: AppConstants.supportedPlatforms.map((platform) {
                  final isSelected = _selectedPlatforms.contains(platform);
                  return GestureDetector(onTap: () => _togglePlatform(platform), child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: isSelected ? AppTheme.primaryColor.withOpacity(0.2) : AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor, width: 1.5)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(isSelected ? Icons.check_circle : Icons.add_circle_outline, color: isSelected ? AppTheme.primaryColor : AppTheme.textMutedColor, size: 18), const SizedBox(width: 8), Text(platform, style: TextStyle(color: isSelected ? AppTheme.textPrimaryColor : AppTheme.textSecondaryColor, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal))])));
                }).toList()),
                const SizedBox(height: 32),
                Text('Prova con:', style: AppTheme.bodySmall.copyWith(color: AppTheme.textMutedColor)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: [_buildSuggestionChip('Un thriller avvincente'), _buildSuggestionChip('Commedia leggera'), _buildSuggestionChip('Documentario natura'), _buildSuggestionChip("Film d'azione 90s")]),
                const SizedBox(height: 40),
                SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: _isSearching ? null : () => _performSearch(), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: _isSearching ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textPrimaryColor))) : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search, color: AppTheme.textPrimaryColor), SizedBox(width: 8), Text('Trova i miei 3 titoli', style: AppTheme.buttonText)]))),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return GestureDetector(onTap: () => _performSearch(text), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.surfaceColor)), child: Text(text, style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondaryColor))));
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(context: context, backgroundColor: AppTheme.surfaceColor, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (context) => _SettingsSheet());
  }
}

class _SettingsSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPrefs = ref.watch(userPreferencesProvider);
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.textMutedColor, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 24),
          Text('Impostazioni', style: AppTheme.headlineSmall),
          const SizedBox(height: 24),
          if (userPrefs.feedback.isNotEmpty) ...[
            Text('Le tue preferenze', style: AppTheme.bodySmall.copyWith(color: AppTheme.textMutedColor)),
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.thumb_up, color: AppTheme.successColor, size: 20), const SizedBox(width: 8), Text('\${userPrefs.feedback.values.where((f) => f == FeedbackType.like).length}', style: AppTheme.bodyMedium),
              const SizedBox(width: 24), Icon(Icons.thumb_down, color: AppTheme.errorColor, size: 20), const SizedBox(width: 8), Text('\${userPrefs.feedback.values.where((f) => f == FeedbackType.dislike).length}', style: AppTheme.bodyMedium),
              const SizedBox(width: 24), Icon(Icons.block, color: AppTheme.textMutedColor, size: 20), const SizedBox(width: 8), Text('\${userPrefs.excludedTitles.length}', style: AppTheme.bodyMedium),
            ]),
            const SizedBox(height: 16),
          ],
          ListTile(leading: const Icon(Icons.history, color: AppTheme.textSecondaryColor), title: const Text('Cancella storico ricerche'), onTap: () async { await ref.read(userPreferencesProvider.notifier).clearHistory(); if (context.mounted) Navigator.of(context).pop(); }),
          ListTile(leading: const Icon(Icons.block, color: AppTheme.errorColor), title: const Text('Ripristina titoli esclusi'), onTap: () async { await ref.read(userPreferencesProvider.notifier).clearExclusions(); if (context.mounted) Navigator.of(context).pop(); }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}