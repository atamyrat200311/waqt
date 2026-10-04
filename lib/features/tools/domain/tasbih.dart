/// One phrase of a tasbih sequence.
class TasbihPhase {
  const TasbihPhase(this.transliteration, this.arabic, this.target);
  final String transliteration;
  final String arabic;
  final int target;
}

enum TasbihTap { counted, phaseDone, complete, restarted }

/// Pure tasbih counter: the after-prayer preset (33 · 33 · 34) or a custom
/// single phrase with a goal.
class TasbihState {
  const TasbihState({
    required this.phases,
    required this.phase,
    required this.count,
    required this.isComplete,
    this.custom = false,
  });

  factory TasbihState.preset() => const TasbihState(phases: presetPhases, phase: 0, count: 0, isComplete: false);

  factory TasbihState.custom(String phrase, int goal) => TasbihState(
        phases: [TasbihPhase(phrase.trim().isEmpty ? presetPhases.first.transliteration : phrase.trim(), '', goal.clamp(1, 9999))],
        phase: 0,
        count: 0,
        isComplete: false,
        custom: true,
      );

  static const presetPhases = [
    TasbihPhase('SubḥānAllāh', 'سُبْحَانَ اللَّهِ', 33),
    TasbihPhase('Alḥamdulillāh', 'الْحَمْدُ لِلَّهِ', 33),
    TasbihPhase('Allāhu akbar', 'اللَّهُ أَكْبَرُ', 34),
  ];

  final List<TasbihPhase> phases;
  final int phase;
  final int count;
  final bool isComplete;
  final bool custom;

  TasbihPhase get current => phases[phase];
  int get goal => phases.fold(0, (a, p) => a + p.target);

  /// Total counted across phases.
  int get total {
    if (isComplete) return goal;
    var t = count;
    for (var i = 0; i < phase; i++) {
      t += phases[i].target;
    }
    return t;
  }

  /// Ring fill for the current phase.
  double get progress => isComplete ? 1 : count / current.target;

  /// The current phase is full but not yet advanced.
  bool get atPhaseEnd => !isComplete && count >= current.target && phase < phases.length - 1;

  /// Label for history: the phrase or "preset".
  String get label => custom ? current.transliteration : 'preset';

  (TasbihState, TasbihTap) tap() {
    if (isComplete) return (restart(), TasbihTap.restarted);
    // A tap during the short pause at a phase end moves on and counts.
    if (atPhaseEnd) return advance().tap();
    final n = count + 1;
    if (n >= current.target) {
      if (phase == phases.length - 1) {
        return (_copy(count: n, isComplete: true), TasbihTap.complete);
      }
      return (_copy(count: n), TasbihTap.phaseDone);
    }
    return (_copy(count: n), TasbihTap.counted);
  }

  TasbihState advance() => atPhaseEnd ? _copy(phase: phase + 1, count: 0) : this;

  TasbihState restart() => _copy(phase: 0, count: 0, isComplete: false);

  TasbihState _copy({int? phase, int? count, bool? isComplete}) => TasbihState(
        phases: phases,
        phase: phase ?? this.phase,
        count: count ?? this.count,
        isComplete: isComplete ?? this.isComplete,
        custom: custom,
      );
}
