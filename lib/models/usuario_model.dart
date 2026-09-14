class Usuario {
  final int id;
  final String nombres;
  final String apellidos;
  final String correo;
  final String? telefono;
  final List<String> roles;
  final int noShows;

  Usuario({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.correo,
    this.telefono,
    required this.roles,
    required this.noShows,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? 0,
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      correo: json['correo'] ?? '',
      // La API omite el campo cuando el usuario no tiene telefono.
      telefono: json['telefono'],
      roles: List<String>.from(json['roles'] ?? []),
      noShows: json['noShows'] ?? 0,
    );
  }

  // AGREGAR ESTE MÉTODO:
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombres': nombres,
      'apellidos': apellidos,
      'correo': correo,
      'telefono': telefono,
      'roles': roles,
      'noShows': noShows,
    };
  }
}

class LoginResponse {
  final String token;
  final Usuario usuario;

  LoginResponse({required this.token, required this.usuario});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      usuario: Usuario.fromJson(json['usuario'] ?? {}),
    );
  }
}