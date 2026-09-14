import 'package:shared_preferences/shared_preferences.dart';

class LocalPreferencesService {
  static const String _keyZonaPreferidaId = 'zona_preferida_id';
  static const String _keyZonaPreferidaNombre = 'zona_preferida_nombre';

  // Guardar la Zona Preferida del Cliente
  static Future<void> guardarZonaPreferida({required int id, required String nombre}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyZonaPreferidaId, id);
    await prefs.setString(_keyZonaPreferidaNombre, nombre);
  }

  // Obtener el ID de la Zona Preferida
  static Future<int?> obtenerZonaPreferidaId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyZonaPreferidaId);
  }

  // Obtener el Nombre de la Zona Preferida
  static Future<String?> obtenerZonaPreferidaNombre() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyZonaPreferidaNombre);
  }

  // Limpiar Preferencias Locales
  static Future<void> limpiarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyZonaPreferidaId);
    await prefs.remove(_keyZonaPreferidaNombre);
  }
}