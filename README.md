# app_core

Socle Flutter commun des applis de la série (Quittances, puis les outils
pour frontaliers du Luxembourg) : thème, consentement RGPD, pubs AdMob,
achat Pro, stockage local, PDF, partage, notifications et utilitaires en
français.

## Utilisation dans une appli

Dans le `pubspec.yaml` de l'appli, épinglez un tag :

```yaml
dependencies:
  app_core:
    git:
      url: https://github.com/ef-sketch57/app_core.git
      ref: v0.1.0
```

Pour travailler sur le socle et l'appli en même temps, clonez les deux dépôts
côte à côte :

```
mes-projets/
├── app_core/
└── quittances/
```

Ajoutez ensuite dans l'appli un `pubspec_overrides.yaml`, ignoré par Git :

```yaml
dependency_overrides:
  app_core:
    path: ../app_core
```

Le build de release se fait **sans** ce fichier, pour vérifier que la version
taguée suffit.

## Contenu

| Module | Rôle |
|---|---|
| `AppConfig` / `appConfigProvider` | IDs pub par plateforme, ID produit Pro, plafond des interstitiels. IDs de test Google en debug. |
| `buildAppTheme(AppPalette)` | Thème Material 3 paramétré, police Manrope embarquée (`kFontFamily`). |
| `ConsentService` | Consentement RGPD Google UMP ; `showPrivacyOptions()` pour « Gérer mes choix ». |
| `adsReadyProvider`, `showAdsProvider` | Pubs initialisées seulement après consentement ; aucune si Pro. |
| `AdaptiveBanner` | Bannière adaptative ancrée. |
| `InterstitialManager` | Interstitiel préchargé, au plus un toutes les 3 minutes, jamais au premier lancement. |
| `isProProvider` (`ProState`) | Achat unique non consommable, restauration, état persistant. |
| `openAppDatabase`, `AppPrefs` | Base SQLite locale (drift) et petits réglages. Rien ne quitte l'appareil. |
| `PdfFonts`, `a4Document`, `pdfAmountRow`, `pdfLabel` | Helpers PDF A4 avec polices embarquées. |
| `ShareService` | Partage (e-mail, WhatsApp…) et enregistrement de PDF. |
| `NotificationService` | Rappels locaux programmés, notifications immédiates, boutons d'action traités en arrière-plan. |
| `RemoteJsonConfig` | Règles chiffrées hébergées (JSON), avec cache et repli sur les valeurs embarquées hors ligne. |
| `toCsv`, `csvBytes`, `ShareService.shareFile` | Export CSV lisible par Excel. |
| `HomeWidgetService` | Données du widget d'écran d'accueil (`home_widget`) ; le dessin natif reste dans l'appli. |
| `a4MultiPageDocument` | PDF A4 sur plusieurs pages (relevés longs). |
| `amountInWordsFr`, `formatEuros`, `parseEurosToCents`, dates FR | Utilitaires en français. |
| `LabeledField`, `AppCard`, `SegmentedChoice`, `StatusChip`, `SignatureField`… | Widgets communs. |

Gestion d'état : Riverpod. Les applis utilisent go_router pour la navigation.

## Démarrage type d'une appli

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await AppPrefs.load();
  await prefs.registerLaunch();
  runApp(ProviderScope(
    overrides: [
      appConfigProvider.overrideWithValue(maConfig),
      appPrefsProvider.overrideWithValue(prefs),
    ],
    child: MonAppli(), // MaterialApp.router(theme: buildAppTheme(maPalette), …)
  ));
}
```

- Après l'onboarding, puis à chaque lancement :
  `ref.read(adsReadyProvider.notifier).start()` (consentement, puis SDK pub).
- Bannière : `const AdaptiveBanner()` en bas des écrans voulus.
- Interstitiel : `await ref.read(interstitialManagerProvider).showIfAllowed()`.

Configuration native requise dans chaque appli :

- l'ID d'application AdMob dans `AndroidManifest.xml` et `Info.plist` ;
- les récepteurs `flutter_local_notifications` et la permission
  `POST_NOTIFICATIONS` dans le manifeste ;
- `isCoreLibraryDesugaringEnabled = true` et la dépendance
  `desugar_jdk_libs` dans `android/app/build.gradle.kts`, ainsi que
  `minSdk = 24` ;
- pour l'aperçu web avec drift : `sqlite3.wasm` et `drift_worker.js` dans
  `web/`.

L'appli Quittances sert d'exemple complet.

## Configurations distantes (`remote/`)

Le dépôt étant public, le dossier `remote/` sert les règles chiffrées des
applis, lues par `RemoteJsonConfig` à l'adresse
`https://raw.githubusercontent.com/ef-sketch57/app_core/main/remote/<appli>/rules.json`.
Modifier un de ces fichiers sur `main` change les règles de l'appli sans la
republier (prise en compte au lancement suivant). Le fichier doit rester un
JSON valide et complet : sinon l'appli l'ignore et garde la version
précédente.

## Règles de modification

1. Toute modification du socle se fait ici, jamais en recopiant du code du
   socle dans une appli.
2. Ne pas casser l'API existante : ajouter plutôt que modifier. Si un
   changement cassant est inévitable, passer à la version majeure suivante.
3. Lancer `flutter test`, committer, mettre à jour `version` dans
   `pubspec.yaml` et le `CHANGELOG.md`, créer le tag (`v0.2.0`…) et le
   pousser.
4. Dans l'appli concernée, mettre `ref:` sur le nouveau tag.

Les autres applis restent sur leur ancien tag tant qu'on ne les met pas à
jour : une modification du socle ne peut pas casser une appli déjà publiée.

## Tests

```bash
flutter pub get
flutter test
```

## Licences

La police Manrope est distribuée sous licence SIL Open Font License
(`assets/fonts/OFL.txt`).
