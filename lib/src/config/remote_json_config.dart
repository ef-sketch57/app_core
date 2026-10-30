import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Origine des valeurs renvoyées par [RemoteJsonConfig.load].
enum ConfigSource { remote, cache, embedded }

/// Résultat d'un chargement : le JSON et son origine.
class LoadedConfig {
  const LoadedConfig(this.json, this.source);

  final Map<String, dynamic> json;
  final ConfigSource source;
}

/// Configuration JSON hébergée (GitHub Pages, fichier brut…), modifiable sans
/// republier l'appli.
///
/// Ordre de repli : JSON distant, puis dernière version valide en cache, puis
/// valeurs embarquées dans l'appli. Aucune donnée utilisateur n'est envoyée :
/// c'est un simple GET.
class RemoteJsonConfig {
  RemoteJsonConfig({
    required this.url,
    required this.embedded,
    required this.cacheKey,
    this.timeout = const Duration(seconds: 6),
    this.validate,
    this.client,
  });

  /// Adresse du fichier JSON.
  final Uri url;

  /// Valeurs par défaut embarquées (souvent lues depuis un asset).
  final Map<String, dynamic> embedded;

  /// Clé SharedPreferences du cache de la dernière version valide.
  final String cacheKey;

  final Duration timeout;

  /// Rejette un JSON incomplet ou mal formé (renvoyer `false`).
  final bool Function(Map<String, dynamic> json)? validate;

  /// Client HTTP injectable (tests) ; sinon un client est créé et fermé.
  final http.Client? client;

  bool _isValid(Map<String, dynamic> json) => validate?.call(json) ?? true;

  /// Valeurs disponibles sans réseau : cache s'il est valide, sinon embarquées.
  Future<LoadedConfig> loadCached() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = _decode(prefs.getString(cacheKey));
    if (cached != null && _isValid(cached)) {
      return LoadedConfig(cached, ConfigSource.cache);
    }
    return LoadedConfig(embedded, ConfigSource.embedded);
  }

  /// Télécharge la version distante ; en cas d'échec (hors ligne, délai
  /// dépassé, JSON invalide), renvoie [loadCached].
  Future<LoadedConfig> load() async {
    final c = client ?? http.Client();
    try {
      final response = await c.get(url).timeout(timeout);
      if (response.statusCode == 200) {
        final json = _decode(utf8.decode(response.bodyBytes));
        if (json != null && _isValid(json)) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(cacheKey, jsonEncode(json));
          return LoadedConfig(json, ConfigSource.remote);
        }
      }
      debugPrint('Config distante ignorée (${response.statusCode})');
    } catch (e) {
      debugPrint('Config distante indisponible : $e');
    } finally {
      if (client == null) c.close();
    }
    return loadCached();
  }

  static Map<String, dynamic>? _decode(String? raw) {
    if (raw == null) return null;
    try {
      final value = jsonDecode(raw);
      return value is Map<String, dynamic> ? value : null;
    } catch (_) {
      return null;
    }
  }
}
