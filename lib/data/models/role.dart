/// app_role enum uit Supabase (admin wordt in de UI niet gebruikt).
enum Role {
  coach,
  klant;

  static Role? tryParse(String? value) => switch (value) {
        'coach' => Role.coach,
        'klant' => Role.klant,
        _ => null,
      };

  String get db => name;
}
