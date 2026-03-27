String kanaToRomaji(String input) {
  final text = _normalizeKana(input);
  if (text.isEmpty) {
    return '';
  }

  final buffer = StringBuffer();
  var pendingGeminate = false;
  var lastVowel = '';

  for (var index = 0; index < text.length; index++) {
    final current = text[index];

    if (current == 'っ') {
      pendingGeminate = true;
      continue;
    }

    if (current == 'ー') {
      if (lastVowel.isNotEmpty) {
        buffer.write(lastVowel);
      }
      continue;
    }

    String? romaji;
    if (index + 1 < text.length) {
      final pair = text.substring(index, index + 2);
      romaji = _compoundKana[pair];
      if (romaji != null) {
        index += 1;
      }
    }

    romaji ??= _singleKana[current];
    if (romaji == null) {
      buffer.write(current);
      pendingGeminate = false;
      continue;
    }

    if (pendingGeminate && romaji.isNotEmpty) {
      buffer.write(romaji[0]);
    }
    pendingGeminate = false;
    buffer.write(romaji);
    lastVowel = _lastVowel(romaji);
  }

  return buffer.toString();
}

String _normalizeKana(String input) {
  final lower = input.trim().toLowerCase();
  if (lower.isEmpty) {
    return '';
  }

  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    if (rune >= 0x30A1 && rune <= 0x30F6) {
      buffer.writeCharCode(rune - 0x60);
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}

String _lastVowel(String value) {
  for (var index = value.length - 1; index >= 0; index--) {
    final char = value[index];
    if (char == 'a' ||
        char == 'e' ||
        char == 'i' ||
        char == 'o' ||
        char == 'u') {
      return char;
    }
  }
  return '';
}

const Map<String, String> _compoundKana = {
  'きゃ': 'kya',
  'きゅ': 'kyu',
  'きょ': 'kyo',
  'ぎゃ': 'gya',
  'ぎゅ': 'gyu',
  'ぎょ': 'gyo',
  'しゃ': 'sha',
  'しゅ': 'shu',
  'しょ': 'sho',
  'じゃ': 'ja',
  'じゅ': 'ju',
  'じょ': 'jo',
  'ちゃ': 'cha',
  'ちゅ': 'chu',
  'ちょ': 'cho',
  'にゃ': 'nya',
  'にゅ': 'nyu',
  'にょ': 'nyo',
  'ひゃ': 'hya',
  'ひゅ': 'hyu',
  'ひょ': 'hyo',
  'びゃ': 'bya',
  'びゅ': 'byu',
  'びょ': 'byo',
  'ぴゃ': 'pya',
  'ぴゅ': 'pyu',
  'ぴょ': 'pyo',
  'みゃ': 'mya',
  'みゅ': 'myu',
  'みょ': 'myo',
  'りゃ': 'rya',
  'りゅ': 'ryu',
  'りょ': 'ryo',
  'う゛ぁ': 'va',
  'う゛ぃ': 'vi',
  'う゛ぇ': 've',
  'う゛ぉ': 'vo',
  'てぃ': 'ti',
  'でぃ': 'di',
  'とぅ': 'tu',
  'どぅ': 'du',
  'ふぁ': 'fa',
  'ふぃ': 'fi',
  'ふぇ': 'fe',
  'ふぉ': 'fo',
  'しぇ': 'she',
  'じぇ': 'je',
  'ちぇ': 'che',
  'つぁ': 'tsa',
  'つぃ': 'tsi',
  'つぇ': 'tse',
  'つぉ': 'tso',
};

const Map<String, String> _singleKana = {
  'あ': 'a',
  'い': 'i',
  'う': 'u',
  'え': 'e',
  'お': 'o',
  'か': 'ka',
  'き': 'ki',
  'く': 'ku',
  'け': 'ke',
  'こ': 'ko',
  'が': 'ga',
  'ぎ': 'gi',
  'ぐ': 'gu',
  'げ': 'ge',
  'ご': 'go',
  'さ': 'sa',
  'し': 'shi',
  'す': 'su',
  'せ': 'se',
  'そ': 'so',
  'ざ': 'za',
  'じ': 'ji',
  'ず': 'zu',
  'ぜ': 'ze',
  'ぞ': 'zo',
  'た': 'ta',
  'ち': 'chi',
  'つ': 'tsu',
  'て': 'te',
  'と': 'to',
  'だ': 'da',
  'ぢ': 'ji',
  'づ': 'zu',
  'で': 'de',
  'ど': 'do',
  'な': 'na',
  'に': 'ni',
  'ぬ': 'nu',
  'ね': 'ne',
  'の': 'no',
  'は': 'ha',
  'ひ': 'hi',
  'ふ': 'fu',
  'へ': 'he',
  'ほ': 'ho',
  'ば': 'ba',
  'び': 'bi',
  'ぶ': 'bu',
  'べ': 'be',
  'ぼ': 'bo',
  'ぱ': 'pa',
  'ぴ': 'pi',
  'ぷ': 'pu',
  'ぺ': 'pe',
  'ぽ': 'po',
  'ま': 'ma',
  'み': 'mi',
  'む': 'mu',
  'め': 'me',
  'も': 'mo',
  'や': 'ya',
  'ゆ': 'yu',
  'よ': 'yo',
  'ら': 'ra',
  'り': 'ri',
  'る': 'ru',
  'れ': 're',
  'ろ': 'ro',
  'わ': 'wa',
  'を': 'o',
  'ん': 'n',
  'ゔ': 'vu',
  'ぁ': 'a',
  'ぃ': 'i',
  'ぅ': 'u',
  'ぇ': 'e',
  'ぉ': 'o',
  'ゃ': 'ya',
  'ゅ': 'yu',
  'ょ': 'yo',
};
