String normalizeGrammarTitleEn(String? raw) {
  var value = (raw ?? '').trim();
  if (value.isEmpty) {
    return value;
  }

  const replacements = <String, String>{
    'N exists / is understood (ga arimasu/wakarimasu)':
        'N exists / is understood (が あります / わかります)',
    'Yes/No Responses (Sou desu)': 'Yes/No Responses (そうです)',
    'What? (nan/nani)': 'What? (何 / なん / なに)',
    'What (nan/nani)': 'What (何 / なん / なに)',
    'Because (kara)': 'Because (から)',
    'Why? (Doushite)': 'Why? (どうして)',
    'Become (narimasu)': 'Become (なります)',
    'Dictionary Form (V-ru)': 'Dictionary Form (V-る)',
    'Before ... (mae ni)': 'Before ... (前に)',
    'After ... (ato de)': 'After ... (あとで)',
    'By means of transport (Particle de)': 'By means of transport (Particle で)',
    'Action at a place (Particle de)': 'Action at a place (Particle で)',
    'With N (Tool/Means) (Particle de)': 'With N (Tool/Means) (Particle で)',
    'Going on foot (aruite)': 'Going on foot (歩いて)',
    'When (itsu)': 'When (いつ)',
    'If/When (tara)': 'If/When (たら)',
    'Even if ... (temo)': 'Even if ... (ても)',
    'What should I do? (doushitara)': 'What should I do? (どうしたら)',
    'How is...? (Dou desu ka)': 'How is...? (どうですか)',
    'Where / Which way (doko/dochira)': 'Where / Which way (どこ / どちら)',
    'To exist (imasu/arimasu)': 'To exist (います / あります)',
    'Only (dake)': 'Only (だけ)',
    'How long/much? (Donokurai)': 'How long/much? (どのくらい)',
    'Want (hoshii)': 'Want (ほしい)',
    'Want to do (V-tai)': 'Want to do (V-たい)',
    'To Give (Agemasu)': 'To Give (あげます)',
    'To Receive (Moraimasu)': 'To Receive (もらいます)',
    'Already (Mou V-mashita)': 'Already (もう V-ました)',
    'State of being (V-te imasu)': 'State of being (V-ています)',
    'State of being (V-te arimasu - Transitive)':
        'State of being (V-てあります - Transitive)',
    'State of being (V-te imasu - Intransitive)':
        'State of being (V-ています - Intransitive)',
    'N o V (Transitive Verbs)': 'N を V (Transitive Verbs)',
    'Do N (N o shimasu)': 'Do N (N を します)',
    'What do you do? (Nani o shimasu ka)': 'What do you do? (何をしますか)',
    'Doing with someone (Particle to)': 'Doing with someone (Particle と)',
    'N1 and N2 (Particle to)': 'N1 and N2 (Particle と)',
    'Adverbs of Degree (yoku, daitai, etc.)':
        'Adverbs of Degree (よく, だいたい, etc.)',
    '..., but ... (Particle ga)': '..., but ... (Particle が)',
    'To give me (kuremasu)': 'To give me (くれます)',
    'Do ... for someone (V-te agemasu)': 'Do ... for someone (V-てあげます)',
    'Get someone to do ... (V-te moraimasu)':
        'Get someone to do ... (V-てもらいます)',
    'Someone does ... for me (V-te kuremasu)':
        'Someone does ... for me (V-てくれます)',
    'When (toki)': 'When (とき)',
    'V-ru/V-ta toki (Time Difference)': 'V-る / V-た とき (Time Difference)',
    '..., but (kedo)': '..., but (けど)',
    'And, and (shi)': 'And, and (し)',
    'Intend to (tsumori)': 'Intend to (つもり)',
    'Plan/Schedule (yotei)': 'Plan/Schedule (予定)',
    'While (nagara)': 'While (ながら)',
    'Habitual Action (V-te imasu)': 'Habitual Action (V-ています)',
    'Try doing ... (V-te mimasu)': 'Try doing ... (V-てみます)',
    'To finish completely / Regret (shimaimashita)':
        'To finish completely / Regret (しまいました)',
    'Go and come back (V-te kimasu)': 'Go and come back (V-てきます)',
    'Only (shika ... masen)': 'Only (しか ... ません)',
    'Probably ... (deshou)': 'Probably ... (でしょう)',
    'Might ... (kamoshiremasen)': 'Might ... (かもしれません)',
    'Just as ... (toori ni)': 'Just as ... (とおりに)',
    'Read as ... (yomimasu)': 'Read as ... (よみます)',
    'Even though ... (noni - Complaint/Surprise)':
        'Even though ... (のに - Complaint/Surprise)',
    'Too much ... (sugimasu)': 'Too much ... (すぎます)',
    'I hear that ... (sou desu - Hearsay)': 'I hear that ... (そうです - Hearsay)',
    'It seems/looks like ... (you desu)': 'It seems/looks like ... (ようです)',
    'Looks like ... (sou desu)': 'Looks like ... (そうです)',
    'Just about to / In the middle / Just finished (tokoro)':
        'Just about to / In the middle / Just finished (ところ)',
    'Just did ... (bakari - Feeling)': 'Just did ... (ばかり - Feeling)',
    'Surely / Should be (hazu)': 'Surely / Should be (はず)',
    'For / In order to (tameni)': 'For / In order to (ために)',
    'For (noni - Usage)': 'For (のに - Usage)',
    'So that ... (youni - Purpose)': 'So that ... (ように - Purpose)',
    'Try to ... (youni shite imasu)': 'Try to ... (ように しています)',
    'Nominalization (no)': 'Nominalization (の)',
    'Forgot to ... (no o wasuremashita)': 'Forgot to ... (のを 忘れました)',
    '~ n desu (Explanation/Emphasis)': '〜んです (Explanation/Emphasis)',
    'Conditional Form (ba)': 'Conditional Form (ば)',
    'In case/event of ... (baai)': 'In case/event of ... (場合)',
    'Honorifics (Sonkeigo)': 'Honorifics (尊敬語)',
    'Humble Language (Kenjougo)': 'Humble Language (謙譲語)',
    'Causative Form (Shieki)': 'Causative Form (使役形)',
    'yaru (give downward)': 'やる (give downward)',
    'kudasaru / kudasaimashita': 'くださる / くださいました',
    'itadaku / itadakimashita': 'いただく / いただきました',
    '~te kudasaru (someone does for me)': '~てくださる (someone does for me)',
  };

  replacements.forEach((oldValue, newValue) {
    value = value.replaceAll(oldValue, newValue);
  });

  const tokenReplacements = <String, String>{
    'V-ru': 'V-る',
    'V-tai': 'V-たい',
    'V-nai': 'V-ない',
    'V-ta': 'V-た',
    'V-te': 'V-て',
    'V-masu': 'V-ます',
    'V-mashita': 'V-ました',
    'A-na': 'A-な',
    'A-i': 'A-い',
    '~te': '~て',
  };

  tokenReplacements.forEach((oldValue, newValue) {
    value = value.replaceAll(oldValue, newValue);
  });

  return value.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
}

