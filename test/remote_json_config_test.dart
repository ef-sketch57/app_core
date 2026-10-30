import 'dart:convert';

import 'package:app_core/app_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const embedded = {'seuil': 34};
  final url = Uri.parse('https://exemple.test/rules.json');

  RemoteJsonConfig config(http.Client client) => RemoteJsonConfig(
        url: url,
        embedded: embedded,
        cacheKey: 'test.rules',
        client: client,
        validate: (json) => json['seuil'] is int,
      );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('utilise le JSON distant et le met en cache', () async {
    final ok = MockClient((_) async => http.Response('{"seuil": 30}', 200));
    final loaded = await config(ok).load();
    expect(loaded.source, ConfigSource.remote);
    expect(loaded.json['seuil'], 30);

    final offline = MockClient((_) async => throw Exception('hors ligne'));
    final again = await config(offline).load();
    expect(again.source, ConfigSource.cache);
    expect(again.json['seuil'], 30);
  });

  test('hors ligne sans cache : valeurs embarquées', () async {
    final offline = MockClient((_) async => throw Exception('hors ligne'));
    final loaded = await config(offline).load();
    expect(loaded.source, ConfigSource.embedded);
    expect(loaded.json, embedded);
  });

  test('ignore une erreur HTTP ou un JSON invalide', () async {
    for (final response in [
      http.Response('introuvable', 404),
      http.Response('pas du json', 200),
      http.Response(jsonEncode({'seuil': 'trente'}), 200),
    ]) {
      final loaded = await config(MockClient((_) async => response)).load();
      expect(loaded.source, ConfigSource.embedded);
    }
  });

  test('délai dépassé : repli', () async {
    final slow = MockClient((_) =>
        Future.delayed(const Duration(seconds: 1), () => http.Response('{}', 200)));
    final loaded = await RemoteJsonConfig(
      url: url,
      embedded: embedded,
      cacheKey: 'test.rules',
      client: slow,
      timeout: const Duration(milliseconds: 50),
    ).load();
    expect(loaded.source, ConfigSource.embedded);
  });
}
