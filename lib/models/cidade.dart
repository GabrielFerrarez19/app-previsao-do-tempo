/// Cidade retornada pela API de geocodificação do Open-Meteo.
class Cidade {
  final int id;
  final String nome;
  final double latitude;
  final double longitude;
  final String? estado; // admin1
  final String? pais;

  const Cidade({
    required this.id,
    required this.nome,
    required this.latitude,
    required this.longitude,
    this.estado,
    this.pais,
  });

  factory Cidade.fromJson(Map<String, dynamic> json) {
    return Cidade(
      id: json['id'] as int,
      nome: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      estado: json['admin1'] as String?,
      pais: json['country'] as String?,
    );
  }

  /// Ex.: "Minas Gerais, Brasil"
  String get descricao =>
      [estado, pais].where((p) => p != null && p.isNotEmpty).join(', ');
}
