import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/deep_link_helper.dart';
import '../widgets/movie_card.dart';
import '../widgets/feedback_widget.dart';
import '../providers/search_provider.dart';
import '../providers/user_provider.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final String query;
  final List<String> platforms;
  const ResultScreen({super.key, required this.query, required this.platforms});
  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchProvider.notifier).updatePlatforms(widget.platforms);
      ref.read(searchProvider.notifier).search(widget.query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final userPrefs = ref.watch(userPreferencesProvider);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(children: [
            _buildHeader(searchState),
            Expanded(child: _buildContent(searchState, userPrefs)),
          ]),
        ),
      ),
    );
  }

  Widget _buildHeader(SearchState searchState) {
    return Padding(padding: const EdgeInsets.all(16), child: Row(children: [
      IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimaryColor)),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('I tuoi 3 consigli', style: AppTheme.headlineSmall.copyWith(fontSize: 18)),
        const SizedBox(height: 4),
        Text(widget.query, style: AppTheme.bodySmall.copyWith(color: AppTheme.textMutedColor), maxLines: 1, overflow: TextOverflow.ellipsis),
      ])),
      if (!searchState.isLoading) IconButton(onPressed: () { ref.read(searchProvider.notifier).search(widget.query); }, icon: const Icon(Icons.refresh, color: AppTheme.textSecondaryColor)),
    ]));
  }

  Widget _buildContent(SearchState searchState, UserPreferencesState userPrefs) {
    if (searchState.isLoading) return _buildLoading();
    if (searchState.error != null) return _buildError(searchState.error!);
    if (searchState.recommendations.isEmpty) return _buildEmpty();
    return _buildResults(searchState, userPrefs);
  }

  Widget _buildLoading() {
    return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(width: 60, height: 60, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor))),
      SizedBox(height: 24), Text("L'AI sta analizzando il catalogo...", style: AppTheme.bodyMedium),
      SizedBox(height: 8), Text('Cerchiamo i 3 titoli perfetti per te', style: AppTheme.bodySmall),
    ]));
  }

  Widget _buildError(String error) {
    return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
      const SizedBox(height: 16), Text('Oops, qualcosa e andato storto', style: AppTheme.headlineSmall),
      const SizedBox(height: 8), Text(error, style: AppTheme.bodyMedium, textAlign: TextAlign.center),
      const SizedBox(height: 24), ElevatedButton(onPressed: () { ref.read(searchProvider.notifier).search(widget.query); }, child: const Text('Riprova')),
    ])));
  }

  Widget _buildEmpty() {
    return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.search_off, size: 64, color: AppTheme.textMutedColor),
      const SizedBox(height: 16), Text('Nessun risultato trovato', style: AppTheme.headlineSmall),
      const SizedBox(height: 8), Text('Prova a modificare la tua ricerca o selezionare altre piattaforme', style: AppTheme.bodyMedium, textAlign: TextAlign.center),
      const SizedBox(height: 24), ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Torna indietro')),
    ])));
  }

  Widget _buildResults(SearchState searchState, UserPreferencesState userPrefs) {
    final top3 = searchState.recommendations.take(3).toList();
    return Column(children: [
      if (searchState.criteria != null) Container(margin: const EdgeInsets.symmetric(horizontal: 16), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.secondaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.3))), child: Row(children: [Icon(Icons.auto_awesome, color: AppTheme.secondaryColor, size: 20), const SizedBox(width: 10), Expanded(child: Text('AI ha trovato ${searchState.totalCandidates} candidati, ti mostriamo i top 3', style: TextStyle(color: AppTheme.secondaryColor, size: 13)))])),
      const SizedBox(height: 16),
      if (widget.platforms.isNotEmpty) Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [Icon(Icons.filter_list, color: AppTheme.textMutedColor, size: 16), const SizedBox(width: 8), Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: widget.platforms.map((platform) => Padding(padding: const EdgeInsets.only(right: 8), child: Chip(label: Text(platform, style: const TextStyle(color: AppTheme.textPrimaryColor, fontSize: 12)), backgroundColor: AppTheme.surfaceColor, side: BorderSide.none, padding: const EdgeInsets.symmetric(horizontal: 8), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap))).toList())))])),
      const SizedBox(height: 16),
      Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: top3.length, itemBuilder: (context, index) {
        final item = top3[index];
        final movie = item.movie;
        return Padding(padding: const EdgeInsets.only(bottom: 16), child: Column(children: [
          MovieCard(rank: index + 1, title: movie.title, year: movie.year ?? 0, overview: movie.overview ?? 'Nessuna descrizione disponibile', posterPath: movie.posterPath ?? '', voteAverage: movie.voteAverage ?? 0, platform: movie.platformName ?? 'Sconosciuta', genres: [], runtime: 0, watchLink: movie.watchLink, onTap: () => _openContent(movie)),
          Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [
            Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.surfaceColor.withOpacity(0.5), borderRadius: BorderRadius.circular(8)), child: Row(children: [Icon(Icons.auto_awesome, size: 14, color: AppTheme.secondaryColor), const SizedBox(width: 6), Expanded(child: Text(item.reason, style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondaryColor, fontStyle: FontStyle.italic), maxLines: 2, overflow: TextOverflow.ellipsis))]))),
            const SizedBox(width: 8),
            FeedbackWidget(movieId: movie.id, movieTitle: movie.title),
          ])),
        ]));
      })),
      if (searchState.recommendations.length > 3) Padding(padding: const EdgeInsets.all(16), child: Text('E altri ${searchState.recommendations.length - 3} titoli disponibili...', style: AppTheme.bodySmall.copyWith(color: AppTheme.textMutedColor))),
    ]);
  }

  Future<void> _openContent(dynamic movie) async {
    if (movie.watchLink == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Link non disponibile per ${movie.title}'), backgroundColor: AppTheme.errorColor));
      return;
    }
    final result = await DeepLinkService.launchContent(platform: movie.platformName ?? '', contentId: movie.id.toString(), fallbackUrl: movie.watchLink!);
    if (!result.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.error ?? "Errore nell'apertura del link"), backgroundColor: AppTheme.errorColor, action: SnackBarAction(label: 'Installa app', textColor: AppTheme.textPrimaryColor, onPressed: () {
        final storeUrl = DeepLinkService.getStoreUrl(movie.platformName ?? '');
        if (storeUrl.isNotEmpty) { DeepLinkService.launchContent(platform: movie.platformName ?? '', contentId: 'store', fallbackUrl: storeUrl); }
      })));
    }
  }
}