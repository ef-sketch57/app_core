# Changelog

## 0.2.0

Ajouts, sans changement de l'API existante :

- `RemoteJsonConfig` : configuration JSON hébergée, avec cache de la
  dernière version valide et repli sur les valeurs embarquées hors ligne.
- `NotificationService` : boutons d'action (`categories`,
  `NotificationActionSpec`), traitement en arrière-plan
  (`onBackgroundResponse`), flux `responses`, `show()` immédiat,
  `pendingIds()`, paramètre `categoryId` dans `schedule()`.
- `toCsv`, `csvBytes` : export CSV lisible par Excel ;
  `ShareService.shareFile()` pour partager un fichier quelconque.
- `HomeWidgetService` : données du widget d'écran d'accueil (`home_widget`).
- `a4MultiPageDocument` : PDF A4 sur plusieurs pages avec pied de page.
- `weekdayNameFr`, `formatWeekdayDateFr`.
- `remote/` : fichiers de configuration distants des applis
  (`remote/compteur34/rules.json`).

## 0.1.0

Première version : thème Material 3 paramétré (Manrope embarquée),
consentement UMP, bannière adaptative, interstitiel plafonné, achat Pro non
consommable, ouverture de base drift, réglages persistants, helpers PDF A4,
partage, notifications locales, montant en toutes lettres, formats fr_FR,
widgets communs.
