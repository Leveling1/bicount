part of 'main_finance_projection_service.dart';

class _FriendAggregate {
  _FriendAggregate(this._friend);

  final FriendsModel _friend;
  final Map<String, double> _giveByCurrency = {};
  final Map<String, double> _receiveByCurrency = {};
  final Map<String, double> _personalIncomeByCurrency = {};
  final Map<String, double> _companyIncomeByCurrency = {};

  void apply({
    required double nativeAmount,
    required String currencyCode,
    required int category,
    required bool isSender,
  }) {
    final directionalMap = isSender ? _giveByCurrency : _receiveByCurrency;
    directionalMap[currencyCode] =
        (directionalMap[currencyCode] ?? 0) + nativeAmount;

    final signedAmount = isSender ? -nativeAmount : nativeAmount;
    if (category == Constants.personal) {
      _personalIncomeByCurrency[currencyCode] =
          (_personalIncomeByCurrency[currencyCode] ?? 0) + signedAmount;
    } else if (category == Constants.company) {
      _companyIncomeByCurrency[currencyCode] =
          (_companyIncomeByCurrency[currencyCode] ?? 0) + signedAmount;
    }
  }

  FriendsModel toModel(
    MainFinanceProjectionService service,
    CurrencyConfigEntity currencyConfig,
  ) {
    return FriendsModel(
      sid: _friend.sid,
      uid: _friend.uid,
      fid: _friend.fid,
      image: _friend.image,
      username: _friend.username,
      email: _friend.email,
      give: service._convertNetByCurrency(_giveByCurrency, currencyConfig),
      receive: service._convertNetByCurrency(
        _receiveByCurrency,
        currencyConfig,
      ),
      relationType: _friend.relationType,
      personalIncome: service._convertNetByCurrency(
        _personalIncomeByCurrency,
        currencyConfig,
      ),
      companyIncome: service._convertNetByCurrency(
        _companyIncomeByCurrency,
        currencyConfig,
      ),
    );
  }
}
