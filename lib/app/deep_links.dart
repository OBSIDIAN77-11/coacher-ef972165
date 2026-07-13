import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// Vangt de `coacher://` deep links op mobiel/desktop op.
///
/// - `coacher://login-callback` — genegeerd; supabase_flutter verwerkt de
///   OAuth-redirect al zelf via zijn eigen interne AppLinks-listener.
/// - `coacher://payment-return?ref=<id>` — Mollie stuurt de gebruiker hier
///   naartoe na de hosted checkout. We routeren dit naar dezelfde
///   `/payment-result`-pagina die de webflow ook gebruikt, zodat de app
///   direct de eindstatus toont zodra hij weer op de voorgrond komt —
///   in plaats van te vertrouwen op de polling-loop in PaymentScreen, die
///   op iOS kan pauzeren zodra de app naar de achtergrond gaat.
class DeepLinkListener {
  DeepLinkListener(this._router) {
    if (kIsWeb) return;
    _appLinks = AppLinks();
    _sub = _appLinks.uriLinkStream.listen(_handle, onError: (_) {});
    // Cold start: de app is net geopend via de link zelf.
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handle(uri);
    });
  }

  final GoRouter _router;
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  void _handle(Uri uri) {
    if (uri.scheme != 'coacher') return;
    final isPaymentReturn =
        uri.host == 'payment-return' || uri.path.contains('payment-return');
    if (!isPaymentReturn) return;

    final ref = uri.queryParameters['ref'];
    _router.go(ref != null ? '/payment-result?ref=$ref' : '/payment-result');
  }

  void dispose() {
    _sub?.cancel();
  }
}
