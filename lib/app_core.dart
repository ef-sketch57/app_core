/// Socle commun des applis : thème, consentement, pubs, achat Pro, stockage,
/// PDF, partage, notifications et utilitaires.
library;

export 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show
        DidReceiveBackgroundNotificationResponseCallback,
        NotificationResponse,
        NotificationResponseType;

export 'src/ads/adaptive_banner.dart';
export 'src/ads/ads_service.dart';
export 'src/ads/interstitial_manager.dart';
export 'src/config/app_config.dart';
export 'src/config/remote_json_config.dart';
export 'src/consent/consent_service.dart';
export 'src/notifications/notification_service.dart';
export 'src/pdf/pdf_helpers.dart';
export 'src/purchase/pro_service.dart';
export 'src/share/share_service.dart';
export 'src/storage/db_opener.dart';
export 'src/storage/prefs.dart';
export 'src/theme/app_theme.dart';
export 'src/utils/amount_in_words_fr.dart';
export 'src/utils/csv.dart';
export 'src/utils/date_fr.dart';
export 'src/utils/money_format.dart';
export 'src/widgets/home_widget_service.dart';
export 'src/widgets/signature_field.dart';
export 'src/widgets/widgets.dart';