String normalizeGrammarStructureEn(String? raw) {
  var value = (raw ?? '').trim();
  if (value.isEmpty) {
    return value;
  }

  const exactReplacements = <String, String>{
    'kore / sore / are wa nan desu ka': 'これ / それ / あれ は 何ですか',
    '"~" wa [Language] de nan desu ka': '"~" は [Language] で 何ですか',
    'N1 と N2 to dochira ga A desu ka': 'N1 と N2 と どちらが A ですか',
    'V-て mo ii desu ka': 'V-てもいいですか',
    'V-て wa ikemasen': 'V-てはいけません',
    'V-て imasu': 'V-ています',
    'V-て iru': 'V-ている',
    'V-て arimasu': 'V-てあります',
    'V-て okimasu': 'V-ておきます',
    'V-て shimaimashita': 'V-てしまいました',
    'V-て mimasu': 'V-てみます',
    'V-て agemasu': 'V-てあげます',
    'V-て moraimasu': 'V-てもらいます',
    'V-ないde kudasai': 'V-ないでください',
    'V-る koto ga dekimasu': 'V-る ことができます',
    'V-た koto ga arimasu': 'V-た ことがあります',
    'V-る toki vs V-た toki': 'V-る とき vs V-た とき',
    'V-る / N の / Time + mae に, V2': 'V-る / N の / Time + 前に, V2',
    'V-る / N の / Time + mae ni, V2': 'V-る / N の / Time + 前に, V2',
    'V-る / V-て iru / V-た + tokoro desu': 'V-る / V-ている / V-た + ところです',
    'V-た + bakari desu': 'V-た + ばかりです',
    'V-た / V-ない + hou ga ii desu': 'V-た / V-ない + ほうがいいです',
    'V-る / V-ない + you ni, ~': 'V-る / V-ない + ように, ~',
    'V-る (Potential) + you ni narimashita': 'V-る (Potential) + ように なりました',
    'V-る / V-ない + you ni shite imasu': 'V-る / V-ない + ように しています',
    'V-る / N + noni + ...': 'V-る / N + のに + ...',
    'V-る / N no + tameni, ~': 'V-る / N の + ために, ~',
    'V-る / N no + yotei desu': 'V-る / N の + 予定です',
    'V-る / V-ない + tsumori desu': 'V-る / V-ない + つもりです',
    'V-る / V-た / N no + toori ni, V2': 'V-る / V-た / N の + とおりに, V2',
    'V-た / N no + ato de, V2': 'V-た / N の + あとで, V2',
    'S (Plain) / "Quote" + to itte imashita': 'S (Plain) / "Quote" + と言っていました',
    '"Quote" / S (Plain Form) to iimashita': '"Quote" / S (Plain Form) と言いました',
    'S desu ka → hai, sou desu / iie, sou ja arimasen':
        'S ですか → はい、そうです / いいえ、そうじゃありません',
    'Doko [e] mo ikimasen': 'どこ [へ] も いきません',
    'aruite ikimasu': '歩いて いきます',
    'N shika + V (Negative)': 'N しか + V (Negative)',
    'N nara': 'N なら',
    'N dake': 'N だけ',
    'N ga arimasu / wakarimasu': 'N が あります / わかります',
    'N ga suki/kirai/jouzu/heta desu': 'N が 好き / 嫌い / 上手 / 下手 です',
    'donna N ga suki desu ka': 'どんな N が 好きですか',
    'N ga hoshii desu': 'N が ほしいです',
    'N ga imasu / arimasu': 'N が います / あります',
    'N (Person) ni [N (Thing) o] agemasu': 'N (Person) に [N (Thing) を] あげます',
    'N (Person) ni [N (Thing) o] moraimasu': 'N (Person) に [N (Thing) を] もらいます',
    'Mou V-mashita': 'もう V-ました',
    'N (Place) e ikimasu / kimasu / kaerimasu':
        'N (Place) へ いきます / きます / かえります',
    'N (Transport) de ikimasu / kimasu / kaerimasu':
        'N (Transport) で いきます / きます / かえります',
    'N o V (transitive verb)': 'N を V (transitive verb)',
    'N o shimasu': 'N を します',
    'Nani o shimasu ka': '何をしますか',
    'V-causative-て itadakemasen ka': 'V-使役形 + ていただけませんか',
  };

  exactReplacements.forEach((oldValue, newValue) {
    value = value.replaceAll(oldValue, newValue);
  });

  const simpleReplacements = <String, String>{
    'V-ru': 'V-る',
    'V-tai': 'V-たい',
    'V-nai': 'V-ない',
    'V-ta': 'V-た',
    'V-te': 'V-て',
    'V-ba': 'V-ば',
    'V-masu': 'V-ます',
    'V-masen ka': 'V-ませんか',
    'V-mashou ka': 'V-ましょうか',
    'V-mashou': 'V-ましょう',
    'V-mashita': 'V-ました',
    'A-na': 'A-な',
    'A-i': 'A-い',
    'A-kutemo': 'A-くても',
    'A-katta': 'A-かった',
    'A-kereba': 'A-ければ',
    'A-kute': 'A-くて',
    'A-ni': 'A-に',
    'noni': 'のに',
    'tameni': 'ために',
    'toki': 'とき',
    'koto': 'こと',
    'you ni': 'ように',
    'tokoro desu': 'ところです',
    'bakari desu': 'ばかりです',
    'tsumori desu': 'つもりです',
    'yotei desu': '予定です',
    'toori ni': 'とおりに',
    'ato de': 'あとで',
    'mae ni': '前に',
    'mae': '前',
    'shika': 'しか',
    'dake': 'だけ',
    'nara': 'なら',
    'moraimasu': 'もらいます',
    'agemasu': 'あげます',
    'kuremasu': 'くれます',
    'kudasai': 'ください',
    'ikimasu': 'いきます',
    'kimasu': 'きます',
    'kaerimasu': 'かえります',
    'wakarimasu': 'わかります',
    'arimasu': 'あります',
    'imasu': 'います',
    'dochira': 'どちら',
    'doko': 'どこ',
    'donokurai': 'どのくらい',
    'aruite': '歩いて',
  };

  simpleReplacements.forEach((oldValue, newValue) {
    value = value.replaceAll(oldValue, newValue);
  });

  final regexReplacements = <Pattern, String>{
    RegExp(r'\bdesu ka\b'): 'ですか',
    RegExp(r'\bdesu\b'): 'です',
    RegExp(r'\bwa\b'): 'は',
    RegExp(r'\bga\b'): 'が',
    RegExp(r'\bni\b'): 'に',
    RegExp(r'\bde\b'): 'で',
    RegExp(r'\bto\b'): 'と',
    RegExp(r'\bmo\b'): 'も',
    RegExp(r'\bno\b'): 'の',
    RegExp(r'\bo\b'): 'を',
    RegExp(r'\be\b'): 'へ',
    RegExp(r'\bnan\b'): '何',
    RegExp(r'\bnani\b'): 'なに',
    RegExp(r'\bitsu\b'): 'いつ',
    RegExp(r'\bmou\b'): 'もう',
  };

  regexReplacements.forEach((pattern, replacement) {
    value = value.replaceAll(pattern, replacement);
  });

  return value.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
}

