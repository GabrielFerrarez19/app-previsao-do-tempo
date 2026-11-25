import 'package:flutter/material.dart';

/// Converte o código WMO (weather_code) do Open-Meteo em descrição e ícone.
({String descricao, IconData icone}) infoTempo(int codigo) {
  return switch (codigo) {
    0 => (descricao: 'Céu limpo', icone: Icons.wb_sunny),
    1 => (descricao: 'Predominantemente limpo', icone: Icons.wb_sunny_outlined),
    2 => (descricao: 'Parcialmente nublado', icone: Icons.wb_cloudy_outlined),
    3 => (descricao: 'Nublado', icone: Icons.cloud),
    45 || 48 => (descricao: 'Neblina', icone: Icons.foggy),
    51 || 53 || 55 => (descricao: 'Garoa', icone: Icons.grain),
    56 || 57 => (descricao: 'Garoa congelante', icone: Icons.ac_unit),
    61 => (descricao: 'Chuva fraca', icone: Icons.water_drop_outlined),
    63 => (descricao: 'Chuva moderada', icone: Icons.water_drop),
    65 => (descricao: 'Chuva forte', icone: Icons.water_drop),
    66 || 67 => (descricao: 'Chuva congelante', icone: Icons.ac_unit),
    71 || 73 || 75 || 77 => (descricao: 'Neve', icone: Icons.ac_unit),
    80 || 81 || 82 => (descricao: 'Pancadas de chuva', icone: Icons.umbrella),
    85 || 86 => (descricao: 'Pancadas de neve', icone: Icons.ac_unit),
    95 => (descricao: 'Trovoada', icone: Icons.thunderstorm),
    96 || 99 => (descricao: 'Trovoada com granizo', icone: Icons.thunderstorm),
    _ => (descricao: 'Indefinido', icone: Icons.help_outline),
  };
}
