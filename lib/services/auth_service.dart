import 'dart:convert';
import '../core/network/api_client.dart';
import '../core/network/storage_service.dart';
import '../models/usuario_model.dart';

class AuthService {
  // Inicio de Sesión
  static Future<LoginResponse> login(String correo, String contrasena) async {
    final response = await ApiClient.post('/auth/login', {
      'correo': correo,
      'contrasena': contrasena,
    });

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final loginResponse = LoginResponse.fromJson(data);
      // Guardar token y usuario en almacenamiento local
      await StorageService.guardarToken(loginResponse.token);
      await StorageService.guardarUsuario(loginResponse.usuario);
      return loginResponse;
    } else {
      final String codigo = data['codigo'] ?? 'ERROR_DESCONOCIDO';
      final String mensaje = data['mensaje'] ?? 'Ocurrió un error al iniciar sesión';

      if (response.statusCode == 403 && codigo == 'USUARIO_NO_ACTIVO') {
        throw Exception('Tu cuenta está suspendida o inactiva.');
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        throw Exception('Credenciales incorrectas. Verifica tu correo y contraseña.');
      } else {
        throw Exception(mensaje);
      }
    }
  }

  // Registro de Cliente
  static Future<void> registrarCliente({
    required String nombres,
    required String apellidos,
    required String correo,
    required String telefono,
    required String contrasena,
  }) async {
    final response = await ApiClient.post('/auth/registro', {
      'nombres': nombres,
      'apellidos': apellidos,
      'correo': correo,
      'telefono': telefono,
      'contrasena': contrasena,
    });

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      final mensaje = data['mensaje'] ?? 'No se pudo crear la cuenta';
      throw Exception(mensaje);
    }
  }

  // Obtener Perfil Actual (/api/auth/yo)
  static Future<Usuario> obtenerPerfilActual() async {
    final response = await ApiClient.get('/auth/yo');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final usuario = Usuario.fromJson(data);
      await StorageService.guardarUsuario(usuario);
      return usuario;
    } else {
      throw Exception('No se pudo obtener la información de la sesión.');
    }
  }

  // Cerrar Sesión
  static Future<void> logout() async {
    await StorageService.limpiarSesion();
  }
}