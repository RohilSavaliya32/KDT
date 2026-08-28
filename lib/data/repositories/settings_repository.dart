import '../models/settings/settings_model.dart';
import '../providers/settings_provider.dart';

class SettingsDataRepository {
  final SettingsProvider provider;

  SettingsDataRepository(this.provider);

  Future<SettingsModel> getSettings() {
    return provider.fetchSettings();
  }
}