String resolveCanonicalGrammarPointSource({
  String? grammarPoint,
  String? structure,
  String? title,
  String? structureEn,
  String? titleEn,
}) {
  final japaneseFirstCandidates = <String>[
    _cleanCanonicalGrammarCandidate(grammarPoint),
    _cleanCanonicalGrammarCandidate(structure),
    _cleanCanonicalGrammarCandidate(title),
  ];

  for (final candidate in japaneseFirstCandidates) {
    if (candidate.isEmpty) continue;
    if (containsVietnameseGrammarText(candidate)) continue;
    if (_hasJapaneseOrGrammarPlaceholder(candidate)) {
      return candidate;
    }
  }

  for (final candidate in japaneseFirstCandidates) {
    if (candidate.isEmpty) continue;
    if (!containsVietnameseGrammarText(candidate)) {
      return candidate;
    }
  }

  final englishFallbacks = <String>[
    normalizeGrammarStructureEn(structureEn),
    normalizeGrammarTitleEn(titleEn),
  ];
  for (final candidate in englishFallbacks) {
    if (candidate.isEmpty) continue;
    if (!containsVietnameseGrammarText(candidate)) {
      return candidate;
    }
  }

  final rawFallbacks = <String>[
    (grammarPoint ?? '').trim(),
    (structure ?? '').trim(),
    (title ?? '').trim(),
  ];
  for (final candidate in rawFallbacks) {
    if (candidate.isNotEmpty) {
      return candidate;
    }
  }

  return '';
}

