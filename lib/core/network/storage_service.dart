import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/usuario_model.dart';

class StorageService {
  static const String _keyToken = 'auth_token';
  static const String _keyUsuario = 'auth_usuario';
  static const String _keySucursalId = 'sucursal_id_seleccionada';

  // Guardar Token JWT
  static Future<void> guardarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  // Obtener Token JWT
  static Future<String?> obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // Guardar Datos del Usuario Sesión
  static Future<void> guardarUsuario(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioJson = jsonEncode(usuario.toJson());
    await prefs.setString(_keyUsuario, usuarioJson);
  }

  // Obtener Datos del Usuario Sesión
  static Future<Usuario?> obtenerUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioString = prefs.getString(_keyUsuario);
    if (usuarioString == null) return null;
    return Usuario.fromJson(jsonDecode(usuarioString));
  }

  // Guardar Sucursal Seleccionada (Para Comercio)
  static Future<void> guardarSucursalId(int sucursalId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySucursalId, sucursalId);
  }

  // Obtener Sucursal Seleccionada
  static Future<int?> obtenerSucursalId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keySucursalId);
  }

  // Cerrar Sesión / Limpiar Almacenamiento
  static Future<void> limpiarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}