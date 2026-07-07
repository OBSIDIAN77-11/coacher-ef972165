import 'package:flutter_riverpod/legacy.dart';

/// Demo-modus: alleen actief via "Demo bekijken →" op het welkomstscherm.
/// In demo tonen de schermen de mock-data uit het Lovable-origineel;
/// met een echte sessie tonen ze echte data en nette lege staten.
final demoModeProvider = StateProvider<bool>((ref) => false);
