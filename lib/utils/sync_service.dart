import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/ue.dart';

class SyncService {
  static const String syncTaskName = "com.bgmax.sync_data_task";
  static const String serverUrl = "https://pharel.duckdns.org/sync";

  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      try {
        final synced = await syncDataToServer();
        return Future.value(synced);
      } catch (e) {
        return Future.value(false);
      }
    });
  }

  static Future<void> init() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  static Future<void> scheduleSync() async {
    await Workmanager().registerOneOffTask(
      "sync-task-${DateTime.now().millisecondsSinceEpoch}",
      syncTaskName,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  static Future<bool> syncDataToServer() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? 'Unknown';
    final matricule = prefs.getString('matricule') ?? 'Unknown';
    final uesJson = prefs.getString('ues_data');
    
    List<Map<String, dynamic>> uesList = [];
    if (uesJson != null) {
      final List<dynamic> decoded = jsonDecode(uesJson);
      uesList = decoded.cast<Map<String, dynamic>>();
    }

    final data = {
      'username': username,
      'matricule': matricule,
      'ues': uesList,
      'device_timestamp': DateTime.now().toIso8601String(),
    };

    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Data successfully synced to server.");
        return true;
      } else {
        print("Failed to sync data. Status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error syncing data: $e");
      return false;
    }
  }

  static Future<void> saveAndTriggerSync(List<UE> ues) async {
    final prefs = await SharedPreferences.getInstance();
    final uesJson = jsonEncode(ues.map((e) => e.toJson()).toList());
    await prefs.setString('ues_data', uesJson);
    
    // Trigger immediate sync attempt
    syncDataToServer();
    
    // Schedule background sync in case it fails or for future
    scheduleSync();
  }
}
