part of 'currency_repository_impl.dart';

extension on CurrencyRepositoryImpl {
  Future<void> _hydrateCurrencies() async {
    final cachedCurrencies = await _localDataSource.readCachedCurrencies();
    final cachedSnapshots = await _localDataSource.readCachedSnapshots();
    final storedReference = await _localDataSource.readReferenceCurrencyCode();
    final userReference = await _userPreferenceService
        .readCurrentUserReferenceCurrency();
    if (_disposed) return;

    _pushConfig(
      CurrencyConfigEntity(
        referenceCurrencyCode: CurrencyConfigEntity.normalizeCode(
          userReference ?? storedReference,
        ),
        currencies: cachedCurrencies.isEmpty
            ? currentConfig.currencies
            : cachedCurrencies,
        snapshotsByKey: cachedSnapshots,
      ),
    );
    _watchCurrencyCatalog();
    await _refreshRemoteCurrencyData();
  }

  void _onAuthStateChanged(AuthState state) {
    final previousUserId = _sessionUserId;
    final userId = state.session?.user.id;
    _sessionUserId = userId;
    if (userId != null && userId != previousUserId) {
      unawaited(_refreshAfterSignIn(userId));
    } else {
      unawaited(_safeRebindUserPreferenceStream());
    }
  }

  Future<void> _refreshAfterSignIn(String userId) async {
    try {
      await _hydrationInFlight?.catchError((Object error) {
        debugPrint('Currency local hydration warning: $error');
      });
      if (_disposed ||
          Supabase.instance.client.auth.currentUser?.id != userId) {
        return;
      }
      final subscription = _currencyCatalogSubscription;
      _currencyCatalogSubscription = null;
      await subscription?.cancel();
      if (_disposed) return;
      _watchCurrencyCatalog();
      await _refreshRemoteCurrencyData();
    } catch (error) {
      debugPrint('Currency sign-in refresh warning: $error');
    }
  }

  void _watchCurrencyCatalog() {
    _currencyCatalogSubscription ??= _remoteDataSource.watchCurrencies().listen(
      (currencies) => unawaited(_safeOnRemoteCurrenciesChanged(currencies)),
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Currency catalog realtime unavailable: $error');
      },
    );
  }

  Future<void> _refreshRemoteCurrencyData() async {
    try {
      await refreshCurrencies();
    } catch (error) {
      debugPrint('Currency catalog refresh warning: $error');
    }
    if (_disposed) return;
    await _safeRebindUserPreferenceStream();
    if (_disposed) return;
    await _refreshLatestSnapshots({
      ...currentConfig.currencies.map((currency) => currency.code),
      currentConfig.referenceCurrencyCode,
    });
    try {
      await _refreshReferenceHistory(currentConfig.referenceCurrencyCode);
    } catch (error) {
      debugPrint('Currency rate history refresh warning: $error');
    }
  }

  Future<List<ExchangeRateSnapshotEntity>> _refreshLatestSnapshots(
    Set<String> codes,
  ) async {
    final normalizedCodes = codes
        .map(CurrencyConfigEntity.normalizeCode)
        .toSet();
    List<ExchangeRateSnapshotEntity> available() => normalizedCodes
        .map(currentConfig.latestSnapshot)
        .whereType<ExchangeRateSnapshotEntity>()
        .toList(growable: false);

    final cached = available();
    final remoteCodes = normalizedCodes
        .where(
          (code) => code != CurrencyConfigEntity.defaultReferenceCurrencyCode,
        )
        .toList(growable: false);
    if (remoteCodes.isEmpty) return cached;

    final refresh = _fetchAndCacheLatestRates(remoteCodes);
    if (cached.length == normalizedCodes.length) {
      unawaited(refresh);
      return cached;
    }
    // The original request still populates the cache if it completes later.
    await refresh.timeout(const Duration(seconds: 3), onTimeout: () {});
    return available();
  }

  Future<void> _fetchAndCacheLatestRates(List<String> codes) async {
    try {
      await _mergeSnapshots(
        await _remoteDataSource.fetchLatestSnapshotsForCodes(codes),
      );
    } catch (error) {
      debugPrint('Currency latest rate refresh warning: $error');
    }
  }
}
