// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_database.dart';

// ignore_for_file: type=lint
class $VocabTable extends Vocab with TableInfo<$VocabTable, VocabData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VocabTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _termMeta = const VerificationMeta('term');
  @override
  late final GeneratedColumn<String> term = GeneratedColumn<String>(
    'term',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readingMeta = const VerificationMeta(
    'reading',
  );
  @override
  late final GeneratedColumn<String> reading = GeneratedColumn<String>(
    'reading',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _meaningMeta = const VerificationMeta(
    'meaning',
  );
  @override
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
    'meaning',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meaningEnMeta = const VerificationMeta(
    'meaningEn',
  );
  @override
  late final GeneratedColumn<String> meaningEn = GeneratedColumn<String>(
    'meaning_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kanjiMeaningMeta = const VerificationMeta(
    'kanjiMeaning',
  );
  @override
  late final GeneratedColumn<String> kanjiMeaning = GeneratedColumn<String>(
    'kanji_meaning',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceVocabIdMeta = const VerificationMeta(
    'sourceVocabId',
  );
  @override
  late final GeneratedColumn<String> sourceVocabId = GeneratedColumn<String>(
    'source_vocab_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceSenseIdMeta = const VerificationMeta(
    'sourceSenseId',
  );
  @override
  late final GeneratedColumn<String> sourceSenseId = GeneratedColumn<String>(
    'source_sense_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seriesMeta = const VerificationMeta('series');
  @override
  late final GeneratedColumn<String> series = GeneratedColumn<String>(
    'series',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('minna'),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    term,
    reading,
    meaning,
    meaningEn,
    kanjiMeaning,
    sourceVocabId,
    sourceSenseId,
    series,
    level,
    tags,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vocab';
  @override
  VerificationContext validateIntegrity(
    Insertable<VocabData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('term')) {
      context.handle(
        _termMeta,
        term.isAcceptableOrUnknown(data['term']!, _termMeta),
      );
    } else if (isInserting) {
      context.missing(_termMeta);
    }
    if (data.containsKey('reading')) {
      context.handle(
        _readingMeta,
        reading.isAcceptableOrUnknown(data['reading']!, _readingMeta),
      );
    }
    if (data.containsKey('meaning')) {
      context.handle(
        _meaningMeta,
        meaning.isAcceptableOrUnknown(data['meaning']!, _meaningMeta),
      );
    } else if (isInserting) {
      context.missing(_meaningMeta);
    }
    if (data.containsKey('meaning_en')) {
      context.handle(
        _meaningEnMeta,
        meaningEn.isAcceptableOrUnknown(data['meaning_en']!, _meaningEnMeta),
      );
    }
    if (data.containsKey('kanji_meaning')) {
      context.handle(
        _kanjiMeaningMeta,
        kanjiMeaning.isAcceptableOrUnknown(
          data['kanji_meaning']!,
          _kanjiMeaningMeta,
        ),
      );
    }
    if (data.containsKey('source_vocab_id')) {
      context.handle(
        _sourceVocabIdMeta,
        sourceVocabId.isAcceptableOrUnknown(
          data['source_vocab_id']!,
          _sourceVocabIdMeta,
        ),
      );
    }
    if (data.containsKey('source_sense_id')) {
      context.handle(
        _sourceSenseIdMeta,
        sourceSenseId.isAcceptableOrUnknown(
          data['source_sense_id']!,
          _sourceSenseIdMeta,
        ),
      );
    }
    if (data.containsKey('series')) {
      context.handle(
        _seriesMeta,
        series.isAcceptableOrUnknown(data['series']!, _seriesMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VocabData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VocabData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      term: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term'],
      )!,
      reading: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reading'],
      ),
      meaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning'],
      )!,
      meaningEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning_en'],
      ),
      kanjiMeaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kanji_meaning'],
      ),
      sourceVocabId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_vocab_id'],
      ),
      sourceSenseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_sense_id'],
      ),
      series: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
    );
  }

  @override
  $VocabTable createAlias(String alias) {
    return $VocabTable(attachedDatabase, alias);
  }
}

