import 'package:flutter/widgets.dart';

import '../app/theme/tokens.dart';

/// Mock-data, letterlijk overgenomen uit de React-schermen zodat de
/// Flutter-app visueel identiek is. Wordt later vervangen door echte data.

class MockSession {
  const MockSession(this.time, this.name, this.type, this.dur);

  final String time;
  final String name;
  final String type;
  final String dur;
}

const coachSessions = [
  MockSession('09:00', 'Sophie B.', 'Krachttraining', '60 min'),
  MockSession('11:00', 'Tim R.', 'Online check-in', '30 min'),
  MockSession('14:30', 'Nora K.', 'Voedingsgesprek', '45 min'),
  MockSession('16:00', 'Bas H.', 'Krachttraining', '60 min'),
];

class MockClient {
  const MockClient(this.name, this.goal, this.week, this.delta, this.pct,
      this.gradient);

  final String name;
  final String goal;
  final String week;
  final String delta;
  final int pct;
  final Gradient gradient;

  String get initials =>
      name.split(' ').map((p) => p.isEmpty ? '' : p[0]).join();
}

const coachClients = [
  MockClient(
    'Sophie B.', 'Afvallen', 'Week 8', '-4.2 kg', 72,
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.primary, AppColors.accent],
    ),
  ),
  MockClient(
    'Tim R.', 'Spieropbouw', 'Week 6', '+3.1 kg', 55,
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.accent, AppColors.purple],
    ),
  ),
  MockClient(
    'Nora K.', 'Conditie', 'Week 8', 'Wk 8/10', 88,
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.red, AppColors.cyan],
    ),
  ),
  MockClient(
    'Bas H.', 'Kracht', 'Week 4', '+15 kg', 40,
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.accent, AppColors.primary],
    ),
  ),
];
