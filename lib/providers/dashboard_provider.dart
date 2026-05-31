import 'package:flutter/foundation.dart';

import '../models/dashboard_snapshot.dart';
import '../models/scenario_model.dart';
import '../services/api_service.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardSnapshot? snapshot;
  List<ScenarioModel> scenarios = const [];
  bool loading = false;
  String? error;

  void reset() {
    snapshot = null;
    scenarios = const [];
    loading = false;
    error = null;
    notifyListeners();
  }

  Future<void> load(ApiService api) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final dash = await api.dashboardMe();
      final raw = await api.scenarios();
      snapshot = DashboardSnapshot.fromJson(dash);
      scenarios = raw
          .map((e) => ScenarioModel.fromJson(e as Map<String, dynamic>))
          .toList();
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