class VocabData extends DataClass implements Insertable<VocabData> {
  final int id;
  final String term;
  final String? reading;
  final String meaning;
  final String? meaningEn;
  final String? kanjiMeaning;
  final String? sourceVocabId;
  final String? sourceSenseId;
  final String series;
  final String level;
  final String? tags;
  const VocabData({
    required this.id,
    required this.term,
    this.reading,
    required this.meaning,
    this.meaningEn,
    this.kanjiMeaning,
    this.sourceVocabId,
    this.sourceSenseId,
    required this.series,
    required this.level,
    this.tags,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['term'] = Variable<String>(term);
    if (!nullToAbsent || reading != null) {
      map['reading'] = Variable<String>(reading);
    }
    map['meaning'] = Variable<String>(meaning);
    if (!nullToAbsent || meaningEn != null) {
      map['meaning_en'] = Variable<String>(meaningEn);
    }
    if (!nullToAbsent || kanjiMeaning != null) {
      map['kanji_meaning'] = Variable<String>(kanjiMeaning);
    }
    if (!nullToAbsent || sourceVocabId != null) {
      map['source_vocab_id'] = Variable<String>(sourceVocabId);
    }
    if (!nullToAbsent || sourceSenseId != null) {
      map['source_sense_id'] = Variable<String>(sourceSenseId);
    }
    map['series'] = Variable<String>(series);
    map['level'] = Variable<String>(level);
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    return map;
  }

  VocabCompanion toCompanion(bool nullToAbsent) {
    return VocabCompanion(
      id: Value(id),
      term: Value(term),
      reading: reading == null && nullToAbsent
          ? const Value.absent()
          : Value(reading),
      meaning: Value(meaning),
      meaningEn: meaningEn == null && nullToAbsent
          ? const Value.absent()
          : Value(meaningEn),
      kanjiMeaning: kanjiMeaning == null && nullToAbsent
          ? const Value.absent()
          : Value(kanjiMeaning),
      sourceVocabId: sourceVocabId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceVocabId),
      sourceSenseId: sourceSenseId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceSenseId),
      series: Value(series),
      level: Value(level),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
    );
  }

  factory VocabData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VocabData(
      id: serializer.fromJson<int>(json['id']),
      term: serializer.fromJson<String>(json['term']),
      reading: serializer.fromJson<String?>(json['reading']),
      meaning: serializer.fromJson<String>(json['meaning']),
      meaningEn: serializer.fromJson<String?>(json['meaningEn']),
      kanjiMeaning: serializer.fromJson<String?>(json['kanjiMeaning']),
      sourceVocabId: serializer.fromJson<String?>(json['sourceVocabId']),
      sourceSenseId: serializer.fromJson<String?>(json['sourceSenseId']),
      series: serializer.fromJson<String>(json['series']),
      level: serializer.fromJson<String>(json['level']),
      tags: serializer.fromJson<String?>(json['tags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'term': serializer.toJson<String>(term),
      'reading': serializer.toJson<String?>(reading),
      'meaning': serializer.toJson<String>(meaning),
      'meaningEn': serializer.toJson<String?>(meaningEn),
      'kanjiMeaning': serializer.toJson<String?>(kanjiMeaning),
      'sourceVocabId': serializer.toJson<String?>(sourceVocabId),
      'sourceSenseId': serializer.toJson<String?>(sourceSenseId),
      'series': serializer.toJson<String>(series),
      'level': serializer.toJson<String>(level),
      'tags': serializer.toJson<String?>(tags),
    };
  }

  VocabData copyWith({
    int? id,
    String? term,
    Value<String?> reading = const Value.absent(),
    String? meaning,
    Value<String?> meaningEn = const Value.absent(),
    Value<String?> kanjiMeaning = const Value.absent(),
    Value<String?> sourceVocabId = const Value.absent(),
    Value<String?> sourceSenseId = const Value.absent(),
    String? series,
    String? level,
    Value<String?> tags = const Value.absent(),
  }) => VocabData(
    id: id ?? this.id,
    term: term ?? this.term,
    reading: reading.present ? reading.value : this.reading,
    meaning: meaning ?? this.meaning,
    meaningEn: meaningEn.present ? meaningEn.value : this.meaningEn,
    kanjiMeaning: kanjiMeaning.present ? kanjiMeaning.value : this.kanjiMeaning,
    sourceVocabId: sourceVocabId.present
        ? sourceVocabId.value
        : this.sourceVocabId,
    sourceSenseId: sourceSenseId.present
        ? sourceSenseId.value
        : this.sourceSenseId,
    series: series ?? this.series,
    level: level ?? this.level,
    tags: tags.present ? tags.value : this.tags,
  );
  VocabData copyWithCompanion(VocabCompanion data) {
    return VocabData(
      id: data.id.present ? data.id.value : this.id,
      term: data.term.present ? data.term.value : this.term,
      reading: data.reading.present ? data.reading.value : this.reading,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      meaningEn: data.meaningEn.present ? data.meaningEn.value : this.meaningEn,
      kanjiMeaning: data.kanjiMeaning.present
          ? data.kanjiMeaning.value
          : this.kanjiMeaning,
      sourceVocabId: data.sourceVocabId.present
          ? data.sourceVocabId.value
          : this.sourceVocabId,
      sourceSenseId: data.sourceSenseId.present
          ? data.sourceSenseId.value
          : this.sourceSenseId,
      series: data.series.present ? data.series.value : this.series,
      level: data.level.present ? data.level.value : this.level,
      tags: data.tags.present ? data.tags.value : this.tags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VocabData(')
          ..write('id: $id, ')
          ..write('term: $term, ')
          ..write('reading: $reading, ')
          ..write('meaning: $meaning, ')
          ..write('meaningEn: $meaningEn, ')
          ..write('kanjiMeaning: $kanjiMeaning, ')
          ..write('sourceVocabId: $sourceVocabId, ')
          ..write('sourceSenseId: $sourceSenseId, ')
          ..write('series: $series, ')
          ..write('level: $level, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    term,
    reading,
    meaning,
    meaningEn,
    kanjiMeaning,
    sourceVocabId,
    sourceSenseId,
    series,
    level,
    tags,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VocabData &&
          other.id == this.id &&
          other.term == this.term &&
          other.reading == this.reading &&
          other.meaning == this.meaning &&
          other.meaningEn == this.meaningEn &&
          other.kanjiMeaning == this.kanjiMeaning &&
          other.sourceVocabId == this.sourceVocabId &&
          other.sourceSenseId == this.sourceSenseId &&
          other.series == this.series &&
          other.level == this.level &&
          other.tags == this.tags);
}

class VocabCompanion extends UpdateCompanion<VocabData> {
  final Value<int> id;
  final Value<String> term;
  final Value<String?> reading;
  final Value<String> meaning;
  final Value<String?> meaningEn;
  final Value<String?> kanjiMeaning;
  final Value<String?> sourceVocabId;
  final Value<String?> sourceSenseId;
  final Value<String> series;
  final Value<String> level;
  final Value<String?> tags;
  const VocabCompanion({
    this.id = const Value.absent(),
    this.term = const Value.absent(),
    this.reading = const Value.absent(),
    this.meaning = const Value.absent(),
    this.meaningEn = const Value.absent(),
    this.kanjiMeaning = const Value.absent(),
    this.sourceVocabId = const Value.absent(),
    this.sourceSenseId = const Value.absent(),
    this.series = const Value.absent(),
    this.level = const Value.absent(),
    this.tags = const Value.absent(),
  });
  VocabCompanion.insert({
    this.id = const Value.absent(),
    required String term,
    this.reading = const Value.absent(),
    required String meaning,
    this.meaningEn = const Value.absent(),
    this.kanjiMeaning = const Value.absent(),
    this.sourceVocabId = const Value.absent(),
    this.sourceSenseId = const Value.absent(),
    this.series = const Value.absent(),
    required String level,
    this.tags = const Value.absent(),
  }) : term = Value(term),
       meaning = Value(meaning),
       level = Value(level);
  static Insertable<VocabData> custom({
    Expression<int>? id,
    Expression<String>? term,
    Expression<String>? reading,
    Expression<String>? meaning,
    Expression<String>? meaningEn,
    Expression<String>? kanjiMeaning,
    Expression<String>? sourceVocabId,
    Expression<String>? sourceSenseId,
    Expression<String>? series,
    Expression<String>? level,
    Expression<String>? tags,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (term != null) 'term': term,
      if (reading != null) 'reading': reading,
      if (meaning != null) 'meaning': meaning,
      if (meaningEn != null) 'meaning_en': meaningEn,
      if (kanjiMeaning != null) 'kanji_meaning': kanjiMeaning,
      if (sourceVocabId != null) 'source_vocab_id': sourceVocabId,
      if (sourceSenseId != null) 'source_sense_id': sourceSenseId,
      if (series != null) 'series': series,
      if (level != null) 'level': level,
      if (tags != null) 'tags': tags,
    });
  }

  VocabCompanion copyWith({
    Value<int>? id,
    Value<String>? term,
    Value<String?>? reading,
    Value<String>? meaning,
    Value<String?>? meaningEn,
    Value<String?>? kanjiMeaning,
    Value<String?>? sourceVocabId,
    Value<String?>? sourceSenseId,
    Value<String>? series,
    Value<String>? level,
    Value<String?>? tags,
  }) {
    return VocabCompanion(
      id: id ?? this.id,
      term: term ?? this.term,
      reading: reading ?? this.reading,
      meaning: meaning ?? this.meaning,
      meaningEn: meaningEn ?? this.meaningEn,
      kanjiMeaning: kanjiMeaning ?? this.kanjiMeaning,
      sourceVocabId: sourceVocabId ?? this.sourceVocabId,
      sourceSenseId: sourceSenseId ?? this.sourceSenseId,
      series: series ?? this.series,
      level: level ?? this.level,
      tags: tags ?? this.tags,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (term.present) {
      map['term'] = Variable<String>(term.value);
    }
    if (reading.present) {
      map['reading'] = Variable<String>(reading.value);
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (meaningEn.present) {
      map['meaning_en'] = Variable<String>(meaningEn.value);
    }
    if (kanjiMeaning.present) {
      map['kanji_meaning'] = Variable<String>(kanjiMeaning.value);
    }
    if (sourceVocabId.present) {
      map['source_vocab_id'] = Variable<String>(sourceVocabId.value);
    }
    if (sourceSenseId.present) {
      map['source_sense_id'] = Variable<String>(sourceSenseId.value);
    }
    if (series.present) {
      map['series'] = Variable<String>(series.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VocabCompanion(')
          ..write('id: $id, ')
          ..write('term: $term, ')
          ..write('reading: $reading, ')
          ..write('meaning: $meaning, ')
          ..write('meaningEn: $meaningEn, ')
          ..write('kanjiMeaning: $kanjiMeaning, ')
          ..write('sourceVocabId: $sourceVocabId, ')
          ..write('sourceSenseId: $sourceSenseId, ')
          ..write('series: $series, ')
          ..write('level: $level, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }
}

class $GrammarPointTable extends GrammarPoint
    with TableInfo<$GrammarPointTable, GrammarPointData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GrammarPointTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<int> lessonId = GeneratedColumn<int>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleEnMeta = const VerificationMeta(
    'titleEn',
  );
  @override
  late final GeneratedColumn<String> titleEn = GeneratedColumn<String>(
    'title_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _structureMeta = const VerificationMeta(
    'structure',
  );
  @override
  late final GeneratedColumn<String> structure = GeneratedColumn<String>(
    'structure',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _structureEnMeta = const VerificationMeta(
    'structureEn',
  );
  @override
  late final GeneratedColumn<String> structureEn = GeneratedColumn<String>(
    'structure_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _explanationMeta = const VerificationMeta(
    'explanation',
  );
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
    'explanation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _explanationEnMeta = const VerificationMeta(
    'explanationEn',
  );
  @override
  late final GeneratedColumn<String> explanationEn = GeneratedColumn<String>(
    'explanation_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lessonId,
    title,
    titleEn,
    structure,
    structureEn,
    explanation,
    explanationEn,
    level,
    tags,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grammar_point';
  @override
  VerificationContext validateIntegrity(
    Insertable<GrammarPointData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('title_en')) {
      context.handle(
        _titleEnMeta,
        titleEn.isAcceptableOrUnknown(data['title_en']!, _titleEnMeta),
      );
    }
    if (data.containsKey('structure')) {
      context.handle(
        _structureMeta,
        structure.isAcceptableOrUnknown(data['structure']!, _structureMeta),
      );
    } else if (isInserting) {
      context.missing(_structureMeta);
    }
    if (data.containsKey('structure_en')) {
      context.handle(
        _structureEnMeta,
        structureEn.isAcceptableOrUnknown(
          data['structure_en']!,
          _structureEnMeta,
        ),
      );
    }
    if (data.containsKey('explanation')) {
      context.handle(
        _explanationMeta,
        explanation.isAcceptableOrUnknown(
          data['explanation']!,
          _explanationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_explanationMeta);
    }
    if (data.containsKey('explanation_en')) {
      context.handle(
        _explanationEnMeta,
        explanationEn.isAcceptableOrUnknown(
          data['explanation_en']!,
          _explanationEnMeta,
        ),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GrammarPointData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GrammarPointData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lesson_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      titleEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_en'],
      ),
      structure: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}structure'],
      )!,
      structureEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}structure_en'],
      ),
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      )!,
      explanationEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation_en'],
      ),
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
    );
  }

  @override
  $GrammarPointTable createAlias(String alias) {
    return $GrammarPointTable(attachedDatabase, alias);
  }
}

class GrammarPointData extends DataClass
    implements Insertable<GrammarPointData> {
  final int id;
  final int lessonId;
  final String title;
  final String? titleEn;
  final String structure;
  final String? structureEn;
  final String explanation;
  final String? explanationEn;
  final String level;
  final String? tags;
  const GrammarPointData({
    required this.id,
    required this.lessonId,
    required this.title,
    this.titleEn,
    required this.structure,
    this.structureEn,
    required this.explanation,
    this.explanationEn,
    required this.level,
    this.tags,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['lesson_id'] = Variable<int>(lessonId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || titleEn != null) {
      map['title_en'] = Variable<String>(titleEn);
    }
    map['structure'] = Variable<String>(structure);
    if (!nullToAbsent || structureEn != null) {
      map['structure_en'] = Variable<String>(structureEn);
    }
    map['explanation'] = Variable<String>(explanation);
    if (!nullToAbsent || explanationEn != null) {
      map['explanation_en'] = Variable<String>(explanationEn);
    }
    map['level'] = Variable<String>(level);
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    return map;
  }

  GrammarPointCompanion toCompanion(bool nullToAbsent) {
    return GrammarPointCompanion(
      id: Value(id),
      lessonId: Value(lessonId),
      title: Value(title),
      titleEn: titleEn == null && nullToAbsent
          ? const Value.absent()
          : Value(titleEn),
      structure: Value(structure),
      structureEn: structureEn == null && nullToAbsent
          ? const Value.absent()
          : Value(structureEn),
      explanation: Value(explanation),
      explanationEn: explanationEn == null && nullToAbsent
          ? const Value.absent()
          : Value(explanationEn),
      level: Value(level),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
    );
  }

  factory GrammarPointData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GrammarPointData(
      id: serializer.fromJson<int>(json['id']),
      lessonId: serializer.fromJson<int>(json['lessonId']),
      title: serializer.fromJson<String>(json['title']),
      titleEn: serializer.fromJson<String?>(json['titleEn']),
      structure: serializer.fromJson<String>(json['structure']),
      structureEn: serializer.fromJson<String?>(json['structureEn']),
      explanation: serializer.fromJson<String>(json['explanation']),
      explanationEn: serializer.fromJson<String?>(json['explanationEn']),
      level: serializer.fromJson<String>(json['level']),
      tags: serializer.fromJson<String?>(json['tags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lessonId': serializer.toJson<int>(lessonId),
      'title': serializer.toJson<String>(title),
      'titleEn': serializer.toJson<String?>(titleEn),
      'structure': serializer.toJson<String>(structure),
      'structureEn': serializer.toJson<String?>(structureEn),
      'explanation': serializer.toJson<String>(explanation),
      'explanationEn': serializer.toJson<String?>(explanationEn),
      'level': serializer.toJson<String>(level),
      'tags': serializer.toJson<String?>(tags),
    };
  }

  GrammarPointData copyWith({
    int? id,
    int? lessonId,
    String? title,
    Value<String?> titleEn = const Value.absent(),
    String? structure,
    Value<String?> structureEn = const Value.absent(),
    String? explanation,
    Value<String?> explanationEn = const Value.absent(),
    String? level,
    Value<String?> tags = const Value.absent(),
  }) => GrammarPointData(
    id: id ?? this.id,
    lessonId: lessonId ?? this.lessonId,
    title: title ?? this.title,
    titleEn: titleEn.present ? titleEn.value : this.titleEn,
    structure: structure ?? this.structure,
    structureEn: structureEn.present ? structureEn.value : this.structureEn,
    explanation: explanation ?? this.explanation,
    explanationEn: explanationEn.present
        ? explanationEn.value
        : this.explanationEn,
    level: level ?? this.level,
    tags: tags.present ? tags.value : this.tags,
  );
  GrammarPointData copyWithCompanion(GrammarPointCompanion data) {
    return GrammarPointData(
      id: data.id.present ? data.id.value : this.id,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      title: data.title.present ? data.title.value : this.title,
      titleEn: data.titleEn.present ? data.titleEn.value : this.titleEn,
      structure: data.structure.present ? data.structure.value : this.structure,
      structureEn: data.structureEn.present
          ? data.structureEn.value
          : this.structureEn,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
      explanationEn: data.explanationEn.present
          ? data.explanationEn.value
          : this.explanationEn,
      level: data.level.present ? data.level.value : this.level,
      tags: data.tags.present ? data.tags.value : this.tags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GrammarPointData(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('title: $title, ')
          ..write('titleEn: $titleEn, ')
          ..write('structure: $structure, ')
          ..write('structureEn: $structureEn, ')
          ..write('explanation: $explanation, ')
          ..write('explanationEn: $explanationEn, ')
          ..write('level: $level, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lessonId,
    title,
    titleEn,
    structure,
    structureEn,
    explanation,
    explanationEn,
    level,
    tags,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GrammarPointData &&
          other.id == this.id &&
          other.lessonId == this.lessonId &&
          other.title == this.title &&
          other.titleEn == this.titleEn &&
          other.structure == this.structure &&
          other.structureEn == this.structureEn &&
          other.explanation == this.explanation &&
          other.explanationEn == this.explanationEn &&
          other.level == this.level &&
          other.tags == this.tags);
}

class GrammarPointCompanion extends UpdateCompanion<GrammarPointData> {
  final Value<int> id;
  final Value<int> lessonId;
  final Value<String> title;
  final Value<String?> titleEn;
  final Value<String> structure;
  final Value<String?> structureEn;
  final Value<String> explanation;
  final Value<String?> explanationEn;
  final Value<String> level;
  final Value<String?> tags;
  const GrammarPointCompanion({
    this.id = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.title = const Value.absent(),
    this.titleEn = const Value.absent(),
    this.structure = const Value.absent(),
    this.structureEn = const Value.absent(),
    this.explanation = const Value.absent(),
    this.explanationEn = const Value.absent(),
    this.level = const Value.absent(),
    this.tags = const Value.absent(),
  });
  GrammarPointCompanion.insert({
    this.id = const Value.absent(),
    required int lessonId,
    required String title,
    this.titleEn = const Value.absent(),
    required String structure,
    this.structureEn = const Value.absent(),
    required String explanation,
    this.explanationEn = const Value.absent(),
    required String level,
    this.tags = const Value.absent(),
  }) : lessonId = Value(lessonId),
       title = Value(title),
       structure = Value(structure),
       explanation = Value(explanation),
       level = Value(level);
  static Insertable<GrammarPointData> custom({
    Expression<int>? id,
    Expression<int>? lessonId,
    Expression<String>? title,
    Expression<String>? titleEn,
    Expression<String>? structure,
    Expression<String>? structureEn,
    Expression<String>? explanation,
    Expression<String>? explanationEn,
    Expression<String>? level,
    Expression<String>? tags,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lessonId != null) 'lesson_id': lessonId,
      if (title != null) 'title': title,
      if (titleEn != null) 'title_en': titleEn,
      if (structure != null) 'structure': structure,
      if (structureEn != null) 'structure_en': structureEn,
      if (explanation != null) 'explanation': explanation,
      if (explanationEn != null) 'explanation_en': explanationEn,
      if (level != null) 'level': level,
      if (tags != null) 'tags': tags,
    });
  }

  GrammarPointCompanion copyWith({
    Value<int>? id,
    Value<int>? lessonId,
    Value<String>? title,
    Value<String?>? titleEn,
    Value<String>? structure,
    Value<String?>? structureEn,
    Value<String>? explanation,
    Value<String?>? explanationEn,
    Value<String>? level,
    Value<String?>? tags,
  }) {
    return GrammarPointCompanion(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      title: title ?? this.title,
      titleEn: titleEn ?? this.titleEn,
      structure: structure ?? this.structure,
      structureEn: structureEn ?? this.structureEn,
      explanation: explanation ?? this.explanation,
      explanationEn: explanationEn ?? this.explanationEn,
      level: level ?? this.level,
      tags: tags ?? this.tags,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<int>(lessonId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (titleEn.present) {
      map['title_en'] = Variable<String>(titleEn.value);
    }
    if (structure.present) {
      map['structure'] = Variable<String>(structure.value);
    }
    if (structureEn.present) {
      map['structure_en'] = Variable<String>(structureEn.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (explanationEn.present) {
      map['explanation_en'] = Variable<String>(explanationEn.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GrammarPointCompanion(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('title: $title, ')
          ..write('titleEn: $titleEn, ')
          ..write('structure: $structure, ')
          ..write('structureEn: $structureEn, ')
          ..write('explanation: $explanation, ')
          ..write('explanationEn: $explanationEn, ')
          ..write('level: $level, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }
}

class $GrammarExampleTable extends GrammarExample
    with TableInfo<$GrammarExampleTable, GrammarExampleData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GrammarExampleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _grammarPointIdMeta = const VerificationMeta(
    'grammarPointId',
  );
  @override
  late final GeneratedColumn<int> grammarPointId = GeneratedColumn<int>(
    'grammar_point_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES grammar_point (id)',
    ),
  );
  static const VerificationMeta _sentenceMeta = const VerificationMeta(
    'sentence',
  );
  @override
  late final GeneratedColumn<String> sentence = GeneratedColumn<String>(
    'sentence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _translationMeta = const VerificationMeta(
    'translation',
  );
  @override
  late final GeneratedColumn<String> translation = GeneratedColumn<String>(
    'translation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _translationEnMeta = const VerificationMeta(
    'translationEn',
  );
  @override
  late final GeneratedColumn<String> translationEn = GeneratedColumn<String>(
    'translation_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    grammarPointId,
    sentence,
    translation,
    translationEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grammar_example';
  @override
  VerificationContext validateIntegrity(
    Insertable<GrammarExampleData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('grammar_point_id')) {
      context.handle(
        _grammarPointIdMeta,
        grammarPointId.isAcceptableOrUnknown(
          data['grammar_point_id']!,
          _grammarPointIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_grammarPointIdMeta);
    }
    if (data.containsKey('sentence')) {
      context.handle(
        _sentenceMeta,
        sentence.isAcceptableOrUnknown(data['sentence']!, _sentenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sentenceMeta);
    }
    if (data.containsKey('translation')) {
      context.handle(
        _translationMeta,
        translation.isAcceptableOrUnknown(
          data['translation']!,
          _translationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translationMeta);
    }
    if (data.containsKey('translation_en')) {
      context.handle(
        _translationEnMeta,
        translationEn.isAcceptableOrUnknown(
          data['translation_en']!,
          _translationEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GrammarExampleData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GrammarExampleData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      grammarPointId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grammar_point_id'],
      )!,
      sentence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sentence'],
      )!,
      translation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation'],
      )!,
      translationEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation_en'],
      ),
    );
  }

  @override
  $GrammarExampleTable createAlias(String alias) {
    return $GrammarExampleTable(attachedDatabase, alias);
  }
}

class GrammarExampleData extends DataClass
    implements Insertable<GrammarExampleData> {
  final int id;
  final int grammarPointId;
  final String sentence;
  final String translation;
  final String? translationEn;
  const GrammarExampleData({
    required this.id,
    required this.grammarPointId,
    required this.sentence,
    required this.translation,
    this.translationEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['grammar_point_id'] = Variable<int>(grammarPointId);
    map['sentence'] = Variable<String>(sentence);
    map['translation'] = Variable<String>(translation);
    if (!nullToAbsent || translationEn != null) {
      map['translation_en'] = Variable<String>(translationEn);
    }
    return map;
  }

  GrammarExampleCompanion toCompanion(bool nullToAbsent) {
    return GrammarExampleCompanion(
      id: Value(id),
      grammarPointId: Value(grammarPointId),
      sentence: Value(sentence),
      translation: Value(translation),
      translationEn: translationEn == null && nullToAbsent
          ? const Value.absent()
          : Value(translationEn),
    );
  }

  factory GrammarExampleData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GrammarExampleData(
      id: serializer.fromJson<int>(json['id']),
      grammarPointId: serializer.fromJson<int>(json['grammarPointId']),
      sentence: serializer.fromJson<String>(json['sentence']),
      translation: serializer.fromJson<String>(json['translation']),
      translationEn: serializer.fromJson<String?>(json['translationEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'grammarPointId': serializer.toJson<int>(grammarPointId),
      'sentence': serializer.toJson<String>(sentence),
      'translation': serializer.toJson<String>(translation),
      'translationEn': serializer.toJson<String?>(translationEn),
    };
  }

  GrammarExampleData copyWith({
    int? id,
    int? grammarPointId,
    String? sentence,
    String? translation,
    Value<String?> translationEn = const Value.absent(),
  }) => GrammarExampleData(
    id: id ?? this.id,
    grammarPointId: grammarPointId ?? this.grammarPointId,
    sentence: sentence ?? this.sentence,
    translation: translation ?? this.translation,
    translationEn: translationEn.present
        ? translationEn.value
        : this.translationEn,
  );
  GrammarExampleData copyWithCompanion(GrammarExampleCompanion data) {
    return GrammarExampleData(
      id: data.id.present ? data.id.value : this.id,
      grammarPointId: data.grammarPointId.present
          ? data.grammarPointId.value
          : this.grammarPointId,
      sentence: data.sentence.present ? data.sentence.value : this.sentence,
      translation: data.translation.present
          ? data.translation.value
          : this.translation,
      translationEn: data.translationEn.present
          ? data.translationEn.value
          : this.translationEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GrammarExampleData(')
          ..write('id: $id, ')
          ..write('grammarPointId: $grammarPointId, ')
          ..write('sentence: $sentence, ')
          ..write('translation: $translation, ')
          ..write('translationEn: $translationEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, grammarPointId, sentence, translation, translationEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GrammarExampleData &&
          other.id == this.id &&
          other.grammarPointId == this.grammarPointId &&
          other.sentence == this.sentence &&
          other.translation == this.translation &&
          other.translationEn == this.translationEn);
}

class GrammarExampleCompanion extends UpdateCompanion<GrammarExampleData> {
  final Value<int> id;
  final Value<int> grammarPointId;
  final Value<String> sentence;
  final Value<String> translation;
  final Value<String?> translationEn;
  const GrammarExampleCompanion({
    this.id = const Value.absent(),
    this.grammarPointId = const Value.absent(),
    this.sentence = const Value.absent(),
    this.translation = const Value.absent(),
    this.translationEn = const Value.absent(),
  });
  GrammarExampleCompanion.insert({
    this.id = const Value.absent(),
    required int grammarPointId,
    required String sentence,
    required String translation,
    this.translationEn = const Value.absent(),
  }) : grammarPointId = Value(grammarPointId),
       sentence = Value(sentence),
       translation = Value(translation);
  static Insertable<GrammarExampleData> custom({
    Expression<int>? id,
    Expression<int>? grammarPointId,
    Expression<String>? sentence,
    Expression<String>? translation,
    Expression<String>? translationEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (grammarPointId != null) 'grammar_point_id': grammarPointId,
      if (sentence != null) 'sentence': sentence,
      if (translation != null) 'translation': translation,
      if (translationEn != null) 'translation_en': translationEn,
    });
  }

  GrammarExampleCompanion copyWith({
    Value<int>? id,
    Value<int>? grammarPointId,
    Value<String>? sentence,
    Value<String>? translation,
    Value<String?>? translationEn,
  }) {
    return GrammarExampleCompanion(
      id: id ?? this.id,
      grammarPointId: grammarPointId ?? this.grammarPointId,
      sentence: sentence ?? this.sentence,
      translation: translation ?? this.translation,
      translationEn: translationEn ?? this.translationEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (grammarPointId.present) {
      map['grammar_point_id'] = Variable<int>(grammarPointId.value);
    }
    if (sentence.present) {
      map['sentence'] = Variable<String>(sentence.value);
    }
    if (translation.present) {
      map['translation'] = Variable<String>(translation.value);
    }
    if (translationEn.present) {
      map['translation_en'] = Variable<String>(translationEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GrammarExampleCompanion(')
          ..write('id: $id, ')
          ..write('grammarPointId: $grammarPointId, ')
          ..write('sentence: $sentence, ')
          ..write('translation: $translation, ')
          ..write('translationEn: $translationEn')
          ..write(')'))
        .toString();
  }
}

class $QuestionTable extends Question
    with TableInfo<$QuestionTable, QuestionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promptMeta = const VerificationMeta('prompt');
  @override
  late final GeneratedColumn<String> prompt = GeneratedColumn<String>(
    'prompt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _choicesJsonMeta = const VerificationMeta(
    'choicesJson',
  );
  @override
  late final GeneratedColumn<String> choicesJson = GeneratedColumn<String>(
    'choices_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctIndexMeta = const VerificationMeta(
    'correctIndex',
  );
  @override
  late final GeneratedColumn<int> correctIndex = GeneratedColumn<int>(
    'correct_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grammarIdMeta = const VerificationMeta(
    'grammarId',
  );
  @override
  late final GeneratedColumn<int> grammarId = GeneratedColumn<int>(
    'grammar_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _explanationMeta = const VerificationMeta(
    'explanation',
  );
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
    'explanation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    level,
    prompt,
    choicesJson,
    correctIndex,
    grammarId,
    explanation,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'question';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuestionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('prompt')) {
      context.handle(
        _promptMeta,
        prompt.isAcceptableOrUnknown(data['prompt']!, _promptMeta),
      );
    } else if (isInserting) {
      context.missing(_promptMeta);
    }
    if (data.containsKey('choices_json')) {
      context.handle(
        _choicesJsonMeta,
        choicesJson.isAcceptableOrUnknown(
          data['choices_json']!,
          _choicesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_choicesJsonMeta);
    }
    if (data.containsKey('correct_index')) {
      context.handle(
        _correctIndexMeta,
        correctIndex.isAcceptableOrUnknown(
          data['correct_index']!,
          _correctIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctIndexMeta);
    }
    if (data.containsKey('grammar_id')) {
      context.handle(
        _grammarIdMeta,
        grammarId.isAcceptableOrUnknown(data['grammar_id']!, _grammarIdMeta),
      );
    }
    if (data.containsKey('explanation')) {
      context.handle(
        _explanationMeta,
        explanation.isAcceptableOrUnknown(
          data['explanation']!,
          _explanationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuestionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestionData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      prompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt'],
      )!,
      choicesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}choices_json'],
      )!,
      correctIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_index'],
      )!,
      grammarId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grammar_id'],
      ),
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      ),
    );
  }

  @override
  $QuestionTable createAlias(String alias) {
    return $QuestionTable(attachedDatabase, alias);
  }
}

class QuestionData extends DataClass implements Insertable<QuestionData> {
  final int id;
  final String level;
  final String prompt;
  final String choicesJson;
  final int correctIndex;
  final int? grammarId;
  final String? explanation;
  const QuestionData({
    required this.id,
    required this.level,
    required this.prompt,
    required this.choicesJson,
    required this.correctIndex,
    this.grammarId,
    this.explanation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['level'] = Variable<String>(level);
    map['prompt'] = Variable<String>(prompt);
    map['choices_json'] = Variable<String>(choicesJson);
    map['correct_index'] = Variable<int>(correctIndex);
    if (!nullToAbsent || grammarId != null) {
      map['grammar_id'] = Variable<int>(grammarId);
    }
    if (!nullToAbsent || explanation != null) {
      map['explanation'] = Variable<String>(explanation);
    }
    return map;
  }

  QuestionCompanion toCompanion(bool nullToAbsent) {
    return QuestionCompanion(
      id: Value(id),
      level: Value(level),
      prompt: Value(prompt),
      choicesJson: Value(choicesJson),
      correctIndex: Value(correctIndex),
      grammarId: grammarId == null && nullToAbsent
          ? const Value.absent()
          : Value(grammarId),
      explanation: explanation == null && nullToAbsent
          ? const Value.absent()
          : Value(explanation),
    );
  }

  factory QuestionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestionData(
      id: serializer.fromJson<int>(json['id']),
      level: serializer.fromJson<String>(json['level']),
      prompt: serializer.fromJson<String>(json['prompt']),
      choicesJson: serializer.fromJson<String>(json['choicesJson']),
      correctIndex: serializer.fromJson<int>(json['correctIndex']),
      grammarId: serializer.fromJson<int?>(json['grammarId']),
      explanation: serializer.fromJson<String?>(json['explanation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'level': serializer.toJson<String>(level),
      'prompt': serializer.toJson<String>(prompt),
      'choicesJson': serializer.toJson<String>(choicesJson),
      'correctIndex': serializer.toJson<int>(correctIndex),
      'grammarId': serializer.toJson<int?>(grammarId),
      'explanation': serializer.toJson<String?>(explanation),
    };
  }

  QuestionData copyWith({
    int? id,
    String? level,
    String? prompt,
    String? choicesJson,
    int? correctIndex,
    Value<int?> grammarId = const Value.absent(),
    Value<String?> explanation = const Value.absent(),
  }) => QuestionData(
    id: id ?? this.id,
    level: level ?? this.level,
    prompt: prompt ?? this.prompt,
    choicesJson: choicesJson ?? this.choicesJson,
    correctIndex: correctIndex ?? this.correctIndex,
    grammarId: grammarId.present ? grammarId.value : this.grammarId,
    explanation: explanation.present ? explanation.value : this.explanation,
  );
  QuestionData copyWithCompanion(QuestionCompanion data) {
    return QuestionData(
      id: data.id.present ? data.id.value : this.id,
      level: data.level.present ? data.level.value : this.level,
      prompt: data.prompt.present ? data.prompt.value : this.prompt,
      choicesJson: data.choicesJson.present
          ? data.choicesJson.value
          : this.choicesJson,
      correctIndex: data.correctIndex.present
          ? data.correctIndex.value
          : this.correctIndex,
      grammarId: data.grammarId.present ? data.grammarId.value : this.grammarId,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestionData(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('prompt: $prompt, ')
          ..write('choicesJson: $choicesJson, ')
          ..write('correctIndex: $correctIndex, ')
          ..write('grammarId: $grammarId, ')
          ..write('explanation: $explanation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    level,
    prompt,
    choicesJson,
    correctIndex,
    grammarId,
    explanation,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestionData &&
          other.id == this.id &&
          other.level == this.level &&
          other.prompt == this.prompt &&
          other.choicesJson == this.choicesJson &&
          other.correctIndex == this.correctIndex &&
          other.grammarId == this.grammarId &&
          other.explanation == this.explanation);
}

class QuestionCompanion extends UpdateCompanion<QuestionData> {
  final Value<int> id;
  final Value<String> level;
  final Value<String> prompt;
  final Value<String> choicesJson;
  final Value<int> correctIndex;
  final Value<int?> grammarId;
  final Value<String?> explanation;
  const QuestionCompanion({
    this.id = const Value.absent(),
    this.level = const Value.absent(),
    this.prompt = const Value.absent(),
    this.choicesJson = const Value.absent(),
    this.correctIndex = const Value.absent(),
    this.grammarId = const Value.absent(),
    this.explanation = const Value.absent(),
  });
  QuestionCompanion.insert({
    this.id = const Value.absent(),
    required String level,
    required String prompt,
    required String choicesJson,
    required int correctIndex,
    this.grammarId = const Value.absent(),
    this.explanation = const Value.absent(),
  }) : level = Value(level),
       prompt = Value(prompt),
       choicesJson = Value(choicesJson),
       correctIndex = Value(correctIndex);
  static Insertable<QuestionData> custom({
    Expression<int>? id,
    Expression<String>? level,
    Expression<String>? prompt,
    Expression<String>? choicesJson,
    Expression<int>? correctIndex,
    Expression<int>? grammarId,
    Expression<String>? explanation,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (level != null) 'level': level,
      if (prompt != null) 'prompt': prompt,
      if (choicesJson != null) 'choices_json': choicesJson,
      if (correctIndex != null) 'correct_index': correctIndex,
      if (grammarId != null) 'grammar_id': grammarId,
      if (explanation != null) 'explanation': explanation,
    });
  }

  QuestionCompanion copyWith({
    Value<int>? id,
    Value<String>? level,
    Value<String>? prompt,
    Value<String>? choicesJson,
    Value<int>? correctIndex,
    Value<int?>? grammarId,
    Value<String?>? explanation,
  }) {
    return QuestionCompanion(
      id: id ?? this.id,
      level: level ?? this.level,
      prompt: prompt ?? this.prompt,
      choicesJson: choicesJson ?? this.choicesJson,
      correctIndex: correctIndex ?? this.correctIndex,
      grammarId: grammarId ?? this.grammarId,
      explanation: explanation ?? this.explanation,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (prompt.present) {
      map['prompt'] = Variable<String>(prompt.value);
    }
    if (choicesJson.present) {
      map['choices_json'] = Variable<String>(choicesJson.value);
    }
    if (correctIndex.present) {
      map['correct_index'] = Variable<int>(correctIndex.value);
    }
    if (grammarId.present) {
      map['grammar_id'] = Variable<int>(grammarId.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionCompanion(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('prompt: $prompt, ')
          ..write('choicesJson: $choicesJson, ')
          ..write('correctIndex: $correctIndex, ')
          ..write('grammarId: $grammarId, ')
          ..write('explanation: $explanation')
          ..write(')'))
        .toString();
  }
}

class $MockTestTable extends MockTest
    with TableInfo<$MockTestTable, MockTestData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MockTestTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, level, title, durationSeconds];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mock_test';
  @override
  VerificationContext validateIntegrity(
    Insertable<MockTestData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MockTestData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MockTestData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
    );
  }

  @override
  $MockTestTable createAlias(String alias) {
    return $MockTestTable(attachedDatabase, alias);
  }
}

class MockTestData extends DataClass implements Insertable<MockTestData> {
  final int id;
  final String level;
  final String title;
  final int durationSeconds;
  const MockTestData({
    required this.id,
    required this.level,
    required this.title,
    required this.durationSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['level'] = Variable<String>(level);
    map['title'] = Variable<String>(title);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    return map;
  }

  MockTestCompanion toCompanion(bool nullToAbsent) {
    return MockTestCompanion(
      id: Value(id),
      level: Value(level),
      title: Value(title),
      durationSeconds: Value(durationSeconds),
    );
  }

  factory MockTestData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MockTestData(
      id: serializer.fromJson<int>(json['id']),
      level: serializer.fromJson<String>(json['level']),
      title: serializer.fromJson<String>(json['title']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'level': serializer.toJson<String>(level),
      'title': serializer.toJson<String>(title),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
    };
  }

  MockTestData copyWith({
    int? id,
    String? level,
    String? title,
    int? durationSeconds,
  }) => MockTestData(
    id: id ?? this.id,
    level: level ?? this.level,
    title: title ?? this.title,
    durationSeconds: durationSeconds ?? this.durationSeconds,
  );
  MockTestData copyWithCompanion(MockTestCompanion data) {
    return MockTestData(
      id: data.id.present ? data.id.value : this.id,
      level: data.level.present ? data.level.value : this.level,
      title: data.title.present ? data.title.value : this.title,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MockTestData(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('title: $title, ')
          ..write('durationSeconds: $durationSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, level, title, durationSeconds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MockTestData &&
          other.id == this.id &&
          other.level == this.level &&
          other.title == this.title &&
          other.durationSeconds == this.durationSeconds);
}

class MockTestCompanion extends UpdateCompanion<MockTestData> {
  final Value<int> id;
  final Value<String> level;
  final Value<String> title;
  final Value<int> durationSeconds;
  const MockTestCompanion({
    this.id = const Value.absent(),
    this.level = const Value.absent(),
    this.title = const Value.absent(),
    this.durationSeconds = const Value.absent(),
  });
  MockTestCompanion.insert({
    this.id = const Value.absent(),
    required String level,
    required String title,
    required int durationSeconds,
  }) : level = Value(level),
       title = Value(title),
       durationSeconds = Value(durationSeconds);
  static Insertable<MockTestData> custom({
    Expression<int>? id,
    Expression<String>? level,
    Expression<String>? title,
    Expression<int>? durationSeconds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (level != null) 'level': level,
      if (title != null) 'title': title,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
    });
  }

  MockTestCompanion copyWith({
    Value<int>? id,
    Value<String>? level,
    Value<String>? title,
    Value<int>? durationSeconds,
  }) {
    return MockTestCompanion(
      id: id ?? this.id,
      level: level ?? this.level,
      title: title ?? this.title,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MockTestCompanion(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('title: $title, ')
          ..write('durationSeconds: $durationSeconds')
          ..write(')'))
        .toString();
  }
}

class $MockTestSectionTable extends MockTestSection
    with TableInfo<$MockTestSectionTable, MockTestSectionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MockTestSectionTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _testIdMeta = const VerificationMeta('testId');
  @override
  late final GeneratedColumn<int> testId = GeneratedColumn<int>(
    'test_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, testId, title, orderIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mock_test_section';
  @override
  VerificationContext validateIntegrity(
    Insertable<MockTestSectionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('test_id')) {
      context.handle(
        _testIdMeta,
        testId.isAcceptableOrUnknown(data['test_id']!, _testIdMeta),
      );
    } else if (isInserting) {
      context.missing(_testIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MockTestSectionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MockTestSectionData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      testId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}test_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
    );
  }

  @override
  $MockTestSectionTable createAlias(String alias) {
    return $MockTestSectionTable(attachedDatabase, alias);
  }
}

class MockTestSectionData extends DataClass
    implements Insertable<MockTestSectionData> {
  final int id;
  final int testId;
  final String title;
  final int orderIndex;
  const MockTestSectionData({
    required this.id,
    required this.testId,
    required this.title,
    required this.orderIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['test_id'] = Variable<int>(testId);
    map['title'] = Variable<String>(title);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  MockTestSectionCompanion toCompanion(bool nullToAbsent) {
    return MockTestSectionCompanion(
      id: Value(id),
      testId: Value(testId),
      title: Value(title),
      orderIndex: Value(orderIndex),
    );
  }

  factory MockTestSectionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MockTestSectionData(
      id: serializer.fromJson<int>(json['id']),
      testId: serializer.fromJson<int>(json['testId']),
      title: serializer.fromJson<String>(json['title']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'testId': serializer.toJson<int>(testId),
      'title': serializer.toJson<String>(title),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  MockTestSectionData copyWith({
    int? id,
    int? testId,
    String? title,
    int? orderIndex,
  }) => MockTestSectionData(
    id: id ?? this.id,
    testId: testId ?? this.testId,
    title: title ?? this.title,
    orderIndex: orderIndex ?? this.orderIndex,
  );
  MockTestSectionData copyWithCompanion(MockTestSectionCompanion data) {
    return MockTestSectionData(
      id: data.id.present ? data.id.value : this.id,
      testId: data.testId.present ? data.testId.value : this.testId,
      title: data.title.present ? data.title.value : this.title,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MockTestSectionData(')
          ..write('id: $id, ')
          ..write('testId: $testId, ')
          ..write('title: $title, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, testId, title, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MockTestSectionData &&
          other.id == this.id &&
          other.testId == this.testId &&
          other.title == this.title &&
          other.orderIndex == this.orderIndex);
}

class MockTestSectionCompanion extends UpdateCompanion<MockTestSectionData> {
  final Value<int> id;
  final Value<int> testId;
  final Value<String> title;
  final Value<int> orderIndex;
  const MockTestSectionCompanion({
    this.id = const Value.absent(),
    this.testId = const Value.absent(),
    this.title = const Value.absent(),
    this.orderIndex = const Value.absent(),
  });
  MockTestSectionCompanion.insert({
    this.id = const Value.absent(),
    required int testId,
    required String title,
    required int orderIndex,
  }) : testId = Value(testId),
       title = Value(title),
       orderIndex = Value(orderIndex);
  static Insertable<MockTestSectionData> custom({
    Expression<int>? id,
    Expression<int>? testId,
    Expression<String>? title,
    Expression<int>? orderIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (testId != null) 'test_id': testId,
      if (title != null) 'title': title,
      if (orderIndex != null) 'order_index': orderIndex,
    });
  }

  MockTestSectionCompanion copyWith({
    Value<int>? id,
    Value<int>? testId,
    Value<String>? title,
    Value<int>? orderIndex,
  }) {
    return MockTestSectionCompanion(
      id: id ?? this.id,
      testId: testId ?? this.testId,
      title: title ?? this.title,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (testId.present) {
      map['test_id'] = Variable<int>(testId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MockTestSectionCompanion(')
          ..write('id: $id, ')
          ..write('testId: $testId, ')
          ..write('title: $title, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }
}

class $MockTestQuestionMapTable extends MockTestQuestionMap
    with TableInfo<$MockTestQuestionMapTable, MockTestQuestionMapData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MockTestQuestionMapTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _testIdMeta = const VerificationMeta('testId');
  @override
  late final GeneratedColumn<int> testId = GeneratedColumn<int>(
    'test_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<int> sectionId = GeneratedColumn<int>(
    'section_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<int> questionId = GeneratedColumn<int>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    testId,
    sectionId,
    questionId,
    orderIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mock_test_question_map';
  @override
  VerificationContext validateIntegrity(
    Insertable<MockTestQuestionMapData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('test_id')) {
      context.handle(
        _testIdMeta,
        testId.isAcceptableOrUnknown(data['test_id']!, _testIdMeta),
      );
    } else if (isInserting) {
      context.missing(_testIdMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MockTestQuestionMapData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MockTestQuestionMapData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      testId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}test_id'],
      )!,
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}section_id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_id'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
    );
  }

  @override
  $MockTestQuestionMapTable createAlias(String alias) {
    return $MockTestQuestionMapTable(attachedDatabase, alias);
  }
}

class MockTestQuestionMapData extends DataClass
    implements Insertable<MockTestQuestionMapData> {
  final int id;
  final int testId;
  final int sectionId;
  final int questionId;
  final int orderIndex;
  const MockTestQuestionMapData({
    required this.id,
    required this.testId,
    required this.sectionId,
    required this.questionId,
    required this.orderIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['test_id'] = Variable<int>(testId);
    map['section_id'] = Variable<int>(sectionId);
    map['question_id'] = Variable<int>(questionId);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  MockTestQuestionMapCompanion toCompanion(bool nullToAbsent) {
    return MockTestQuestionMapCompanion(
      id: Value(id),
      testId: Value(testId),
      sectionId: Value(sectionId),
      questionId: Value(questionId),
      orderIndex: Value(orderIndex),
    );
  }

  factory MockTestQuestionMapData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MockTestQuestionMapData(
      id: serializer.fromJson<int>(json['id']),
      testId: serializer.fromJson<int>(json['testId']),
      sectionId: serializer.fromJson<int>(json['sectionId']),
      questionId: serializer.fromJson<int>(json['questionId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'testId': serializer.toJson<int>(testId),
      'sectionId': serializer.toJson<int>(sectionId),
      'questionId': serializer.toJson<int>(questionId),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  MockTestQuestionMapData copyWith({
    int? id,
    int? testId,
    int? sectionId,
    int? questionId,
    int? orderIndex,
  }) => MockTestQuestionMapData(
    id: id ?? this.id,
    testId: testId ?? this.testId,
    sectionId: sectionId ?? this.sectionId,
    questionId: questionId ?? this.questionId,
    orderIndex: orderIndex ?? this.orderIndex,
  );
  MockTestQuestionMapData copyWithCompanion(MockTestQuestionMapCompanion data) {
    return MockTestQuestionMapData(
      id: data.id.present ? data.id.value : this.id,
      testId: data.testId.present ? data.testId.value : this.testId,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MockTestQuestionMapData(')
          ..write('id: $id, ')
          ..write('testId: $testId, ')
          ..write('sectionId: $sectionId, ')
          ..write('questionId: $questionId, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, testId, sectionId, questionId, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MockTestQuestionMapData &&
          other.id == this.id &&
          other.testId == this.testId &&
          other.sectionId == this.sectionId &&
          other.questionId == this.questionId &&
          other.orderIndex == this.orderIndex);
}

class MockTestQuestionMapCompanion
    extends UpdateCompanion<MockTestQuestionMapData> {
  final Value<int> id;
  final Value<int> testId;
  final Value<int> sectionId;
  final Value<int> questionId;
  final Value<int> orderIndex;
  const MockTestQuestionMapCompanion({
    this.id = const Value.absent(),
    this.testId = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.orderIndex = const Value.absent(),
  });
  MockTestQuestionMapCompanion.insert({
    this.id = const Value.absent(),
    required int testId,
    required int sectionId,
    required int questionId,
    required int orderIndex,
  }) : testId = Value(testId),
       sectionId = Value(sectionId),
       questionId = Value(questionId),
       orderIndex = Value(orderIndex);
  static Insertable<MockTestQuestionMapData> custom({
    Expression<int>? id,
    Expression<int>? testId,
    Expression<int>? sectionId,
    Expression<int>? questionId,
    Expression<int>? orderIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (testId != null) 'test_id': testId,
      if (sectionId != null) 'section_id': sectionId,
      if (questionId != null) 'question_id': questionId,
      if (orderIndex != null) 'order_index': orderIndex,
    });
  }

  MockTestQuestionMapCompanion copyWith({
    Value<int>? id,
    Value<int>? testId,
    Value<int>? sectionId,
    Value<int>? questionId,
    Value<int>? orderIndex,
  }) {
    return MockTestQuestionMapCompanion(
      id: id ?? this.id,
      testId: testId ?? this.testId,
      sectionId: sectionId ?? this.sectionId,
      questionId: questionId ?? this.questionId,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (testId.present) {
      map['test_id'] = Variable<int>(testId.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<int>(sectionId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<int>(questionId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MockTestQuestionMapCompanion(')
          ..write('id: $id, ')
          ..write('testId: $testId, ')
          ..write('sectionId: $sectionId, ')
          ..write('questionId: $questionId, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }
}

class $UserProgressTable extends UserProgress
    with TableInfo<$UserProgressTable, UserProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _vocabIdMeta = const VerificationMeta(
    'vocabId',
  );
  @override
  late final GeneratedColumn<int> vocabId = GeneratedColumn<int>(
    'vocab_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vocab (id)',
    ),
  );
  static const VerificationMeta _correctCountMeta = const VerificationMeta(
    'correctCount',
  );
  @override
  late final GeneratedColumn<int> correctCount = GeneratedColumn<int>(
    'correct_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _missedCountMeta = const VerificationMeta(
    'missedCount',
  );
  @override
  late final GeneratedColumn<int> missedCount = GeneratedColumn<int>(
    'missed_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastReviewedAtMeta = const VerificationMeta(
    'lastReviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReviewedAt =
      GeneratedColumn<DateTime>(
        'last_reviewed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    vocabId,
    correctCount,
    missedCount,
    lastReviewedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('vocab_id')) {
      context.handle(
        _vocabIdMeta,
        vocabId.isAcceptableOrUnknown(data['vocab_id']!, _vocabIdMeta),
      );
    }
    if (data.containsKey('correct_count')) {
      context.handle(
        _correctCountMeta,
        correctCount.isAcceptableOrUnknown(
          data['correct_count']!,
          _correctCountMeta,
        ),
      );
    }
    if (data.containsKey('missed_count')) {
      context.handle(
        _missedCountMeta,
        missedCount.isAcceptableOrUnknown(
          data['missed_count']!,
          _missedCountMeta,
        ),
      );
    }
    if (data.containsKey('last_reviewed_at')) {
      context.handle(
        _lastReviewedAtMeta,
        lastReviewedAt.isAcceptableOrUnknown(
          data['last_reviewed_at']!,
          _lastReviewedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {vocabId};
  @override
  UserProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProgressData(
      vocabId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vocab_id'],
      )!,
      correctCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_count'],
      )!,
      missedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}missed_count'],
      )!,
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reviewed_at'],
      ),
    );
  }

  @override
  $UserProgressTable createAlias(String alias) {
    return $UserProgressTable(attachedDatabase, alias);
  }
}

class UserProgressData extends DataClass
    implements Insertable<UserProgressData> {
  final int vocabId;
  final int correctCount;
  final int missedCount;
  final DateTime? lastReviewedAt;
  const UserProgressData({
    required this.vocabId,
    required this.correctCount,
    required this.missedCount,
    this.lastReviewedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['vocab_id'] = Variable<int>(vocabId);
    map['correct_count'] = Variable<int>(correctCount);
    map['missed_count'] = Variable<int>(missedCount);
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt);
    }
    return map;
  }

  UserProgressCompanion toCompanion(bool nullToAbsent) {
    return UserProgressCompanion(
      vocabId: Value(vocabId),
      correctCount: Value(correctCount),
      missedCount: Value(missedCount),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
    );
  }

  factory UserProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProgressData(
      vocabId: serializer.fromJson<int>(json['vocabId']),
      correctCount: serializer.fromJson<int>(json['correctCount']),
      missedCount: serializer.fromJson<int>(json['missedCount']),
      lastReviewedAt: serializer.fromJson<DateTime?>(json['lastReviewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'vocabId': serializer.toJson<int>(vocabId),
      'correctCount': serializer.toJson<int>(correctCount),
      'missedCount': serializer.toJson<int>(missedCount),
      'lastReviewedAt': serializer.toJson<DateTime?>(lastReviewedAt),
    };
  }

  UserProgressData copyWith({
    int? vocabId,
    int? correctCount,
    int? missedCount,
    Value<DateTime?> lastReviewedAt = const Value.absent(),
  }) => UserProgressData(
    vocabId: vocabId ?? this.vocabId,
    correctCount: correctCount ?? this.correctCount,
    missedCount: missedCount ?? this.missedCount,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
  );
  UserProgressData copyWithCompanion(UserProgressCompanion data) {
    return UserProgressData(
      vocabId: data.vocabId.present ? data.vocabId.value : this.vocabId,
      correctCount: data.correctCount.present
          ? data.correctCount.value
          : this.correctCount,
      missedCount: data.missedCount.present
          ? data.missedCount.value
          : this.missedCount,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProgressData(')
          ..write('vocabId: $vocabId, ')
          ..write('correctCount: $correctCount, ')
          ..write('missedCount: $missedCount, ')
          ..write('lastReviewedAt: $lastReviewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(vocabId, correctCount, missedCount, lastReviewedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProgressData &&
          other.vocabId == this.vocabId &&
          other.correctCount == this.correctCount &&
          other.missedCount == this.missedCount &&
          other.lastReviewedAt == this.lastReviewedAt);
}

class UserProgressCompanion extends UpdateCompanion<UserProgressData> {
  final Value<int> vocabId;
  final Value<int> correctCount;
  final Value<int> missedCount;
  final Value<DateTime?> lastReviewedAt;
  const UserProgressCompanion({
    this.vocabId = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.missedCount = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
  });
  UserProgressCompanion.insert({
    this.vocabId = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.missedCount = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
  });
  static Insertable<UserProgressData> custom({
    Expression<int>? vocabId,
    Expression<int>? correctCount,
    Expression<int>? missedCount,
    Expression<DateTime>? lastReviewedAt,
  }) {
    return RawValuesInsertable({
      if (vocabId != null) 'vocab_id': vocabId,
      if (correctCount != null) 'correct_count': correctCount,
      if (missedCount != null) 'missed_count': missedCount,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
    });
  }

  UserProgressCompanion copyWith({
    Value<int>? vocabId,
    Value<int>? correctCount,
    Value<int>? missedCount,
    Value<DateTime?>? lastReviewedAt,
  }) {
    return UserProgressCompanion(
      vocabId: vocabId ?? this.vocabId,
      correctCount: correctCount ?? this.correctCount,
      missedCount: missedCount ?? this.missedCount,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (vocabId.present) {
      map['vocab_id'] = Variable<int>(vocabId.value);
    }
    if (correctCount.present) {
      map['correct_count'] = Variable<int>(correctCount.value);
    }
    if (missedCount.present) {
      map['missed_count'] = Variable<int>(missedCount.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProgressCompanion(')
          ..write('vocabId: $vocabId, ')
          ..write('correctCount: $correctCount, ')
          ..write('missedCount: $missedCount, ')
          ..write('lastReviewedAt: $lastReviewedAt')
          ..write(')'))
        .toString();
  }
}

class $KanjiTable extends Kanji with TableInfo<$KanjiTable, KanjiData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KanjiTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<int> lessonId = GeneratedColumn<int>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _characterMeta = const VerificationMeta(
    'character',
  );
  @override
  late final GeneratedColumn<String> character = GeneratedColumn<String>(
    'character',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _strokeCountMeta = const VerificationMeta(
    'strokeCount',
  );
  @override
  late final GeneratedColumn<int> strokeCount = GeneratedColumn<int>(
    'stroke_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _onyomiMeta = const VerificationMeta('onyomi');
  @override
  late final GeneratedColumn<String> onyomi = GeneratedColumn<String>(
    'onyomi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kunyomiMeta = const VerificationMeta(
    'kunyomi',
  );
  @override
  late final GeneratedColumn<String> kunyomi = GeneratedColumn<String>(
    'kunyomi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _meaningMeta = const VerificationMeta(
    'meaning',
  );
  @override
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
    'meaning',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meaningEnMeta = const VerificationMeta(
    'meaningEn',
  );
  @override
  late final GeneratedColumn<String> meaningEn = GeneratedColumn<String>(
    'meaning_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _meaningJaMeta = const VerificationMeta(
    'meaningJa',
  );
  @override
  late final GeneratedColumn<String> meaningJa = GeneratedColumn<String>(
    'meaning_ja',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mnemonicViMeta = const VerificationMeta(
    'mnemonicVi',
  );
  @override
  late final GeneratedColumn<String> mnemonicVi = GeneratedColumn<String>(
    'mnemonic_vi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mnemonicEnMeta = const VerificationMeta(
    'mnemonicEn',
  );
  @override
  late final GeneratedColumn<String> mnemonicEn = GeneratedColumn<String>(
    'mnemonic_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _decompositionJsonMeta = const VerificationMeta(
    'decompositionJson',
  );
  @override
  late final GeneratedColumn<String> decompositionJson =
      GeneratedColumn<String>(
        'decomposition_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _examplesJsonMeta = const VerificationMeta(
    'examplesJson',
  );
  @override
  late final GeneratedColumn<String> examplesJson = GeneratedColumn<String>(
    'examples_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jlptLevelMeta = const VerificationMeta(
    'jlptLevel',
  );
  @override
  late final GeneratedColumn<String> jlptLevel = GeneratedColumn<String>(
    'jlpt_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lessonId,
    character,
    strokeCount,
    onyomi,
    kunyomi,
    meaning,
    meaningEn,
    meaningJa,
    mnemonicVi,
    mnemonicEn,
    decompositionJson,
    examplesJson,
    jlptLevel,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kanji';
  @override
  VerificationContext validateIntegrity(
    Insertable<KanjiData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('character')) {
      context.handle(
        _characterMeta,
        character.isAcceptableOrUnknown(data['character']!, _characterMeta),
      );
    } else if (isInserting) {
      context.missing(_characterMeta);
    }
    if (data.containsKey('stroke_count')) {
      context.handle(
        _strokeCountMeta,
        strokeCount.isAcceptableOrUnknown(
          data['stroke_count']!,
          _strokeCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_strokeCountMeta);
    }
    if (data.containsKey('onyomi')) {
      context.handle(
        _onyomiMeta,
        onyomi.isAcceptableOrUnknown(data['onyomi']!, _onyomiMeta),
      );
    }
    if (data.containsKey('kunyomi')) {
      context.handle(
        _kunyomiMeta,
        kunyomi.isAcceptableOrUnknown(data['kunyomi']!, _kunyomiMeta),
      );
    }
    if (data.containsKey('meaning')) {
      context.handle(
        _meaningMeta,
        meaning.isAcceptableOrUnknown(data['meaning']!, _meaningMeta),
      );
    } else if (isInserting) {
      context.missing(_meaningMeta);
    }
    if (data.containsKey('meaning_en')) {
      context.handle(
        _meaningEnMeta,
        meaningEn.isAcceptableOrUnknown(data['meaning_en']!, _meaningEnMeta),
      );
    }
    if (data.containsKey('meaning_ja')) {
      context.handle(
        _meaningJaMeta,
        meaningJa.isAcceptableOrUnknown(data['meaning_ja']!, _meaningJaMeta),
      );
    }
    if (data.containsKey('mnemonic_vi')) {
      context.handle(
        _mnemonicViMeta,
        mnemonicVi.isAcceptableOrUnknown(data['mnemonic_vi']!, _mnemonicViMeta),
      );
    }
    if (data.containsKey('mnemonic_en')) {
      context.handle(
        _mnemonicEnMeta,
        mnemonicEn.isAcceptableOrUnknown(data['mnemonic_en']!, _mnemonicEnMeta),
      );
    }
    if (data.containsKey('decomposition_json')) {
      context.handle(
        _decompositionJsonMeta,
        decompositionJson.isAcceptableOrUnknown(
          data['decomposition_json']!,
          _decompositionJsonMeta,
        ),
      );
    }
    if (data.containsKey('examples_json')) {
      context.handle(
        _examplesJsonMeta,
        examplesJson.isAcceptableOrUnknown(
          data['examples_json']!,
          _examplesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_examplesJsonMeta);
    }
    if (data.containsKey('jlpt_level')) {
      context.handle(
        _jlptLevelMeta,
        jlptLevel.isAcceptableOrUnknown(data['jlpt_level']!, _jlptLevelMeta),
      );
    } else if (isInserting) {
      context.missing(_jlptLevelMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KanjiData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KanjiData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lesson_id'],
      )!,
      character: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}character'],
      )!,
      strokeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stroke_count'],
      )!,
      onyomi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}onyomi'],
      ),
      kunyomi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kunyomi'],
      ),
      meaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning'],
      )!,
      meaningEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning_en'],
      ),
      meaningJa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning_ja'],
      ),
      mnemonicVi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mnemonic_vi'],
      ),
      mnemonicEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mnemonic_en'],
      ),
      decompositionJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decomposition_json'],
      ),
      examplesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}examples_json'],
      )!,
      jlptLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jlpt_level'],
      )!,
    );
  }

  @override
  $KanjiTable createAlias(String alias) {
    return $KanjiTable(attachedDatabase, alias);
  }
}

class KanjiData extends DataClass implements Insertable<KanjiData> {
  final int id;
  final int lessonId;
  final String character;
  final int strokeCount;
  final String? onyomi;
  final String? kunyomi;
  final String meaning;
  final String? meaningEn;
  final String? meaningJa;
  final String? mnemonicVi;
  final String? mnemonicEn;
  final String? decompositionJson;
  final String examplesJson;
  final String jlptLevel;
  const KanjiData({
    required this.id,
    required this.lessonId,
    required this.character,
    required this.strokeCount,
    this.onyomi,
    this.kunyomi,
    required this.meaning,
    this.meaningEn,
    this.meaningJa,
    this.mnemonicVi,
    this.mnemonicEn,
    this.decompositionJson,
    required this.examplesJson,
    required this.jlptLevel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['lesson_id'] = Variable<int>(lessonId);
    map['character'] = Variable<String>(character);
    map['stroke_count'] = Variable<int>(strokeCount);
    if (!nullToAbsent || onyomi != null) {
      map['onyomi'] = Variable<String>(onyomi);
    }
    if (!nullToAbsent || kunyomi != null) {
      map['kunyomi'] = Variable<String>(kunyomi);
    }
    map['meaning'] = Variable<String>(meaning);
    if (!nullToAbsent || meaningEn != null) {
      map['meaning_en'] = Variable<String>(meaningEn);
    }
    if (!nullToAbsent || meaningJa != null) {
      map['meaning_ja'] = Variable<String>(meaningJa);
    }
    if (!nullToAbsent || mnemonicVi != null) {
      map['mnemonic_vi'] = Variable<String>(mnemonicVi);
    }
    if (!nullToAbsent || mnemonicEn != null) {
      map['mnemonic_en'] = Variable<String>(mnemonicEn);
    }
    if (!nullToAbsent || decompositionJson != null) {
      map['decomposition_json'] = Variable<String>(decompositionJson);
    }
    map['examples_json'] = Variable<String>(examplesJson);
    map['jlpt_level'] = Variable<String>(jlptLevel);
    return map;
  }

  KanjiCompanion toCompanion(bool nullToAbsent) {
    return KanjiCompanion(
      id: Value(id),
      lessonId: Value(lessonId),
      character: Value(character),
      strokeCount: Value(strokeCount),
      onyomi: onyomi == null && nullToAbsent
          ? const Value.absent()
          : Value(onyomi),
      kunyomi: kunyomi == null && nullToAbsent
          ? const Value.absent()
          : Value(kunyomi),
      meaning: Value(meaning),
      meaningEn: meaningEn == null && nullToAbsent
          ? const Value.absent()
          : Value(meaningEn),
      meaningJa: meaningJa == null && nullToAbsent
          ? const Value.absent()
          : Value(meaningJa),
      mnemonicVi: mnemonicVi == null && nullToAbsent
          ? const Value.absent()
          : Value(mnemonicVi),
      mnemonicEn: mnemonicEn == null && nullToAbsent
          ? const Value.absent()
          : Value(mnemonicEn),
      decompositionJson: decompositionJson == null && nullToAbsent
          ? const Value.absent()
          : Value(decompositionJson),
      examplesJson: Value(examplesJson),
      jlptLevel: Value(jlptLevel),
    );
  }

  factory KanjiData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KanjiData(
      id: serializer.fromJson<int>(json['id']),
      lessonId: serializer.fromJson<int>(json['lessonId']),
      character: serializer.fromJson<String>(json['character']),
      strokeCount: serializer.fromJson<int>(json['strokeCount']),
      onyomi: serializer.fromJson<String?>(json['onyomi']),
      kunyomi: serializer.fromJson<String?>(json['kunyomi']),
      meaning: serializer.fromJson<String>(json['meaning']),
      meaningEn: serializer.fromJson<String?>(json['meaningEn']),
      meaningJa: serializer.fromJson<String?>(json['meaningJa']),
      mnemonicVi: serializer.fromJson<String?>(json['mnemonicVi']),
      mnemonicEn: serializer.fromJson<String?>(json['mnemonicEn']),
      decompositionJson: serializer.fromJson<String?>(
        json['decompositionJson'],
      ),
      examplesJson: serializer.fromJson<String>(json['examplesJson']),
      jlptLevel: serializer.fromJson<String>(json['jlptLevel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lessonId': serializer.toJson<int>(lessonId),
      'character': serializer.toJson<String>(character),
      'strokeCount': serializer.toJson<int>(strokeCount),
      'onyomi': serializer.toJson<String?>(onyomi),
      'kunyomi': serializer.toJson<String?>(kunyomi),
      'meaning': serializer.toJson<String>(meaning),
      'meaningEn': serializer.toJson<String?>(meaningEn),
      'meaningJa': serializer.toJson<String?>(meaningJa),
      'mnemonicVi': serializer.toJson<String?>(mnemonicVi),
      'mnemonicEn': serializer.toJson<String?>(mnemonicEn),
      'decompositionJson': serializer.toJson<String?>(decompositionJson),
      'examplesJson': serializer.toJson<String>(examplesJson),
      'jlptLevel': serializer.toJson<String>(jlptLevel),
    };
  }

  KanjiData copyWith({
    int? id,
    int? lessonId,
    String? character,
    int? strokeCount,
    Value<String?> onyomi = const Value.absent(),
    Value<String?> kunyomi = const Value.absent(),
    String? meaning,
    Value<String?> meaningEn = const Value.absent(),
    Value<String?> meaningJa = const Value.absent(),
    Value<String?> mnemonicVi = const Value.absent(),
    Value<String?> mnemonicEn = const Value.absent(),
    Value<String?> decompositionJson = const Value.absent(),
    String? examplesJson,
    String? jlptLevel,
  }) => KanjiData(
    id: id ?? this.id,
    lessonId: lessonId ?? this.lessonId,
    character: character ?? this.character,
    strokeCount: strokeCount ?? this.strokeCount,
    onyomi: onyomi.present ? onyomi.value : this.onyomi,
    kunyomi: kunyomi.present ? kunyomi.value : this.kunyomi,
    meaning: meaning ?? this.meaning,
    meaningEn: meaningEn.present ? meaningEn.value : this.meaningEn,
    meaningJa: meaningJa.present ? meaningJa.value : this.meaningJa,
    mnemonicVi: mnemonicVi.present ? mnemonicVi.value : this.mnemonicVi,
    mnemonicEn: mnemonicEn.present ? mnemonicEn.value : this.mnemonicEn,
    decompositionJson: decompositionJson.present
        ? decompositionJson.value
        : this.decompositionJson,
    examplesJson: examplesJson ?? this.examplesJson,
    jlptLevel: jlptLevel ?? this.jlptLevel,
  );
  KanjiData copyWithCompanion(KanjiCompanion data) {
    return KanjiData(
      id: data.id.present ? data.id.value : this.id,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      character: data.character.present ? data.character.value : this.character,
      strokeCount: data.strokeCount.present
          ? data.strokeCount.value
          : this.strokeCount,
      onyomi: data.onyomi.present ? data.onyomi.value : this.onyomi,
      kunyomi: data.kunyomi.present ? data.kunyomi.value : this.kunyomi,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      meaningEn: data.meaningEn.present ? data.meaningEn.value : this.meaningEn,
      meaningJa: data.meaningJa.present ? data.meaningJa.value : this.meaningJa,
      mnemonicVi: data.mnemonicVi.present
          ? data.mnemonicVi.value
          : this.mnemonicVi,
      mnemonicEn: data.mnemonicEn.present
          ? data.mnemonicEn.value
          : this.mnemonicEn,
      decompositionJson: data.decompositionJson.present
          ? data.decompositionJson.value
          : this.decompositionJson,
      examplesJson: data.examplesJson.present
          ? data.examplesJson.value
          : this.examplesJson,
      jlptLevel: data.jlptLevel.present ? data.jlptLevel.value : this.jlptLevel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KanjiData(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('character: $character, ')
          ..write('strokeCount: $strokeCount, ')
          ..write('onyomi: $onyomi, ')
          ..write('kunyomi: $kunyomi, ')
          ..write('meaning: $meaning, ')
          ..write('meaningEn: $meaningEn, ')
          ..write('meaningJa: $meaningJa, ')
          ..write('mnemonicVi: $mnemonicVi, ')
          ..write('mnemonicEn: $mnemonicEn, ')
          ..write('decompositionJson: $decompositionJson, ')
          ..write('examplesJson: $examplesJson, ')
          ..write('jlptLevel: $jlptLevel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lessonId,
    character,
    strokeCount,
    onyomi,
    kunyomi,
    meaning,
    meaningEn,
    meaningJa,
    mnemonicVi,
    mnemonicEn,
    decompositionJson,
    examplesJson,
    jlptLevel,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KanjiData &&
          other.id == this.id &&
          other.lessonId == this.lessonId &&
          other.character == this.character &&
          other.strokeCount == this.strokeCount &&
          other.onyomi == this.onyomi &&
          other.kunyomi == this.kunyomi &&
          other.meaning == this.meaning &&
          other.meaningEn == this.meaningEn &&
          other.meaningJa == this.meaningJa &&
          other.mnemonicVi == this.mnemonicVi &&
          other.mnemonicEn == this.mnemonicEn &&
          other.decompositionJson == this.decompositionJson &&
          other.examplesJson == this.examplesJson &&
          other.jlptLevel == this.jlptLevel);
}

class KanjiCompanion extends UpdateCompanion<KanjiData> {
  final Value<int> id;
  final Value<int> lessonId;
  final Value<String> character;
  final Value<int> strokeCount;
  final Value<String?> onyomi;
  final Value<String?> kunyomi;
  final Value<String> meaning;
  final Value<String?> meaningEn;
  final Value<String?> meaningJa;
  final Value<String?> mnemonicVi;
  final Value<String?> mnemonicEn;
  final Value<String?> decompositionJson;
  final Value<String> examplesJson;
  final Value<String> jlptLevel;
  const KanjiCompanion({
    this.id = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.character = const Value.absent(),
    this.strokeCount = const Value.absent(),
    this.onyomi = const Value.absent(),
    this.kunyomi = const Value.absent(),
    this.meaning = const Value.absent(),
    this.meaningEn = const Value.absent(),
    this.meaningJa = const Value.absent(),
    this.mnemonicVi = const Value.absent(),
    this.mnemonicEn = const Value.absent(),
    this.decompositionJson = const Value.absent(),
    this.examplesJson = const Value.absent(),
    this.jlptLevel = const Value.absent(),
  });
  KanjiCompanion.insert({
    this.id = const Value.absent(),
    required int lessonId,
    required String character,
    required int strokeCount,
    this.onyomi = const Value.absent(),
    this.kunyomi = const Value.absent(),
    required String meaning,
    this.meaningEn = const Value.absent(),
    this.meaningJa = const Value.absent(),
    this.mnemonicVi = const Value.absent(),
    this.mnemonicEn = const Value.absent(),
    this.decompositionJson = const Value.absent(),
    required String examplesJson,
    required String jlptLevel,
  }) : lessonId = Value(lessonId),
       character = Value(character),
       strokeCount = Value(strokeCount),
       meaning = Value(meaning),
       examplesJson = Value(examplesJson),
       jlptLevel = Value(jlptLevel);
  static Insertable<KanjiData> custom({
    Expression<int>? id,
    Expression<int>? lessonId,
    Expression<String>? character,
    Expression<int>? strokeCount,
    Expression<String>? onyomi,
    Expression<String>? kunyomi,
    Expression<String>? meaning,
    Expression<String>? meaningEn,
    Expression<String>? meaningJa,
    Expression<String>? mnemonicVi,
    Expression<String>? mnemonicEn,
    Expression<String>? decompositionJson,
    Expression<String>? examplesJson,
    Expression<String>? jlptLevel,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lessonId != null) 'lesson_id': lessonId,
      if (character != null) 'character': character,
      if (strokeCount != null) 'stroke_count': strokeCount,
      if (onyomi != null) 'onyomi': onyomi,
      if (kunyomi != null) 'kunyomi': kunyomi,
      if (meaning != null) 'meaning': meaning,
      if (meaningEn != null) 'meaning_en': meaningEn,
      if (meaningJa != null) 'meaning_ja': meaningJa,
      if (mnemonicVi != null) 'mnemonic_vi': mnemonicVi,
      if (mnemonicEn != null) 'mnemonic_en': mnemonicEn,
      if (decompositionJson != null) 'decomposition_json': decompositionJson,
      if (examplesJson != null) 'examples_json': examplesJson,
      if (jlptLevel != null) 'jlpt_level': jlptLevel,
    });
  }

  KanjiCompanion copyWith({
    Value<int>? id,
    Value<int>? lessonId,
    Value<String>? character,
    Value<int>? strokeCount,
    Value<String?>? onyomi,
    Value<String?>? kunyomi,
    Value<String>? meaning,
    Value<String?>? meaningEn,
    Value<String?>? meaningJa,
    Value<String?>? mnemonicVi,
    Value<String?>? mnemonicEn,
    Value<String?>? decompositionJson,
    Value<String>? examplesJson,
    Value<String>? jlptLevel,
  }) {
    return KanjiCompanion(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      character: character ?? this.character,
      strokeCount: strokeCount ?? this.strokeCount,
      onyomi: onyomi ?? this.onyomi,
      kunyomi: kunyomi ?? this.kunyomi,
      meaning: meaning ?? this.meaning,
      meaningEn: meaningEn ?? this.meaningEn,
      meaningJa: meaningJa ?? this.meaningJa,
      mnemonicVi: mnemonicVi ?? this.mnemonicVi,
      mnemonicEn: mnemonicEn ?? this.mnemonicEn,
      decompositionJson: decompositionJson ?? this.decompositionJson,
      examplesJson: examplesJson ?? this.examplesJson,
      jlptLevel: jlptLevel ?? this.jlptLevel,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<int>(lessonId.value);
    }
    if (character.present) {
      map['character'] = Variable<String>(character.value);
    }
    if (strokeCount.present) {
      map['stroke_count'] = Variable<int>(strokeCount.value);
    }
    if (onyomi.present) {
      map['onyomi'] = Variable<String>(onyomi.value);
    }
    if (kunyomi.present) {
      map['kunyomi'] = Variable<String>(kunyomi.value);
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (meaningEn.present) {
      map['meaning_en'] = Variable<String>(meaningEn.value);
    }
    if (meaningJa.present) {
      map['meaning_ja'] = Variable<String>(meaningJa.value);
    }
    if (mnemonicVi.present) {
      map['mnemonic_vi'] = Variable<String>(mnemonicVi.value);
    }
    if (mnemonicEn.present) {
      map['mnemonic_en'] = Variable<String>(mnemonicEn.value);
    }
    if (decompositionJson.present) {
      map['decomposition_json'] = Variable<String>(decompositionJson.value);
    }
    if (examplesJson.present) {
      map['examples_json'] = Variable<String>(examplesJson.value);
    }
    if (jlptLevel.present) {
      map['jlpt_level'] = Variable<String>(jlptLevel.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KanjiCompanion(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('character: $character, ')
          ..write('strokeCount: $strokeCount, ')
          ..write('onyomi: $onyomi, ')
          ..write('kunyomi: $kunyomi, ')
          ..write('meaning: $meaning, ')
          ..write('meaningEn: $meaningEn, ')
          ..write('meaningJa: $meaningJa, ')
          ..write('mnemonicVi: $mnemonicVi, ')
          ..write('mnemonicEn: $mnemonicEn, ')
          ..write('decompositionJson: $decompositionJson, ')
          ..write('examplesJson: $examplesJson, ')
          ..write('jlptLevel: $jlptLevel')
          ..write(')'))
        .toString();
  }
}

abstract class _$ContentDatabase extends GeneratedDatabase {
  _$ContentDatabase(QueryExecutor e) : super(e);
  $ContentDatabaseManager get managers => $ContentDatabaseManager(this);
  late final $VocabTable vocab = $VocabTable(this);
  late final $GrammarPointTable grammarPoint = $GrammarPointTable(this);
  late final $GrammarExampleTable grammarExample = $GrammarExampleTable(this);
  late final $QuestionTable question = $QuestionTable(this);
  late final $MockTestTable mockTest = $MockTestTable(this);
  late final $MockTestSectionTable mockTestSection = $MockTestSectionTable(
    this,
  );
  late final $MockTestQuestionMapTable mockTestQuestionMap =
      $MockTestQuestionMapTable(this);
  late final $UserProgressTable userProgress = $UserProgressTable(this);
  late final $KanjiTable kanji = $KanjiTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vocab,
    grammarPoint,
    grammarExample,
    question,
    mockTest,
    mockTestSection,
    mockTestQuestionMap,
    userProgress,
    kanji,
  ];
}

typedef $$VocabTableCreateCompanionBuilder =
    VocabCompanion Function({
      Value<int> id,
      required String term,
      Value<String?> reading,
      required String meaning,
      Value<String?> meaningEn,
      Value<String?> kanjiMeaning,
      Value<String?> sourceVocabId,
      Value<String?> sourceSenseId,
      Value<String> series,
      required String level,
      Value<String?> tags,
    });
typedef $$VocabTableUpdateCompanionBuilder =
    VocabCompanion Function({
      Value<int> id,
      Value<String> term,
      Value<String?> reading,
      Value<String> meaning,
      Value<String?> meaningEn,
      Value<String?> kanjiMeaning,
      Value<String?> sourceVocabId,
      Value<String?> sourceSenseId,
      Value<String> series,
      Value<String> level,
      Value<String?> tags,
    });

final class $$VocabTableReferences
    extends BaseReferences<_$ContentDatabase, $VocabTable, VocabData> {
  $$VocabTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserProgressTable, List<UserProgressData>>
  _userProgressRefsTable(_$ContentDatabase db) => MultiTypedResultKey.fromTable(
    db.userProgress,
    aliasName: $_aliasNameGenerator(db.vocab.id, db.userProgress.vocabId),
  );

  $$UserProgressTableProcessedTableManager get userProgressRefs {
    final manager = $$UserProgressTableTableManager(
      $_db,
      $_db.userProgress,
    ).filter((f) => f.vocabId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userProgressRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VocabTableFilterComposer
    extends Composer<_$ContentDatabase, $VocabTable> {
  $$VocabTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reading => $composableBuilder(
    column: $table.reading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaningEn => $composableBuilder(
    column: $table.meaningEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kanjiMeaning => $composableBuilder(
    column: $table.kanjiMeaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceVocabId => $composableBuilder(
    column: $table.sourceVocabId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceSenseId => $composableBuilder(
    column: $table.sourceSenseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get series => $composableBuilder(
    column: $table.series,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> userProgressRefs(
    Expression<bool> Function($$UserProgressTableFilterComposer f) f,
  ) {
    final $$UserProgressTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userProgress,
      getReferencedColumn: (t) => t.vocabId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProgressTableFilterComposer(
            $db: $db,
            $table: $db.userProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VocabTableOrderingComposer
    extends Composer<_$ContentDatabase, $VocabTable> {
  $$VocabTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reading => $composableBuilder(
    column: $table.reading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaningEn => $composableBuilder(
    column: $table.meaningEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kanjiMeaning => $composableBuilder(
    column: $table.kanjiMeaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceVocabId => $composableBuilder(
    column: $table.sourceVocabId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceSenseId => $composableBuilder(
    column: $table.sourceSenseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get series => $composableBuilder(
    column: $table.series,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VocabTableAnnotationComposer
    extends Composer<_$ContentDatabase, $VocabTable> {
  $$VocabTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get term =>
      $composableBuilder(column: $table.term, builder: (column) => column);

  GeneratedColumn<String> get reading =>
      $composableBuilder(column: $table.reading, builder: (column) => column);

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumn<String> get meaningEn =>
      $composableBuilder(column: $table.meaningEn, builder: (column) => column);

  GeneratedColumn<String> get kanjiMeaning => $composableBuilder(
    column: $table.kanjiMeaning,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceVocabId => $composableBuilder(
    column: $table.sourceVocabId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceSenseId => $composableBuilder(
    column: $table.sourceSenseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get series =>
      $composableBuilder(column: $table.series, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  Expression<T> userProgressRefs<T extends Object>(
    Expression<T> Function($$UserProgressTableAnnotationComposer a) f,
  ) {
    final $$UserProgressTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userProgress,
      getReferencedColumn: (t) => t.vocabId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProgressTableAnnotationComposer(
            $db: $db,
            $table: $db.userProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VocabTableTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          $VocabTable,
          VocabData,
          $$VocabTableFilterComposer,
          $$VocabTableOrderingComposer,
          $$VocabTableAnnotationComposer,
          $$VocabTableCreateCompanionBuilder,
          $$VocabTableUpdateCompanionBuilder,
          (VocabData, $$VocabTableReferences),
          VocabData,
          PrefetchHooks Function({bool userProgressRefs})
        > {
  $$VocabTableTableManager(_$ContentDatabase db, $VocabTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VocabTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VocabTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VocabTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> term = const Value.absent(),
                Value<String?> reading = const Value.absent(),
                Value<String> meaning = const Value.absent(),
                Value<String?> meaningEn = const Value.absent(),
                Value<String?> kanjiMeaning = const Value.absent(),
                Value<String?> sourceVocabId = const Value.absent(),
                Value<String?> sourceSenseId = const Value.absent(),
                Value<String> series = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String?> tags = const Value.absent(),
              }) => VocabCompanion(
                id: id,
                term: term,
                reading: reading,
                meaning: meaning,
                meaningEn: meaningEn,
                kanjiMeaning: kanjiMeaning,
                sourceVocabId: sourceVocabId,
                sourceSenseId: sourceSenseId,
                series: series,
                level: level,
                tags: tags,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String term,
                Value<String?> reading = const Value.absent(),
                required String meaning,
                Value<String?> meaningEn = const Value.absent(),
                Value<String?> kanjiMeaning = const Value.absent(),
                Value<String?> sourceVocabId = const Value.absent(),
                Value<String?> sourceSenseId = const Value.absent(),
                Value<String> series = const Value.absent(),
                required String level,
                Value<String?> tags = const Value.absent(),
              }) => VocabCompanion.insert(
                id: id,
                term: term,
                reading: reading,
                meaning: meaning,
                meaningEn: meaningEn,
                kanjiMeaning: kanjiMeaning,
                sourceVocabId: sourceVocabId,
                sourceSenseId: sourceSenseId,
                series: series,
                level: level,
                tags: tags,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$VocabTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({userProgressRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (userProgressRefs) db.userProgress],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userProgressRefs)
                    await $_getPrefetchedData<
                      VocabData,
                      $VocabTable,
                      UserProgressData
                    >(
                      currentTable: table,
                      referencedTable: $$VocabTableReferences
                          ._userProgressRefsTable(db),
                      managerFromTypedResult: (p0) => $$VocabTableReferences(
                        db,
                        table,
                        p0,
                      ).userProgressRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.vocabId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$VocabTableProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      $VocabTable,
      VocabData,
      $$VocabTableFilterComposer,
      $$VocabTableOrderingComposer,
      $$VocabTableAnnotationComposer,
      $$VocabTableCreateCompanionBuilder,
      $$VocabTableUpdateCompanionBuilder,
      (VocabData, $$VocabTableReferences),
      VocabData,
      PrefetchHooks Function({bool userProgressRefs})
    >;
typedef $$GrammarPointTableCreateCompanionBuilder =
    GrammarPointCompanion Function({
      Value<int> id,
      required int lessonId,
      required String title,
      Value<String?> titleEn,
      required String structure,
      Value<String?> structureEn,
      required String explanation,
      Value<String?> explanationEn,
      required String level,
      Value<String?> tags,
    });
typedef $$GrammarPointTableUpdateCompanionBuilder =
    GrammarPointCompanion Function({
      Value<int> id,
      Value<int> lessonId,
      Value<String> title,
      Value<String?> titleEn,
      Value<String> structure,
      Value<String?> structureEn,
      Value<String> explanation,
      Value<String?> explanationEn,
      Value<String> level,
      Value<String?> tags,
    });

final class $$GrammarPointTableReferences
    extends
        BaseReferences<
          _$ContentDatabase,
          $GrammarPointTable,
          GrammarPointData
        > {
  $$GrammarPointTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GrammarExampleTable, List<GrammarExampleData>>
  _grammarExampleRefsTable(_$ContentDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.grammarExample,
        aliasName: $_aliasNameGenerator(
          db.grammarPoint.id,
          db.grammarExample.grammarPointId,
        ),
      );

  $$GrammarExampleTableProcessedTableManager get grammarExampleRefs {
    final manager = $$GrammarExampleTableTableManager(
      $_db,
      $_db.grammarExample,
    ).filter((f) => f.grammarPointId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_grammarExampleRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GrammarPointTableFilterComposer
    extends Composer<_$ContentDatabase, $GrammarPointTable> {
  $$GrammarPointTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleEn => $composableBuilder(
    column: $table.titleEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get structure => $composableBuilder(
    column: $table.structure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get structureEn => $composableBuilder(
    column: $table.structureEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanationEn => $composableBuilder(
    column: $table.explanationEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> grammarExampleRefs(
    Expression<bool> Function($$GrammarExampleTableFilterComposer f) f,
  ) {
    final $$GrammarExampleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.grammarExample,
      getReferencedColumn: (t) => t.grammarPointId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrammarExampleTableFilterComposer(
            $db: $db,
            $table: $db.grammarExample,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GrammarPointTableOrderingComposer
    extends Composer<_$ContentDatabase, $GrammarPointTable> {
  $$GrammarPointTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleEn => $composableBuilder(
    column: $table.titleEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get structure => $composableBuilder(
    column: $table.structure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get structureEn => $composableBuilder(
    column: $table.structureEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanationEn => $composableBuilder(
    column: $table.explanationEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GrammarPointTableAnnotationComposer
    extends Composer<_$ContentDatabase, $GrammarPointTable> {
  $$GrammarPointTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get titleEn =>
      $composableBuilder(column: $table.titleEn, builder: (column) => column);

  GeneratedColumn<String> get structure =>
      $composableBuilder(column: $table.structure, builder: (column) => column);

  GeneratedColumn<String> get structureEn => $composableBuilder(
    column: $table.structureEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get explanationEn => $composableBuilder(
    column: $table.explanationEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  Expression<T> grammarExampleRefs<T extends Object>(
    Expression<T> Function($$GrammarExampleTableAnnotationComposer a) f,
  ) {
    final $$GrammarExampleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.grammarExample,
      getReferencedColumn: (t) => t.grammarPointId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrammarExampleTableAnnotationComposer(
            $db: $db,
            $table: $db.grammarExample,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GrammarPointTableTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          $GrammarPointTable,
          GrammarPointData,
          $$GrammarPointTableFilterComposer,
          $$GrammarPointTableOrderingComposer,
          $$GrammarPointTableAnnotationComposer,
          $$GrammarPointTableCreateCompanionBuilder,
          $$GrammarPointTableUpdateCompanionBuilder,
          (GrammarPointData, $$GrammarPointTableReferences),
          GrammarPointData,
          PrefetchHooks Function({bool grammarExampleRefs})
        > {
  $$GrammarPointTableTableManager(
    _$ContentDatabase db,
    $GrammarPointTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GrammarPointTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GrammarPointTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GrammarPointTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> lessonId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> titleEn = const Value.absent(),
                Value<String> structure = const Value.absent(),
                Value<String?> structureEn = const Value.absent(),
                Value<String> explanation = const Value.absent(),
                Value<String?> explanationEn = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String?> tags = const Value.absent(),
              }) => GrammarPointCompanion(
                id: id,
                lessonId: lessonId,
                title: title,
                titleEn: titleEn,
                structure: structure,
                structureEn: structureEn,
                explanation: explanation,
                explanationEn: explanationEn,
                level: level,
                tags: tags,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int lessonId,
                required String title,
                Value<String?> titleEn = const Value.absent(),
                required String structure,
                Value<String?> structureEn = const Value.absent(),
                required String explanation,
                Value<String?> explanationEn = const Value.absent(),
                required String level,
                Value<String?> tags = const Value.absent(),
              }) => GrammarPointCompanion.insert(
                id: id,
                lessonId: lessonId,
                title: title,
                titleEn: titleEn,
                structure: structure,
                structureEn: structureEn,
                explanation: explanation,
                explanationEn: explanationEn,
                level: level,
                tags: tags,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GrammarPointTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({grammarExampleRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (grammarExampleRefs) db.grammarExample,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (grammarExampleRefs)
                    await $_getPrefetchedData<
                      GrammarPointData,
                      $GrammarPointTable,
                      GrammarExampleData
                    >(
                      currentTable: table,
                      referencedTable: $$GrammarPointTableReferences
                          ._grammarExampleRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$GrammarPointTableReferences(
                            db,
                            table,
                            p0,
                          ).grammarExampleRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.grammarPointId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GrammarPointTableProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      $GrammarPointTable,
      GrammarPointData,
      $$GrammarPointTableFilterComposer,
      $$GrammarPointTableOrderingComposer,
      $$GrammarPointTableAnnotationComposer,
      $$GrammarPointTableCreateCompanionBuilder,
      $$GrammarPointTableUpdateCompanionBuilder,
      (GrammarPointData, $$GrammarPointTableReferences),
      GrammarPointData,
      PrefetchHooks Function({bool grammarExampleRefs})
    >;
typedef $$GrammarExampleTableCreateCompanionBuilder =
    GrammarExampleCompanion Function({
      Value<int> id,
      required int grammarPointId,
      required String sentence,
      required String translation,
      Value<String?> translationEn,
    });
typedef $$GrammarExampleTableUpdateCompanionBuilder =
    GrammarExampleCompanion Function({
      Value<int> id,
      Value<int> grammarPointId,
      Value<String> sentence,
      Value<String> translation,
      Value<String?> translationEn,
    });

final class $$GrammarExampleTableReferences
    extends
        BaseReferences<
          _$ContentDatabase,
          $GrammarExampleTable,
          GrammarExampleData
        > {
  $$GrammarExampleTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GrammarPointTable _grammarPointIdTable(_$ContentDatabase db) =>
      db.grammarPoint.createAlias(
        $_aliasNameGenerator(
          db.grammarExample.grammarPointId,
          db.grammarPoint.id,
        ),
      );

  $$GrammarPointTableProcessedTableManager get grammarPointId {
    final $_column = $_itemColumn<int>('grammar_point_id')!;

    final manager = $$GrammarPointTableTableManager(
      $_db,
      $_db.grammarPoint,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_grammarPointIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GrammarExampleTableFilterComposer
    extends Composer<_$ContentDatabase, $GrammarExampleTable> {
  $$GrammarExampleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sentence => $composableBuilder(
    column: $table.sentence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translationEn => $composableBuilder(
    column: $table.translationEn,
    builder: (column) => ColumnFilters(column),
  );

  $$GrammarPointTableFilterComposer get grammarPointId {
    final $$GrammarPointTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.grammarPointId,
      referencedTable: $db.grammarPoint,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrammarPointTableFilterComposer(
            $db: $db,
            $table: $db.grammarPoint,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GrammarExampleTableOrderingComposer
    extends Composer<_$ContentDatabase, $GrammarExampleTable> {
  $$GrammarExampleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sentence => $composableBuilder(
    column: $table.sentence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translationEn => $composableBuilder(
    column: $table.translationEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$GrammarPointTableOrderingComposer get grammarPointId {
    final $$GrammarPointTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.grammarPointId,
      referencedTable: $db.grammarPoint,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrammarPointTableOrderingComposer(
            $db: $db,
            $table: $db.grammarPoint,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GrammarExampleTableAnnotationComposer
    extends Composer<_$ContentDatabase, $GrammarExampleTable> {
  $$GrammarExampleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sentence =>
      $composableBuilder(column: $table.sentence, builder: (column) => column);

  GeneratedColumn<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get translationEn => $composableBuilder(
    column: $table.translationEn,
    builder: (column) => column,
  );

  $$GrammarPointTableAnnotationComposer get grammarPointId {
    final $$GrammarPointTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.grammarPointId,
      referencedTable: $db.grammarPoint,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrammarPointTableAnnotationComposer(
            $db: $db,
            $table: $db.grammarPoint,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GrammarExampleTableTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          $GrammarExampleTable,
          GrammarExampleData,
          $$GrammarExampleTableFilterComposer,
          $$GrammarExampleTableOrderingComposer,
          $$GrammarExampleTableAnnotationComposer,
          $$GrammarExampleTableCreateCompanionBuilder,
          $$GrammarExampleTableUpdateCompanionBuilder,
          (GrammarExampleData, $$GrammarExampleTableReferences),
          GrammarExampleData,
          PrefetchHooks Function({bool grammarPointId})
        > {
  $$GrammarExampleTableTableManager(
    _$ContentDatabase db,
    $GrammarExampleTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GrammarExampleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GrammarExampleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GrammarExampleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> grammarPointId = const Value.absent(),
                Value<String> sentence = const Value.absent(),
                Value<String> translation = const Value.absent(),
                Value<String?> translationEn = const Value.absent(),
              }) => GrammarExampleCompanion(
                id: id,
                grammarPointId: grammarPointId,
                sentence: sentence,
                translation: translation,
                translationEn: translationEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int grammarPointId,
                required String sentence,
                required String translation,
                Value<String?> translationEn = const Value.absent(),
              }) => GrammarExampleCompanion.insert(
                id: id,
                grammarPointId: grammarPointId,
                sentence: sentence,
                translation: translation,
                translationEn: translationEn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GrammarExampleTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({grammarPointId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (grammarPointId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.grammarPointId,
                                referencedTable: $$GrammarExampleTableReferences
                                    ._grammarPointIdTable(db),
                                referencedColumn:
                                    $$GrammarExampleTableReferences
                                        ._grammarPointIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GrammarExampleTableProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      $GrammarExampleTable,
      GrammarExampleData,
      $$GrammarExampleTableFilterComposer,
      $$GrammarExampleTableOrderingComposer,
      $$GrammarExampleTableAnnotationComposer,
      $$GrammarExampleTableCreateCompanionBuilder,
      $$GrammarExampleTableUpdateCompanionBuilder,
      (GrammarExampleData, $$GrammarExampleTableReferences),
      GrammarExampleData,
      PrefetchHooks Function({bool grammarPointId})
    >;
typedef $$QuestionTableCreateCompanionBuilder =
    QuestionCompanion Function({
      Value<int> id,
      required String level,
      required String prompt,
      required String choicesJson,
      required int correctIndex,
      Value<int?> grammarId,
      Value<String?> explanation,
    });
typedef $$QuestionTableUpdateCompanionBuilder =
    QuestionCompanion Function({
      Value<int> id,
      Value<String> level,
      Value<String> prompt,
      Value<String> choicesJson,
      Value<int> correctIndex,
      Value<int?> grammarId,
      Value<String?> explanation,
    });

class $$QuestionTableFilterComposer
    extends Composer<_$ContentDatabase, $QuestionTable> {
  $$QuestionTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get choicesJson => $composableBuilder(
    column: $table.choicesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctIndex => $composableBuilder(
    column: $table.correctIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grammarId => $composableBuilder(
    column: $table.grammarId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuestionTableOrderingComposer
    extends Composer<_$ContentDatabase, $QuestionTable> {
  $$QuestionTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get choicesJson => $composableBuilder(
    column: $table.choicesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctIndex => $composableBuilder(
    column: $table.correctIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grammarId => $composableBuilder(
    column: $table.grammarId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuestionTableAnnotationComposer
    extends Composer<_$ContentDatabase, $QuestionTable> {
  $$QuestionTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get prompt =>
      $composableBuilder(column: $table.prompt, builder: (column) => column);

  GeneratedColumn<String> get choicesJson => $composableBuilder(
    column: $table.choicesJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctIndex => $composableBuilder(
    column: $table.correctIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get grammarId =>
      $composableBuilder(column: $table.grammarId, builder: (column) => column);

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );
}

class $$QuestionTableTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          $QuestionTable,
          QuestionData,
          $$QuestionTableFilterComposer,
          $$QuestionTableOrderingComposer,
          $$QuestionTableAnnotationComposer,
          $$QuestionTableCreateCompanionBuilder,
          $$QuestionTableUpdateCompanionBuilder,
          (
            QuestionData,
            BaseReferences<_$ContentDatabase, $QuestionTable, QuestionData>,
          ),
          QuestionData,
          PrefetchHooks Function()
        > {
  $$QuestionTableTableManager(_$ContentDatabase db, $QuestionTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestionTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestionTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> prompt = const Value.absent(),
                Value<String> choicesJson = const Value.absent(),
                Value<int> correctIndex = const Value.absent(),
                Value<int?> grammarId = const Value.absent(),
                Value<String?> explanation = const Value.absent(),
              }) => QuestionCompanion(
                id: id,
                level: level,
                prompt: prompt,
                choicesJson: choicesJson,
                correctIndex: correctIndex,
                grammarId: grammarId,
                explanation: explanation,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String level,
                required String prompt,
                required String choicesJson,
                required int correctIndex,
                Value<int?> grammarId = const Value.absent(),
                Value<String?> explanation = const Value.absent(),
              }) => QuestionCompanion.insert(
                id: id,
                level: level,
                prompt: prompt,
                choicesJson: choicesJson,
                correctIndex: correctIndex,
                grammarId: grammarId,
                explanation: explanation,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuestionTableProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      $QuestionTable,
      QuestionData,
      $$QuestionTableFilterComposer,
      $$QuestionTableOrderingComposer,
      $$QuestionTableAnnotationComposer,
      $$QuestionTableCreateCompanionBuilder,
      $$QuestionTableUpdateCompanionBuilder,
      (
        QuestionData,
        BaseReferences<_$ContentDatabase, $QuestionTable, QuestionData>,
      ),
      QuestionData,
      PrefetchHooks Function()
    >;
typedef $$MockTestTableCreateCompanionBuilder =
    MockTestCompanion Function({
      Value<int> id,
      required String level,
      required String title,
      required int durationSeconds,
    });
typedef $$MockTestTableUpdateCompanionBuilder =
    MockTestCompanion Function({
      Value<int> id,
      Value<String> level,
      Value<String> title,
      Value<int> durationSeconds,
    });

class $$MockTestTableFilterComposer
    extends Composer<_$ContentDatabase, $MockTestTable> {
  $$MockTestTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MockTestTableOrderingComposer
    extends Composer<_$ContentDatabase, $MockTestTable> {
  $$MockTestTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MockTestTableAnnotationComposer
    extends Composer<_$ContentDatabase, $MockTestTable> {
  $$MockTestTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );
}

class $$MockTestTableTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          $MockTestTable,
          MockTestData,
          $$MockTestTableFilterComposer,
          $$MockTestTableOrderingComposer,
          $$MockTestTableAnnotationComposer,
          $$MockTestTableCreateCompanionBuilder,
          $$MockTestTableUpdateCompanionBuilder,
          (
            MockTestData,
            BaseReferences<_$ContentDatabase, $MockTestTable, MockTestData>,
          ),
          MockTestData,
          PrefetchHooks Function()
        > {
  $$MockTestTableTableManager(_$ContentDatabase db, $MockTestTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MockTestTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MockTestTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MockTestTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
              }) => MockTestCompanion(
                id: id,
                level: level,
                title: title,
                durationSeconds: durationSeconds,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String level,
                required String title,
                required int durationSeconds,
              }) => MockTestCompanion.insert(
                id: id,
                level: level,
                title: title,
                durationSeconds: durationSeconds,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MockTestTableProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      $MockTestTable,
      MockTestData,
      $$MockTestTableFilterComposer,
      $$MockTestTableOrderingComposer,
      $$MockTestTableAnnotationComposer,
      $$MockTestTableCreateCompanionBuilder,
      $$MockTestTableUpdateCompanionBuilder,
      (
        MockTestData,
        BaseReferences<_$ContentDatabase, $MockTestTable, MockTestData>,
      ),
      MockTestData,
      PrefetchHooks Function()
    >;
typedef $$MockTestSectionTableCreateCompanionBuilder =
    MockTestSectionCompanion Function({
      Value<int> id,
      required int testId,
      required String title,
      required int orderIndex,
    });
typedef $$MockTestSectionTableUpdateCompanionBuilder =
    MockTestSectionCompanion Function({
      Value<int> id,
      Value<int> testId,
      Value<String> title,
      Value<int> orderIndex,
    });

class $$MockTestSectionTableFilterComposer
    extends Composer<_$ContentDatabase, $MockTestSectionTable> {
  $$MockTestSectionTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get testId => $composableBuilder(
    column: $table.testId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MockTestSectionTableOrderingComposer
    extends Composer<_$ContentDatabase, $MockTestSectionTable> {
  $$MockTestSectionTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get testId => $composableBuilder(
    column: $table.testId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MockTestSectionTableAnnotationComposer
    extends Composer<_$ContentDatabase, $MockTestSectionTable> {
  $$MockTestSectionTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get testId =>
      $composableBuilder(column: $table.testId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );
}

class $$MockTestSectionTableTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          $MockTestSectionTable,
          MockTestSectionData,
          $$MockTestSectionTableFilterComposer,
          $$MockTestSectionTableOrderingComposer,
          $$MockTestSectionTableAnnotationComposer,
          $$MockTestSectionTableCreateCompanionBuilder,
          $$MockTestSectionTableUpdateCompanionBuilder,
          (
            MockTestSectionData,
            BaseReferences<
              _$ContentDatabase,
              $MockTestSectionTable,
              MockTestSectionData
            >,
          ),
          MockTestSectionData,
          PrefetchHooks Function()
        > {
  $$MockTestSectionTableTableManager(
    _$ContentDatabase db,
    $MockTestSectionTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MockTestSectionTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MockTestSectionTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MockTestSectionTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> testId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
              }) => MockTestSectionCompanion(
                id: id,
                testId: testId,
                title: title,
                orderIndex: orderIndex,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int testId,
                required String title,
                required int orderIndex,
              }) => MockTestSectionCompanion.insert(
                id: id,
                testId: testId,
                title: title,
                orderIndex: orderIndex,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MockTestSectionTableProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      $MockTestSectionTable,
      MockTestSectionData,
      $$MockTestSectionTableFilterComposer,
      $$MockTestSectionTableOrderingComposer,
      $$MockTestSectionTableAnnotationComposer,
      $$MockTestSectionTableCreateCompanionBuilder,
      $$MockTestSectionTableUpdateCompanionBuilder,
      (
        MockTestSectionData,
        BaseReferences<
          _$ContentDatabase,
          $MockTestSectionTable,
          MockTestSectionData
        >,
      ),
      MockTestSectionData,
      PrefetchHooks Function()
    >;
typedef $$MockTestQuestionMapTableCreateCompanionBuilder =
    MockTestQuestionMapCompanion Function({
      Value<int> id,
      required int testId,
      required int sectionId,
      required int questionId,
      required int orderIndex,
    });
typedef $$MockTestQuestionMapTableUpdateCompanionBuilder =
    MockTestQuestionMapCompanion Function({
      Value<int> id,
      Value<int> testId,
      Value<int> sectionId,
      Value<int> questionId,
      Value<int> orderIndex,
    });

class $$MockTestQuestionMapTableFilterComposer
    extends Composer<_$ContentDatabase, $MockTestQuestionMapTable> {
  $$MockTestQuestionMapTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get testId => $composableBuilder(
    column: $table.testId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MockTestQuestionMapTableOrderingComposer
    extends Composer<_$ContentDatabase, $MockTestQuestionMapTable> {
  $$MockTestQuestionMapTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get testId => $composableBuilder(
    column: $table.testId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MockTestQuestionMapTableAnnotationComposer
    extends Composer<_$ContentDatabase, $MockTestQuestionMapTable> {
  $$MockTestQuestionMapTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get testId =>
      $composableBuilder(column: $table.testId, builder: (column) => column);

  GeneratedColumn<int> get sectionId =>
      $composableBuilder(column: $table.sectionId, builder: (column) => column);

  GeneratedColumn<int> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );
}

class $$MockTestQuestionMapTableTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          $MockTestQuestionMapTable,
          MockTestQuestionMapData,
          $$MockTestQuestionMapTableFilterComposer,
          $$MockTestQuestionMapTableOrderingComposer,
          $$MockTestQuestionMapTableAnnotationComposer,
          $$MockTestQuestionMapTableCreateCompanionBuilder,
          $$MockTestQuestionMapTableUpdateCompanionBuilder,
          (
            MockTestQuestionMapData,
            BaseReferences<
              _$ContentDatabase,
              $MockTestQuestionMapTable,
              MockTestQuestionMapData
            >,
          ),
          MockTestQuestionMapData,
          PrefetchHooks Function()
        > {
  $$MockTestQuestionMapTableTableManager(
    _$ContentDatabase db,
    $MockTestQuestionMapTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MockTestQuestionMapTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MockTestQuestionMapTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MockTestQuestionMapTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> testId = const Value.absent(),
                Value<int> sectionId = const Value.absent(),
                Value<int> questionId = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
              }) => MockTestQuestionMapCompanion(
                id: id,
                testId: testId,
                sectionId: sectionId,
                questionId: questionId,
                orderIndex: orderIndex,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int testId,
                required int sectionId,
                required int questionId,
                required int orderIndex,
              }) => MockTestQuestionMapCompanion.insert(
                id: id,
                testId: testId,
                sectionId: sectionId,
                questionId: questionId,
                orderIndex: orderIndex,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MockTestQuestionMapTableProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      $MockTestQuestionMapTable,
      MockTestQuestionMapData,
      $$MockTestQuestionMapTableFilterComposer,
      $$MockTestQuestionMapTableOrderingComposer,
      $$MockTestQuestionMapTableAnnotationComposer,
      $$MockTestQuestionMapTableCreateCompanionBuilder,
      $$MockTestQuestionMapTableUpdateCompanionBuilder,
      (
        MockTestQuestionMapData,
        BaseReferences<
          _$ContentDatabase,
          $MockTestQuestionMapTable,
          MockTestQuestionMapData
        >,
      ),
      MockTestQuestionMapData,
      PrefetchHooks Function()
    >;
typedef $$UserProgressTableCreateCompanionBuilder =
    UserProgressCompanion Function({
      Value<int> vocabId,
      Value<int> correctCount,
      Value<int> missedCount,
      Value<DateTime?> lastReviewedAt,
    });
typedef $$UserProgressTableUpdateCompanionBuilder =
    UserProgressCompanion Function({
      Value<int> vocabId,
      Value<int> correctCount,
      Value<int> missedCount,
      Value<DateTime?> lastReviewedAt,
    });

final class $$UserProgressTableReferences
    extends
        BaseReferences<
          _$ContentDatabase,
          $UserProgressTable,
          UserProgressData
        > {
  $$UserProgressTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VocabTable _vocabIdTable(_$ContentDatabase db) => db.vocab
      .createAlias($_aliasNameGenerator(db.userProgress.vocabId, db.vocab.id));

  $$VocabTableProcessedTableManager get vocabId {
    final $_column = $_itemColumn<int>('vocab_id')!;

    final manager = $$VocabTableTableManager(
      $_db,
      $_db.vocab,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vocabIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserProgressTableFilterComposer
    extends Composer<_$ContentDatabase, $UserProgressTable> {
  $$UserProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get missedCount => $composableBuilder(
    column: $table.missedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$VocabTableFilterComposer get vocabId {
    final $$VocabTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vocabId,
      referencedTable: $db.vocab,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabTableFilterComposer(
            $db: $db,
            $table: $db.vocab,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserProgressTableOrderingComposer
    extends Composer<_$ContentDatabase, $UserProgressTable> {
  $$UserProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get missedCount => $composableBuilder(
    column: $table.missedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$VocabTableOrderingComposer get vocabId {
    final $$VocabTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vocabId,
      referencedTable: $db.vocab,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabTableOrderingComposer(
            $db: $db,
            $table: $db.vocab,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserProgressTableAnnotationComposer
    extends Composer<_$ContentDatabase, $UserProgressTable> {
  $$UserProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get missedCount => $composableBuilder(
    column: $table.missedCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => column,
  );

  $$VocabTableAnnotationComposer get vocabId {
    final $$VocabTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vocabId,
      referencedTable: $db.vocab,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabTableAnnotationComposer(
            $db: $db,
            $table: $db.vocab,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserProgressTableTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          $UserProgressTable,
          UserProgressData,
          $$UserProgressTableFilterComposer,
          $$UserProgressTableOrderingComposer,
          $$UserProgressTableAnnotationComposer,
          $$UserProgressTableCreateCompanionBuilder,
          $$UserProgressTableUpdateCompanionBuilder,
          (UserProgressData, $$UserProgressTableReferences),
          UserProgressData,
          PrefetchHooks Function({bool vocabId})
        > {
  $$UserProgressTableTableManager(
    _$ContentDatabase db,
    $UserProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> vocabId = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
                Value<int> missedCount = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
              }) => UserProgressCompanion(
                vocabId: vocabId,
                correctCount: correctCount,
                missedCount: missedCount,
                lastReviewedAt: lastReviewedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> vocabId = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
                Value<int> missedCount = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
              }) => UserProgressCompanion.insert(
                vocabId: vocabId,
                correctCount: correctCount,
                missedCount: missedCount,
                lastReviewedAt: lastReviewedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserProgressTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vocabId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vocabId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.vocabId,
                                referencedTable: $$UserProgressTableReferences
                                    ._vocabIdTable(db),
                                referencedColumn: $$UserProgressTableReferences
                                    ._vocabIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$UserProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      $UserProgressTable,
      UserProgressData,
      $$UserProgressTableFilterComposer,
      $$UserProgressTableOrderingComposer,
      $$UserProgressTableAnnotationComposer,
      $$UserProgressTableCreateCompanionBuilder,
      $$UserProgressTableUpdateCompanionBuilder,
      (UserProgressData, $$UserProgressTableReferences),
      UserProgressData,
      PrefetchHooks Function({bool vocabId})
    >;
typedef $$KanjiTableCreateCompanionBuilder =
    KanjiCompanion Function({
      Value<int> id,
      required int lessonId,
      required String character,
      required int strokeCount,
      Value<String?> onyomi,
      Value<String?> kunyomi,
      required String meaning,
      Value<String?> meaningEn,
      Value<String?> meaningJa,
      Value<String?> mnemonicVi,
      Value<String?> mnemonicEn,
      Value<String?> decompositionJson,
      required String examplesJson,
      required String jlptLevel,
    });
typedef $$KanjiTableUpdateCompanionBuilder =
    KanjiCompanion Function({
      Value<int> id,
      Value<int> lessonId,
      Value<String> character,
      Value<int> strokeCount,
      Value<String?> onyomi,
      Value<String?> kunyomi,
      Value<String> meaning,
      Value<String?> meaningEn,
      Value<String?> meaningJa,
      Value<String?> mnemonicVi,
      Value<String?> mnemonicEn,
      Value<String?> decompositionJson,
      Value<String> examplesJson,
      Value<String> jlptLevel,
    });

class $$KanjiTableFilterComposer
    extends Composer<_$ContentDatabase, $KanjiTable> {
  $$KanjiTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get character => $composableBuilder(
    column: $table.character,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get strokeCount => $composableBuilder(
    column: $table.strokeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get onyomi => $composableBuilder(
    column: $table.onyomi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kunyomi => $composableBuilder(
    column: $table.kunyomi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaningEn => $composableBuilder(
    column: $table.meaningEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaningJa => $composableBuilder(
    column: $table.meaningJa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mnemonicVi => $composableBuilder(
    column: $table.mnemonicVi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mnemonicEn => $composableBuilder(
    column: $table.mnemonicEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decompositionJson => $composableBuilder(
    column: $table.decompositionJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get examplesJson => $composableBuilder(
    column: $table.examplesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jlptLevel => $composableBuilder(
    column: $table.jlptLevel,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KanjiTableOrderingComposer
    extends Composer<_$ContentDatabase, $KanjiTable> {
  $$KanjiTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get character => $composableBuilder(
    column: $table.character,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get strokeCount => $composableBuilder(
    column: $table.strokeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get onyomi => $composableBuilder(
    column: $table.onyomi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kunyomi => $composableBuilder(
    column: $table.kunyomi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaningEn => $composableBuilder(
    column: $table.meaningEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaningJa => $composableBuilder(
    column: $table.meaningJa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mnemonicVi => $composableBuilder(
    column: $table.mnemonicVi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mnemonicEn => $composableBuilder(
    column: $table.mnemonicEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decompositionJson => $composableBuilder(
    column: $table.decompositionJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get examplesJson => $composableBuilder(
    column: $table.examplesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jlptLevel => $composableBuilder(
    column: $table.jlptLevel,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KanjiTableAnnotationComposer
    extends Composer<_$ContentDatabase, $KanjiTable> {
  $$KanjiTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<String> get character =>
      $composableBuilder(column: $table.character, builder: (column) => column);

  GeneratedColumn<int> get strokeCount => $composableBuilder(
    column: $table.strokeCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get onyomi =>
      $composableBuilder(column: $table.onyomi, builder: (column) => column);

  GeneratedColumn<String> get kunyomi =>
      $composableBuilder(column: $table.kunyomi, builder: (column) => column);

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumn<String> get meaningEn =>
      $composableBuilder(column: $table.meaningEn, builder: (column) => column);

  GeneratedColumn<String> get meaningJa =>
      $composableBuilder(column: $table.meaningJa, builder: (column) => column);

  GeneratedColumn<String> get mnemonicVi => $composableBuilder(
    column: $table.mnemonicVi,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mnemonicEn => $composableBuilder(
    column: $table.mnemonicEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get decompositionJson => $composableBuilder(
    column: $table.decompositionJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get examplesJson => $composableBuilder(
    column: $table.examplesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jlptLevel =>
      $composableBuilder(column: $table.jlptLevel, builder: (column) => column);
}

class $$KanjiTableTableManager
    extends
        RootTableManager<
          _$ContentDatabase,
          $KanjiTable,
          KanjiData,
          $$KanjiTableFilterComposer,
          $$KanjiTableOrderingComposer,
          $$KanjiTableAnnotationComposer,
          $$KanjiTableCreateCompanionBuilder,
          $$KanjiTableUpdateCompanionBuilder,
          (
            KanjiData,
            BaseReferences<_$ContentDatabase, $KanjiTable, KanjiData>,
          ),
          KanjiData,
          PrefetchHooks Function()
        > {
  $$KanjiTableTableManager(_$ContentDatabase db, $KanjiTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KanjiTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KanjiTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KanjiTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> lessonId = const Value.absent(),
                Value<String> character = const Value.absent(),
                Value<int> strokeCount = const Value.absent(),
                Value<String?> onyomi = const Value.absent(),
                Value<String?> kunyomi = const Value.absent(),
                Value<String> meaning = const Value.absent(),
                Value<String?> meaningEn = const Value.absent(),
                Value<String?> meaningJa = const Value.absent(),
                Value<String?> mnemonicVi = const Value.absent(),
                Value<String?> mnemonicEn = const Value.absent(),
                Value<String?> decompositionJson = const Value.absent(),
                Value<String> examplesJson = const Value.absent(),
                Value<String> jlptLevel = const Value.absent(),
              }) => KanjiCompanion(
                id: id,
                lessonId: lessonId,
                character: character,
                strokeCount: strokeCount,
                onyomi: onyomi,
                kunyomi: kunyomi,
                meaning: meaning,
                meaningEn: meaningEn,
                meaningJa: meaningJa,
                mnemonicVi: mnemonicVi,
                mnemonicEn: mnemonicEn,
                decompositionJson: decompositionJson,
                examplesJson: examplesJson,
                jlptLevel: jlptLevel,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int lessonId,
                required String character,
                required int strokeCount,
                Value<String?> onyomi = const Value.absent(),
                Value<String?> kunyomi = const Value.absent(),
                required String meaning,
                Value<String?> meaningEn = const Value.absent(),
                Value<String?> meaningJa = const Value.absent(),
                Value<String?> mnemonicVi = const Value.absent(),
                Value<String?> mnemonicEn = const Value.absent(),
                Value<String?> decompositionJson = const Value.absent(),
                required String examplesJson,
                required String jlptLevel,
              }) => KanjiCompanion.insert(
                id: id,
                lessonId: lessonId,
                character: character,
                strokeCount: strokeCount,
                onyomi: onyomi,
                kunyomi: kunyomi,
                meaning: meaning,
                meaningEn: meaningEn,
                meaningJa: meaningJa,
                mnemonicVi: mnemonicVi,
                mnemonicEn: mnemonicEn,
                decompositionJson: decompositionJson,
                examplesJson: examplesJson,
                jlptLevel: jlptLevel,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KanjiTableProcessedTableManager =
    ProcessedTableManager<
      _$ContentDatabase,
      $KanjiTable,
      KanjiData,
      $$KanjiTableFilterComposer,
      $$KanjiTableOrderingComposer,
      $$KanjiTableAnnotationComposer,
      $$KanjiTableCreateCompanionBuilder,
      $$KanjiTableUpdateCompanionBuilder,
      (KanjiData, BaseReferences<_$ContentDatabase, $KanjiTable, KanjiData>),
      KanjiData,
      PrefetchHooks Function()
    >;

class $ContentDatabaseManager {
  final _$ContentDatabase _db;
  $ContentDatabaseManager(this._db);
  $$VocabTableTableManager get vocab =>
      $$VocabTableTableManager(_db, _db.vocab);
  $$GrammarPointTableTableManager get grammarPoint =>
      $$GrammarPointTableTableManager(_db, _db.grammarPoint);
  $$GrammarExampleTableTableManager get grammarExample =>
      $$GrammarExampleTableTableManager(_db, _db.grammarExample);
  $$QuestionTableTableManager get question =>
      $$QuestionTableTableManager(_db, _db.question);
  $$MockTestTableTableManager get mockTest =>
      $$MockTestTableTableManager(_db, _db.mockTest);
  $$MockTestSectionTableTableManager get mockTestSection =>
      $$MockTestSectionTableTableManager(_db, _db.mockTestSection);
  $$MockTestQuestionMapTableTableManager get mockTestQuestionMap =>
      $$MockTestQuestionMapTableTableManager(_db, _db.mockTestQuestionMap);
  $$UserProgressTableTableManager get userProgress =>
      $$UserProgressTableTableManager(_db, _db.userProgress);
  $$KanjiTableTableManager get kanji =>
      $$KanjiTableTableManager(_db, _db.kanji);
}
