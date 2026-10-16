String removeDiacritics(String input) {
  String s = input;
  const diacritics = [
    '\u064B',
    '\u064C',
    '\u064D',
    '\u064E',
    '\u064F',
    '\u0650',
    '\u0651',
    '\u0652',
    '\u0670',
    '\u06D6',
    '\u06D7',
    '\u06D8',
  ];
  for (var d in diacritics) {
    s = s.replaceAll(d, '');
  }
  return s;
}
