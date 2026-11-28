part of 'analysis_bloc.dart';

typedef AnalysisCategorySelection = ({
  String ownerUid,
  List<FriendsModel> contacts,
  Set<String> selected,
});

extension AnalysisCategoryActions on AnalysisBloc {
  Future<void> _onAnalysisStarted(
    AnalysisStarted event,
    Emitter<AnalysisState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AnalysisStatus.loading,
        clearDashboard: true,
        errorMessage: null,
      ),
    );

    await _sourcesSubscription?.cancel();
    final mainStates = mainBloc.stream
        .startWith(mainBloc.state)
        .shareReplay(maxSize: 1);
    final categories = mainStates
        .map((state) => state is MainLoaded ? state.startData.user.uid : null)
        .distinct()
        .switchMap(_watchCategories);
    _sourcesSubscription =
        Rx.combineLatest3<
              MainState,
              CurrencyConfigEntity,
              List<AnalysisContactCategory>,
              _AnalysisSourcesSnapshot
            >(
              mainStates,
              currencyRepository.watchConfig(),
              categories,
              (mainState, currencyConfig, categories) =>
                  _AnalysisSourcesSnapshot(
                    mainState: mainState,
                    currencyConfig: currencyConfig,
                    categories: categories,
                  ),
            )
            .listen(
              (snapshot) => add(
                _AnalysisSourcesUpdated(
                  snapshot.mainState,
                  snapshot.currencyConfig,
                  snapshot.categories,
                ),
              ),
              onError: (error, _) =>
                  add(_AnalysisDashboardFailed(error.toString())),
            );
  }

  Stream<List<AnalysisContactCategory>> _watchCategories(String? ownerUid) {
    if (ownerUid == null || ownerUid.isEmpty) return Stream.value(const []);
    return _categoryRepository.watch(ownerUid).startWith(const []);
  }

  AnalysisCategorySelection? categorySelection(AnalysisChart chart) {
    final mainState = mainBloc.state;
    if (mainState is! MainLoaded) return null;

    final ownerUid = mainState.startData.user.uid;
    final contacts = analysisCategoryContacts(
      mainState.startData.friends,
      ownerUid,
    );
    final allowed = contacts.map((friend) => friend.sid).toSet();
    return (
      ownerUid: ownerUid,
      contacts: contacts,
      selected: {
        for (final category in _categories)
          if (category.ownerUid == ownerUid &&
              category.chart == chart &&
              allowed.contains(category.friendSid))
            category.friendSid,
      },
    );
  }

  Future<void> saveCategorySelection({
    required AnalysisCategorySelection original,
    required AnalysisChart chart,
    required Set<String> selected,
    required bool bothCharts,
  }) async {
    final current = categorySelection(chart);
    if (current == null || current.ownerUid != original.ownerUid) {
      throw StateError('The analysis account changed.');
    }
    final allowed = current.contacts.map((friend) => friend.sid).toSet();
    await _categoryRepository.save(
      ownerUid: original.ownerUid,
      chart: chart,
      original: original.selected.intersection(allowed),
      selected: selected.intersection(allowed),
      bothCharts: bothCharts,
    );
  }
}
