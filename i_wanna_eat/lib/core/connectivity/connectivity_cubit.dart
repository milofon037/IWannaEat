import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit() : super(true) {
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      emit(!_isOffline(result));
    });
    _loadInitialState();
  }

  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  Future<void> _loadInitialState() async {
    final result = await Connectivity().checkConnectivity();
    emit(!_isOffline(result));
  }

  bool _isOffline(List<ConnectivityResult> result) {
    return result.every((item) => item == ConnectivityResult.none);
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
