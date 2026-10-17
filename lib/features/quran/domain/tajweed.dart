/// A run of ayah text, optionally marked with a tajweed rule class
/// (`ghunnah`, `qalaqah`, `ikhafa`…).
typedef TajweedRun = ({String text, String? rule});

final _tag = RegExp(r'<tajweed class=(\w+)>(.*?)</tajweed>', dotAll: true);

/// Splits `plain <tajweed class=x>marked</tajweed> plain` markup (see
/// tool/build_tajweed.dart) into runs. Text outside tags has a null rule.
List<TajweedRun> parseTajweed(String tagged) {
  final out = <TajweedRun>[];
  var pos = 0;
  for (final m in _tag.allMatches(tagged)) {
    if (m.start > pos) out.add((text: tagged.substring(pos, m.start), rule: null));
    out.add((text: m.group(2)!, rule: m.group(1)));
    pos = m.end;
  }
  if (pos < tagged.length) out.add((text: tagged.substring(pos), rule: null));
  return out;
}