String stripNonCanonicalGrammarNotes(String? raw) {
  var value = (raw ?? '').trim();
  if (value.isEmpty) {
    return value;
  }

  value = value.replaceAllMapped(RegExp(r'[（(]([^()（）]*)[)）]'), (match) {
    final inner = (match.group(1) ?? '').trim();
    if (inner.isEmpty) {
      return '';
    }
    if (_containsLatin(inner) || containsVietnameseGrammarText(inner)) {
      return '';
    }
    return match.group(0) ?? '';
  });

  const replacements = <String, String>{
    'Số lượng từ': '数量詞',
    'số lượng từ': '数量詞',
    '（数量詞）': '',
    '(数量詞)': '',
    '（Only）': '',
    '(Only)': '',
    '（Tồn tại）': '',
    '(Tồn tại)': '',
    '（Vân vân）': '',
    '(Vân vân)': '',
  };
  replacements.forEach((from, to) {
    value = value.replaceAll(from, to);
  });

  value = value
      .replaceAllMapped(RegExp(r'\s*/\s*'), (_) => ' / ')
      .replaceAllMapped(RegExp(r'\s*,\s*'), (_) => ', ')
      .replaceAllMapped(RegExp(r'\s*\+\s*'), (_) => ' + ')
      .replaceAll(RegExp(r'\s{2,}'), ' ')
      .trim();

  return value;
}

final RegExp _vietnameseGrammarTextPattern = RegExp(
  r'[ăâđêôơưĂÂĐÊÔƠƯáàảãạấầẩẫậắằẳẵặéèẻẽẹếềểễệ'
  r'íìỉĩịóòỏõọốồổỗộớờởỡợúùủũụứừửữựýỳỷỹỵ]',
);

const List<String> _vietnameseGrammarKeywords = <String>[
  'địa điểm',
  'vật/người',
  'vật',
  'người',
  'mục đích',
  'so sánh',
  'muốn',
  'trợ từ',
  'động từ',
  'danh từ',
  'tính từ',
  'thời gian',
  'vị trí',
  'phương hướng',
  'liệt kê',
  'diễn tả',
  'ngữ pháp',
  'ví dụ',
  'câu đúng',
  'câu sai',
];

