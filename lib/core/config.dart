/// Konfiguracja aplikacji. Wartości można nadpisać przy buildzie:
/// `flutter run --dart-define=AI_HUB_URL=https://...convex.site`
class AppConfig {
  /// Endpoint HTTP wspólnego backendu ai-hub (Convex, adres `.convex.site`).
  static const aiHubUrl = String.fromEnvironment(
    'AI_HUB_URL',
    defaultValue: 'https://qualified-jackal-293.eu-west-1.convex.site',
  );

  /// Identyfikator tej aplikacji w ai-hub (convex/appConfigs/plantsai.ts).
  static const aiHubApp = 'plantsai';

  /// Publiczny klucz klienta — ten sam co `clientKey` w konfiguracji na serwerze.
  static const aiHubClientKey = String.fromEnvironment(
    'AI_HUB_CLIENT_KEY',
    defaultValue: 'pk_plantsai_94580ade3dc2eef077c98966',
  );

  static const revenueCatAndroidKey = 'goog_JAECeoDvUtPzyJCMILswDqaphZy';
  static const proEntitlement = 'Pro';

  static const adsEnabled = true;

  /// Reklama pełnoekranowa co tyle zapytań do AI (tylko wersja darmowa).
  static const interstitialEvery = 3;

  static const privacyUrl = 'https://sites.google.com/view/privacy-policy-inudev/strona-g%C5%82%C3%B3wna';
}
