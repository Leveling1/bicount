part of 'main_bloc.dart';

abstract class MainState {
  const MainState();
}

class MainInitial extends MainState {
  const MainInitial();
}

class MainStateConnexion extends MainState {
  final int selectedIndex;
  final NetworkStatus networkStatus;

  const MainStateConnexion({
    this.selectedIndex = 0,
    this.networkStatus = NetworkStatus.connected,
  });

  MainStateConnexion copyWith({
    int? selectedIndex,
    NetworkStatus? networkStatus,
  }) {
    return MainStateConnexion(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      networkStatus: networkStatus ?? this.networkStatus,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MainStateConnexion &&
        other.selectedIndex == selectedIndex &&
        other.networkStatus == networkStatus;
  }

  @override
  int get hashCode => selectedIndex.hashCode ^ networkStatus.hashCode;

  @override
  String toString() {
    return 'MainStateConnexion(selectedIndex: $selectedIndex, networkStatus: $networkStatus)';
  }
}

//For the start data like members with a link
class MainLoading extends MainState {  }

class MainLoaded extends MainState {
  final MainEntity startData;
  const MainLoaded(this.startData);
}

class MainError extends MainState {
  final String error;
  MainError(this.error);
}