bool containsVietnameseGrammarText(String? raw) {
  final value = (raw ?? '').trim();
  if (value.isEmpty) {
    return false;
  }
  if (_vietnameseGrammarTextPattern.hasMatch(value)) {
    return true;
  }

  final lowered = value.toLowerCase();
  return _vietnameseGrammarKeywords.any(lowered.contains);
}

bool _containsLatin(String value) => RegExp(r'[A-Za-z]').hasMatch(value);

bool _hasJapaneseOrGrammarPlaceholder(String value) {
  return RegExp(
    r'[ぁ-ゖァ-ヶ一-龯々ー]|(^|[^A-Za-z])(N\d*|V\d*|A\d*|S\d*)(?=$|[^A-Za-z])',
  ).hasMatch(value);
}

String _cleanCanonicalGrammarCandidate(String? raw) {
  final value = stripNonCanonicalGrammarNotes(raw);
  return value.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
}

String resolveEnglishGrammarLabel({
  String? titleEn,
  String? meaningEn,
  String? connectionEn,
  String? connection,
  String? grammarPoint,
}) {
  final candidates = <String>[
    _cleanEnglishGrammarLabel(titleEn),
    _cleanJapaneseGrammarFallback(grammarPoint),
    _cleanEnglishGrammarStructure(connectionEn),
    _cleanEnglishGrammarLabel(meaningEn),
    _cleanJapaneseGrammarFallback(connection),
  ];

  for (final candidate in candidates) {
    if (candidate.isNotEmpty) {
      return candidate;
    }
  }
  return 'Target pattern';
}

String resolveEnglishGrammarMeaning({
  String? meaningEn,
  String? titleEn,
  String? connectionEn,
  String? connection,
  String? grammarPoint,
}) {
  final candidates = <String>[
    _cleanEnglishGrammarLabel(meaningEn),
    _cleanEnglishGrammarLabel(titleEn),
    _cleanEnglishGrammarStructure(connectionEn),
    _cleanJapaneseGrammarFallback(connection),
    _cleanJapaneseGrammarFallback(grammarPoint),
  ];

  for (final candidate in candidates) {
    if (candidate.isNotEmpty) {
      return candidate;
    }
  }
  return 'Target pattern';
}

String resolveEnglishGrammarConnection({
  String? connectionEn,
  String? connection,
  String? grammarPoint,
  String? titleEn,
  String? meaningEn,
}) {
  final candidates = <String>[
    _cleanEnglishGrammarStructure(connectionEn),
    _cleanJapaneseGrammarFallback(connection),
    _cleanJapaneseGrammarFallback(grammarPoint),
    _cleanEnglishGrammarLabel(titleEn),
    _cleanEnglishGrammarLabel(meaningEn),
  ];

  for (final candidate in candidates) {
    if (candidate.isNotEmpty) {
      return candidate;
    }
  }
  return 'Grammar pattern';
}

String resolveEnglishGrammarExplanation({
  String? explanationEn,
  String? explanation,
  String? label,
}) {
  final candidates = <String>[
    _cleanEnglishFreeText(explanationEn),
    _cleanEnglishFreeText(explanation),
  ];

  for (final candidate in candidates) {
    if (candidate.isNotEmpty) {
      return candidate;
    }
  }

  final cleanedLabel = (label ?? '').trim();
  if (cleanedLabel.isNotEmpty) {
    return 'Use $cleanedLabel in the right context.';
  }
  return 'Use the target pattern in the right context.';
}

String resolveEnglishGrammarExampleTranslation({
  required String japanese,
  String? translationEn,
  String? translation,
}) {
  final candidates = <String>[
    _cleanEnglishFreeText(translationEn),
    _cleanEnglishFreeText(translation),
  ];

  for (final candidate in candidates) {
    if (candidate.isNotEmpty) {
      return candidate;
    }
  }

  return japanese.trim();
}

String _cleanEnglishGrammarLabel(String? raw) {
  final value = normalizeGrammarTitleEn(raw);
  if (value.isEmpty || containsVietnameseGrammarText(value)) {
    return '';
  }
  return value;
}

String _cleanEnglishGrammarStructure(String? raw) {
  final value = normalizeGrammarStructureEn(raw);
  if (value.isEmpty || containsVietnameseGrammarText(value)) {
    return '';
  }
  return value;
}

String _cleanJapaneseGrammarFallback(String? raw) {
  final value = normalizeGrammarStructureEn(raw);
  if (value.isEmpty || containsVietnameseGrammarText(value)) {
    return '';
  }
  return value;
}

String _cleanEnglishFreeText(String? raw) {
  final value = (raw ?? '').trim();
  if (value.isEmpty || containsVietnameseGrammarText(value)) {
    return '';
  }
  return value;
}
