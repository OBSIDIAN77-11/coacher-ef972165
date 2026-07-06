import 'package:flutter_web_plugins/url_strategy.dart';

/// Schone URL's (zonder #) zodat /reset-password en /payment-result
/// rechtstreeks aanklikbaar zijn vanuit e-mails en Mollie-redirects.
void configureUrlStrategy() => usePathUrlStrategy();
