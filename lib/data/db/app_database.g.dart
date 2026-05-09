// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SrsStateTable extends SrsState
    with TableInfo<$SrsStateTable, SrsStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SrsStateTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _vocabIdMeta = const VerificationMeta(
    'vocabId',
  );
  @override
  late final GeneratedColumn<int> vocabId = GeneratedColumn<int>(
    'vocab_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _boxMeta = const VerificationMeta('box');
  @override
  late final GeneratedColumn<int> box = GeneratedColumn<int>(
    'box',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _repetitionsMeta = const VerificationMeta(
    'repetitions',
  );
  @override
  late final GeneratedColumn<int> repetitions = GeneratedColumn<int>(
    'repetitions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _easeMeta = const VerificationMeta('ease');
  @override
  late final GeneratedColumn<double> ease = GeneratedColumn<double>(
    'ease',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2.5),
  );
  static const VerificationMeta _stabilityMeta = const VerificationMeta(
    'stability',
  );
  @override
  late final GeneratedColumn<double> stability = GeneratedColumn<double>(
    'stability',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(5.0),
  );
  static const VerificationMeta _lastConfidenceMeta = const VerificationMeta(
    'lastConfidence',
  );
  @override
  late final GeneratedColumn<int> lastConfidence = GeneratedColumn<int>(
    'last_confidence',
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
  static const VerificationMeta _nextReviewAtMeta = const VerificationMeta(
    'nextReviewAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextReviewAt = GeneratedColumn<DateTime>(
    'next_review_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vocabId,
    box,
    repetitions,
    ease,
    stability,
    difficulty,
    lastConfidence,
    lastReviewedAt,
    nextReviewAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'srs_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SrsStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vocab_id')) {
      context.handle(
        _vocabIdMeta,
        vocabId.isAcceptableOrUnknown(data['vocab_id']!, _vocabIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vocabIdMeta);
    }
    if (data.containsKey('box')) {
      context.handle(
        _boxMeta,
        box.isAcceptableOrUnknown(data['box']!, _boxMeta),
      );
    }
    if (data.containsKey('repetitions')) {
      context.handle(
        _repetitionsMeta,
        repetitions.isAcceptableOrUnknown(
          data['repetitions']!,
          _repetitionsMeta,
        ),
      );
    }
    if (data.containsKey('ease')) {
      context.handle(
        _easeMeta,
        ease.isAcceptableOrUnknown(data['ease']!, _easeMeta),
      );
    }
    if (data.containsKey('stability')) {
      context.handle(
        _stabilityMeta,
        stability.isAcceptableOrUnknown(data['stability']!, _stabilityMeta),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('last_confidence')) {
      context.handle(
        _lastConfidenceMeta,
        lastConfidence.isAcceptableOrUnknown(
          data['last_confidence']!,
          _lastConfidenceMeta,
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
    if (data.containsKey('next_review_at')) {
      context.handle(
        _nextReviewAtMeta,
        nextReviewAt.isAcceptableOrUnknown(
          data['next_review_at']!,
          _nextReviewAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextReviewAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {vocabId},
  ];
  @override
  SrsStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SrsStateData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      vocabId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vocab_id'],
      )!,
      box: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}box'],
      )!,
      repetitions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repetitions'],
      )!,
      ease: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ease'],
      )!,
      stability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stability'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}difficulty'],
      )!,
      lastConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_confidence'],
      )!,
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reviewed_at'],
      ),
      nextReviewAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_review_at'],
      )!,
    );
  }

  @override
  $SrsStateTable createAlias(String alias) {
    return $SrsStateTable(attachedDatabase, alias);
  }
}

class SrsStateData extends DataClass implements Insertable<SrsStateData> {
  final int id;
  final int vocabId;
  final int box;
  final int repetitions;
  final double ease;
  final double stability;
  final double difficulty;
  final int lastConfidence;
  final DateTime? lastReviewedAt;
  final DateTime nextReviewAt;
  const SrsStateData({
    required this.id,
    required this.vocabId,
    required this.box,
    required this.repetitions,
    required this.ease,
    required this.stability,
    required this.difficulty,
    required this.lastConfidence,
    this.lastReviewedAt,
    required this.nextReviewAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vocab_id'] = Variable<int>(vocabId);
    map['box'] = Variable<int>(box);
    map['repetitions'] = Variable<int>(repetitions);
    map['ease'] = Variable<double>(ease);
    map['stability'] = Variable<double>(stability);
    map['difficulty'] = Variable<double>(difficulty);
    map['last_confidence'] = Variable<int>(lastConfidence);
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt);
    }
    map['next_review_at'] = Variable<DateTime>(nextReviewAt);
    return map;
  }

  SrsStateCompanion toCompanion(bool nullToAbsent) {
    return SrsStateCompanion(
      id: Value(id),
      vocabId: Value(vocabId),
      box: Value(box),
      repetitions: Value(repetitions),
      ease: Value(ease),
      stability: Value(stability),
      difficulty: Value(difficulty),
      lastConfidence: Value(lastConfidence),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
      nextReviewAt: Value(nextReviewAt),
    );
  }

  factory SrsStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SrsStateData(
      id: serializer.fromJson<int>(json['id']),
      vocabId: serializer.fromJson<int>(json['vocabId']),
      box: serializer.fromJson<int>(json['box']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
      ease: serializer.fromJson<double>(json['ease']),
      stability: serializer.fromJson<double>(json['stability']),
      difficulty: serializer.fromJson<double>(json['difficulty']),
      lastConfidence: serializer.fromJson<int>(json['lastConfidence']),
      lastReviewedAt: serializer.fromJson<DateTime?>(json['lastReviewedAt']),
      nextReviewAt: serializer.fromJson<DateTime>(json['nextReviewAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vocabId': serializer.toJson<int>(vocabId),
      'box': serializer.toJson<int>(box),
      'repetitions': serializer.toJson<int>(repetitions),
      'ease': serializer.toJson<double>(ease),
      'stability': serializer.toJson<double>(stability),
      'difficulty': serializer.toJson<double>(difficulty),
      'lastConfidence': serializer.toJson<int>(lastConfidence),
      'lastReviewedAt': serializer.toJson<DateTime?>(lastReviewedAt),
      'nextReviewAt': serializer.toJson<DateTime>(nextReviewAt),
    };
  }

  SrsStateData copyWith({
    int? id,
    int? vocabId,
    int? box,
    int? repetitions,
    double? ease,
    double? stability,
    double? difficulty,
    int? lastConfidence,
    Value<DateTime?> lastReviewedAt = const Value.absent(),
    DateTime? nextReviewAt,
  }) => SrsStateData(
    id: id ?? this.id,
    vocabId: vocabId ?? this.vocabId,
    box: box ?? this.box,
    repetitions: repetitions ?? this.repetitions,
    ease: ease ?? this.ease,
    stability: stability ?? this.stability,
    difficulty: difficulty ?? this.difficulty,
    lastConfidence: lastConfidence ?? this.lastConfidence,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
    nextReviewAt: nextReviewAt ?? this.nextReviewAt,
  );
  SrsStateData copyWithCompanion(SrsStateCompanion data) {
    return SrsStateData(
      id: data.id.present ? data.id.value : this.id,
      vocabId: data.vocabId.present ? data.vocabId.value : this.vocabId,
      box: data.box.present ? data.box.value : this.box,
      repetitions: data.repetitions.present
          ? data.repetitions.value
          : this.repetitions,
      ease: data.ease.present ? data.ease.value : this.ease,
      stability: data.stability.present ? data.stability.value : this.stability,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      lastConfidence: data.lastConfidence.present
          ? data.lastConfidence.value
          : this.lastConfidence,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
      nextReviewAt: data.nextReviewAt.present
          ? data.nextReviewAt.value
          : this.nextReviewAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SrsStateData(')
          ..write('id: $id, ')
          ..write('vocabId: $vocabId, ')
          ..write('box: $box, ')
          ..write('repetitions: $repetitions, ')
          ..write('ease: $ease, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('lastConfidence: $lastConfidence, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('nextReviewAt: $nextReviewAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vocabId,
    box,
    repetitions,
    ease,
    stability,
    difficulty,
    lastConfidence,
    lastReviewedAt,
    nextReviewAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SrsStateData &&
          other.id == this.id &&
          other.vocabId == this.vocabId &&
          other.box == this.box &&
          other.repetitions == this.repetitions &&
          other.ease == this.ease &&
          other.stability == this.stability &&
          other.difficulty == this.difficulty &&
          other.lastConfidence == this.lastConfidence &&
          other.lastReviewedAt == this.lastReviewedAt &&
          other.nextReviewAt == this.nextReviewAt);
}

class SrsStateCompanion extends UpdateCompanion<SrsStateData> {
  final Value<int> id;
  final Value<int> vocabId;
  final Value<int> box;
  final Value<int> repetitions;
  final Value<double> ease;
  final Value<double> stability;
  final Value<double> difficulty;
  final Value<int> lastConfidence;
  final Value<DateTime?> lastReviewedAt;
  final Value<DateTime> nextReviewAt;
  const SrsStateCompanion({
    this.id = const Value.absent(),
    this.vocabId = const Value.absent(),
    this.box = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.ease = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.lastConfidence = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
  });
  SrsStateCompanion.insert({
    this.id = const Value.absent(),
    required int vocabId,
    this.box = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.ease = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.lastConfidence = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    required DateTime nextReviewAt,
  }) : vocabId = Value(vocabId),
       nextReviewAt = Value(nextReviewAt);
  static Insertable<SrsStateData> custom({
    Expression<int>? id,
    Expression<int>? vocabId,
    Expression<int>? box,
    Expression<int>? repetitions,
    Expression<double>? ease,
    Expression<double>? stability,
    Expression<double>? difficulty,
    Expression<int>? lastConfidence,
    Expression<DateTime>? lastReviewedAt,
    Expression<DateTime>? nextReviewAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vocabId != null) 'vocab_id': vocabId,
      if (box != null) 'box': box,
      if (repetitions != null) 'repetitions': repetitions,
      if (ease != null) 'ease': ease,
      if (stability != null) 'stability': stability,
      if (difficulty != null) 'difficulty': difficulty,
      if (lastConfidence != null) 'last_confidence': lastConfidence,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (nextReviewAt != null) 'next_review_at': nextReviewAt,
    });
  }

  SrsStateCompanion copyWith({
    Value<int>? id,
    Value<int>? vocabId,
    Value<int>? box,
    Value<int>? repetitions,
    Value<double>? ease,
    Value<double>? stability,
    Value<double>? difficulty,
    Value<int>? lastConfidence,
    Value<DateTime?>? lastReviewedAt,
    Value<DateTime>? nextReviewAt,
  }) {
    return SrsStateCompanion(
      id: id ?? this.id,
      vocabId: vocabId ?? this.vocabId,
      box: box ?? this.box,
      repetitions: repetitions ?? this.repetitions,
      ease: ease ?? this.ease,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      lastConfidence: lastConfidence ?? this.lastConfidence,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vocabId.present) {
      map['vocab_id'] = Variable<int>(vocabId.value);
    }
    if (box.present) {
      map['box'] = Variable<int>(box.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<int>(repetitions.value);
    }
    if (ease.present) {
      map['ease'] = Variable<double>(ease.value);
    }
    if (stability.present) {
      map['stability'] = Variable<double>(stability.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    if (lastConfidence.present) {
      map['last_confidence'] = Variable<int>(lastConfidence.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
    }
    if (nextReviewAt.present) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SrsStateCompanion(')
          ..write('id: $id, ')
          ..write('vocabId: $vocabId, ')
          ..write('box: $box, ')
          ..write('repetitions: $repetitions, ')
          ..write('ease: $ease, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('lastConfidence: $lastConfidence, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('nextReviewAt: $nextReviewAt')
          ..write(')'))
        .toString();
  }
}

class $KanjiSrsStateTable extends KanjiSrsState
    with TableInfo<$KanjiSrsStateTable, KanjiSrsStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KanjiSrsStateTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _kanjiIdMeta = const VerificationMeta(
    'kanjiId',
  );
  @override
  late final GeneratedColumn<int> kanjiId = GeneratedColumn<int>(
    'kanji_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stabilityMeta = const VerificationMeta(
    'stability',
  );
  @override
  late final GeneratedColumn<double> stability = GeneratedColumn<double>(
    'stability',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(5.0),
  );
  static const VerificationMeta _lastConfidenceMeta = const VerificationMeta(
    'lastConfidence',
  );
  @override
  late final GeneratedColumn<int> lastConfidence = GeneratedColumn<int>(
    'last_confidence',
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
  static const VerificationMeta _nextReviewAtMeta = const VerificationMeta(
    'nextReviewAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextReviewAt = GeneratedColumn<DateTime>(
    'next_review_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kanjiId,
    stability,
    difficulty,
    lastConfidence,
    lastReviewedAt,
    nextReviewAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kanji_srs_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<KanjiSrsStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kanji_id')) {
      context.handle(
        _kanjiIdMeta,
        kanjiId.isAcceptableOrUnknown(data['kanji_id']!, _kanjiIdMeta),
      );
    } else if (isInserting) {
      context.missing(_kanjiIdMeta);
    }
    if (data.containsKey('stability')) {
      context.handle(
        _stabilityMeta,
        stability.isAcceptableOrUnknown(data['stability']!, _stabilityMeta),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('last_confidence')) {
      context.handle(
        _lastConfidenceMeta,
        lastConfidence.isAcceptableOrUnknown(
          data['last_confidence']!,
          _lastConfidenceMeta,
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
    if (data.containsKey('next_review_at')) {
      context.handle(
        _nextReviewAtMeta,
        nextReviewAt.isAcceptableOrUnknown(
          data['next_review_at']!,
          _nextReviewAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextReviewAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {kanjiId},
  ];
  @override
  KanjiSrsStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KanjiSrsStateData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kanjiId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kanji_id'],
      )!,
      stability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stability'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}difficulty'],
      )!,
      lastConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_confidence'],
      )!,
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reviewed_at'],
      ),
      nextReviewAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_review_at'],
      )!,
    );
  }

  @override
  $KanjiSrsStateTable createAlias(String alias) {
    return $KanjiSrsStateTable(attachedDatabase, alias);
  }
}

class KanjiSrsStateData extends DataClass
    implements Insertable<KanjiSrsStateData> {
  final int id;
  final int kanjiId;
  final double stability;
  final double difficulty;
  final int lastConfidence;
  final DateTime? lastReviewedAt;
  final DateTime nextReviewAt;
  const KanjiSrsStateData({
    required this.id,
    required this.kanjiId,
    required this.stability,
    required this.difficulty,
    required this.lastConfidence,
    this.lastReviewedAt,
    required this.nextReviewAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kanji_id'] = Variable<int>(kanjiId);
    map['stability'] = Variable<double>(stability);
    map['difficulty'] = Variable<double>(difficulty);
    map['last_confidence'] = Variable<int>(lastConfidence);
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt);
    }
    map['next_review_at'] = Variable<DateTime>(nextReviewAt);
    return map;
  }

  KanjiSrsStateCompanion toCompanion(bool nullToAbsent) {
    return KanjiSrsStateCompanion(
      id: Value(id),
      kanjiId: Value(kanjiId),
      stability: Value(stability),
      difficulty: Value(difficulty),
      lastConfidence: Value(lastConfidence),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
      nextReviewAt: Value(nextReviewAt),
    );
  }

  factory KanjiSrsStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KanjiSrsStateData(
      id: serializer.fromJson<int>(json['id']),
      kanjiId: serializer.fromJson<int>(json['kanjiId']),
      stability: serializer.fromJson<double>(json['stability']),
      difficulty: serializer.fromJson<double>(json['difficulty']),
      lastConfidence: serializer.fromJson<int>(json['lastConfidence']),
      lastReviewedAt: serializer.fromJson<DateTime?>(json['lastReviewedAt']),
      nextReviewAt: serializer.fromJson<DateTime>(json['nextReviewAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kanjiId': serializer.toJson<int>(kanjiId),
      'stability': serializer.toJson<double>(stability),
      'difficulty': serializer.toJson<double>(difficulty),
      'lastConfidence': serializer.toJson<int>(lastConfidence),
      'lastReviewedAt': serializer.toJson<DateTime?>(lastReviewedAt),
      'nextReviewAt': serializer.toJson<DateTime>(nextReviewAt),
    };
  }

  KanjiSrsStateData copyWith({
    int? id,
    int? kanjiId,
    double? stability,
    double? difficulty,
    int? lastConfidence,
    Value<DateTime?> lastReviewedAt = const Value.absent(),
    DateTime? nextReviewAt,
  }) => KanjiSrsStateData(
    id: id ?? this.id,
    kanjiId: kanjiId ?? this.kanjiId,
    stability: stability ?? this.stability,
    difficulty: difficulty ?? this.difficulty,
    lastConfidence: lastConfidence ?? this.lastConfidence,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
    nextReviewAt: nextReviewAt ?? this.nextReviewAt,
  );
  KanjiSrsStateData copyWithCompanion(KanjiSrsStateCompanion data) {
    return KanjiSrsStateData(
      id: data.id.present ? data.id.value : this.id,
      kanjiId: data.kanjiId.present ? data.kanjiId.value : this.kanjiId,
      stability: data.stability.present ? data.stability.value : this.stability,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      lastConfidence: data.lastConfidence.present
          ? data.lastConfidence.value
          : this.lastConfidence,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
      nextReviewAt: data.nextReviewAt.present
          ? data.nextReviewAt.value
          : this.nextReviewAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KanjiSrsStateData(')
          ..write('id: $id, ')
          ..write('kanjiId: $kanjiId, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('lastConfidence: $lastConfidence, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('nextReviewAt: $nextReviewAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kanjiId,
    stability,
    difficulty,
    lastConfidence,
    lastReviewedAt,
    nextReviewAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KanjiSrsStateData &&
          other.id == this.id &&
          other.kanjiId == this.kanjiId &&
          other.stability == this.stability &&
          other.difficulty == this.difficulty &&
          other.lastConfidence == this.lastConfidence &&
          other.lastReviewedAt == this.lastReviewedAt &&
          other.nextReviewAt == this.nextReviewAt);
}

class KanjiSrsStateCompanion extends UpdateCompanion<KanjiSrsStateData> {
  final Value<int> id;
  final Value<int> kanjiId;
  final Value<double> stability;
  final Value<double> difficulty;
  final Value<int> lastConfidence;
  final Value<DateTime?> lastReviewedAt;
  final Value<DateTime> nextReviewAt;
  const KanjiSrsStateCompanion({
    this.id = const Value.absent(),
    this.kanjiId = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.lastConfidence = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
  });
  KanjiSrsStateCompanion.insert({
    this.id = const Value.absent(),
    required int kanjiId,
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.lastConfidence = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    required DateTime nextReviewAt,
  }) : kanjiId = Value(kanjiId),
       nextReviewAt = Value(nextReviewAt);
  static Insertable<KanjiSrsStateData> custom({
    Expression<int>? id,
    Expression<int>? kanjiId,
    Expression<double>? stability,
    Expression<double>? difficulty,
    Expression<int>? lastConfidence,
    Expression<DateTime>? lastReviewedAt,
    Expression<DateTime>? nextReviewAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kanjiId != null) 'kanji_id': kanjiId,
      if (stability != null) 'stability': stability,
      if (difficulty != null) 'difficulty': difficulty,
      if (lastConfidence != null) 'last_confidence': lastConfidence,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (nextReviewAt != null) 'next_review_at': nextReviewAt,
    });
  }

  KanjiSrsStateCompanion copyWith({
    Value<int>? id,
    Value<int>? kanjiId,
    Value<double>? stability,
    Value<double>? difficulty,
    Value<int>? lastConfidence,
    Value<DateTime?>? lastReviewedAt,
    Value<DateTime>? nextReviewAt,
  }) {
    return KanjiSrsStateCompanion(
      id: id ?? this.id,
      kanjiId: kanjiId ?? this.kanjiId,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      lastConfidence: lastConfidence ?? this.lastConfidence,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kanjiId.present) {
      map['kanji_id'] = Variable<int>(kanjiId.value);
    }
    if (stability.present) {
      map['stability'] = Variable<double>(stability.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    if (lastConfidence.present) {
      map['last_confidence'] = Variable<int>(lastConfidence.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
    }
    if (nextReviewAt.present) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KanjiSrsStateCompanion(')
          ..write('id: $id, ')
          ..write('kanjiId: $kanjiId, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('lastConfidence: $lastConfidence, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('nextReviewAt: $nextReviewAt')
          ..write(')'))
        .toString();
  }
}

class $KanaSrsStateTable extends KanaSrsState
    with TableInfo<$KanaSrsStateTable, KanaSrsStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KanaSrsStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _kanaMeta = const VerificationMeta('kana');
  @override
  late final GeneratedColumn<String> kana = GeneratedColumn<String>(
    'kana',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scriptMeta = const VerificationMeta('script');
  @override
  late final GeneratedColumn<String> script = GeneratedColumn<String>(
    'script',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lapsesMeta = const VerificationMeta('lapses');
  @override
  late final GeneratedColumn<int> lapses = GeneratedColumn<int>(
    'lapses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stabilityMeta = const VerificationMeta(
    'stability',
  );
  @override
  late final GeneratedColumn<double> stability = GeneratedColumn<double>(
    'stability',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
    kana,
    script,
    reps,
    lapses,
    stability,
    difficulty,
    dueAt,
    lastReviewedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kana_srs_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<KanaSrsStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('kana')) {
      context.handle(
        _kanaMeta,
        kana.isAcceptableOrUnknown(data['kana']!, _kanaMeta),
      );
    } else if (isInserting) {
      context.missing(_kanaMeta);
    }
    if (data.containsKey('script')) {
      context.handle(
        _scriptMeta,
        script.isAcceptableOrUnknown(data['script']!, _scriptMeta),
      );
    } else if (isInserting) {
      context.missing(_scriptMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    }
    if (data.containsKey('lapses')) {
      context.handle(
        _lapsesMeta,
        lapses.isAcceptableOrUnknown(data['lapses']!, _lapsesMeta),
      );
    }
    if (data.containsKey('stability')) {
      context.handle(
        _stabilityMeta,
        stability.isAcceptableOrUnknown(data['stability']!, _stabilityMeta),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
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
  Set<GeneratedColumn> get $primaryKey => {kana};
  @override
  KanaSrsStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KanaSrsStateData(
      kana: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kana'],
      )!,
      script: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}script'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      lapses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lapses'],
      )!,
      stability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stability'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}difficulty'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      ),
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reviewed_at'],
      ),
    );
  }

  @override
  $KanaSrsStateTable createAlias(String alias) {
    return $KanaSrsStateTable(attachedDatabase, alias);
  }
}

class KanaSrsStateData extends DataClass
    implements Insertable<KanaSrsStateData> {
  final String kana;
  final String script;
  final int reps;
  final int lapses;
  final double stability;
  final double difficulty;
  final DateTime? dueAt;
  final DateTime? lastReviewedAt;
  const KanaSrsStateData({
    required this.kana,
    required this.script,
    required this.reps,
    required this.lapses,
    required this.stability,
    required this.difficulty,
    this.dueAt,
    this.lastReviewedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['kana'] = Variable<String>(kana);
    map['script'] = Variable<String>(script);
    map['reps'] = Variable<int>(reps);
    map['lapses'] = Variable<int>(lapses);
    map['stability'] = Variable<double>(stability);
    map['difficulty'] = Variable<double>(difficulty);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<DateTime>(dueAt);
    }
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt);
    }
    return map;
  }

  KanaSrsStateCompanion toCompanion(bool nullToAbsent) {
    return KanaSrsStateCompanion(
      kana: Value(kana),
      script: Value(script),
      reps: Value(reps),
      lapses: Value(lapses),
      stability: Value(stability),
      difficulty: Value(difficulty),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
    );
  }

  factory KanaSrsStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KanaSrsStateData(
      kana: serializer.fromJson<String>(json['kana']),
      script: serializer.fromJson<String>(json['script']),
      reps: serializer.fromJson<int>(json['reps']),
      lapses: serializer.fromJson<int>(json['lapses']),
      stability: serializer.fromJson<double>(json['stability']),
      difficulty: serializer.fromJson<double>(json['difficulty']),
      dueAt: serializer.fromJson<DateTime?>(json['dueAt']),
      lastReviewedAt: serializer.fromJson<DateTime?>(json['lastReviewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'kana': serializer.toJson<String>(kana),
      'script': serializer.toJson<String>(script),
      'reps': serializer.toJson<int>(reps),
      'lapses': serializer.toJson<int>(lapses),
      'stability': serializer.toJson<double>(stability),
      'difficulty': serializer.toJson<double>(difficulty),
      'dueAt': serializer.toJson<DateTime?>(dueAt),
      'lastReviewedAt': serializer.toJson<DateTime?>(lastReviewedAt),
    };
  }

  KanaSrsStateData copyWith({
    String? kana,
    String? script,
    int? reps,
    int? lapses,
    double? stability,
    double? difficulty,
    Value<DateTime?> dueAt = const Value.absent(),
    Value<DateTime?> lastReviewedAt = const Value.absent(),
  }) => KanaSrsStateData(
    kana: kana ?? this.kana,
    script: script ?? this.script,
    reps: reps ?? this.reps,
    lapses: lapses ?? this.lapses,
    stability: stability ?? this.stability,
    difficulty: difficulty ?? this.difficulty,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
  );
  KanaSrsStateData copyWithCompanion(KanaSrsStateCompanion data) {
    return KanaSrsStateData(
      kana: data.kana.present ? data.kana.value : this.kana,
      script: data.script.present ? data.script.value : this.script,
      reps: data.reps.present ? data.reps.value : this.reps,
      lapses: data.lapses.present ? data.lapses.value : this.lapses,
      stability: data.stability.present ? data.stability.value : this.stability,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KanaSrsStateData(')
          ..write('kana: $kana, ')
          ..write('script: $script, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('dueAt: $dueAt, ')
          ..write('lastReviewedAt: $lastReviewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    kana,
    script,
    reps,
    lapses,
    stability,
    difficulty,
    dueAt,
    lastReviewedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KanaSrsStateData &&
          other.kana == this.kana &&
          other.script == this.script &&
          other.reps == this.reps &&
          other.lapses == this.lapses &&
          other.stability == this.stability &&
          other.difficulty == this.difficulty &&
          other.dueAt == this.dueAt &&
          other.lastReviewedAt == this.lastReviewedAt);
}

class KanaSrsStateCompanion extends UpdateCompanion<KanaSrsStateData> {
  final Value<String> kana;
  final Value<String> script;
  final Value<int> reps;
  final Value<int> lapses;
  final Value<double> stability;
  final Value<double> difficulty;
  final Value<DateTime?> dueAt;
  final Value<DateTime?> lastReviewedAt;
  final Value<int> rowid;
  const KanaSrsStateCompanion({
    this.kana = const Value.absent(),
    this.script = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KanaSrsStateCompanion.insert({
    required String kana,
    required String script,
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : kana = Value(kana),
       script = Value(script);
  static Insertable<KanaSrsStateData> custom({
    Expression<String>? kana,
    Expression<String>? script,
    Expression<int>? reps,
    Expression<int>? lapses,
    Expression<double>? stability,
    Expression<double>? difficulty,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? lastReviewedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (kana != null) 'kana': kana,
      if (script != null) 'script': script,
      if (reps != null) 'reps': reps,
      if (lapses != null) 'lapses': lapses,
      if (stability != null) 'stability': stability,
      if (difficulty != null) 'difficulty': difficulty,
      if (dueAt != null) 'due_at': dueAt,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KanaSrsStateCompanion copyWith({
    Value<String>? kana,
    Value<String>? script,
    Value<int>? reps,
    Value<int>? lapses,
    Value<double>? stability,
    Value<double>? difficulty,
    Value<DateTime?>? dueAt,
    Value<DateTime?>? lastReviewedAt,
    Value<int>? rowid,
  }) {
    return KanaSrsStateCompanion(
      kana: kana ?? this.kana,
      script: script ?? this.script,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      dueAt: dueAt ?? this.dueAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (kana.present) {
      map['kana'] = Variable<String>(kana.value);
    }
    if (script.present) {
      map['script'] = Variable<String>(script.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (lapses.present) {
      map['lapses'] = Variable<int>(lapses.value);
    }
    if (stability.present) {
      map['stability'] = Variable<double>(stability.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KanaSrsStateCompanion(')
          ..write('kana: $kana, ')
          ..write('script: $script, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('dueAt: $dueAt, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('rowid: $rowid')
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
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<DateTime> day = GeneratedColumn<DateTime>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _xpMeta = const VerificationMeta('xp');
  @override
  late final GeneratedColumn<int> xp = GeneratedColumn<int>(
    'xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _streakMeta = const VerificationMeta('streak');
  @override
  late final GeneratedColumn<int> streak = GeneratedColumn<int>(
    'streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reviewedCountMeta = const VerificationMeta(
    'reviewedCount',
  );
  @override
  late final GeneratedColumn<int> reviewedCount = GeneratedColumn<int>(
    'reviewed_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reviewAgainCountMeta = const VerificationMeta(
    'reviewAgainCount',
  );
  @override
  late final GeneratedColumn<int> reviewAgainCount = GeneratedColumn<int>(
    'review_again_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reviewHardCountMeta = const VerificationMeta(
    'reviewHardCount',
  );
  @override
  late final GeneratedColumn<int> reviewHardCount = GeneratedColumn<int>(
    'review_hard_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reviewGoodCountMeta = const VerificationMeta(
    'reviewGoodCount',
  );
  @override
  late final GeneratedColumn<int> reviewGoodCount = GeneratedColumn<int>(
    'review_good_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reviewEasyCountMeta = const VerificationMeta(
    'reviewEasyCount',
  );
  @override
  late final GeneratedColumn<int> reviewEasyCount = GeneratedColumn<int>(
    'review_easy_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    day,
    xp,
    streak,
    reviewedCount,
    reviewAgainCount,
    reviewHardCount,
    reviewGoodCount,
    reviewEasyCount,
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
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('xp')) {
      context.handle(_xpMeta, xp.isAcceptableOrUnknown(data['xp']!, _xpMeta));
    }
    if (data.containsKey('streak')) {
      context.handle(
        _streakMeta,
        streak.isAcceptableOrUnknown(data['streak']!, _streakMeta),
      );
    }
    if (data.containsKey('reviewed_count')) {
      context.handle(
        _reviewedCountMeta,
        reviewedCount.isAcceptableOrUnknown(
          data['reviewed_count']!,
          _reviewedCountMeta,
        ),
      );
    }
    if (data.containsKey('review_again_count')) {
      context.handle(
        _reviewAgainCountMeta,
        reviewAgainCount.isAcceptableOrUnknown(
          data['review_again_count']!,
          _reviewAgainCountMeta,
        ),
      );
    }
    if (data.containsKey('review_hard_count')) {
      context.handle(
        _reviewHardCountMeta,
        reviewHardCount.isAcceptableOrUnknown(
          data['review_hard_count']!,
          _reviewHardCountMeta,
        ),
      );
    }
    if (data.containsKey('review_good_count')) {
      context.handle(
        _reviewGoodCountMeta,
        reviewGoodCount.isAcceptableOrUnknown(
          data['review_good_count']!,
          _reviewGoodCountMeta,
        ),
      );
    }
    if (data.containsKey('review_easy_count')) {
      context.handle(
        _reviewEasyCountMeta,
        reviewEasyCount.isAcceptableOrUnknown(
          data['review_easy_count']!,
          _reviewEasyCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProgressData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}day'],
      )!,
      xp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp'],
      )!,
      streak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak'],
      )!,
      reviewedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reviewed_count'],
      )!,
      reviewAgainCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}review_again_count'],
      )!,
      reviewHardCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}review_hard_count'],
      )!,
      reviewGoodCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}review_good_count'],
      )!,
      reviewEasyCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}review_easy_count'],
      )!,
    );
  }

  @override
  $UserProgressTable createAlias(String alias) {
    return $UserProgressTable(attachedDatabase, alias);
  }
}

class UserProgressData extends DataClass
    implements Insertable<UserProgressData> {
  final int id;
  final DateTime day;
  final int xp;
  final int streak;
  final int reviewedCount;
  final int reviewAgainCount;
  final int reviewHardCount;
  final int reviewGoodCount;
  final int reviewEasyCount;
  const UserProgressData({
    required this.id,
    required this.day,
    required this.xp,
    required this.streak,
    required this.reviewedCount,
    required this.reviewAgainCount,
    required this.reviewHardCount,
    required this.reviewGoodCount,
    required this.reviewEasyCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day'] = Variable<DateTime>(day);
    map['xp'] = Variable<int>(xp);
    map['streak'] = Variable<int>(streak);
    map['reviewed_count'] = Variable<int>(reviewedCount);
    map['review_again_count'] = Variable<int>(reviewAgainCount);
    map['review_hard_count'] = Variable<int>(reviewHardCount);
    map['review_good_count'] = Variable<int>(reviewGoodCount);
    map['review_easy_count'] = Variable<int>(reviewEasyCount);
    return map;
  }

  UserProgressCompanion toCompanion(bool nullToAbsent) {
    return UserProgressCompanion(
      id: Value(id),
      day: Value(day),
      xp: Value(xp),
      streak: Value(streak),
      reviewedCount: Value(reviewedCount),
      reviewAgainCount: Value(reviewAgainCount),
      reviewHardCount: Value(reviewHardCount),
      reviewGoodCount: Value(reviewGoodCount),
      reviewEasyCount: Value(reviewEasyCount),
    );
  }

  factory UserProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProgressData(
      id: serializer.fromJson<int>(json['id']),
      day: serializer.fromJson<DateTime>(json['day']),
      xp: serializer.fromJson<int>(json['xp']),
      streak: serializer.fromJson<int>(json['streak']),
      reviewedCount: serializer.fromJson<int>(json['reviewedCount']),
      reviewAgainCount: serializer.fromJson<int>(json['reviewAgainCount']),
      reviewHardCount: serializer.fromJson<int>(json['reviewHardCount']),
      reviewGoodCount: serializer.fromJson<int>(json['reviewGoodCount']),
      reviewEasyCount: serializer.fromJson<int>(json['reviewEasyCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'day': serializer.toJson<DateTime>(day),
      'xp': serializer.toJson<int>(xp),
      'streak': serializer.toJson<int>(streak),
      'reviewedCount': serializer.toJson<int>(reviewedCount),
      'reviewAgainCount': serializer.toJson<int>(reviewAgainCount),
      'reviewHardCount': serializer.toJson<int>(reviewHardCount),
      'reviewGoodCount': serializer.toJson<int>(reviewGoodCount),
      'reviewEasyCount': serializer.toJson<int>(reviewEasyCount),
    };
  }

  UserProgressData copyWith({
    int? id,
    DateTime? day,
    int? xp,
    int? streak,
    int? reviewedCount,
    int? reviewAgainCount,
    int? reviewHardCount,
    int? reviewGoodCount,
    int? reviewEasyCount,
  }) => UserProgressData(
    id: id ?? this.id,
    day: day ?? this.day,
    xp: xp ?? this.xp,
    streak: streak ?? this.streak,
    reviewedCount: reviewedCount ?? this.reviewedCount,
    reviewAgainCount: reviewAgainCount ?? this.reviewAgainCount,
    reviewHardCount: reviewHardCount ?? this.reviewHardCount,
    reviewGoodCount: reviewGoodCount ?? this.reviewGoodCount,
    reviewEasyCount: reviewEasyCount ?? this.reviewEasyCount,
  );
  UserProgressData copyWithCompanion(UserProgressCompanion data) {
    return UserProgressData(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      xp: data.xp.present ? data.xp.value : this.xp,
      streak: data.streak.present ? data.streak.value : this.streak,
      reviewedCount: data.reviewedCount.present
          ? data.reviewedCount.value
          : this.reviewedCount,
      reviewAgainCount: data.reviewAgainCount.present
          ? data.reviewAgainCount.value
          : this.reviewAgainCount,
      reviewHardCount: data.reviewHardCount.present
          ? data.reviewHardCount.value
          : this.reviewHardCount,
      reviewGoodCount: data.reviewGoodCount.present
          ? data.reviewGoodCount.value
          : this.reviewGoodCount,
      reviewEasyCount: data.reviewEasyCount.present
          ? data.reviewEasyCount.value
          : this.reviewEasyCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProgressData(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('xp: $xp, ')
          ..write('streak: $streak, ')
          ..write('reviewedCount: $reviewedCount, ')
          ..write('reviewAgainCount: $reviewAgainCount, ')
          ..write('reviewHardCount: $reviewHardCount, ')
          ..write('reviewGoodCount: $reviewGoodCount, ')
          ..write('reviewEasyCount: $reviewEasyCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    day,
    xp,
    streak,
    reviewedCount,
    reviewAgainCount,
    reviewHardCount,
    reviewGoodCount,
    reviewEasyCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProgressData &&
          other.id == this.id &&
          other.day == this.day &&
          other.xp == this.xp &&
          other.streak == this.streak &&
          other.reviewedCount == this.reviewedCount &&
          other.reviewAgainCount == this.reviewAgainCount &&
          other.reviewHardCount == this.reviewHardCount &&
          other.reviewGoodCount == this.reviewGoodCount &&
          other.reviewEasyCount == this.reviewEasyCount);
}

class UserProgressCompanion extends UpdateCompanion<UserProgressData> {
  final Value<int> id;
  final Value<DateTime> day;
  final Value<int> xp;
  final Value<int> streak;
  final Value<int> reviewedCount;
  final Value<int> reviewAgainCount;
  final Value<int> reviewHardCount;
  final Value<int> reviewGoodCount;
  final Value<int> reviewEasyCount;
  const UserProgressCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.xp = const Value.absent(),
    this.streak = const Value.absent(),
    this.reviewedCount = const Value.absent(),
    this.reviewAgainCount = const Value.absent(),
    this.reviewHardCount = const Value.absent(),
    this.reviewGoodCount = const Value.absent(),
    this.reviewEasyCount = const Value.absent(),
  });
  UserProgressCompanion.insert({
    this.id = const Value.absent(),
    required DateTime day,
    this.xp = const Value.absent(),
    this.streak = const Value.absent(),
    this.reviewedCount = const Value.absent(),
    this.reviewAgainCount = const Value.absent(),
    this.reviewHardCount = const Value.absent(),
    this.reviewGoodCount = const Value.absent(),
    this.reviewEasyCount = const Value.absent(),
  }) : day = Value(day);
  static Insertable<UserProgressData> custom({
    Expression<int>? id,
    Expression<DateTime>? day,
    Expression<int>? xp,
    Expression<int>? streak,
    Expression<int>? reviewedCount,
    Expression<int>? reviewAgainCount,
    Expression<int>? reviewHardCount,
    Expression<int>? reviewGoodCount,
    Expression<int>? reviewEasyCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (xp != null) 'xp': xp,
      if (streak != null) 'streak': streak,
      if (reviewedCount != null) 'reviewed_count': reviewedCount,
      if (reviewAgainCount != null) 'review_again_count': reviewAgainCount,
      if (reviewHardCount != null) 'review_hard_count': reviewHardCount,
      if (reviewGoodCount != null) 'review_good_count': reviewGoodCount,
      if (reviewEasyCount != null) 'review_easy_count': reviewEasyCount,
    });
  }

  UserProgressCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? day,
    Value<int>? xp,
    Value<int>? streak,
    Value<int>? reviewedCount,
    Value<int>? reviewAgainCount,
    Value<int>? reviewHardCount,
    Value<int>? reviewGoodCount,
    Value<int>? reviewEasyCount,
  }) {
    return UserProgressCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      reviewedCount: reviewedCount ?? this.reviewedCount,
      reviewAgainCount: reviewAgainCount ?? this.reviewAgainCount,
      reviewHardCount: reviewHardCount ?? this.reviewHardCount,
      reviewGoodCount: reviewGoodCount ?? this.reviewGoodCount,
      reviewEasyCount: reviewEasyCount ?? this.reviewEasyCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<DateTime>(day.value);
    }
    if (xp.present) {
      map['xp'] = Variable<int>(xp.value);
    }
    if (streak.present) {
      map['streak'] = Variable<int>(streak.value);
    }
    if (reviewedCount.present) {
      map['reviewed_count'] = Variable<int>(reviewedCount.value);
    }
    if (reviewAgainCount.present) {
      map['review_again_count'] = Variable<int>(reviewAgainCount.value);
    }
    if (reviewHardCount.present) {
      map['review_hard_count'] = Variable<int>(reviewHardCount.value);
    }
    if (reviewGoodCount.present) {
      map['review_good_count'] = Variable<int>(reviewGoodCount.value);
    }
    if (reviewEasyCount.present) {
      map['review_easy_count'] = Variable<int>(reviewEasyCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProgressCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('xp: $xp, ')
          ..write('streak: $streak, ')
          ..write('reviewedCount: $reviewedCount, ')
          ..write('reviewAgainCount: $reviewAgainCount, ')
          ..write('reviewHardCount: $reviewHardCount, ')
          ..write('reviewGoodCount: $reviewGoodCount, ')
          ..write('reviewEasyCount: $reviewEasyCount')
          ..write(')'))
        .toString();
  }
}

class $AttemptTable extends Attempt with TableInfo<$AttemptTable, AttemptData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttemptTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
    'total',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mode,
    level,
    startedAt,
    finishedAt,
    score,
    total,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attempt';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttemptData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttemptData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttemptData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      ),
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total'],
      ),
    );
  }

  @override
  $AttemptTable createAlias(String alias) {
    return $AttemptTable(attachedDatabase, alias);
  }
}

class AttemptData extends DataClass implements Insertable<AttemptData> {
  final int id;
  final String mode;
  final String level;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int? score;
  final int? total;
  const AttemptData({
    required this.id,
    required this.mode,
    required this.level,
    required this.startedAt,
    this.finishedAt,
    this.score,
    this.total,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['mode'] = Variable<String>(mode);
    map['level'] = Variable<String>(level);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    if (!nullToAbsent || score != null) {
      map['score'] = Variable<int>(score);
    }
    if (!nullToAbsent || total != null) {
      map['total'] = Variable<int>(total);
    }
    return map;
  }

  AttemptCompanion toCompanion(bool nullToAbsent) {
    return AttemptCompanion(
      id: Value(id),
      mode: Value(mode),
      level: Value(level),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      score: score == null && nullToAbsent
          ? const Value.absent()
          : Value(score),
      total: total == null && nullToAbsent
          ? const Value.absent()
          : Value(total),
    );
  }

  factory AttemptData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttemptData(
      id: serializer.fromJson<int>(json['id']),
      mode: serializer.fromJson<String>(json['mode']),
      level: serializer.fromJson<String>(json['level']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      score: serializer.fromJson<int?>(json['score']),
      total: serializer.fromJson<int?>(json['total']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mode': serializer.toJson<String>(mode),
      'level': serializer.toJson<String>(level),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'score': serializer.toJson<int?>(score),
      'total': serializer.toJson<int?>(total),
    };
  }

  AttemptData copyWith({
    int? id,
    String? mode,
    String? level,
    DateTime? startedAt,
    Value<DateTime?> finishedAt = const Value.absent(),
    Value<int?> score = const Value.absent(),
    Value<int?> total = const Value.absent(),
  }) => AttemptData(
    id: id ?? this.id,
    mode: mode ?? this.mode,
    level: level ?? this.level,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    score: score.present ? score.value : this.score,
    total: total.present ? total.value : this.total,
  );
  AttemptData copyWithCompanion(AttemptCompanion data) {
    return AttemptData(
      id: data.id.present ? data.id.value : this.id,
      mode: data.mode.present ? data.mode.value : this.mode,
      level: data.level.present ? data.level.value : this.level,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      score: data.score.present ? data.score.value : this.score,
      total: data.total.present ? data.total.value : this.total,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttemptData(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('level: $level, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('score: $score, ')
          ..write('total: $total')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, mode, level, startedAt, finishedAt, score, total);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttemptData &&
          other.id == this.id &&
          other.mode == this.mode &&
          other.level == this.level &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.score == this.score &&
          other.total == this.total);
}

class AttemptCompanion extends UpdateCompanion<AttemptData> {
  final Value<int> id;
  final Value<String> mode;
  final Value<String> level;
  final Value<DateTime> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<int?> score;
  final Value<int?> total;
  const AttemptCompanion({
    this.id = const Value.absent(),
    this.mode = const Value.absent(),
    this.level = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.score = const Value.absent(),
    this.total = const Value.absent(),
  });
  AttemptCompanion.insert({
    this.id = const Value.absent(),
    required String mode,
    required String level,
    required DateTime startedAt,
    this.finishedAt = const Value.absent(),
    this.score = const Value.absent(),
    this.total = const Value.absent(),
  }) : mode = Value(mode),
       level = Value(level),
       startedAt = Value(startedAt);
  static Insertable<AttemptData> custom({
    Expression<int>? id,
    Expression<String>? mode,
    Expression<String>? level,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<int>? score,
    Expression<int>? total,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mode != null) 'mode': mode,
      if (level != null) 'level': level,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (score != null) 'score': score,
      if (total != null) 'total': total,
    });
  }

  AttemptCompanion copyWith({
    Value<int>? id,
    Value<String>? mode,
    Value<String>? level,
    Value<DateTime>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<int?>? score,
    Value<int?>? total,
  }) {
    return AttemptCompanion(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      level: level ?? this.level,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      score: score ?? this.score,
      total: total ?? this.total,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (total.present) {
      map['total'] = Variable<int>(total.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttemptCompanion(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('level: $level, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('score: $score, ')
          ..write('total: $total')
          ..write(')'))
        .toString();
  }
}

class $AttemptAnswerTable extends AttemptAnswer
    with TableInfo<$AttemptAnswerTable, AttemptAnswerData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttemptAnswerTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _attemptIdMeta = const VerificationMeta(
    'attemptId',
  );
  @override
  late final GeneratedColumn<int> attemptId = GeneratedColumn<int>(
    'attempt_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES attempt (id)',
    ),
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
  static const VerificationMeta _selectedIndexMeta = const VerificationMeta(
    'selectedIndex',
  );
  @override
  late final GeneratedColumn<int> selectedIndex = GeneratedColumn<int>(
    'selected_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCorrectMeta = const VerificationMeta(
    'isCorrect',
  );
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
    'is_correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_correct" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    attemptId,
    questionId,
    selectedIndex,
    isCorrect,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attempt_answer';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttemptAnswerData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('attempt_id')) {
      context.handle(
        _attemptIdMeta,
        attemptId.isAcceptableOrUnknown(data['attempt_id']!, _attemptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_attemptIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('selected_index')) {
      context.handle(
        _selectedIndexMeta,
        selectedIndex.isAcceptableOrUnknown(
          data['selected_index']!,
          _selectedIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_selectedIndexMeta);
    }
    if (data.containsKey('is_correct')) {
      context.handle(
        _isCorrectMeta,
        isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta),
      );
    } else if (isInserting) {
      context.missing(_isCorrectMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttemptAnswerData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttemptAnswerData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      attemptId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_id'],
      )!,
      selectedIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selected_index'],
      )!,
      isCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_correct'],
      )!,
    );
  }

  @override
  $AttemptAnswerTable createAlias(String alias) {
    return $AttemptAnswerTable(attachedDatabase, alias);
  }
}

class AttemptAnswerData extends DataClass
    implements Insertable<AttemptAnswerData> {
  final int id;
  final int attemptId;
  final int questionId;
  final int selectedIndex;
  final bool isCorrect;
  const AttemptAnswerData({
    required this.id,
    required this.attemptId,
    required this.questionId,
    required this.selectedIndex,
    required this.isCorrect,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['attempt_id'] = Variable<int>(attemptId);
    map['question_id'] = Variable<int>(questionId);
    map['selected_index'] = Variable<int>(selectedIndex);
    map['is_correct'] = Variable<bool>(isCorrect);
    return map;
  }

  AttemptAnswerCompanion toCompanion(bool nullToAbsent) {
    return AttemptAnswerCompanion(
      id: Value(id),
      attemptId: Value(attemptId),
      questionId: Value(questionId),
      selectedIndex: Value(selectedIndex),
      isCorrect: Value(isCorrect),
    );
  }

  factory AttemptAnswerData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttemptAnswerData(
      id: serializer.fromJson<int>(json['id']),
      attemptId: serializer.fromJson<int>(json['attemptId']),
      questionId: serializer.fromJson<int>(json['questionId']),
      selectedIndex: serializer.fromJson<int>(json['selectedIndex']),
      isCorrect: serializer.fromJson<bool>(json['isCorrect']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'attemptId': serializer.toJson<int>(attemptId),
      'questionId': serializer.toJson<int>(questionId),
      'selectedIndex': serializer.toJson<int>(selectedIndex),
      'isCorrect': serializer.toJson<bool>(isCorrect),
    };
  }

  AttemptAnswerData copyWith({
    int? id,
    int? attemptId,
    int? questionId,
    int? selectedIndex,
    bool? isCorrect,
  }) => AttemptAnswerData(
    id: id ?? this.id,
    attemptId: attemptId ?? this.attemptId,
    questionId: questionId ?? this.questionId,
    selectedIndex: selectedIndex ?? this.selectedIndex,
    isCorrect: isCorrect ?? this.isCorrect,
  );
  AttemptAnswerData copyWithCompanion(AttemptAnswerCompanion data) {
    return AttemptAnswerData(
      id: data.id.present ? data.id.value : this.id,
      attemptId: data.attemptId.present ? data.attemptId.value : this.attemptId,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      selectedIndex: data.selectedIndex.present
          ? data.selectedIndex.value
          : this.selectedIndex,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttemptAnswerData(')
          ..write('id: $id, ')
          ..write('attemptId: $attemptId, ')
          ..write('questionId: $questionId, ')
          ..write('selectedIndex: $selectedIndex, ')
          ..write('isCorrect: $isCorrect')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, attemptId, questionId, selectedIndex, isCorrect);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttemptAnswerData &&
          other.id == this.id &&
          other.attemptId == this.attemptId &&
          other.questionId == this.questionId &&
          other.selectedIndex == this.selectedIndex &&
          other.isCorrect == this.isCorrect);
}

class AttemptAnswerCompanion extends UpdateCompanion<AttemptAnswerData> {
  final Value<int> id;
  final Value<int> attemptId;
  final Value<int> questionId;
  final Value<int> selectedIndex;
  final Value<bool> isCorrect;
  const AttemptAnswerCompanion({
    this.id = const Value.absent(),
    this.attemptId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.selectedIndex = const Value.absent(),
    this.isCorrect = const Value.absent(),
  });
  AttemptAnswerCompanion.insert({
    this.id = const Value.absent(),
    required int attemptId,
    required int questionId,
    required int selectedIndex,
    required bool isCorrect,
  }) : attemptId = Value(attemptId),
       questionId = Value(questionId),
       selectedIndex = Value(selectedIndex),
       isCorrect = Value(isCorrect);
  static Insertable<AttemptAnswerData> custom({
    Expression<int>? id,
    Expression<int>? attemptId,
    Expression<int>? questionId,
    Expression<int>? selectedIndex,
    Expression<bool>? isCorrect,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (attemptId != null) 'attempt_id': attemptId,
      if (questionId != null) 'question_id': questionId,
      if (selectedIndex != null) 'selected_index': selectedIndex,
      if (isCorrect != null) 'is_correct': isCorrect,
    });
  }

  AttemptAnswerCompanion copyWith({
    Value<int>? id,
    Value<int>? attemptId,
    Value<int>? questionId,
    Value<int>? selectedIndex,
    Value<bool>? isCorrect,
  }) {
    return AttemptAnswerCompanion(
      id: id ?? this.id,
      attemptId: attemptId ?? this.attemptId,
      questionId: questionId ?? this.questionId,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (attemptId.present) {
      map['attempt_id'] = Variable<int>(attemptId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<int>(questionId.value);
    }
    if (selectedIndex.present) {
      map['selected_index'] = Variable<int>(selectedIndex.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttemptAnswerCompanion(')
          ..write('id: $id, ')
          ..write('attemptId: $attemptId, ')
          ..write('questionId: $questionId, ')
          ..write('selectedIndex: $selectedIndex, ')
          ..write('isCorrect: $isCorrect')
          ..write(')'))
        .toString();
  }
}

class $GrammarPointsTable extends GrammarPoints
    with TableInfo<$GrammarPointsTable, GrammarPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GrammarPointsTable(this.attachedDatabase, [this._alias]);
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
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _grammarPointMeta = const VerificationMeta(
    'grammarPoint',
  );
  @override
  late final GeneratedColumn<String> grammarPoint = GeneratedColumn<String>(
    'grammar_point',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
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
  static const VerificationMeta _meaningViMeta = const VerificationMeta(
    'meaningVi',
  );
  @override
  late final GeneratedColumn<String> meaningVi = GeneratedColumn<String>(
    'meaning_vi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _connectionMeta = const VerificationMeta(
    'connection',
  );
  @override
  late final GeneratedColumn<String> connection = GeneratedColumn<String>(
    'connection',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _connectionEnMeta = const VerificationMeta(
    'connectionEn',
  );
  @override
  late final GeneratedColumn<String> connectionEn = GeneratedColumn<String>(
    'connection_en',
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
  static const VerificationMeta _explanationViMeta = const VerificationMeta(
    'explanationVi',
  );
  @override
  late final GeneratedColumn<String> explanationVi = GeneratedColumn<String>(
    'explanation_vi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _jlptLevelMeta = const VerificationMeta(
    'jlptLevel',
  );
  @override
  late final GeneratedColumn<String> jlptLevel = GeneratedColumn<String>(
    'jlpt_level',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 2,
      maxTextLength: 2,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isLearnedMeta = const VerificationMeta(
    'isLearned',
  );
  @override
  late final GeneratedColumn<bool> isLearned = GeneratedColumn<bool>(
    'is_learned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_learned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lessonId,
    grammarPoint,
    titleEn,
    meaning,
    meaningVi,
    meaningEn,
    connection,
    connectionEn,
    explanation,
    explanationVi,
    explanationEn,
    jlptLevel,
    isLearned,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grammar_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<GrammarPoint> instance, {
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
    }
    if (data.containsKey('grammar_point')) {
      context.handle(
        _grammarPointMeta,
        grammarPoint.isAcceptableOrUnknown(
          data['grammar_point']!,
          _grammarPointMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_grammarPointMeta);
    }
    if (data.containsKey('title_en')) {
      context.handle(
        _titleEnMeta,
        titleEn.isAcceptableOrUnknown(data['title_en']!, _titleEnMeta),
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
    if (data.containsKey('meaning_vi')) {
      context.handle(
        _meaningViMeta,
        meaningVi.isAcceptableOrUnknown(data['meaning_vi']!, _meaningViMeta),
      );
    }
    if (data.containsKey('meaning_en')) {
      context.handle(
        _meaningEnMeta,
        meaningEn.isAcceptableOrUnknown(data['meaning_en']!, _meaningEnMeta),
      );
    }
    if (data.containsKey('connection')) {
      context.handle(
        _connectionMeta,
        connection.isAcceptableOrUnknown(data['connection']!, _connectionMeta),
      );
    } else if (isInserting) {
      context.missing(_connectionMeta);
    }
    if (data.containsKey('connection_en')) {
      context.handle(
        _connectionEnMeta,
        connectionEn.isAcceptableOrUnknown(
          data['connection_en']!,
          _connectionEnMeta,
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
    if (data.containsKey('explanation_vi')) {
      context.handle(
        _explanationViMeta,
        explanationVi.isAcceptableOrUnknown(
          data['explanation_vi']!,
          _explanationViMeta,
        ),
      );
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
    if (data.containsKey('jlpt_level')) {
      context.handle(
        _jlptLevelMeta,
        jlptLevel.isAcceptableOrUnknown(data['jlpt_level']!, _jlptLevelMeta),
      );
    } else if (isInserting) {
      context.missing(_jlptLevelMeta);
    }
    if (data.containsKey('is_learned')) {
      context.handle(
        _isLearnedMeta,
        isLearned.isAcceptableOrUnknown(data['is_learned']!, _isLearnedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GrammarPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GrammarPoint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lesson_id'],
      ),
      grammarPoint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grammar_point'],
      )!,
      titleEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_en'],
      ),
      meaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning'],
      )!,
      meaningVi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning_vi'],
      ),
      meaningEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning_en'],
      ),
      connection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}connection'],
      )!,
      connectionEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}connection_en'],
      ),
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      )!,
      explanationVi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation_vi'],
      ),
      explanationEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation_en'],
      ),
      jlptLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jlpt_level'],
      )!,
      isLearned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_learned'],
      )!,
    );
  }

  @override
  $GrammarPointsTable createAlias(String alias) {
    return $GrammarPointsTable(attachedDatabase, alias);
  }
}

class GrammarPoint extends DataClass implements Insertable<GrammarPoint> {
  final int id;
  final int? lessonId;
  final String grammarPoint;
  final String? titleEn;
  final String meaning;
  final String? meaningVi;
  final String? meaningEn;
  final String connection;
  final String? connectionEn;
  final String explanation;
  final String? explanationVi;
  final String? explanationEn;
  final String jlptLevel;
  final bool isLearned;
  const GrammarPoint({
    required this.id,
    this.lessonId,
    required this.grammarPoint,
    this.titleEn,
    required this.meaning,
    this.meaningVi,
    this.meaningEn,
    required this.connection,
    this.connectionEn,
    required this.explanation,
    this.explanationVi,
    this.explanationEn,
    required this.jlptLevel,
    required this.isLearned,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || lessonId != null) {
      map['lesson_id'] = Variable<int>(lessonId);
    }
    map['grammar_point'] = Variable<String>(grammarPoint);
    if (!nullToAbsent || titleEn != null) {
      map['title_en'] = Variable<String>(titleEn);
    }
    map['meaning'] = Variable<String>(meaning);
    if (!nullToAbsent || meaningVi != null) {
      map['meaning_vi'] = Variable<String>(meaningVi);
    }
    if (!nullToAbsent || meaningEn != null) {
      map['meaning_en'] = Variable<String>(meaningEn);
    }
    map['connection'] = Variable<String>(connection);
    if (!nullToAbsent || connectionEn != null) {
      map['connection_en'] = Variable<String>(connectionEn);
    }
    map['explanation'] = Variable<String>(explanation);
    if (!nullToAbsent || explanationVi != null) {
      map['explanation_vi'] = Variable<String>(explanationVi);
    }
    if (!nullToAbsent || explanationEn != null) {
      map['explanation_en'] = Variable<String>(explanationEn);
    }
    map['jlpt_level'] = Variable<String>(jlptLevel);
    map['is_learned'] = Variable<bool>(isLearned);
    return map;
  }

  GrammarPointsCompanion toCompanion(bool nullToAbsent) {
    return GrammarPointsCompanion(
      id: Value(id),
      lessonId: lessonId == null && nullToAbsent
          ? const Value.absent()
          : Value(lessonId),
      grammarPoint: Value(grammarPoint),
      titleEn: titleEn == null && nullToAbsent
          ? const Value.absent()
          : Value(titleEn),
      meaning: Value(meaning),
      meaningVi: meaningVi == null && nullToAbsent
          ? const Value.absent()
          : Value(meaningVi),
      meaningEn: meaningEn == null && nullToAbsent
          ? const Value.absent()
          : Value(meaningEn),
      connection: Value(connection),
      connectionEn: connectionEn == null && nullToAbsent
          ? const Value.absent()
          : Value(connectionEn),
      explanation: Value(explanation),
      explanationVi: explanationVi == null && nullToAbsent
          ? const Value.absent()
          : Value(explanationVi),
      explanationEn: explanationEn == null && nullToAbsent
          ? const Value.absent()
          : Value(explanationEn),
      jlptLevel: Value(jlptLevel),
      isLearned: Value(isLearned),
    );
  }

  factory GrammarPoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GrammarPoint(
      id: serializer.fromJson<int>(json['id']),
      lessonId: serializer.fromJson<int?>(json['lessonId']),
      grammarPoint: serializer.fromJson<String>(json['grammarPoint']),
      titleEn: serializer.fromJson<String?>(json['titleEn']),
      meaning: serializer.fromJson<String>(json['meaning']),
      meaningVi: serializer.fromJson<String?>(json['meaningVi']),
      meaningEn: serializer.fromJson<String?>(json['meaningEn']),
      connection: serializer.fromJson<String>(json['connection']),
      connectionEn: serializer.fromJson<String?>(json['connectionEn']),
      explanation: serializer.fromJson<String>(json['explanation']),
      explanationVi: serializer.fromJson<String?>(json['explanationVi']),
      explanationEn: serializer.fromJson<String?>(json['explanationEn']),
      jlptLevel: serializer.fromJson<String>(json['jlptLevel']),
      isLearned: serializer.fromJson<bool>(json['isLearned']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lessonId': serializer.toJson<int?>(lessonId),
      'grammarPoint': serializer.toJson<String>(grammarPoint),
      'titleEn': serializer.toJson<String?>(titleEn),
      'meaning': serializer.toJson<String>(meaning),
      'meaningVi': serializer.toJson<String?>(meaningVi),
      'meaningEn': serializer.toJson<String?>(meaningEn),
      'connection': serializer.toJson<String>(connection),
      'connectionEn': serializer.toJson<String?>(connectionEn),
      'explanation': serializer.toJson<String>(explanation),
      'explanationVi': serializer.toJson<String?>(explanationVi),
      'explanationEn': serializer.toJson<String?>(explanationEn),
      'jlptLevel': serializer.toJson<String>(jlptLevel),
      'isLearned': serializer.toJson<bool>(isLearned),
    };
  }

  GrammarPoint copyWith({
    int? id,
    Value<int?> lessonId = const Value.absent(),
    String? grammarPoint,
    Value<String?> titleEn = const Value.absent(),
    String? meaning,
    Value<String?> meaningVi = const Value.absent(),
    Value<String?> meaningEn = const Value.absent(),
    String? connection,
    Value<String?> connectionEn = const Value.absent(),
    String? explanation,
    Value<String?> explanationVi = const Value.absent(),
    Value<String?> explanationEn = const Value.absent(),
    String? jlptLevel,
    bool? isLearned,
  }) => GrammarPoint(
    id: id ?? this.id,
    lessonId: lessonId.present ? lessonId.value : this.lessonId,
    grammarPoint: grammarPoint ?? this.grammarPoint,
    titleEn: titleEn.present ? titleEn.value : this.titleEn,
    meaning: meaning ?? this.meaning,
    meaningVi: meaningVi.present ? meaningVi.value : this.meaningVi,
    meaningEn: meaningEn.present ? meaningEn.value : this.meaningEn,
    connection: connection ?? this.connection,
    connectionEn: connectionEn.present ? connectionEn.value : this.connectionEn,
    explanation: explanation ?? this.explanation,
    explanationVi: explanationVi.present
        ? explanationVi.value
        : this.explanationVi,
    explanationEn: explanationEn.present
        ? explanationEn.value
        : this.explanationEn,
    jlptLevel: jlptLevel ?? this.jlptLevel,
    isLearned: isLearned ?? this.isLearned,
  );
  GrammarPoint copyWithCompanion(GrammarPointsCompanion data) {
    return GrammarPoint(
      id: data.id.present ? data.id.value : this.id,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      grammarPoint: data.grammarPoint.present
          ? data.grammarPoint.value
          : this.grammarPoint,
      titleEn: data.titleEn.present ? data.titleEn.value : this.titleEn,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      meaningVi: data.meaningVi.present ? data.meaningVi.value : this.meaningVi,
      meaningEn: data.meaningEn.present ? data.meaningEn.value : this.meaningEn,
      connection: data.connection.present
          ? data.connection.value
          : this.connection,
      connectionEn: data.connectionEn.present
          ? data.connectionEn.value
          : this.connectionEn,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
      explanationVi: data.explanationVi.present
          ? data.explanationVi.value
          : this.explanationVi,
      explanationEn: data.explanationEn.present
          ? data.explanationEn.value
          : this.explanationEn,
      jlptLevel: data.jlptLevel.present ? data.jlptLevel.value : this.jlptLevel,
      isLearned: data.isLearned.present ? data.isLearned.value : this.isLearned,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GrammarPoint(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('grammarPoint: $grammarPoint, ')
          ..write('titleEn: $titleEn, ')
          ..write('meaning: $meaning, ')
          ..write('meaningVi: $meaningVi, ')
          ..write('meaningEn: $meaningEn, ')
          ..write('connection: $connection, ')
          ..write('connectionEn: $connectionEn, ')
          ..write('explanation: $explanation, ')
          ..write('explanationVi: $explanationVi, ')
          ..write('explanationEn: $explanationEn, ')
          ..write('jlptLevel: $jlptLevel, ')
          ..write('isLearned: $isLearned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lessonId,
    grammarPoint,
    titleEn,
    meaning,
    meaningVi,
    meaningEn,
    connection,
    connectionEn,
    explanation,
    explanationVi,
    explanationEn,
    jlptLevel,
    isLearned,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GrammarPoint &&
          other.id == this.id &&
          other.lessonId == this.lessonId &&
          other.grammarPoint == this.grammarPoint &&
          other.titleEn == this.titleEn &&
          other.meaning == this.meaning &&
          other.meaningVi == this.meaningVi &&
          other.meaningEn == this.meaningEn &&
          other.connection == this.connection &&
          other.connectionEn == this.connectionEn &&
          other.explanation == this.explanation &&
          other.explanationVi == this.explanationVi &&
          other.explanationEn == this.explanationEn &&
          other.jlptLevel == this.jlptLevel &&
          other.isLearned == this.isLearned);
}

class GrammarPointsCompanion extends UpdateCompanion<GrammarPoint> {
  final Value<int> id;
  final Value<int?> lessonId;
  final Value<String> grammarPoint;
  final Value<String?> titleEn;
  final Value<String> meaning;
  final Value<String?> meaningVi;
  final Value<String?> meaningEn;
  final Value<String> connection;
  final Value<String?> connectionEn;
  final Value<String> explanation;
  final Value<String?> explanationVi;
  final Value<String?> explanationEn;
  final Value<String> jlptLevel;
  final Value<bool> isLearned;
  const GrammarPointsCompanion({
    this.id = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.grammarPoint = const Value.absent(),
    this.titleEn = const Value.absent(),
    this.meaning = const Value.absent(),
    this.meaningVi = const Value.absent(),
    this.meaningEn = const Value.absent(),
    this.connection = const Value.absent(),
    this.connectionEn = const Value.absent(),
    this.explanation = const Value.absent(),
    this.explanationVi = const Value.absent(),
    this.explanationEn = const Value.absent(),
    this.jlptLevel = const Value.absent(),
    this.isLearned = const Value.absent(),
  });
  GrammarPointsCompanion.insert({
    this.id = const Value.absent(),
    this.lessonId = const Value.absent(),
    required String grammarPoint,
    this.titleEn = const Value.absent(),
    required String meaning,
    this.meaningVi = const Value.absent(),
    this.meaningEn = const Value.absent(),
    required String connection,
    this.connectionEn = const Value.absent(),
    required String explanation,
    this.explanationVi = const Value.absent(),
    this.explanationEn = const Value.absent(),
    required String jlptLevel,
    this.isLearned = const Value.absent(),
  }) : grammarPoint = Value(grammarPoint),
       meaning = Value(meaning),
       connection = Value(connection),
       explanation = Value(explanation),
       jlptLevel = Value(jlptLevel);
  static Insertable<GrammarPoint> custom({
    Expression<int>? id,
    Expression<int>? lessonId,
    Expression<String>? grammarPoint,
    Expression<String>? titleEn,
    Expression<String>? meaning,
    Expression<String>? meaningVi,
    Expression<String>? meaningEn,
    Expression<String>? connection,
    Expression<String>? connectionEn,
    Expression<String>? explanation,
    Expression<String>? explanationVi,
    Expression<String>? explanationEn,
    Expression<String>? jlptLevel,
    Expression<bool>? isLearned,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lessonId != null) 'lesson_id': lessonId,
      if (grammarPoint != null) 'grammar_point': grammarPoint,
      if (titleEn != null) 'title_en': titleEn,
      if (meaning != null) 'meaning': meaning,
      if (meaningVi != null) 'meaning_vi': meaningVi,
      if (meaningEn != null) 'meaning_en': meaningEn,
      if (connection != null) 'connection': connection,
      if (connectionEn != null) 'connection_en': connectionEn,
      if (explanation != null) 'explanation': explanation,
      if (explanationVi != null) 'explanation_vi': explanationVi,
      if (explanationEn != null) 'explanation_en': explanationEn,
      if (jlptLevel != null) 'jlpt_level': jlptLevel,
      if (isLearned != null) 'is_learned': isLearned,
    });
  }

  GrammarPointsCompanion copyWith({
    Value<int>? id,
    Value<int?>? lessonId,
    Value<String>? grammarPoint,
    Value<String?>? titleEn,
    Value<String>? meaning,
    Value<String?>? meaningVi,
    Value<String?>? meaningEn,
    Value<String>? connection,
    Value<String?>? connectionEn,
    Value<String>? explanation,
    Value<String?>? explanationVi,
    Value<String?>? explanationEn,
    Value<String>? jlptLevel,
    Value<bool>? isLearned,
  }) {
    return GrammarPointsCompanion(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      grammarPoint: grammarPoint ?? this.grammarPoint,
      titleEn: titleEn ?? this.titleEn,
      meaning: meaning ?? this.meaning,
      meaningVi: meaningVi ?? this.meaningVi,
      meaningEn: meaningEn ?? this.meaningEn,
      connection: connection ?? this.connection,
      connectionEn: connectionEn ?? this.connectionEn,
      explanation: explanation ?? this.explanation,
      explanationVi: explanationVi ?? this.explanationVi,
      explanationEn: explanationEn ?? this.explanationEn,
      jlptLevel: jlptLevel ?? this.jlptLevel,
      isLearned: isLearned ?? this.isLearned,
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
    if (grammarPoint.present) {
      map['grammar_point'] = Variable<String>(grammarPoint.value);
    }
    if (titleEn.present) {
      map['title_en'] = Variable<String>(titleEn.value);
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (meaningVi.present) {
      map['meaning_vi'] = Variable<String>(meaningVi.value);
    }
    if (meaningEn.present) {
      map['meaning_en'] = Variable<String>(meaningEn.value);
    }
    if (connection.present) {
      map['connection'] = Variable<String>(connection.value);
    }
    if (connectionEn.present) {
      map['connection_en'] = Variable<String>(connectionEn.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (explanationVi.present) {
      map['explanation_vi'] = Variable<String>(explanationVi.value);
    }
    if (explanationEn.present) {
      map['explanation_en'] = Variable<String>(explanationEn.value);
    }
    if (jlptLevel.present) {
      map['jlpt_level'] = Variable<String>(jlptLevel.value);
    }
    if (isLearned.present) {
      map['is_learned'] = Variable<bool>(isLearned.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GrammarPointsCompanion(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('grammarPoint: $grammarPoint, ')
          ..write('titleEn: $titleEn, ')
          ..write('meaning: $meaning, ')
          ..write('meaningVi: $meaningVi, ')
          ..write('meaningEn: $meaningEn, ')
          ..write('connection: $connection, ')
          ..write('connectionEn: $connectionEn, ')
          ..write('explanation: $explanation, ')
          ..write('explanationVi: $explanationVi, ')
          ..write('explanationEn: $explanationEn, ')
          ..write('jlptLevel: $jlptLevel, ')
          ..write('isLearned: $isLearned')
          ..write(')'))
        .toString();
  }
}

class $GrammarExamplesTable extends GrammarExamples
    with TableInfo<$GrammarExamplesTable, GrammarExample> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GrammarExamplesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _grammarIdMeta = const VerificationMeta(
    'grammarId',
  );
  @override
  late final GeneratedColumn<int> grammarId = GeneratedColumn<int>(
    'grammar_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES grammar_points (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _japaneseMeta = const VerificationMeta(
    'japanese',
  );
  @override
  late final GeneratedColumn<String> japanese = GeneratedColumn<String>(
    'japanese',
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
  static const VerificationMeta _translationViMeta = const VerificationMeta(
    'translationVi',
  );
  @override
  late final GeneratedColumn<String> translationVi = GeneratedColumn<String>(
    'translation_vi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    grammarId,
    japanese,
    translation,
    translationVi,
    translationEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grammar_examples';
  @override
  VerificationContext validateIntegrity(
    Insertable<GrammarExample> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('grammar_id')) {
      context.handle(
        _grammarIdMeta,
        grammarId.isAcceptableOrUnknown(data['grammar_id']!, _grammarIdMeta),
      );
    } else if (isInserting) {
      context.missing(_grammarIdMeta);
    }
    if (data.containsKey('japanese')) {
      context.handle(
        _japaneseMeta,
        japanese.isAcceptableOrUnknown(data['japanese']!, _japaneseMeta),
      );
    } else if (isInserting) {
      context.missing(_japaneseMeta);
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
    if (data.containsKey('translation_vi')) {
      context.handle(
        _translationViMeta,
        translationVi.isAcceptableOrUnknown(
          data['translation_vi']!,
          _translationViMeta,
        ),
      );
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
  GrammarExample map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GrammarExample(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      grammarId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grammar_id'],
      )!,
      japanese: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}japanese'],
      )!,
      translation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation'],
      )!,
      translationVi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation_vi'],
      ),
      translationEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation_en'],
      ),
    );
  }

  @override
  $GrammarExamplesTable createAlias(String alias) {
    return $GrammarExamplesTable(attachedDatabase, alias);
  }
}

class GrammarExample extends DataClass implements Insertable<GrammarExample> {
  final int id;
  final int grammarId;
  final String japanese;
  final String translation;
  final String? translationVi;
  final String? translationEn;
  const GrammarExample({
    required this.id,
    required this.grammarId,
    required this.japanese,
    required this.translation,
    this.translationVi,
    this.translationEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['grammar_id'] = Variable<int>(grammarId);
    map['japanese'] = Variable<String>(japanese);
    map['translation'] = Variable<String>(translation);
    if (!nullToAbsent || translationVi != null) {
      map['translation_vi'] = Variable<String>(translationVi);
    }
    if (!nullToAbsent || translationEn != null) {
      map['translation_en'] = Variable<String>(translationEn);
    }
    return map;
  }

  GrammarExamplesCompanion toCompanion(bool nullToAbsent) {
    return GrammarExamplesCompanion(
      id: Value(id),
      grammarId: Value(grammarId),
      japanese: Value(japanese),
      translation: Value(translation),
      translationVi: translationVi == null && nullToAbsent
          ? const Value.absent()
          : Value(translationVi),
      translationEn: translationEn == null && nullToAbsent
          ? const Value.absent()
          : Value(translationEn),
    );
  }

  factory GrammarExample.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GrammarExample(
      id: serializer.fromJson<int>(json['id']),
      grammarId: serializer.fromJson<int>(json['grammarId']),
      japanese: serializer.fromJson<String>(json['japanese']),
      translation: serializer.fromJson<String>(json['translation']),
      translationVi: serializer.fromJson<String?>(json['translationVi']),
      translationEn: serializer.fromJson<String?>(json['translationEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'grammarId': serializer.toJson<int>(grammarId),
      'japanese': serializer.toJson<String>(japanese),
      'translation': serializer.toJson<String>(translation),
      'translationVi': serializer.toJson<String?>(translationVi),
      'translationEn': serializer.toJson<String?>(translationEn),
    };
  }

  GrammarExample copyWith({
    int? id,
    int? grammarId,
    String? japanese,
    String? translation,
    Value<String?> translationVi = const Value.absent(),
    Value<String?> translationEn = const Value.absent(),
  }) => GrammarExample(
    id: id ?? this.id,
    grammarId: grammarId ?? this.grammarId,
    japanese: japanese ?? this.japanese,
    translation: translation ?? this.translation,
    translationVi: translationVi.present
        ? translationVi.value
        : this.translationVi,
    translationEn: translationEn.present
        ? translationEn.value
        : this.translationEn,
  );
  GrammarExample copyWithCompanion(GrammarExamplesCompanion data) {
    return GrammarExample(
      id: data.id.present ? data.id.value : this.id,
      grammarId: data.grammarId.present ? data.grammarId.value : this.grammarId,
      japanese: data.japanese.present ? data.japanese.value : this.japanese,
      translation: data.translation.present
          ? data.translation.value
          : this.translation,
      translationVi: data.translationVi.present
          ? data.translationVi.value
          : this.translationVi,
      translationEn: data.translationEn.present
          ? data.translationEn.value
          : this.translationEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GrammarExample(')
          ..write('id: $id, ')
          ..write('grammarId: $grammarId, ')
          ..write('japanese: $japanese, ')
          ..write('translation: $translation, ')
          ..write('translationVi: $translationVi, ')
          ..write('translationEn: $translationEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    grammarId,
    japanese,
    translation,
    translationVi,
    translationEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GrammarExample &&
          other.id == this.id &&
          other.grammarId == this.grammarId &&
          other.japanese == this.japanese &&
          other.translation == this.translation &&
          other.translationVi == this.translationVi &&
          other.translationEn == this.translationEn);
}

class GrammarExamplesCompanion extends UpdateCompanion<GrammarExample> {
  final Value<int> id;
  final Value<int> grammarId;
  final Value<String> japanese;
  final Value<String> translation;
  final Value<String?> translationVi;
  final Value<String?> translationEn;
  const GrammarExamplesCompanion({
    this.id = const Value.absent(),
    this.grammarId = const Value.absent(),
    this.japanese = const Value.absent(),
    this.translation = const Value.absent(),
    this.translationVi = const Value.absent(),
    this.translationEn = const Value.absent(),
  });
  GrammarExamplesCompanion.insert({
    this.id = const Value.absent(),
    required int grammarId,
    required String japanese,
    required String translation,
    this.translationVi = const Value.absent(),
    this.translationEn = const Value.absent(),
  }) : grammarId = Value(grammarId),
       japanese = Value(japanese),
       translation = Value(translation);
  static Insertable<GrammarExample> custom({
    Expression<int>? id,
    Expression<int>? grammarId,
    Expression<String>? japanese,
    Expression<String>? translation,
    Expression<String>? translationVi,
    Expression<String>? translationEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (grammarId != null) 'grammar_id': grammarId,
      if (japanese != null) 'japanese': japanese,
      if (translation != null) 'translation': translation,
      if (translationVi != null) 'translation_vi': translationVi,
      if (translationEn != null) 'translation_en': translationEn,
    });
  }

  GrammarExamplesCompanion copyWith({
    Value<int>? id,
    Value<int>? grammarId,
    Value<String>? japanese,
    Value<String>? translation,
    Value<String?>? translationVi,
    Value<String?>? translationEn,
  }) {
    return GrammarExamplesCompanion(
      id: id ?? this.id,
      grammarId: grammarId ?? this.grammarId,
      japanese: japanese ?? this.japanese,
      translation: translation ?? this.translation,
      translationVi: translationVi ?? this.translationVi,
      translationEn: translationEn ?? this.translationEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (grammarId.present) {
      map['grammar_id'] = Variable<int>(grammarId.value);
    }
    if (japanese.present) {
      map['japanese'] = Variable<String>(japanese.value);
    }
    if (translation.present) {
      map['translation'] = Variable<String>(translation.value);
    }
    if (translationVi.present) {
      map['translation_vi'] = Variable<String>(translationVi.value);
    }
    if (translationEn.present) {
      map['translation_en'] = Variable<String>(translationEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GrammarExamplesCompanion(')
          ..write('id: $id, ')
          ..write('grammarId: $grammarId, ')
          ..write('japanese: $japanese, ')
          ..write('translation: $translation, ')
          ..write('translationVi: $translationVi, ')
          ..write('translationEn: $translationEn')
          ..write(')'))
        .toString();
  }
}

class $GrammarSrsStateTable extends GrammarSrsState
    with TableInfo<$GrammarSrsStateTable, GrammarSrsStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GrammarSrsStateTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _grammarIdMeta = const VerificationMeta(
    'grammarId',
  );
  @override
  late final GeneratedColumn<int> grammarId = GeneratedColumn<int>(
    'grammar_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES grammar_points (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _streakMeta = const VerificationMeta('streak');
  @override
  late final GeneratedColumn<int> streak = GeneratedColumn<int>(
    'streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _easeMeta = const VerificationMeta('ease');
  @override
  late final GeneratedColumn<double> ease = GeneratedColumn<double>(
    'ease',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2.5),
  );
  static const VerificationMeta _stabilityMeta = const VerificationMeta(
    'stability',
  );
  @override
  late final GeneratedColumn<double> stability = GeneratedColumn<double>(
    'stability',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(5.0),
  );
  static const VerificationMeta _nextReviewAtMeta = const VerificationMeta(
    'nextReviewAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextReviewAt = GeneratedColumn<DateTime>(
    'next_review_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
  static const VerificationMeta _ghostReviewsDueMeta = const VerificationMeta(
    'ghostReviewsDue',
  );
  @override
  late final GeneratedColumn<int> ghostReviewsDue = GeneratedColumn<int>(
    'ghost_reviews_due',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    grammarId,
    streak,
    ease,
    stability,
    difficulty,
    nextReviewAt,
    lastReviewedAt,
    ghostReviewsDue,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grammar_srs_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<GrammarSrsStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('grammar_id')) {
      context.handle(
        _grammarIdMeta,
        grammarId.isAcceptableOrUnknown(data['grammar_id']!, _grammarIdMeta),
      );
    } else if (isInserting) {
      context.missing(_grammarIdMeta);
    }
    if (data.containsKey('streak')) {
      context.handle(
        _streakMeta,
        streak.isAcceptableOrUnknown(data['streak']!, _streakMeta),
      );
    }
    if (data.containsKey('ease')) {
      context.handle(
        _easeMeta,
        ease.isAcceptableOrUnknown(data['ease']!, _easeMeta),
      );
    }
    if (data.containsKey('stability')) {
      context.handle(
        _stabilityMeta,
        stability.isAcceptableOrUnknown(data['stability']!, _stabilityMeta),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('next_review_at')) {
      context.handle(
        _nextReviewAtMeta,
        nextReviewAt.isAcceptableOrUnknown(
          data['next_review_at']!,
          _nextReviewAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextReviewAtMeta);
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
    if (data.containsKey('ghost_reviews_due')) {
      context.handle(
        _ghostReviewsDueMeta,
        ghostReviewsDue.isAcceptableOrUnknown(
          data['ghost_reviews_due']!,
          _ghostReviewsDueMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {grammarId},
  ];
  @override
  GrammarSrsStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GrammarSrsStateData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      grammarId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grammar_id'],
      )!,
      streak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak'],
      )!,
      ease: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ease'],
      )!,
      stability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stability'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}difficulty'],
      )!,
      nextReviewAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_review_at'],
      )!,
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reviewed_at'],
      ),
      ghostReviewsDue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ghost_reviews_due'],
      )!,
    );
  }

  @override
  $GrammarSrsStateTable createAlias(String alias) {
    return $GrammarSrsStateTable(attachedDatabase, alias);
  }
}

class GrammarSrsStateData extends DataClass
    implements Insertable<GrammarSrsStateData> {
  final int id;
  final int grammarId;
  final int streak;
  final double ease;
  final double stability;
  final double difficulty;
  final DateTime nextReviewAt;
  final DateTime? lastReviewedAt;
  final int ghostReviewsDue;
  const GrammarSrsStateData({
    required this.id,
    required this.grammarId,
    required this.streak,
    required this.ease,
    required this.stability,
    required this.difficulty,
    required this.nextReviewAt,
    this.lastReviewedAt,
    required this.ghostReviewsDue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['grammar_id'] = Variable<int>(grammarId);
    map['streak'] = Variable<int>(streak);
    map['ease'] = Variable<double>(ease);
    map['stability'] = Variable<double>(stability);
    map['difficulty'] = Variable<double>(difficulty);
    map['next_review_at'] = Variable<DateTime>(nextReviewAt);
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt);
    }
    map['ghost_reviews_due'] = Variable<int>(ghostReviewsDue);
    return map;
  }

  GrammarSrsStateCompanion toCompanion(bool nullToAbsent) {
    return GrammarSrsStateCompanion(
      id: Value(id),
      grammarId: Value(grammarId),
      streak: Value(streak),
      ease: Value(ease),
      stability: Value(stability),
      difficulty: Value(difficulty),
      nextReviewAt: Value(nextReviewAt),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
      ghostReviewsDue: Value(ghostReviewsDue),
    );
  }

  factory GrammarSrsStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GrammarSrsStateData(
      id: serializer.fromJson<int>(json['id']),
      grammarId: serializer.fromJson<int>(json['grammarId']),
      streak: serializer.fromJson<int>(json['streak']),
      ease: serializer.fromJson<double>(json['ease']),
      stability: serializer.fromJson<double>(json['stability']),
      difficulty: serializer.fromJson<double>(json['difficulty']),
      nextReviewAt: serializer.fromJson<DateTime>(json['nextReviewAt']),
      lastReviewedAt: serializer.fromJson<DateTime?>(json['lastReviewedAt']),
      ghostReviewsDue: serializer.fromJson<int>(json['ghostReviewsDue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'grammarId': serializer.toJson<int>(grammarId),
      'streak': serializer.toJson<int>(streak),
      'ease': serializer.toJson<double>(ease),
      'stability': serializer.toJson<double>(stability),
      'difficulty': serializer.toJson<double>(difficulty),
      'nextReviewAt': serializer.toJson<DateTime>(nextReviewAt),
      'lastReviewedAt': serializer.toJson<DateTime?>(lastReviewedAt),
      'ghostReviewsDue': serializer.toJson<int>(ghostReviewsDue),
    };
  }

  GrammarSrsStateData copyWith({
    int? id,
    int? grammarId,
    int? streak,
    double? ease,
    double? stability,
    double? difficulty,
    DateTime? nextReviewAt,
    Value<DateTime?> lastReviewedAt = const Value.absent(),
    int? ghostReviewsDue,
  }) => GrammarSrsStateData(
    id: id ?? this.id,
    grammarId: grammarId ?? this.grammarId,
    streak: streak ?? this.streak,
    ease: ease ?? this.ease,
    stability: stability ?? this.stability,
    difficulty: difficulty ?? this.difficulty,
    nextReviewAt: nextReviewAt ?? this.nextReviewAt,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
    ghostReviewsDue: ghostReviewsDue ?? this.ghostReviewsDue,
  );
  GrammarSrsStateData copyWithCompanion(GrammarSrsStateCompanion data) {
    return GrammarSrsStateData(
      id: data.id.present ? data.id.value : this.id,
      grammarId: data.grammarId.present ? data.grammarId.value : this.grammarId,
      streak: data.streak.present ? data.streak.value : this.streak,
      ease: data.ease.present ? data.ease.value : this.ease,
      stability: data.stability.present ? data.stability.value : this.stability,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      nextReviewAt: data.nextReviewAt.present
          ? data.nextReviewAt.value
          : this.nextReviewAt,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
      ghostReviewsDue: data.ghostReviewsDue.present
          ? data.ghostReviewsDue.value
          : this.ghostReviewsDue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GrammarSrsStateData(')
          ..write('id: $id, ')
          ..write('grammarId: $grammarId, ')
          ..write('streak: $streak, ')
          ..write('ease: $ease, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('ghostReviewsDue: $ghostReviewsDue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    grammarId,
    streak,
    ease,
    stability,
    difficulty,
    nextReviewAt,
    lastReviewedAt,
    ghostReviewsDue,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GrammarSrsStateData &&
          other.id == this.id &&
          other.grammarId == this.grammarId &&
          other.streak == this.streak &&
          other.ease == this.ease &&
          other.stability == this.stability &&
          other.difficulty == this.difficulty &&
          other.nextReviewAt == this.nextReviewAt &&
          other.lastReviewedAt == this.lastReviewedAt &&
          other.ghostReviewsDue == this.ghostReviewsDue);
}

class GrammarSrsStateCompanion extends UpdateCompanion<GrammarSrsStateData> {
  final Value<int> id;
  final Value<int> grammarId;
  final Value<int> streak;
  final Value<double> ease;
  final Value<double> stability;
  final Value<double> difficulty;
  final Value<DateTime> nextReviewAt;
  final Value<DateTime?> lastReviewedAt;
  final Value<int> ghostReviewsDue;
  const GrammarSrsStateCompanion({
    this.id = const Value.absent(),
    this.grammarId = const Value.absent(),
    this.streak = const Value.absent(),
    this.ease = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.ghostReviewsDue = const Value.absent(),
  });
  GrammarSrsStateCompanion.insert({
    this.id = const Value.absent(),
    required int grammarId,
    this.streak = const Value.absent(),
    this.ease = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    required DateTime nextReviewAt,
    this.lastReviewedAt = const Value.absent(),
    this.ghostReviewsDue = const Value.absent(),
  }) : grammarId = Value(grammarId),
       nextReviewAt = Value(nextReviewAt);
  static Insertable<GrammarSrsStateData> custom({
    Expression<int>? id,
    Expression<int>? grammarId,
    Expression<int>? streak,
    Expression<double>? ease,
    Expression<double>? stability,
    Expression<double>? difficulty,
    Expression<DateTime>? nextReviewAt,
    Expression<DateTime>? lastReviewedAt,
    Expression<int>? ghostReviewsDue,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (grammarId != null) 'grammar_id': grammarId,
      if (streak != null) 'streak': streak,
      if (ease != null) 'ease': ease,
      if (stability != null) 'stability': stability,
      if (difficulty != null) 'difficulty': difficulty,
      if (nextReviewAt != null) 'next_review_at': nextReviewAt,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (ghostReviewsDue != null) 'ghost_reviews_due': ghostReviewsDue,
    });
  }

  GrammarSrsStateCompanion copyWith({
    Value<int>? id,
    Value<int>? grammarId,
    Value<int>? streak,
    Value<double>? ease,
    Value<double>? stability,
    Value<double>? difficulty,
    Value<DateTime>? nextReviewAt,
    Value<DateTime?>? lastReviewedAt,
    Value<int>? ghostReviewsDue,
  }) {
    return GrammarSrsStateCompanion(
      id: id ?? this.id,
      grammarId: grammarId ?? this.grammarId,
      streak: streak ?? this.streak,
      ease: ease ?? this.ease,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      ghostReviewsDue: ghostReviewsDue ?? this.ghostReviewsDue,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (grammarId.present) {
      map['grammar_id'] = Variable<int>(grammarId.value);
    }
    if (streak.present) {
      map['streak'] = Variable<int>(streak.value);
    }
    if (ease.present) {
      map['ease'] = Variable<double>(ease.value);
    }
    if (stability.present) {
      map['stability'] = Variable<double>(stability.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    if (nextReviewAt.present) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
    }
    if (ghostReviewsDue.present) {
      map['ghost_reviews_due'] = Variable<int>(ghostReviewsDue.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GrammarSrsStateCompanion(')
          ..write('id: $id, ')
          ..write('grammarId: $grammarId, ')
          ..write('streak: $streak, ')
          ..write('ease: $ease, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('ghostReviewsDue: $ghostReviewsDue')
          ..write(')'))
        .toString();
  }
}

class $GrammarQuestionsTable extends GrammarQuestions
    with TableInfo<$GrammarQuestionsTable, GrammarQuestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GrammarQuestionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _grammarIdMeta = const VerificationMeta(
    'grammarId',
  );
  @override
  late final GeneratedColumn<int> grammarId = GeneratedColumn<int>(
    'grammar_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES grammar_points (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionMeta = const VerificationMeta(
    'question',
  );
  @override
  late final GeneratedColumn<String> question = GeneratedColumn<String>(
    'question',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctAnswerMeta = const VerificationMeta(
    'correctAnswer',
  );
  @override
  late final GeneratedColumn<String> correctAnswer = GeneratedColumn<String>(
    'correct_answer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _optionsJsonMeta = const VerificationMeta(
    'optionsJson',
  );
  @override
  late final GeneratedColumn<String> optionsJson = GeneratedColumn<String>(
    'options_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _correctOrderJsonMeta = const VerificationMeta(
    'correctOrderJson',
  );
  @override
  late final GeneratedColumn<String> correctOrderJson = GeneratedColumn<String>(
    'correct_order_json',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    grammarId,
    type,
    question,
    correctAnswer,
    optionsJson,
    correctOrderJson,
    explanation,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grammar_questions';
  @override
  VerificationContext validateIntegrity(
    Insertable<GrammarQuestion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('grammar_id')) {
      context.handle(
        _grammarIdMeta,
        grammarId.isAcceptableOrUnknown(data['grammar_id']!, _grammarIdMeta),
      );
    } else if (isInserting) {
      context.missing(_grammarIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('question')) {
      context.handle(
        _questionMeta,
        question.isAcceptableOrUnknown(data['question']!, _questionMeta),
      );
    } else if (isInserting) {
      context.missing(_questionMeta);
    }
    if (data.containsKey('correct_answer')) {
      context.handle(
        _correctAnswerMeta,
        correctAnswer.isAcceptableOrUnknown(
          data['correct_answer']!,
          _correctAnswerMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctAnswerMeta);
    }
    if (data.containsKey('options_json')) {
      context.handle(
        _optionsJsonMeta,
        optionsJson.isAcceptableOrUnknown(
          data['options_json']!,
          _optionsJsonMeta,
        ),
      );
    }
    if (data.containsKey('correct_order_json')) {
      context.handle(
        _correctOrderJsonMeta,
        correctOrderJson.isAcceptableOrUnknown(
          data['correct_order_json']!,
          _correctOrderJsonMeta,
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
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GrammarQuestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GrammarQuestion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      grammarId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grammar_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      question: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question'],
      )!,
      correctAnswer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}correct_answer'],
      )!,
      optionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}options_json'],
      ),
      correctOrderJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}correct_order_json'],
      ),
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      ),
    );
  }

  @override
  $GrammarQuestionsTable createAlias(String alias) {
    return $GrammarQuestionsTable(attachedDatabase, alias);
  }
}

class GrammarQuestion extends DataClass implements Insertable<GrammarQuestion> {
  final int id;
  final int grammarId;
  final String type;
  final String question;
  final String correctAnswer;
  final String? optionsJson;
  final String? correctOrderJson;
  final String? explanation;
  const GrammarQuestion({
    required this.id,
    required this.grammarId,
    required this.type,
    required this.question,
    required this.correctAnswer,
    this.optionsJson,
    this.correctOrderJson,
    this.explanation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['grammar_id'] = Variable<int>(grammarId);
    map['type'] = Variable<String>(type);
    map['question'] = Variable<String>(question);
    map['correct_answer'] = Variable<String>(correctAnswer);
    if (!nullToAbsent || optionsJson != null) {
      map['options_json'] = Variable<String>(optionsJson);
    }
    if (!nullToAbsent || correctOrderJson != null) {
      map['correct_order_json'] = Variable<String>(correctOrderJson);
    }
    if (!nullToAbsent || explanation != null) {
      map['explanation'] = Variable<String>(explanation);
    }
    return map;
  }

  GrammarQuestionsCompanion toCompanion(bool nullToAbsent) {
    return GrammarQuestionsCompanion(
      id: Value(id),
      grammarId: Value(grammarId),
      type: Value(type),
      question: Value(question),
      correctAnswer: Value(correctAnswer),
      optionsJson: optionsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(optionsJson),
      correctOrderJson: correctOrderJson == null && nullToAbsent
          ? const Value.absent()
          : Value(correctOrderJson),
      explanation: explanation == null && nullToAbsent
          ? const Value.absent()
          : Value(explanation),
    );
  }

  factory GrammarQuestion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GrammarQuestion(
      id: serializer.fromJson<int>(json['id']),
      grammarId: serializer.fromJson<int>(json['grammarId']),
      type: serializer.fromJson<String>(json['type']),
      question: serializer.fromJson<String>(json['question']),
      correctAnswer: serializer.fromJson<String>(json['correctAnswer']),
      optionsJson: serializer.fromJson<String?>(json['optionsJson']),
      correctOrderJson: serializer.fromJson<String?>(json['correctOrderJson']),
      explanation: serializer.fromJson<String?>(json['explanation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'grammarId': serializer.toJson<int>(grammarId),
      'type': serializer.toJson<String>(type),
      'question': serializer.toJson<String>(question),
      'correctAnswer': serializer.toJson<String>(correctAnswer),
      'optionsJson': serializer.toJson<String?>(optionsJson),
      'correctOrderJson': serializer.toJson<String?>(correctOrderJson),
      'explanation': serializer.toJson<String?>(explanation),
    };
  }

  GrammarQuestion copyWith({
    int? id,
    int? grammarId,
    String? type,
    String? question,
    String? correctAnswer,
    Value<String?> optionsJson = const Value.absent(),
    Value<String?> correctOrderJson = const Value.absent(),
    Value<String?> explanation = const Value.absent(),
  }) => GrammarQuestion(
    id: id ?? this.id,
    grammarId: grammarId ?? this.grammarId,
    type: type ?? this.type,
    question: question ?? this.question,
    correctAnswer: correctAnswer ?? this.correctAnswer,
    optionsJson: optionsJson.present ? optionsJson.value : this.optionsJson,
    correctOrderJson: correctOrderJson.present
        ? correctOrderJson.value
        : this.correctOrderJson,
    explanation: explanation.present ? explanation.value : this.explanation,
  );
  GrammarQuestion copyWithCompanion(GrammarQuestionsCompanion data) {
    return GrammarQuestion(
      id: data.id.present ? data.id.value : this.id,
      grammarId: data.grammarId.present ? data.grammarId.value : this.grammarId,
      type: data.type.present ? data.type.value : this.type,
      question: data.question.present ? data.question.value : this.question,
      correctAnswer: data.correctAnswer.present
          ? data.correctAnswer.value
          : this.correctAnswer,
      optionsJson: data.optionsJson.present
          ? data.optionsJson.value
          : this.optionsJson,
      correctOrderJson: data.correctOrderJson.present
          ? data.correctOrderJson.value
          : this.correctOrderJson,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GrammarQuestion(')
          ..write('id: $id, ')
          ..write('grammarId: $grammarId, ')
          ..write('type: $type, ')
          ..write('question: $question, ')
          ..write('correctAnswer: $correctAnswer, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('correctOrderJson: $correctOrderJson, ')
          ..write('explanation: $explanation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    grammarId,
    type,
    question,
    correctAnswer,
    optionsJson,
    correctOrderJson,
    explanation,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GrammarQuestion &&
          other.id == this.id &&
          other.grammarId == this.grammarId &&
          other.type == this.type &&
          other.question == this.question &&
          other.correctAnswer == this.correctAnswer &&
          other.optionsJson == this.optionsJson &&
          other.correctOrderJson == this.correctOrderJson &&
          other.explanation == this.explanation);
}

class GrammarQuestionsCompanion extends UpdateCompanion<GrammarQuestion> {
  final Value<int> id;
  final Value<int> grammarId;
  final Value<String> type;
  final Value<String> question;
  final Value<String> correctAnswer;
  final Value<String?> optionsJson;
  final Value<String?> correctOrderJson;
  final Value<String?> explanation;
  const GrammarQuestionsCompanion({
    this.id = const Value.absent(),
    this.grammarId = const Value.absent(),
    this.type = const Value.absent(),
    this.question = const Value.absent(),
    this.correctAnswer = const Value.absent(),
    this.optionsJson = const Value.absent(),
    this.correctOrderJson = const Value.absent(),
    this.explanation = const Value.absent(),
  });
  GrammarQuestionsCompanion.insert({
    this.id = const Value.absent(),
    required int grammarId,
    required String type,
    required String question,
    required String correctAnswer,
    this.optionsJson = const Value.absent(),
    this.correctOrderJson = const Value.absent(),
    this.explanation = const Value.absent(),
  }) : grammarId = Value(grammarId),
       type = Value(type),
       question = Value(question),
       correctAnswer = Value(correctAnswer);
  static Insertable<GrammarQuestion> custom({
    Expression<int>? id,
    Expression<int>? grammarId,
    Expression<String>? type,
    Expression<String>? question,
    Expression<String>? correctAnswer,
    Expression<String>? optionsJson,
    Expression<String>? correctOrderJson,
    Expression<String>? explanation,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (grammarId != null) 'grammar_id': grammarId,
      if (type != null) 'type': type,
      if (question != null) 'question': question,
      if (correctAnswer != null) 'correct_answer': correctAnswer,
      if (optionsJson != null) 'options_json': optionsJson,
      if (correctOrderJson != null) 'correct_order_json': correctOrderJson,
      if (explanation != null) 'explanation': explanation,
    });
  }

  GrammarQuestionsCompanion copyWith({
    Value<int>? id,
    Value<int>? grammarId,
    Value<String>? type,
    Value<String>? question,
    Value<String>? correctAnswer,
    Value<String?>? optionsJson,
    Value<String?>? correctOrderJson,
    Value<String?>? explanation,
  }) {
    return GrammarQuestionsCompanion(
      id: id ?? this.id,
      grammarId: grammarId ?? this.grammarId,
      type: type ?? this.type,
      question: question ?? this.question,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      optionsJson: optionsJson ?? this.optionsJson,
      correctOrderJson: correctOrderJson ?? this.correctOrderJson,
      explanation: explanation ?? this.explanation,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (grammarId.present) {
      map['grammar_id'] = Variable<int>(grammarId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (question.present) {
      map['question'] = Variable<String>(question.value);
    }
    if (correctAnswer.present) {
      map['correct_answer'] = Variable<String>(correctAnswer.value);
    }
    if (optionsJson.present) {
      map['options_json'] = Variable<String>(optionsJson.value);
    }
    if (correctOrderJson.present) {
      map['correct_order_json'] = Variable<String>(correctOrderJson.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GrammarQuestionsCompanion(')
          ..write('id: $id, ')
          ..write('grammarId: $grammarId, ')
          ..write('type: $type, ')
          ..write('question: $question, ')
          ..write('correctAnswer: $correctAnswer, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('correctOrderJson: $correctOrderJson, ')
          ..write('explanation: $explanation')
          ..write(')'))
        .toString();
  }
}

class $UserLessonTable extends UserLesson
    with TableInfo<$UserLessonTable, UserLessonData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserLessonTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isPublicMeta = const VerificationMeta(
    'isPublic',
  );
  @override
  late final GeneratedColumn<bool> isPublic = GeneratedColumn<bool>(
    'is_public',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_public" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isCustomTitleMeta = const VerificationMeta(
    'isCustomTitle',
  );
  @override
  late final GeneratedColumn<bool> isCustomTitle = GeneratedColumn<bool>(
    'is_custom_title',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom_title" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _learnTermLimitMeta = const VerificationMeta(
    'learnTermLimit',
  );
  @override
  late final GeneratedColumn<int> learnTermLimit = GeneratedColumn<int>(
    'learn_term_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _testQuestionLimitMeta = const VerificationMeta(
    'testQuestionLimit',
  );
  @override
  late final GeneratedColumn<int> testQuestionLimit = GeneratedColumn<int>(
    'test_question_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(12),
  );
  static const VerificationMeta _matchPairLimitMeta = const VerificationMeta(
    'matchPairLimit',
  );
  @override
  late final GeneratedColumn<int> matchPairLimit = GeneratedColumn<int>(
    'match_pair_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(8),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    level,
    title,
    description,
    tags,
    isPublic,
    isCustomTitle,
    learnTermLimit,
    testQuestionLimit,
    matchPairLimit,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_lesson';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserLessonData> instance, {
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
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('is_public')) {
      context.handle(
        _isPublicMeta,
        isPublic.isAcceptableOrUnknown(data['is_public']!, _isPublicMeta),
      );
    }
    if (data.containsKey('is_custom_title')) {
      context.handle(
        _isCustomTitleMeta,
        isCustomTitle.isAcceptableOrUnknown(
          data['is_custom_title']!,
          _isCustomTitleMeta,
        ),
      );
    }
    if (data.containsKey('learn_term_limit')) {
      context.handle(
        _learnTermLimitMeta,
        learnTermLimit.isAcceptableOrUnknown(
          data['learn_term_limit']!,
          _learnTermLimitMeta,
        ),
      );
    }
    if (data.containsKey('test_question_limit')) {
      context.handle(
        _testQuestionLimitMeta,
        testQuestionLimit.isAcceptableOrUnknown(
          data['test_question_limit']!,
          _testQuestionLimitMeta,
        ),
      );
    }
    if (data.containsKey('match_pair_limit')) {
      context.handle(
        _matchPairLimitMeta,
        matchPairLimit.isAcceptableOrUnknown(
          data['match_pair_limit']!,
          _matchPairLimitMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserLessonData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserLessonData(
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
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      isPublic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_public'],
      )!,
      isCustomTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom_title'],
      )!,
      learnTermLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}learn_term_limit'],
      )!,
      testQuestionLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}test_question_limit'],
      )!,
      matchPairLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}match_pair_limit'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $UserLessonTable createAlias(String alias) {
    return $UserLessonTable(attachedDatabase, alias);
  }
}

class UserLessonData extends DataClass implements Insertable<UserLessonData> {
  final int id;
  final String level;
  final String title;
  final String description;
  final String tags;
  final bool isPublic;
  final bool isCustomTitle;
  final int learnTermLimit;
  final int testQuestionLimit;
  final int matchPairLimit;
  final DateTime? updatedAt;
  const UserLessonData({
    required this.id,
    required this.level,
    required this.title,
    required this.description,
    required this.tags,
    required this.isPublic,
    required this.isCustomTitle,
    required this.learnTermLimit,
    required this.testQuestionLimit,
    required this.matchPairLimit,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['level'] = Variable<String>(level);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['tags'] = Variable<String>(tags);
    map['is_public'] = Variable<bool>(isPublic);
    map['is_custom_title'] = Variable<bool>(isCustomTitle);
    map['learn_term_limit'] = Variable<int>(learnTermLimit);
    map['test_question_limit'] = Variable<int>(testQuestionLimit);
    map['match_pair_limit'] = Variable<int>(matchPairLimit);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  UserLessonCompanion toCompanion(bool nullToAbsent) {
    return UserLessonCompanion(
      id: Value(id),
      level: Value(level),
      title: Value(title),
      description: Value(description),
      tags: Value(tags),
      isPublic: Value(isPublic),
      isCustomTitle: Value(isCustomTitle),
      learnTermLimit: Value(learnTermLimit),
      testQuestionLimit: Value(testQuestionLimit),
      matchPairLimit: Value(matchPairLimit),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory UserLessonData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserLessonData(
      id: serializer.fromJson<int>(json['id']),
      level: serializer.fromJson<String>(json['level']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      tags: serializer.fromJson<String>(json['tags']),
      isPublic: serializer.fromJson<bool>(json['isPublic']),
      isCustomTitle: serializer.fromJson<bool>(json['isCustomTitle']),
      learnTermLimit: serializer.fromJson<int>(json['learnTermLimit']),
      testQuestionLimit: serializer.fromJson<int>(json['testQuestionLimit']),
      matchPairLimit: serializer.fromJson<int>(json['matchPairLimit']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'level': serializer.toJson<String>(level),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'tags': serializer.toJson<String>(tags),
      'isPublic': serializer.toJson<bool>(isPublic),
      'isCustomTitle': serializer.toJson<bool>(isCustomTitle),
      'learnTermLimit': serializer.toJson<int>(learnTermLimit),
      'testQuestionLimit': serializer.toJson<int>(testQuestionLimit),
      'matchPairLimit': serializer.toJson<int>(matchPairLimit),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  UserLessonData copyWith({
    int? id,
    String? level,
    String? title,
    String? description,
    String? tags,
    bool? isPublic,
    bool? isCustomTitle,
    int? learnTermLimit,
    int? testQuestionLimit,
    int? matchPairLimit,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => UserLessonData(
    id: id ?? this.id,
    level: level ?? this.level,
    title: title ?? this.title,
    description: description ?? this.description,
    tags: tags ?? this.tags,
    isPublic: isPublic ?? this.isPublic,
    isCustomTitle: isCustomTitle ?? this.isCustomTitle,
    learnTermLimit: learnTermLimit ?? this.learnTermLimit,
    testQuestionLimit: testQuestionLimit ?? this.testQuestionLimit,
    matchPairLimit: matchPairLimit ?? this.matchPairLimit,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  UserLessonData copyWithCompanion(UserLessonCompanion data) {
    return UserLessonData(
      id: data.id.present ? data.id.value : this.id,
      level: data.level.present ? data.level.value : this.level,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      tags: data.tags.present ? data.tags.value : this.tags,
      isPublic: data.isPublic.present ? data.isPublic.value : this.isPublic,
      isCustomTitle: data.isCustomTitle.present
          ? data.isCustomTitle.value
          : this.isCustomTitle,
      learnTermLimit: data.learnTermLimit.present
          ? data.learnTermLimit.value
          : this.learnTermLimit,
      testQuestionLimit: data.testQuestionLimit.present
          ? data.testQuestionLimit.value
          : this.testQuestionLimit,
      matchPairLimit: data.matchPairLimit.present
          ? data.matchPairLimit.value
          : this.matchPairLimit,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserLessonData(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('tags: $tags, ')
          ..write('isPublic: $isPublic, ')
          ..write('isCustomTitle: $isCustomTitle, ')
          ..write('learnTermLimit: $learnTermLimit, ')
          ..write('testQuestionLimit: $testQuestionLimit, ')
          ..write('matchPairLimit: $matchPairLimit, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    level,
    title,
    description,
    tags,
    isPublic,
    isCustomTitle,
    learnTermLimit,
    testQuestionLimit,
    matchPairLimit,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserLessonData &&
          other.id == this.id &&
          other.level == this.level &&
          other.title == this.title &&
          other.description == this.description &&
          other.tags == this.tags &&
          other.isPublic == this.isPublic &&
          other.isCustomTitle == this.isCustomTitle &&
          other.learnTermLimit == this.learnTermLimit &&
          other.testQuestionLimit == this.testQuestionLimit &&
          other.matchPairLimit == this.matchPairLimit &&
          other.updatedAt == this.updatedAt);
}

class UserLessonCompanion extends UpdateCompanion<UserLessonData> {
  final Value<int> id;
  final Value<String> level;
  final Value<String> title;
  final Value<String> description;
  final Value<String> tags;
  final Value<bool> isPublic;
  final Value<bool> isCustomTitle;
  final Value<int> learnTermLimit;
  final Value<int> testQuestionLimit;
  final Value<int> matchPairLimit;
  final Value<DateTime?> updatedAt;
  const UserLessonCompanion({
    this.id = const Value.absent(),
    this.level = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.tags = const Value.absent(),
    this.isPublic = const Value.absent(),
    this.isCustomTitle = const Value.absent(),
    this.learnTermLimit = const Value.absent(),
    this.testQuestionLimit = const Value.absent(),
    this.matchPairLimit = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserLessonCompanion.insert({
    this.id = const Value.absent(),
    required String level,
    required String title,
    this.description = const Value.absent(),
    this.tags = const Value.absent(),
    this.isPublic = const Value.absent(),
    this.isCustomTitle = const Value.absent(),
    this.learnTermLimit = const Value.absent(),
    this.testQuestionLimit = const Value.absent(),
    this.matchPairLimit = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : level = Value(level),
       title = Value(title);
  static Insertable<UserLessonData> custom({
    Expression<int>? id,
    Expression<String>? level,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? tags,
    Expression<bool>? isPublic,
    Expression<bool>? isCustomTitle,
    Expression<int>? learnTermLimit,
    Expression<int>? testQuestionLimit,
    Expression<int>? matchPairLimit,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (level != null) 'level': level,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (tags != null) 'tags': tags,
      if (isPublic != null) 'is_public': isPublic,
      if (isCustomTitle != null) 'is_custom_title': isCustomTitle,
      if (learnTermLimit != null) 'learn_term_limit': learnTermLimit,
      if (testQuestionLimit != null) 'test_question_limit': testQuestionLimit,
      if (matchPairLimit != null) 'match_pair_limit': matchPairLimit,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserLessonCompanion copyWith({
    Value<int>? id,
    Value<String>? level,
    Value<String>? title,
    Value<String>? description,
    Value<String>? tags,
    Value<bool>? isPublic,
    Value<bool>? isCustomTitle,
    Value<int>? learnTermLimit,
    Value<int>? testQuestionLimit,
    Value<int>? matchPairLimit,
    Value<DateTime?>? updatedAt,
  }) {
    return UserLessonCompanion(
      id: id ?? this.id,
      level: level ?? this.level,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
      isCustomTitle: isCustomTitle ?? this.isCustomTitle,
      learnTermLimit: learnTermLimit ?? this.learnTermLimit,
      testQuestionLimit: testQuestionLimit ?? this.testQuestionLimit,
      matchPairLimit: matchPairLimit ?? this.matchPairLimit,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (isPublic.present) {
      map['is_public'] = Variable<bool>(isPublic.value);
    }
    if (isCustomTitle.present) {
      map['is_custom_title'] = Variable<bool>(isCustomTitle.value);
    }
    if (learnTermLimit.present) {
      map['learn_term_limit'] = Variable<int>(learnTermLimit.value);
    }
    if (testQuestionLimit.present) {
      map['test_question_limit'] = Variable<int>(testQuestionLimit.value);
    }
    if (matchPairLimit.present) {
      map['match_pair_limit'] = Variable<int>(matchPairLimit.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserLessonCompanion(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('tags: $tags, ')
          ..write('isPublic: $isPublic, ')
          ..write('isCustomTitle: $isCustomTitle, ')
          ..write('learnTermLimit: $learnTermLimit, ')
          ..write('testQuestionLimit: $testQuestionLimit, ')
          ..write('matchPairLimit: $matchPairLimit, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $UserLessonTermTable extends UserLessonTerm
    with TableInfo<$UserLessonTermTable, UserLessonTermData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserLessonTermTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_lesson (id)',
    ),
  );
  static const VerificationMeta _termMeta = const VerificationMeta('term');
  @override
  late final GeneratedColumn<String> term = GeneratedColumn<String>(
    'term',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _readingMeta = const VerificationMeta(
    'reading',
  );
  @override
  late final GeneratedColumn<String> reading = GeneratedColumn<String>(
    'reading',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _definitionMeta = const VerificationMeta(
    'definition',
  );
  @override
  late final GeneratedColumn<String> definition = GeneratedColumn<String>(
    'definition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _definitionEnMeta = const VerificationMeta(
    'definitionEn',
  );
  @override
  late final GeneratedColumn<String> definitionEn = GeneratedColumn<String>(
    'definition_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _mnemonicViMeta = const VerificationMeta(
    'mnemonicVi',
  );
  @override
  late final GeneratedColumn<String> mnemonicVi = GeneratedColumn<String>(
    'mnemonic_vi',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _mnemonicEnMeta = const VerificationMeta(
    'mnemonicEn',
  );
  @override
  late final GeneratedColumn<String> mnemonicEn = GeneratedColumn<String>(
    'mnemonic_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _kanjiMeaningMeta = const VerificationMeta(
    'kanjiMeaning',
  );
  @override
  late final GeneratedColumn<String> kanjiMeaning = GeneratedColumn<String>(
    'kanji_meaning',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isStarredMeta = const VerificationMeta(
    'isStarred',
  );
  @override
  late final GeneratedColumn<bool> isStarred = GeneratedColumn<bool>(
    'is_starred',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_starred" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isLearnedMeta = const VerificationMeta(
    'isLearned',
  );
  @override
  late final GeneratedColumn<bool> isLearned = GeneratedColumn<bool>(
    'is_learned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_learned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lessonId,
    term,
    reading,
    definition,
    definitionEn,
    mnemonicVi,
    mnemonicEn,
    kanjiMeaning,
    isStarred,
    isLearned,
    orderIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_lesson_term';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserLessonTermData> instance, {
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
    if (data.containsKey('term')) {
      context.handle(
        _termMeta,
        term.isAcceptableOrUnknown(data['term']!, _termMeta),
      );
    }
    if (data.containsKey('reading')) {
      context.handle(
        _readingMeta,
        reading.isAcceptableOrUnknown(data['reading']!, _readingMeta),
      );
    }
    if (data.containsKey('definition')) {
      context.handle(
        _definitionMeta,
        definition.isAcceptableOrUnknown(data['definition']!, _definitionMeta),
      );
    }
    if (data.containsKey('definition_en')) {
      context.handle(
        _definitionEnMeta,
        definitionEn.isAcceptableOrUnknown(
          data['definition_en']!,
          _definitionEnMeta,
        ),
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
    if (data.containsKey('kanji_meaning')) {
      context.handle(
        _kanjiMeaningMeta,
        kanjiMeaning.isAcceptableOrUnknown(
          data['kanji_meaning']!,
          _kanjiMeaningMeta,
        ),
      );
    }
    if (data.containsKey('is_starred')) {
      context.handle(
        _isStarredMeta,
        isStarred.isAcceptableOrUnknown(data['is_starred']!, _isStarredMeta),
      );
    }
    if (data.containsKey('is_learned')) {
      context.handle(
        _isLearnedMeta,
        isLearned.isAcceptableOrUnknown(data['is_learned']!, _isLearnedMeta),
      );
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserLessonTermData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserLessonTermData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lesson_id'],
      )!,
      term: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term'],
      )!,
      reading: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reading'],
      )!,
      definition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition'],
      )!,
      definitionEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition_en'],
      )!,
      mnemonicVi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mnemonic_vi'],
      )!,
      mnemonicEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mnemonic_en'],
      )!,
      kanjiMeaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kanji_meaning'],
      )!,
      isStarred: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_starred'],
      )!,
      isLearned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_learned'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
    );
  }

  @override
  $UserLessonTermTable createAlias(String alias) {
    return $UserLessonTermTable(attachedDatabase, alias);
  }
}

class UserLessonTermData extends DataClass
    implements Insertable<UserLessonTermData> {
  final int id;
  final int lessonId;
  final String term;
  final String reading;
  final String definition;
  final String definitionEn;
  final String mnemonicVi;
  final String mnemonicEn;
  final String kanjiMeaning;
  final bool isStarred;
  final bool isLearned;
  final int orderIndex;
  const UserLessonTermData({
    required this.id,
    required this.lessonId,
    required this.term,
    required this.reading,
    required this.definition,
    required this.definitionEn,
    required this.mnemonicVi,
    required this.mnemonicEn,
    required this.kanjiMeaning,
    required this.isStarred,
    required this.isLearned,
    required this.orderIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['lesson_id'] = Variable<int>(lessonId);
    map['term'] = Variable<String>(term);
    map['reading'] = Variable<String>(reading);
    map['definition'] = Variable<String>(definition);
    map['definition_en'] = Variable<String>(definitionEn);
    map['mnemonic_vi'] = Variable<String>(mnemonicVi);
    map['mnemonic_en'] = Variable<String>(mnemonicEn);
    map['kanji_meaning'] = Variable<String>(kanjiMeaning);
    map['is_starred'] = Variable<bool>(isStarred);
    map['is_learned'] = Variable<bool>(isLearned);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  UserLessonTermCompanion toCompanion(bool nullToAbsent) {
    return UserLessonTermCompanion(
      id: Value(id),
      lessonId: Value(lessonId),
      term: Value(term),
      reading: Value(reading),
      definition: Value(definition),
      definitionEn: Value(definitionEn),
      mnemonicVi: Value(mnemonicVi),
      mnemonicEn: Value(mnemonicEn),
      kanjiMeaning: Value(kanjiMeaning),
      isStarred: Value(isStarred),
      isLearned: Value(isLearned),
      orderIndex: Value(orderIndex),
    );
  }

  factory UserLessonTermData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserLessonTermData(
      id: serializer.fromJson<int>(json['id']),
      lessonId: serializer.fromJson<int>(json['lessonId']),
      term: serializer.fromJson<String>(json['term']),
      reading: serializer.fromJson<String>(json['reading']),
      definition: serializer.fromJson<String>(json['definition']),
      definitionEn: serializer.fromJson<String>(json['definitionEn']),
      mnemonicVi: serializer.fromJson<String>(json['mnemonicVi']),
      mnemonicEn: serializer.fromJson<String>(json['mnemonicEn']),
      kanjiMeaning: serializer.fromJson<String>(json['kanjiMeaning']),
      isStarred: serializer.fromJson<bool>(json['isStarred']),
      isLearned: serializer.fromJson<bool>(json['isLearned']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lessonId': serializer.toJson<int>(lessonId),
      'term': serializer.toJson<String>(term),
      'reading': serializer.toJson<String>(reading),
      'definition': serializer.toJson<String>(definition),
      'definitionEn': serializer.toJson<String>(definitionEn),
      'mnemonicVi': serializer.toJson<String>(mnemonicVi),
      'mnemonicEn': serializer.toJson<String>(mnemonicEn),
      'kanjiMeaning': serializer.toJson<String>(kanjiMeaning),
      'isStarred': serializer.toJson<bool>(isStarred),
      'isLearned': serializer.toJson<bool>(isLearned),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  UserLessonTermData copyWith({
    int? id,
    int? lessonId,
    String? term,
    String? reading,
    String? definition,
    String? definitionEn,
    String? mnemonicVi,
    String? mnemonicEn,
    String? kanjiMeaning,
    bool? isStarred,
    bool? isLearned,
    int? orderIndex,
  }) => UserLessonTermData(
    id: id ?? this.id,
    lessonId: lessonId ?? this.lessonId,
    term: term ?? this.term,
    reading: reading ?? this.reading,
    definition: definition ?? this.definition,
    definitionEn: definitionEn ?? this.definitionEn,
    mnemonicVi: mnemonicVi ?? this.mnemonicVi,
    mnemonicEn: mnemonicEn ?? this.mnemonicEn,
    kanjiMeaning: kanjiMeaning ?? this.kanjiMeaning,
    isStarred: isStarred ?? this.isStarred,
    isLearned: isLearned ?? this.isLearned,
    orderIndex: orderIndex ?? this.orderIndex,
  );
  UserLessonTermData copyWithCompanion(UserLessonTermCompanion data) {
    return UserLessonTermData(
      id: data.id.present ? data.id.value : this.id,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      term: data.term.present ? data.term.value : this.term,
      reading: data.reading.present ? data.reading.value : this.reading,
      definition: data.definition.present
          ? data.definition.value
          : this.definition,
      definitionEn: data.definitionEn.present
          ? data.definitionEn.value
          : this.definitionEn,
      mnemonicVi: data.mnemonicVi.present
          ? data.mnemonicVi.value
          : this.mnemonicVi,
      mnemonicEn: data.mnemonicEn.present
          ? data.mnemonicEn.value
          : this.mnemonicEn,
      kanjiMeaning: data.kanjiMeaning.present
          ? data.kanjiMeaning.value
          : this.kanjiMeaning,
      isStarred: data.isStarred.present ? data.isStarred.value : this.isStarred,
      isLearned: data.isLearned.present ? data.isLearned.value : this.isLearned,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserLessonTermData(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('term: $term, ')
          ..write('reading: $reading, ')
          ..write('definition: $definition, ')
          ..write('definitionEn: $definitionEn, ')
          ..write('mnemonicVi: $mnemonicVi, ')
          ..write('mnemonicEn: $mnemonicEn, ')
          ..write('kanjiMeaning: $kanjiMeaning, ')
          ..write('isStarred: $isStarred, ')
          ..write('isLearned: $isLearned, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lessonId,
    term,
    reading,
    definition,
    definitionEn,
    mnemonicVi,
    mnemonicEn,
    kanjiMeaning,
    isStarred,
    isLearned,
    orderIndex,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserLessonTermData &&
          other.id == this.id &&
          other.lessonId == this.lessonId &&
          other.term == this.term &&
          other.reading == this.reading &&
          other.definition == this.definition &&
          other.definitionEn == this.definitionEn &&
          other.mnemonicVi == this.mnemonicVi &&
          other.mnemonicEn == this.mnemonicEn &&
          other.kanjiMeaning == this.kanjiMeaning &&
          other.isStarred == this.isStarred &&
          other.isLearned == this.isLearned &&
          other.orderIndex == this.orderIndex);
}

class UserLessonTermCompanion extends UpdateCompanion<UserLessonTermData> {
  final Value<int> id;
  final Value<int> lessonId;
  final Value<String> term;
  final Value<String> reading;
  final Value<String> definition;
  final Value<String> definitionEn;
  final Value<String> mnemonicVi;
  final Value<String> mnemonicEn;
  final Value<String> kanjiMeaning;
  final Value<bool> isStarred;
  final Value<bool> isLearned;
  final Value<int> orderIndex;
  const UserLessonTermCompanion({
    this.id = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.term = const Value.absent(),
    this.reading = const Value.absent(),
    this.definition = const Value.absent(),
    this.definitionEn = const Value.absent(),
    this.mnemonicVi = const Value.absent(),
    this.mnemonicEn = const Value.absent(),
    this.kanjiMeaning = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.isLearned = const Value.absent(),
    this.orderIndex = const Value.absent(),
  });
  UserLessonTermCompanion.insert({
    this.id = const Value.absent(),
    required int lessonId,
    this.term = const Value.absent(),
    this.reading = const Value.absent(),
    this.definition = const Value.absent(),
    this.definitionEn = const Value.absent(),
    this.mnemonicVi = const Value.absent(),
    this.mnemonicEn = const Value.absent(),
    this.kanjiMeaning = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.isLearned = const Value.absent(),
    this.orderIndex = const Value.absent(),
  }) : lessonId = Value(lessonId);
  static Insertable<UserLessonTermData> custom({
    Expression<int>? id,
    Expression<int>? lessonId,
    Expression<String>? term,
    Expression<String>? reading,
    Expression<String>? definition,
    Expression<String>? definitionEn,
    Expression<String>? mnemonicVi,
    Expression<String>? mnemonicEn,
    Expression<String>? kanjiMeaning,
    Expression<bool>? isStarred,
    Expression<bool>? isLearned,
    Expression<int>? orderIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lessonId != null) 'lesson_id': lessonId,
      if (term != null) 'term': term,
      if (reading != null) 'reading': reading,
      if (definition != null) 'definition': definition,
      if (definitionEn != null) 'definition_en': definitionEn,
      if (mnemonicVi != null) 'mnemonic_vi': mnemonicVi,
      if (mnemonicEn != null) 'mnemonic_en': mnemonicEn,
      if (kanjiMeaning != null) 'kanji_meaning': kanjiMeaning,
      if (isStarred != null) 'is_starred': isStarred,
      if (isLearned != null) 'is_learned': isLearned,
      if (orderIndex != null) 'order_index': orderIndex,
    });
  }

  UserLessonTermCompanion copyWith({
    Value<int>? id,
    Value<int>? lessonId,
    Value<String>? term,
    Value<String>? reading,
    Value<String>? definition,
    Value<String>? definitionEn,
    Value<String>? mnemonicVi,
    Value<String>? mnemonicEn,
    Value<String>? kanjiMeaning,
    Value<bool>? isStarred,
    Value<bool>? isLearned,
    Value<int>? orderIndex,
  }) {
    return UserLessonTermCompanion(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      term: term ?? this.term,
      reading: reading ?? this.reading,
      definition: definition ?? this.definition,
      definitionEn: definitionEn ?? this.definitionEn,
      mnemonicVi: mnemonicVi ?? this.mnemonicVi,
      mnemonicEn: mnemonicEn ?? this.mnemonicEn,
      kanjiMeaning: kanjiMeaning ?? this.kanjiMeaning,
      isStarred: isStarred ?? this.isStarred,
      isLearned: isLearned ?? this.isLearned,
      orderIndex: orderIndex ?? this.orderIndex,
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
    if (term.present) {
      map['term'] = Variable<String>(term.value);
    }
    if (reading.present) {
      map['reading'] = Variable<String>(reading.value);
    }
    if (definition.present) {
      map['definition'] = Variable<String>(definition.value);
    }
    if (definitionEn.present) {
      map['definition_en'] = Variable<String>(definitionEn.value);
    }
    if (mnemonicVi.present) {
      map['mnemonic_vi'] = Variable<String>(mnemonicVi.value);
    }
    if (mnemonicEn.present) {
      map['mnemonic_en'] = Variable<String>(mnemonicEn.value);
    }
    if (kanjiMeaning.present) {
      map['kanji_meaning'] = Variable<String>(kanjiMeaning.value);
    }
    if (isStarred.present) {
      map['is_starred'] = Variable<bool>(isStarred.value);
    }
    if (isLearned.present) {
      map['is_learned'] = Variable<bool>(isLearned.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserLessonTermCompanion(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('term: $term, ')
          ..write('reading: $reading, ')
          ..write('definition: $definition, ')
          ..write('definitionEn: $definitionEn, ')
          ..write('mnemonicVi: $mnemonicVi, ')
          ..write('mnemonicEn: $mnemonicEn, ')
          ..write('kanjiMeaning: $kanjiMeaning, ')
          ..write('isStarred: $isStarred, ')
          ..write('isLearned: $isLearned, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }
}

class $LearnSessionsTable extends LearnSessions
    with TableInfo<$LearnSessionsTable, LearnSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LearnSessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalQuestionsMeta = const VerificationMeta(
    'totalQuestions',
  );
  @override
  late final GeneratedColumn<int> totalQuestions = GeneratedColumn<int>(
    'total_questions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _wrongCountMeta = const VerificationMeta(
    'wrongCount',
  );
  @override
  late final GeneratedColumn<int> wrongCount = GeneratedColumn<int>(
    'wrong_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currentRoundMeta = const VerificationMeta(
    'currentRound',
  );
  @override
  late final GeneratedColumn<int> currentRound = GeneratedColumn<int>(
    'current_round',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _xpEarnedMeta = const VerificationMeta(
    'xpEarned',
  );
  @override
  late final GeneratedColumn<int> xpEarned = GeneratedColumn<int>(
    'xp_earned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isPerfectMeta = const VerificationMeta(
    'isPerfect',
  );
  @override
  late final GeneratedColumn<bool> isPerfect = GeneratedColumn<bool>(
    'is_perfect',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_perfect" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    lessonId,
    startedAt,
    completedAt,
    totalQuestions,
    correctCount,
    wrongCount,
    currentRound,
    xpEarned,
    isPerfect,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'learn_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LearnSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('total_questions')) {
      context.handle(
        _totalQuestionsMeta,
        totalQuestions.isAcceptableOrUnknown(
          data['total_questions']!,
          _totalQuestionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalQuestionsMeta);
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
    if (data.containsKey('wrong_count')) {
      context.handle(
        _wrongCountMeta,
        wrongCount.isAcceptableOrUnknown(data['wrong_count']!, _wrongCountMeta),
      );
    }
    if (data.containsKey('current_round')) {
      context.handle(
        _currentRoundMeta,
        currentRound.isAcceptableOrUnknown(
          data['current_round']!,
          _currentRoundMeta,
        ),
      );
    }
    if (data.containsKey('xp_earned')) {
      context.handle(
        _xpEarnedMeta,
        xpEarned.isAcceptableOrUnknown(data['xp_earned']!, _xpEarnedMeta),
      );
    }
    if (data.containsKey('is_perfect')) {
      context.handle(
        _isPerfectMeta,
        isPerfect.isAcceptableOrUnknown(data['is_perfect']!, _isPerfectMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LearnSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LearnSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lesson_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      totalQuestions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_questions'],
      )!,
      correctCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_count'],
      )!,
      wrongCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wrong_count'],
      )!,
      currentRound: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_round'],
      )!,
      xpEarned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_earned'],
      )!,
      isPerfect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_perfect'],
      )!,
    );
  }

  @override
  $LearnSessionsTable createAlias(String alias) {
    return $LearnSessionsTable(attachedDatabase, alias);
  }
}

class LearnSession extends DataClass implements Insertable<LearnSession> {
  final int id;
  final String sessionId;
  final int lessonId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int totalQuestions;
  final int correctCount;
  final int wrongCount;
  final int currentRound;
  final int xpEarned;
  final bool isPerfect;
  const LearnSession({
    required this.id,
    required this.sessionId,
    required this.lessonId,
    required this.startedAt,
    this.completedAt,
    required this.totalQuestions,
    required this.correctCount,
    required this.wrongCount,
    required this.currentRound,
    required this.xpEarned,
    required this.isPerfect,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['lesson_id'] = Variable<int>(lessonId);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['total_questions'] = Variable<int>(totalQuestions);
    map['correct_count'] = Variable<int>(correctCount);
    map['wrong_count'] = Variable<int>(wrongCount);
    map['current_round'] = Variable<int>(currentRound);
    map['xp_earned'] = Variable<int>(xpEarned);
    map['is_perfect'] = Variable<bool>(isPerfect);
    return map;
  }

  LearnSessionsCompanion toCompanion(bool nullToAbsent) {
    return LearnSessionsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      lessonId: Value(lessonId),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      totalQuestions: Value(totalQuestions),
      correctCount: Value(correctCount),
      wrongCount: Value(wrongCount),
      currentRound: Value(currentRound),
      xpEarned: Value(xpEarned),
      isPerfect: Value(isPerfect),
    );
  }

  factory LearnSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LearnSession(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      lessonId: serializer.fromJson<int>(json['lessonId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      totalQuestions: serializer.fromJson<int>(json['totalQuestions']),
      correctCount: serializer.fromJson<int>(json['correctCount']),
      wrongCount: serializer.fromJson<int>(json['wrongCount']),
      currentRound: serializer.fromJson<int>(json['currentRound']),
      xpEarned: serializer.fromJson<int>(json['xpEarned']),
      isPerfect: serializer.fromJson<bool>(json['isPerfect']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'lessonId': serializer.toJson<int>(lessonId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'totalQuestions': serializer.toJson<int>(totalQuestions),
      'correctCount': serializer.toJson<int>(correctCount),
      'wrongCount': serializer.toJson<int>(wrongCount),
      'currentRound': serializer.toJson<int>(currentRound),
      'xpEarned': serializer.toJson<int>(xpEarned),
      'isPerfect': serializer.toJson<bool>(isPerfect),
    };
  }

  LearnSession copyWith({
    int? id,
    String? sessionId,
    int? lessonId,
    DateTime? startedAt,
    Value<DateTime?> completedAt = const Value.absent(),
    int? totalQuestions,
    int? correctCount,
    int? wrongCount,
    int? currentRound,
    int? xpEarned,
    bool? isPerfect,
  }) => LearnSession(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    lessonId: lessonId ?? this.lessonId,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    totalQuestions: totalQuestions ?? this.totalQuestions,
    correctCount: correctCount ?? this.correctCount,
    wrongCount: wrongCount ?? this.wrongCount,
    currentRound: currentRound ?? this.currentRound,
    xpEarned: xpEarned ?? this.xpEarned,
    isPerfect: isPerfect ?? this.isPerfect,
  );
  LearnSession copyWithCompanion(LearnSessionsCompanion data) {
    return LearnSession(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      totalQuestions: data.totalQuestions.present
          ? data.totalQuestions.value
          : this.totalQuestions,
      correctCount: data.correctCount.present
          ? data.correctCount.value
          : this.correctCount,
      wrongCount: data.wrongCount.present
          ? data.wrongCount.value
          : this.wrongCount,
      currentRound: data.currentRound.present
          ? data.currentRound.value
          : this.currentRound,
      xpEarned: data.xpEarned.present ? data.xpEarned.value : this.xpEarned,
      isPerfect: data.isPerfect.present ? data.isPerfect.value : this.isPerfect,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LearnSession(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('lessonId: $lessonId, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('correctCount: $correctCount, ')
          ..write('wrongCount: $wrongCount, ')
          ..write('currentRound: $currentRound, ')
          ..write('xpEarned: $xpEarned, ')
          ..write('isPerfect: $isPerfect')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    lessonId,
    startedAt,
    completedAt,
    totalQuestions,
    correctCount,
    wrongCount,
    currentRound,
    xpEarned,
    isPerfect,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LearnSession &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.lessonId == this.lessonId &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.totalQuestions == this.totalQuestions &&
          other.correctCount == this.correctCount &&
          other.wrongCount == this.wrongCount &&
          other.currentRound == this.currentRound &&
          other.xpEarned == this.xpEarned &&
          other.isPerfect == this.isPerfect);
}

class LearnSessionsCompanion extends UpdateCompanion<LearnSession> {
  final Value<int> id;
  final Value<String> sessionId;
  final Value<int> lessonId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<int> totalQuestions;
  final Value<int> correctCount;
  final Value<int> wrongCount;
  final Value<int> currentRound;
  final Value<int> xpEarned;
  final Value<bool> isPerfect;
  const LearnSessionsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.totalQuestions = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.wrongCount = const Value.absent(),
    this.currentRound = const Value.absent(),
    this.xpEarned = const Value.absent(),
    this.isPerfect = const Value.absent(),
  });
  LearnSessionsCompanion.insert({
    this.id = const Value.absent(),
    required String sessionId,
    required int lessonId,
    required DateTime startedAt,
    this.completedAt = const Value.absent(),
    required int totalQuestions,
    this.correctCount = const Value.absent(),
    this.wrongCount = const Value.absent(),
    this.currentRound = const Value.absent(),
    this.xpEarned = const Value.absent(),
    this.isPerfect = const Value.absent(),
  }) : sessionId = Value(sessionId),
       lessonId = Value(lessonId),
       startedAt = Value(startedAt),
       totalQuestions = Value(totalQuestions);
  static Insertable<LearnSession> custom({
    Expression<int>? id,
    Expression<String>? sessionId,
    Expression<int>? lessonId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? totalQuestions,
    Expression<int>? correctCount,
    Expression<int>? wrongCount,
    Expression<int>? currentRound,
    Expression<int>? xpEarned,
    Expression<bool>? isPerfect,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (lessonId != null) 'lesson_id': lessonId,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (totalQuestions != null) 'total_questions': totalQuestions,
      if (correctCount != null) 'correct_count': correctCount,
      if (wrongCount != null) 'wrong_count': wrongCount,
      if (currentRound != null) 'current_round': currentRound,
      if (xpEarned != null) 'xp_earned': xpEarned,
      if (isPerfect != null) 'is_perfect': isPerfect,
    });
  }

  LearnSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? sessionId,
    Value<int>? lessonId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? completedAt,
    Value<int>? totalQuestions,
    Value<int>? correctCount,
    Value<int>? wrongCount,
    Value<int>? currentRound,
    Value<int>? xpEarned,
    Value<bool>? isPerfect,
  }) {
    return LearnSessionsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      lessonId: lessonId ?? this.lessonId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      currentRound: currentRound ?? this.currentRound,
      xpEarned: xpEarned ?? this.xpEarned,
      isPerfect: isPerfect ?? this.isPerfect,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<int>(lessonId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (totalQuestions.present) {
      map['total_questions'] = Variable<int>(totalQuestions.value);
    }
    if (correctCount.present) {
      map['correct_count'] = Variable<int>(correctCount.value);
    }
    if (wrongCount.present) {
      map['wrong_count'] = Variable<int>(wrongCount.value);
    }
    if (currentRound.present) {
      map['current_round'] = Variable<int>(currentRound.value);
    }
    if (xpEarned.present) {
      map['xp_earned'] = Variable<int>(xpEarned.value);
    }
    if (isPerfect.present) {
      map['is_perfect'] = Variable<bool>(isPerfect.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LearnSessionsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('lessonId: $lessonId, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('correctCount: $correctCount, ')
          ..write('wrongCount: $wrongCount, ')
          ..write('currentRound: $currentRound, ')
          ..write('xpEarned: $xpEarned, ')
          ..write('isPerfect: $isPerfect')
          ..write(')'))
        .toString();
  }
}

class $LearnAnswersTable extends LearnAnswers
    with TableInfo<$LearnAnswersTable, LearnAnswer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LearnAnswersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES learn_sessions (session_id)',
    ),
  );
  static const VerificationMeta _questionIndexMeta = const VerificationMeta(
    'questionIndex',
  );
  @override
  late final GeneratedColumn<int> questionIndex = GeneratedColumn<int>(
    'question_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _termIdMeta = const VerificationMeta('termId');
  @override
  late final GeneratedColumn<int> termId = GeneratedColumn<int>(
    'term_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionTypeMeta = const VerificationMeta(
    'questionType',
  );
  @override
  late final GeneratedColumn<String> questionType = GeneratedColumn<String>(
    'question_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userAnswerMeta = const VerificationMeta(
    'userAnswer',
  );
  @override
  late final GeneratedColumn<String> userAnswer = GeneratedColumn<String>(
    'user_answer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCorrectMeta = const VerificationMeta(
    'isCorrect',
  );
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
    'is_correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _timeTakenMsMeta = const VerificationMeta(
    'timeTakenMs',
  );
  @override
  late final GeneratedColumn<int> timeTakenMs = GeneratedColumn<int>(
    'time_taken_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answeredAtMeta = const VerificationMeta(
    'answeredAt',
  );
  @override
  late final GeneratedColumn<DateTime> answeredAt = GeneratedColumn<DateTime>(
    'answered_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    questionIndex,
    termId,
    questionType,
    userAnswer,
    isCorrect,
    timeTakenMs,
    answeredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'learn_answers';
  @override
  VerificationContext validateIntegrity(
    Insertable<LearnAnswer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('question_index')) {
      context.handle(
        _questionIndexMeta,
        questionIndex.isAcceptableOrUnknown(
          data['question_index']!,
          _questionIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionIndexMeta);
    }
    if (data.containsKey('term_id')) {
      context.handle(
        _termIdMeta,
        termId.isAcceptableOrUnknown(data['term_id']!, _termIdMeta),
      );
    } else if (isInserting) {
      context.missing(_termIdMeta);
    }
    if (data.containsKey('question_type')) {
      context.handle(
        _questionTypeMeta,
        questionType.isAcceptableOrUnknown(
          data['question_type']!,
          _questionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionTypeMeta);
    }
    if (data.containsKey('user_answer')) {
      context.handle(
        _userAnswerMeta,
        userAnswer.isAcceptableOrUnknown(data['user_answer']!, _userAnswerMeta),
      );
    }
    if (data.containsKey('is_correct')) {
      context.handle(
        _isCorrectMeta,
        isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta),
      );
    } else if (isInserting) {
      context.missing(_isCorrectMeta);
    }
    if (data.containsKey('time_taken_ms')) {
      context.handle(
        _timeTakenMsMeta,
        timeTakenMs.isAcceptableOrUnknown(
          data['time_taken_ms']!,
          _timeTakenMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeTakenMsMeta);
    }
    if (data.containsKey('answered_at')) {
      context.handle(
        _answeredAtMeta,
        answeredAt.isAcceptableOrUnknown(data['answered_at']!, _answeredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_answeredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LearnAnswer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LearnAnswer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      questionIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_index'],
      )!,
      termId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}term_id'],
      )!,
      questionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_type'],
      )!,
      userAnswer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_answer'],
      ),
      isCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_correct'],
      )!,
      timeTakenMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_taken_ms'],
      )!,
      answeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}answered_at'],
      )!,
    );
  }

  @override
  $LearnAnswersTable createAlias(String alias) {
    return $LearnAnswersTable(attachedDatabase, alias);
  }
}

class LearnAnswer extends DataClass implements Insertable<LearnAnswer> {
  final int id;
  final String sessionId;
  final int questionIndex;
  final int termId;
  final String questionType;
  final String? userAnswer;
  final bool isCorrect;
  final int timeTakenMs;
  final DateTime answeredAt;
  const LearnAnswer({
    required this.id,
    required this.sessionId,
    required this.questionIndex,
    required this.termId,
    required this.questionType,
    this.userAnswer,
    required this.isCorrect,
    required this.timeTakenMs,
    required this.answeredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['question_index'] = Variable<int>(questionIndex);
    map['term_id'] = Variable<int>(termId);
    map['question_type'] = Variable<String>(questionType);
    if (!nullToAbsent || userAnswer != null) {
      map['user_answer'] = Variable<String>(userAnswer);
    }
    map['is_correct'] = Variable<bool>(isCorrect);
    map['time_taken_ms'] = Variable<int>(timeTakenMs);
    map['answered_at'] = Variable<DateTime>(answeredAt);
    return map;
  }

  LearnAnswersCompanion toCompanion(bool nullToAbsent) {
    return LearnAnswersCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      questionIndex: Value(questionIndex),
      termId: Value(termId),
      questionType: Value(questionType),
      userAnswer: userAnswer == null && nullToAbsent
          ? const Value.absent()
          : Value(userAnswer),
      isCorrect: Value(isCorrect),
      timeTakenMs: Value(timeTakenMs),
      answeredAt: Value(answeredAt),
    );
  }

  factory LearnAnswer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LearnAnswer(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      questionIndex: serializer.fromJson<int>(json['questionIndex']),
      termId: serializer.fromJson<int>(json['termId']),
      questionType: serializer.fromJson<String>(json['questionType']),
      userAnswer: serializer.fromJson<String?>(json['userAnswer']),
      isCorrect: serializer.fromJson<bool>(json['isCorrect']),
      timeTakenMs: serializer.fromJson<int>(json['timeTakenMs']),
      answeredAt: serializer.fromJson<DateTime>(json['answeredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'questionIndex': serializer.toJson<int>(questionIndex),
      'termId': serializer.toJson<int>(termId),
      'questionType': serializer.toJson<String>(questionType),
      'userAnswer': serializer.toJson<String?>(userAnswer),
      'isCorrect': serializer.toJson<bool>(isCorrect),
      'timeTakenMs': serializer.toJson<int>(timeTakenMs),
      'answeredAt': serializer.toJson<DateTime>(answeredAt),
    };
  }

  LearnAnswer copyWith({
    int? id,
    String? sessionId,
    int? questionIndex,
    int? termId,
    String? questionType,
    Value<String?> userAnswer = const Value.absent(),
    bool? isCorrect,
    int? timeTakenMs,
    DateTime? answeredAt,
  }) => LearnAnswer(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    questionIndex: questionIndex ?? this.questionIndex,
    termId: termId ?? this.termId,
    questionType: questionType ?? this.questionType,
    userAnswer: userAnswer.present ? userAnswer.value : this.userAnswer,
    isCorrect: isCorrect ?? this.isCorrect,
    timeTakenMs: timeTakenMs ?? this.timeTakenMs,
    answeredAt: answeredAt ?? this.answeredAt,
  );
  LearnAnswer copyWithCompanion(LearnAnswersCompanion data) {
    return LearnAnswer(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      questionIndex: data.questionIndex.present
          ? data.questionIndex.value
          : this.questionIndex,
      termId: data.termId.present ? data.termId.value : this.termId,
      questionType: data.questionType.present
          ? data.questionType.value
          : this.questionType,
      userAnswer: data.userAnswer.present
          ? data.userAnswer.value
          : this.userAnswer,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      timeTakenMs: data.timeTakenMs.present
          ? data.timeTakenMs.value
          : this.timeTakenMs,
      answeredAt: data.answeredAt.present
          ? data.answeredAt.value
          : this.answeredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LearnAnswer(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('questionIndex: $questionIndex, ')
          ..write('termId: $termId, ')
          ..write('questionType: $questionType, ')
          ..write('userAnswer: $userAnswer, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('timeTakenMs: $timeTakenMs, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    questionIndex,
    termId,
    questionType,
    userAnswer,
    isCorrect,
    timeTakenMs,
    answeredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LearnAnswer &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.questionIndex == this.questionIndex &&
          other.termId == this.termId &&
          other.questionType == this.questionType &&
          other.userAnswer == this.userAnswer &&
          other.isCorrect == this.isCorrect &&
          other.timeTakenMs == this.timeTakenMs &&
          other.answeredAt == this.answeredAt);
}

class LearnAnswersCompanion extends UpdateCompanion<LearnAnswer> {
  final Value<int> id;
  final Value<String> sessionId;
  final Value<int> questionIndex;
  final Value<int> termId;
  final Value<String> questionType;
  final Value<String?> userAnswer;
  final Value<bool> isCorrect;
  final Value<int> timeTakenMs;
  final Value<DateTime> answeredAt;
  const LearnAnswersCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.questionIndex = const Value.absent(),
    this.termId = const Value.absent(),
    this.questionType = const Value.absent(),
    this.userAnswer = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.timeTakenMs = const Value.absent(),
    this.answeredAt = const Value.absent(),
  });
  LearnAnswersCompanion.insert({
    this.id = const Value.absent(),
    required String sessionId,
    required int questionIndex,
    required int termId,
    required String questionType,
    this.userAnswer = const Value.absent(),
    required bool isCorrect,
    required int timeTakenMs,
    required DateTime answeredAt,
  }) : sessionId = Value(sessionId),
       questionIndex = Value(questionIndex),
       termId = Value(termId),
       questionType = Value(questionType),
       isCorrect = Value(isCorrect),
       timeTakenMs = Value(timeTakenMs),
       answeredAt = Value(answeredAt);
  static Insertable<LearnAnswer> custom({
    Expression<int>? id,
    Expression<String>? sessionId,
    Expression<int>? questionIndex,
    Expression<int>? termId,
    Expression<String>? questionType,
    Expression<String>? userAnswer,
    Expression<bool>? isCorrect,
    Expression<int>? timeTakenMs,
    Expression<DateTime>? answeredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (questionIndex != null) 'question_index': questionIndex,
      if (termId != null) 'term_id': termId,
      if (questionType != null) 'question_type': questionType,
      if (userAnswer != null) 'user_answer': userAnswer,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (timeTakenMs != null) 'time_taken_ms': timeTakenMs,
      if (answeredAt != null) 'answered_at': answeredAt,
    });
  }

  LearnAnswersCompanion copyWith({
    Value<int>? id,
    Value<String>? sessionId,
    Value<int>? questionIndex,
    Value<int>? termId,
    Value<String>? questionType,
    Value<String?>? userAnswer,
    Value<bool>? isCorrect,
    Value<int>? timeTakenMs,
    Value<DateTime>? answeredAt,
  }) {
    return LearnAnswersCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      questionIndex: questionIndex ?? this.questionIndex,
      termId: termId ?? this.termId,
      questionType: questionType ?? this.questionType,
      userAnswer: userAnswer ?? this.userAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      timeTakenMs: timeTakenMs ?? this.timeTakenMs,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (questionIndex.present) {
      map['question_index'] = Variable<int>(questionIndex.value);
    }
    if (termId.present) {
      map['term_id'] = Variable<int>(termId.value);
    }
    if (questionType.present) {
      map['question_type'] = Variable<String>(questionType.value);
    }
    if (userAnswer.present) {
      map['user_answer'] = Variable<String>(userAnswer.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    if (timeTakenMs.present) {
      map['time_taken_ms'] = Variable<int>(timeTakenMs.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<DateTime>(answeredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LearnAnswersCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('questionIndex: $questionIndex, ')
          ..write('termId: $termId, ')
          ..write('questionType: $questionType, ')
          ..write('userAnswer: $userAnswer, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('timeTakenMs: $timeTakenMs, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }
}

class $TestSessionsTable extends TestSessions
    with TableInfo<$TestSessionsTable, TestSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TestSessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalQuestionsMeta = const VerificationMeta(
    'totalQuestions',
  );
  @override
  late final GeneratedColumn<int> totalQuestions = GeneratedColumn<int>(
    'total_questions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wrongCountMeta = const VerificationMeta(
    'wrongCount',
  );
  @override
  late final GeneratedColumn<int> wrongCount = GeneratedColumn<int>(
    'wrong_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<String> grade = GeneratedColumn<String>(
    'grade',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _xpEarnedMeta = const VerificationMeta(
    'xpEarned',
  );
  @override
  late final GeneratedColumn<int> xpEarned = GeneratedColumn<int>(
    'xp_earned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeLimitMinutesMeta = const VerificationMeta(
    'timeLimitMinutes',
  );
  @override
  late final GeneratedColumn<int> timeLimitMinutes = GeneratedColumn<int>(
    'time_limit_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    lessonId,
    startedAt,
    completedAt,
    totalQuestions,
    correctCount,
    wrongCount,
    score,
    grade,
    xpEarned,
    timeLimitMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'test_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TestSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('total_questions')) {
      context.handle(
        _totalQuestionsMeta,
        totalQuestions.isAcceptableOrUnknown(
          data['total_questions']!,
          _totalQuestionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalQuestionsMeta);
    }
    if (data.containsKey('correct_count')) {
      context.handle(
        _correctCountMeta,
        correctCount.isAcceptableOrUnknown(
          data['correct_count']!,
          _correctCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctCountMeta);
    }
    if (data.containsKey('wrong_count')) {
      context.handle(
        _wrongCountMeta,
        wrongCount.isAcceptableOrUnknown(data['wrong_count']!, _wrongCountMeta),
      );
    } else if (isInserting) {
      context.missing(_wrongCountMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    } else if (isInserting) {
      context.missing(_gradeMeta);
    }
    if (data.containsKey('xp_earned')) {
      context.handle(
        _xpEarnedMeta,
        xpEarned.isAcceptableOrUnknown(data['xp_earned']!, _xpEarnedMeta),
      );
    } else if (isInserting) {
      context.missing(_xpEarnedMeta);
    }
    if (data.containsKey('time_limit_minutes')) {
      context.handle(
        _timeLimitMinutesMeta,
        timeLimitMinutes.isAcceptableOrUnknown(
          data['time_limit_minutes']!,
          _timeLimitMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TestSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TestSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lesson_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      totalQuestions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_questions'],
      )!,
      correctCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_count'],
      )!,
      wrongCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wrong_count'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grade'],
      )!,
      xpEarned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_earned'],
      )!,
      timeLimitMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_limit_minutes'],
      ),
    );
  }

  @override
  $TestSessionsTable createAlias(String alias) {
    return $TestSessionsTable(attachedDatabase, alias);
  }
}

class TestSession extends DataClass implements Insertable<TestSession> {
  final int id;
  final String sessionId;
  final int lessonId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int totalQuestions;
  final int correctCount;
  final int wrongCount;
  final int score;
  final String grade;
  final int xpEarned;
  final int? timeLimitMinutes;
  const TestSession({
    required this.id,
    required this.sessionId,
    required this.lessonId,
    required this.startedAt,
    this.completedAt,
    required this.totalQuestions,
    required this.correctCount,
    required this.wrongCount,
    required this.score,
    required this.grade,
    required this.xpEarned,
    this.timeLimitMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['lesson_id'] = Variable<int>(lessonId);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['total_questions'] = Variable<int>(totalQuestions);
    map['correct_count'] = Variable<int>(correctCount);
    map['wrong_count'] = Variable<int>(wrongCount);
    map['score'] = Variable<int>(score);
    map['grade'] = Variable<String>(grade);
    map['xp_earned'] = Variable<int>(xpEarned);
    if (!nullToAbsent || timeLimitMinutes != null) {
      map['time_limit_minutes'] = Variable<int>(timeLimitMinutes);
    }
    return map;
  }

  TestSessionsCompanion toCompanion(bool nullToAbsent) {
    return TestSessionsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      lessonId: Value(lessonId),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      totalQuestions: Value(totalQuestions),
      correctCount: Value(correctCount),
      wrongCount: Value(wrongCount),
      score: Value(score),
      grade: Value(grade),
      xpEarned: Value(xpEarned),
      timeLimitMinutes: timeLimitMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(timeLimitMinutes),
    );
  }

  factory TestSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TestSession(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      lessonId: serializer.fromJson<int>(json['lessonId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      totalQuestions: serializer.fromJson<int>(json['totalQuestions']),
      correctCount: serializer.fromJson<int>(json['correctCount']),
      wrongCount: serializer.fromJson<int>(json['wrongCount']),
      score: serializer.fromJson<int>(json['score']),
      grade: serializer.fromJson<String>(json['grade']),
      xpEarned: serializer.fromJson<int>(json['xpEarned']),
      timeLimitMinutes: serializer.fromJson<int?>(json['timeLimitMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'lessonId': serializer.toJson<int>(lessonId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'totalQuestions': serializer.toJson<int>(totalQuestions),
      'correctCount': serializer.toJson<int>(correctCount),
      'wrongCount': serializer.toJson<int>(wrongCount),
      'score': serializer.toJson<int>(score),
      'grade': serializer.toJson<String>(grade),
      'xpEarned': serializer.toJson<int>(xpEarned),
      'timeLimitMinutes': serializer.toJson<int?>(timeLimitMinutes),
    };
  }

  TestSession copyWith({
    int? id,
    String? sessionId,
    int? lessonId,
    DateTime? startedAt,
    Value<DateTime?> completedAt = const Value.absent(),
    int? totalQuestions,
    int? correctCount,
    int? wrongCount,
    int? score,
    String? grade,
    int? xpEarned,
    Value<int?> timeLimitMinutes = const Value.absent(),
  }) => TestSession(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    lessonId: lessonId ?? this.lessonId,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    totalQuestions: totalQuestions ?? this.totalQuestions,
    correctCount: correctCount ?? this.correctCount,
    wrongCount: wrongCount ?? this.wrongCount,
    score: score ?? this.score,
    grade: grade ?? this.grade,
    xpEarned: xpEarned ?? this.xpEarned,
    timeLimitMinutes: timeLimitMinutes.present
        ? timeLimitMinutes.value
        : this.timeLimitMinutes,
  );
  TestSession copyWithCompanion(TestSessionsCompanion data) {
    return TestSession(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      totalQuestions: data.totalQuestions.present
          ? data.totalQuestions.value
          : this.totalQuestions,
      correctCount: data.correctCount.present
          ? data.correctCount.value
          : this.correctCount,
      wrongCount: data.wrongCount.present
          ? data.wrongCount.value
          : this.wrongCount,
      score: data.score.present ? data.score.value : this.score,
      grade: data.grade.present ? data.grade.value : this.grade,
      xpEarned: data.xpEarned.present ? data.xpEarned.value : this.xpEarned,
      timeLimitMinutes: data.timeLimitMinutes.present
          ? data.timeLimitMinutes.value
          : this.timeLimitMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TestSession(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('lessonId: $lessonId, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('correctCount: $correctCount, ')
          ..write('wrongCount: $wrongCount, ')
          ..write('score: $score, ')
          ..write('grade: $grade, ')
          ..write('xpEarned: $xpEarned, ')
          ..write('timeLimitMinutes: $timeLimitMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    lessonId,
    startedAt,
    completedAt,
    totalQuestions,
    correctCount,
    wrongCount,
    score,
    grade,
    xpEarned,
    timeLimitMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TestSession &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.lessonId == this.lessonId &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.totalQuestions == this.totalQuestions &&
          other.correctCount == this.correctCount &&
          other.wrongCount == this.wrongCount &&
          other.score == this.score &&
          other.grade == this.grade &&
          other.xpEarned == this.xpEarned &&
          other.timeLimitMinutes == this.timeLimitMinutes);
}

class TestSessionsCompanion extends UpdateCompanion<TestSession> {
  final Value<int> id;
  final Value<String> sessionId;
  final Value<int> lessonId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<int> totalQuestions;
  final Value<int> correctCount;
  final Value<int> wrongCount;
  final Value<int> score;
  final Value<String> grade;
  final Value<int> xpEarned;
  final Value<int?> timeLimitMinutes;
  const TestSessionsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.totalQuestions = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.wrongCount = const Value.absent(),
    this.score = const Value.absent(),
    this.grade = const Value.absent(),
    this.xpEarned = const Value.absent(),
    this.timeLimitMinutes = const Value.absent(),
  });
  TestSessionsCompanion.insert({
    this.id = const Value.absent(),
    required String sessionId,
    required int lessonId,
    required DateTime startedAt,
    this.completedAt = const Value.absent(),
    required int totalQuestions,
    required int correctCount,
    required int wrongCount,
    required int score,
    required String grade,
    required int xpEarned,
    this.timeLimitMinutes = const Value.absent(),
  }) : sessionId = Value(sessionId),
       lessonId = Value(lessonId),
       startedAt = Value(startedAt),
       totalQuestions = Value(totalQuestions),
       correctCount = Value(correctCount),
       wrongCount = Value(wrongCount),
       score = Value(score),
       grade = Value(grade),
       xpEarned = Value(xpEarned);
  static Insertable<TestSession> custom({
    Expression<int>? id,
    Expression<String>? sessionId,
    Expression<int>? lessonId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? totalQuestions,
    Expression<int>? correctCount,
    Expression<int>? wrongCount,
    Expression<int>? score,
    Expression<String>? grade,
    Expression<int>? xpEarned,
    Expression<int>? timeLimitMinutes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (lessonId != null) 'lesson_id': lessonId,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (totalQuestions != null) 'total_questions': totalQuestions,
      if (correctCount != null) 'correct_count': correctCount,
      if (wrongCount != null) 'wrong_count': wrongCount,
      if (score != null) 'score': score,
      if (grade != null) 'grade': grade,
      if (xpEarned != null) 'xp_earned': xpEarned,
      if (timeLimitMinutes != null) 'time_limit_minutes': timeLimitMinutes,
    });
  }

  TestSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? sessionId,
    Value<int>? lessonId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? completedAt,
    Value<int>? totalQuestions,
    Value<int>? correctCount,
    Value<int>? wrongCount,
    Value<int>? score,
    Value<String>? grade,
    Value<int>? xpEarned,
    Value<int?>? timeLimitMinutes,
  }) {
    return TestSessionsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      lessonId: lessonId ?? this.lessonId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      score: score ?? this.score,
      grade: grade ?? this.grade,
      xpEarned: xpEarned ?? this.xpEarned,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<int>(lessonId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (totalQuestions.present) {
      map['total_questions'] = Variable<int>(totalQuestions.value);
    }
    if (correctCount.present) {
      map['correct_count'] = Variable<int>(correctCount.value);
    }
    if (wrongCount.present) {
      map['wrong_count'] = Variable<int>(wrongCount.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (grade.present) {
      map['grade'] = Variable<String>(grade.value);
    }
    if (xpEarned.present) {
      map['xp_earned'] = Variable<int>(xpEarned.value);
    }
    if (timeLimitMinutes.present) {
      map['time_limit_minutes'] = Variable<int>(timeLimitMinutes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TestSessionsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('lessonId: $lessonId, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('correctCount: $correctCount, ')
          ..write('wrongCount: $wrongCount, ')
          ..write('score: $score, ')
          ..write('grade: $grade, ')
          ..write('xpEarned: $xpEarned, ')
          ..write('timeLimitMinutes: $timeLimitMinutes')
          ..write(')'))
        .toString();
  }
}

class $TestAnswersTable extends TestAnswers
    with TableInfo<$TestAnswersTable, TestAnswer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TestAnswersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES test_sessions (session_id)',
    ),
  );
  static const VerificationMeta _questionIndexMeta = const VerificationMeta(
    'questionIndex',
  );
  @override
  late final GeneratedColumn<int> questionIndex = GeneratedColumn<int>(
    'question_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _termIdMeta = const VerificationMeta('termId');
  @override
  late final GeneratedColumn<int> termId = GeneratedColumn<int>(
    'term_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionTypeMeta = const VerificationMeta(
    'questionType',
  );
  @override
  late final GeneratedColumn<String> questionType = GeneratedColumn<String>(
    'question_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userAnswerMeta = const VerificationMeta(
    'userAnswer',
  );
  @override
  late final GeneratedColumn<String> userAnswer = GeneratedColumn<String>(
    'user_answer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCorrectMeta = const VerificationMeta(
    'isCorrect',
  );
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
    'is_correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _answeredAtMeta = const VerificationMeta(
    'answeredAt',
  );
  @override
  late final GeneratedColumn<DateTime> answeredAt = GeneratedColumn<DateTime>(
    'answered_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    questionIndex,
    termId,
    questionType,
    userAnswer,
    isCorrect,
    answeredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'test_answers';
  @override
  VerificationContext validateIntegrity(
    Insertable<TestAnswer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('question_index')) {
      context.handle(
        _questionIndexMeta,
        questionIndex.isAcceptableOrUnknown(
          data['question_index']!,
          _questionIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionIndexMeta);
    }
    if (data.containsKey('term_id')) {
      context.handle(
        _termIdMeta,
        termId.isAcceptableOrUnknown(data['term_id']!, _termIdMeta),
      );
    } else if (isInserting) {
      context.missing(_termIdMeta);
    }
    if (data.containsKey('question_type')) {
      context.handle(
        _questionTypeMeta,
        questionType.isAcceptableOrUnknown(
          data['question_type']!,
          _questionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionTypeMeta);
    }
    if (data.containsKey('user_answer')) {
      context.handle(
        _userAnswerMeta,
        userAnswer.isAcceptableOrUnknown(data['user_answer']!, _userAnswerMeta),
      );
    }
    if (data.containsKey('is_correct')) {
      context.handle(
        _isCorrectMeta,
        isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta),
      );
    } else if (isInserting) {
      context.missing(_isCorrectMeta);
    }
    if (data.containsKey('answered_at')) {
      context.handle(
        _answeredAtMeta,
        answeredAt.isAcceptableOrUnknown(data['answered_at']!, _answeredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_answeredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TestAnswer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TestAnswer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      questionIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_index'],
      )!,
      termId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}term_id'],
      )!,
      questionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_type'],
      )!,
      userAnswer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_answer'],
      ),
      isCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_correct'],
      )!,
      answeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}answered_at'],
      )!,
    );
  }

  @override
  $TestAnswersTable createAlias(String alias) {
    return $TestAnswersTable(attachedDatabase, alias);
  }
}

class TestAnswer extends DataClass implements Insertable<TestAnswer> {
  final int id;
  final String sessionId;
  final int questionIndex;
  final int termId;
  final String questionType;
  final String? userAnswer;
  final bool isCorrect;
  final DateTime answeredAt;
  const TestAnswer({
    required this.id,
    required this.sessionId,
    required this.questionIndex,
    required this.termId,
    required this.questionType,
    this.userAnswer,
    required this.isCorrect,
    required this.answeredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['question_index'] = Variable<int>(questionIndex);
    map['term_id'] = Variable<int>(termId);
    map['question_type'] = Variable<String>(questionType);
    if (!nullToAbsent || userAnswer != null) {
      map['user_answer'] = Variable<String>(userAnswer);
    }
    map['is_correct'] = Variable<bool>(isCorrect);
    map['answered_at'] = Variable<DateTime>(answeredAt);
    return map;
  }

  TestAnswersCompanion toCompanion(bool nullToAbsent) {
    return TestAnswersCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      questionIndex: Value(questionIndex),
      termId: Value(termId),
      questionType: Value(questionType),
      userAnswer: userAnswer == null && nullToAbsent
          ? const Value.absent()
          : Value(userAnswer),
      isCorrect: Value(isCorrect),
      answeredAt: Value(answeredAt),
    );
  }

  factory TestAnswer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TestAnswer(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      questionIndex: serializer.fromJson<int>(json['questionIndex']),
      termId: serializer.fromJson<int>(json['termId']),
      questionType: serializer.fromJson<String>(json['questionType']),
      userAnswer: serializer.fromJson<String?>(json['userAnswer']),
      isCorrect: serializer.fromJson<bool>(json['isCorrect']),
      answeredAt: serializer.fromJson<DateTime>(json['answeredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'questionIndex': serializer.toJson<int>(questionIndex),
      'termId': serializer.toJson<int>(termId),
      'questionType': serializer.toJson<String>(questionType),
      'userAnswer': serializer.toJson<String?>(userAnswer),
      'isCorrect': serializer.toJson<bool>(isCorrect),
      'answeredAt': serializer.toJson<DateTime>(answeredAt),
    };
  }

  TestAnswer copyWith({
    int? id,
    String? sessionId,
    int? questionIndex,
    int? termId,
    String? questionType,
    Value<String?> userAnswer = const Value.absent(),
    bool? isCorrect,
    DateTime? answeredAt,
  }) => TestAnswer(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    questionIndex: questionIndex ?? this.questionIndex,
    termId: termId ?? this.termId,
    questionType: questionType ?? this.questionType,
    userAnswer: userAnswer.present ? userAnswer.value : this.userAnswer,
    isCorrect: isCorrect ?? this.isCorrect,
    answeredAt: answeredAt ?? this.answeredAt,
  );
  TestAnswer copyWithCompanion(TestAnswersCompanion data) {
    return TestAnswer(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      questionIndex: data.questionIndex.present
          ? data.questionIndex.value
          : this.questionIndex,
      termId: data.termId.present ? data.termId.value : this.termId,
      questionType: data.questionType.present
          ? data.questionType.value
          : this.questionType,
      userAnswer: data.userAnswer.present
          ? data.userAnswer.value
          : this.userAnswer,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      answeredAt: data.answeredAt.present
          ? data.answeredAt.value
          : this.answeredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TestAnswer(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('questionIndex: $questionIndex, ')
          ..write('termId: $termId, ')
          ..write('questionType: $questionType, ')
          ..write('userAnswer: $userAnswer, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    questionIndex,
    termId,
    questionType,
    userAnswer,
    isCorrect,
    answeredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TestAnswer &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.questionIndex == this.questionIndex &&
          other.termId == this.termId &&
          other.questionType == this.questionType &&
          other.userAnswer == this.userAnswer &&
          other.isCorrect == this.isCorrect &&
          other.answeredAt == this.answeredAt);
}

class TestAnswersCompanion extends UpdateCompanion<TestAnswer> {
  final Value<int> id;
  final Value<String> sessionId;
  final Value<int> questionIndex;
  final Value<int> termId;
  final Value<String> questionType;
  final Value<String?> userAnswer;
  final Value<bool> isCorrect;
  final Value<DateTime> answeredAt;
  const TestAnswersCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.questionIndex = const Value.absent(),
    this.termId = const Value.absent(),
    this.questionType = const Value.absent(),
    this.userAnswer = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.answeredAt = const Value.absent(),
  });
  TestAnswersCompanion.insert({
    this.id = const Value.absent(),
    required String sessionId,
    required int questionIndex,
    required int termId,
    required String questionType,
    this.userAnswer = const Value.absent(),
    required bool isCorrect,
    required DateTime answeredAt,
  }) : sessionId = Value(sessionId),
       questionIndex = Value(questionIndex),
       termId = Value(termId),
       questionType = Value(questionType),
       isCorrect = Value(isCorrect),
       answeredAt = Value(answeredAt);
  static Insertable<TestAnswer> custom({
    Expression<int>? id,
    Expression<String>? sessionId,
    Expression<int>? questionIndex,
    Expression<int>? termId,
    Expression<String>? questionType,
    Expression<String>? userAnswer,
    Expression<bool>? isCorrect,
    Expression<DateTime>? answeredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (questionIndex != null) 'question_index': questionIndex,
      if (termId != null) 'term_id': termId,
      if (questionType != null) 'question_type': questionType,
      if (userAnswer != null) 'user_answer': userAnswer,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (answeredAt != null) 'answered_at': answeredAt,
    });
  }

  TestAnswersCompanion copyWith({
    Value<int>? id,
    Value<String>? sessionId,
    Value<int>? questionIndex,
    Value<int>? termId,
    Value<String>? questionType,
    Value<String?>? userAnswer,
    Value<bool>? isCorrect,
    Value<DateTime>? answeredAt,
  }) {
    return TestAnswersCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      questionIndex: questionIndex ?? this.questionIndex,
      termId: termId ?? this.termId,
      questionType: questionType ?? this.questionType,
      userAnswer: userAnswer ?? this.userAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (questionIndex.present) {
      map['question_index'] = Variable<int>(questionIndex.value);
    }
    if (termId.present) {
      map['term_id'] = Variable<int>(termId.value);
    }
    if (questionType.present) {
      map['question_type'] = Variable<String>(questionType.value);
    }
    if (userAnswer.present) {
      map['user_answer'] = Variable<String>(userAnswer.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<DateTime>(answeredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TestAnswersCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('questionIndex: $questionIndex, ')
          ..write('termId: $termId, ')
          ..write('questionType: $questionType, ')
          ..write('userAnswer: $userAnswer, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTable extends Achievements
    with TableInfo<$AchievementsTable, Achievement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<int> lessonId = GeneratedColumn<int>(
    'lesson_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _earnedAtMeta = const VerificationMeta(
    'earnedAt',
  );
  @override
  late final GeneratedColumn<DateTime> earnedAt = GeneratedColumn<DateTime>(
    'earned_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isNotifiedMeta = const VerificationMeta(
    'isNotified',
  );
  @override
  late final GeneratedColumn<bool> isNotified = GeneratedColumn<bool>(
    'is_notified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_notified" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    lessonId,
    sessionId,
    value,
    earnedAt,
    isNotified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Achievement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('earned_at')) {
      context.handle(
        _earnedAtMeta,
        earnedAt.isAcceptableOrUnknown(data['earned_at']!, _earnedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_earnedAtMeta);
    }
    if (data.containsKey('is_notified')) {
      context.handle(
        _isNotifiedMeta,
        isNotified.isAcceptableOrUnknown(data['is_notified']!, _isNotifiedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Achievement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Achievement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lesson_id'],
      ),
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      ),
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value'],
      )!,
      earnedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}earned_at'],
      )!,
      isNotified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_notified'],
      )!,
    );
  }

  @override
  $AchievementsTable createAlias(String alias) {
    return $AchievementsTable(attachedDatabase, alias);
  }
}

class Achievement extends DataClass implements Insertable<Achievement> {
  final int id;
  final String type;
  final int? lessonId;
  final String? sessionId;
  final int value;
  final DateTime earnedAt;
  final bool isNotified;
  const Achievement({
    required this.id,
    required this.type,
    this.lessonId,
    this.sessionId,
    required this.value,
    required this.earnedAt,
    required this.isNotified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || lessonId != null) {
      map['lesson_id'] = Variable<int>(lessonId);
    }
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    map['value'] = Variable<int>(value);
    map['earned_at'] = Variable<DateTime>(earnedAt);
    map['is_notified'] = Variable<bool>(isNotified);
    return map;
  }

  AchievementsCompanion toCompanion(bool nullToAbsent) {
    return AchievementsCompanion(
      id: Value(id),
      type: Value(type),
      lessonId: lessonId == null && nullToAbsent
          ? const Value.absent()
          : Value(lessonId),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      value: Value(value),
      earnedAt: Value(earnedAt),
      isNotified: Value(isNotified),
    );
  }

  factory Achievement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Achievement(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      lessonId: serializer.fromJson<int?>(json['lessonId']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
      value: serializer.fromJson<int>(json['value']),
      earnedAt: serializer.fromJson<DateTime>(json['earnedAt']),
      isNotified: serializer.fromJson<bool>(json['isNotified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'lessonId': serializer.toJson<int?>(lessonId),
      'sessionId': serializer.toJson<String?>(sessionId),
      'value': serializer.toJson<int>(value),
      'earnedAt': serializer.toJson<DateTime>(earnedAt),
      'isNotified': serializer.toJson<bool>(isNotified),
    };
  }

  Achievement copyWith({
    int? id,
    String? type,
    Value<int?> lessonId = const Value.absent(),
    Value<String?> sessionId = const Value.absent(),
    int? value,
    DateTime? earnedAt,
    bool? isNotified,
  }) => Achievement(
    id: id ?? this.id,
    type: type ?? this.type,
    lessonId: lessonId.present ? lessonId.value : this.lessonId,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    value: value ?? this.value,
    earnedAt: earnedAt ?? this.earnedAt,
    isNotified: isNotified ?? this.isNotified,
  );
  Achievement copyWithCompanion(AchievementsCompanion data) {
    return Achievement(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      value: data.value.present ? data.value.value : this.value,
      earnedAt: data.earnedAt.present ? data.earnedAt.value : this.earnedAt,
      isNotified: data.isNotified.present
          ? data.isNotified.value
          : this.isNotified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Achievement(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('lessonId: $lessonId, ')
          ..write('sessionId: $sessionId, ')
          ..write('value: $value, ')
          ..write('earnedAt: $earnedAt, ')
          ..write('isNotified: $isNotified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, lessonId, sessionId, value, earnedAt, isNotified);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Achievement &&
          other.id == this.id &&
          other.type == this.type &&
          other.lessonId == this.lessonId &&
          other.sessionId == this.sessionId &&
          other.value == this.value &&
          other.earnedAt == this.earnedAt &&
          other.isNotified == this.isNotified);
}

class AchievementsCompanion extends UpdateCompanion<Achievement> {
  final Value<int> id;
  final Value<String> type;
  final Value<int?> lessonId;
  final Value<String?> sessionId;
  final Value<int> value;
  final Value<DateTime> earnedAt;
  final Value<bool> isNotified;
  const AchievementsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.value = const Value.absent(),
    this.earnedAt = const Value.absent(),
    this.isNotified = const Value.absent(),
  });
  AchievementsCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    this.lessonId = const Value.absent(),
    this.sessionId = const Value.absent(),
    required int value,
    required DateTime earnedAt,
    this.isNotified = const Value.absent(),
  }) : type = Value(type),
       value = Value(value),
       earnedAt = Value(earnedAt);
  static Insertable<Achievement> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<int>? lessonId,
    Expression<String>? sessionId,
    Expression<int>? value,
    Expression<DateTime>? earnedAt,
    Expression<bool>? isNotified,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (lessonId != null) 'lesson_id': lessonId,
      if (sessionId != null) 'session_id': sessionId,
      if (value != null) 'value': value,
      if (earnedAt != null) 'earned_at': earnedAt,
      if (isNotified != null) 'is_notified': isNotified,
    });
  }

  AchievementsCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<int?>? lessonId,
    Value<String?>? sessionId,
    Value<int>? value,
    Value<DateTime>? earnedAt,
    Value<bool>? isNotified,
  }) {
    return AchievementsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      lessonId: lessonId ?? this.lessonId,
      sessionId: sessionId ?? this.sessionId,
      value: value ?? this.value,
      earnedAt: earnedAt ?? this.earnedAt,
      isNotified: isNotified ?? this.isNotified,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<int>(lessonId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (earnedAt.present) {
      map['earned_at'] = Variable<DateTime>(earnedAt.value);
    }
    if (isNotified.present) {
      map['is_notified'] = Variable<bool>(isNotified.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('lessonId: $lessonId, ')
          ..write('sessionId: $sessionId, ')
          ..write('value: $value, ')
          ..write('earnedAt: $earnedAt, ')
          ..write('isNotified: $isNotified')
          ..write(')'))
        .toString();
  }
}

class $FlashcardSettingsTable extends FlashcardSettings
    with TableInfo<$FlashcardSettingsTable, FlashcardSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlashcardSettingsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _showTermFirstMeta = const VerificationMeta(
    'showTermFirst',
  );
  @override
  late final GeneratedColumn<bool> showTermFirst = GeneratedColumn<bool>(
    'show_term_first',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_term_first" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _shuffleCardsMeta = const VerificationMeta(
    'shuffleCards',
  );
  @override
  late final GeneratedColumn<bool> shuffleCards = GeneratedColumn<bool>(
    'shuffle_cards',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("shuffle_cards" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showStarredOnlyMeta = const VerificationMeta(
    'showStarredOnly',
  );
  @override
  late final GeneratedColumn<bool> showStarredOnly = GeneratedColumn<bool>(
    'show_starred_only',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_starred_only" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    showTermFirst,
    shuffleCards,
    showStarredOnly,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flashcard_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<FlashcardSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('show_term_first')) {
      context.handle(
        _showTermFirstMeta,
        showTermFirst.isAcceptableOrUnknown(
          data['show_term_first']!,
          _showTermFirstMeta,
        ),
      );
    }
    if (data.containsKey('shuffle_cards')) {
      context.handle(
        _shuffleCardsMeta,
        shuffleCards.isAcceptableOrUnknown(
          data['shuffle_cards']!,
          _shuffleCardsMeta,
        ),
      );
    }
    if (data.containsKey('show_starred_only')) {
      context.handle(
        _showStarredOnlyMeta,
        showStarredOnly.isAcceptableOrUnknown(
          data['show_starred_only']!,
          _showStarredOnlyMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FlashcardSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FlashcardSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      showTermFirst: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_term_first'],
      )!,
      shuffleCards: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}shuffle_cards'],
      )!,
      showStarredOnly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_starred_only'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $FlashcardSettingsTable createAlias(String alias) {
    return $FlashcardSettingsTable(attachedDatabase, alias);
  }
}

class FlashcardSetting extends DataClass
    implements Insertable<FlashcardSetting> {
  final int id;
  final bool showTermFirst;
  final bool shuffleCards;
  final bool showStarredOnly;
  final DateTime? updatedAt;
  const FlashcardSetting({
    required this.id,
    required this.showTermFirst,
    required this.shuffleCards,
    required this.showStarredOnly,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['show_term_first'] = Variable<bool>(showTermFirst);
    map['shuffle_cards'] = Variable<bool>(shuffleCards);
    map['show_starred_only'] = Variable<bool>(showStarredOnly);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  FlashcardSettingsCompanion toCompanion(bool nullToAbsent) {
    return FlashcardSettingsCompanion(
      id: Value(id),
      showTermFirst: Value(showTermFirst),
      shuffleCards: Value(shuffleCards),
      showStarredOnly: Value(showStarredOnly),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory FlashcardSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FlashcardSetting(
      id: serializer.fromJson<int>(json['id']),
      showTermFirst: serializer.fromJson<bool>(json['showTermFirst']),
      shuffleCards: serializer.fromJson<bool>(json['shuffleCards']),
      showStarredOnly: serializer.fromJson<bool>(json['showStarredOnly']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'showTermFirst': serializer.toJson<bool>(showTermFirst),
      'shuffleCards': serializer.toJson<bool>(shuffleCards),
      'showStarredOnly': serializer.toJson<bool>(showStarredOnly),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  FlashcardSetting copyWith({
    int? id,
    bool? showTermFirst,
    bool? shuffleCards,
    bool? showStarredOnly,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => FlashcardSetting(
    id: id ?? this.id,
    showTermFirst: showTermFirst ?? this.showTermFirst,
    shuffleCards: shuffleCards ?? this.shuffleCards,
    showStarredOnly: showStarredOnly ?? this.showStarredOnly,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  FlashcardSetting copyWithCompanion(FlashcardSettingsCompanion data) {
    return FlashcardSetting(
      id: data.id.present ? data.id.value : this.id,
      showTermFirst: data.showTermFirst.present
          ? data.showTermFirst.value
          : this.showTermFirst,
      shuffleCards: data.shuffleCards.present
          ? data.shuffleCards.value
          : this.shuffleCards,
      showStarredOnly: data.showStarredOnly.present
          ? data.showStarredOnly.value
          : this.showStarredOnly,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardSetting(')
          ..write('id: $id, ')
          ..write('showTermFirst: $showTermFirst, ')
          ..write('shuffleCards: $shuffleCards, ')
          ..write('showStarredOnly: $showStarredOnly, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, showTermFirst, shuffleCards, showStarredOnly, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FlashcardSetting &&
          other.id == this.id &&
          other.showTermFirst == this.showTermFirst &&
          other.shuffleCards == this.shuffleCards &&
          other.showStarredOnly == this.showStarredOnly &&
          other.updatedAt == this.updatedAt);
}

class FlashcardSettingsCompanion extends UpdateCompanion<FlashcardSetting> {
  final Value<int> id;
  final Value<bool> showTermFirst;
  final Value<bool> shuffleCards;
  final Value<bool> showStarredOnly;
  final Value<DateTime?> updatedAt;
  const FlashcardSettingsCompanion({
    this.id = const Value.absent(),
    this.showTermFirst = const Value.absent(),
    this.shuffleCards = const Value.absent(),
    this.showStarredOnly = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FlashcardSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.showTermFirst = const Value.absent(),
    this.shuffleCards = const Value.absent(),
    this.showStarredOnly = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<FlashcardSetting> custom({
    Expression<int>? id,
    Expression<bool>? showTermFirst,
    Expression<bool>? shuffleCards,
    Expression<bool>? showStarredOnly,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (showTermFirst != null) 'show_term_first': showTermFirst,
      if (shuffleCards != null) 'shuffle_cards': shuffleCards,
      if (showStarredOnly != null) 'show_starred_only': showStarredOnly,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FlashcardSettingsCompanion copyWith({
    Value<int>? id,
    Value<bool>? showTermFirst,
    Value<bool>? shuffleCards,
    Value<bool>? showStarredOnly,
    Value<DateTime?>? updatedAt,
  }) {
    return FlashcardSettingsCompanion(
      id: id ?? this.id,
      showTermFirst: showTermFirst ?? this.showTermFirst,
      shuffleCards: shuffleCards ?? this.shuffleCards,
      showStarredOnly: showStarredOnly ?? this.showStarredOnly,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (showTermFirst.present) {
      map['show_term_first'] = Variable<bool>(showTermFirst.value);
    }
    if (shuffleCards.present) {
      map['shuffle_cards'] = Variable<bool>(shuffleCards.value);
    }
    if (showStarredOnly.present) {
      map['show_starred_only'] = Variable<bool>(showStarredOnly.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardSettingsCompanion(')
          ..write('id: $id, ')
          ..write('showTermFirst: $showTermFirst, ')
          ..write('shuffleCards: $shuffleCards, ')
          ..write('showStarredOnly: $showStarredOnly, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LearnSettingsTable extends LearnSettings
    with TableInfo<$LearnSettingsTable, LearnSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LearnSettingsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _defaultQuestionCountMeta =
      const VerificationMeta('defaultQuestionCount');
  @override
  late final GeneratedColumn<int> defaultQuestionCount = GeneratedColumn<int>(
    'default_question_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(20),
  );
  static const VerificationMeta _enableMultipleChoiceMeta =
      const VerificationMeta('enableMultipleChoice');
  @override
  late final GeneratedColumn<bool> enableMultipleChoice = GeneratedColumn<bool>(
    'enable_multiple_choice',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enable_multiple_choice" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _enableTrueFalseMeta = const VerificationMeta(
    'enableTrueFalse',
  );
  @override
  late final GeneratedColumn<bool> enableTrueFalse = GeneratedColumn<bool>(
    'enable_true_false',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enable_true_false" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _enableFillBlankMeta = const VerificationMeta(
    'enableFillBlank',
  );
  @override
  late final GeneratedColumn<bool> enableFillBlank = GeneratedColumn<bool>(
    'enable_fill_blank',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enable_fill_blank" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _shuffleQuestionsMeta = const VerificationMeta(
    'shuffleQuestions',
  );
  @override
  late final GeneratedColumn<bool> shuffleQuestions = GeneratedColumn<bool>(
    'shuffle_questions',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("shuffle_questions" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _enableHintsMeta = const VerificationMeta(
    'enableHints',
  );
  @override
  late final GeneratedColumn<bool> enableHints = GeneratedColumn<bool>(
    'enable_hints',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enable_hints" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showCorrectAnswerMeta = const VerificationMeta(
    'showCorrectAnswer',
  );
  @override
  late final GeneratedColumn<bool> showCorrectAnswer = GeneratedColumn<bool>(
    'show_correct_answer',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_correct_answer" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    defaultQuestionCount,
    enableMultipleChoice,
    enableTrueFalse,
    enableFillBlank,
    shuffleQuestions,
    enableHints,
    showCorrectAnswer,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'learn_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<LearnSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('default_question_count')) {
      context.handle(
        _defaultQuestionCountMeta,
        defaultQuestionCount.isAcceptableOrUnknown(
          data['default_question_count']!,
          _defaultQuestionCountMeta,
        ),
      );
    }
    if (data.containsKey('enable_multiple_choice')) {
      context.handle(
        _enableMultipleChoiceMeta,
        enableMultipleChoice.isAcceptableOrUnknown(
          data['enable_multiple_choice']!,
          _enableMultipleChoiceMeta,
        ),
      );
    }
    if (data.containsKey('enable_true_false')) {
      context.handle(
        _enableTrueFalseMeta,
        enableTrueFalse.isAcceptableOrUnknown(
          data['enable_true_false']!,
          _enableTrueFalseMeta,
        ),
      );
    }
    if (data.containsKey('enable_fill_blank')) {
      context.handle(
        _enableFillBlankMeta,
        enableFillBlank.isAcceptableOrUnknown(
          data['enable_fill_blank']!,
          _enableFillBlankMeta,
        ),
      );
    }
    if (data.containsKey('shuffle_questions')) {
      context.handle(
        _shuffleQuestionsMeta,
        shuffleQuestions.isAcceptableOrUnknown(
          data['shuffle_questions']!,
          _shuffleQuestionsMeta,
        ),
      );
    }
    if (data.containsKey('enable_hints')) {
      context.handle(
        _enableHintsMeta,
        enableHints.isAcceptableOrUnknown(
          data['enable_hints']!,
          _enableHintsMeta,
        ),
      );
    }
    if (data.containsKey('show_correct_answer')) {
      context.handle(
        _showCorrectAnswerMeta,
        showCorrectAnswer.isAcceptableOrUnknown(
          data['show_correct_answer']!,
          _showCorrectAnswerMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LearnSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LearnSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      defaultQuestionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_question_count'],
      )!,
      enableMultipleChoice: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enable_multiple_choice'],
      )!,
      enableTrueFalse: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enable_true_false'],
      )!,
      enableFillBlank: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enable_fill_blank'],
      )!,
      shuffleQuestions: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}shuffle_questions'],
      )!,
      enableHints: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enable_hints'],
      )!,
      showCorrectAnswer: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_correct_answer'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $LearnSettingsTable createAlias(String alias) {
    return $LearnSettingsTable(attachedDatabase, alias);
  }
}

class LearnSetting extends DataClass implements Insertable<LearnSetting> {
  final int id;
  final int defaultQuestionCount;
  final bool enableMultipleChoice;
  final bool enableTrueFalse;
  final bool enableFillBlank;
  final bool shuffleQuestions;
  final bool enableHints;
  final bool showCorrectAnswer;
  final DateTime? updatedAt;
  const LearnSetting({
    required this.id,
    required this.defaultQuestionCount,
    required this.enableMultipleChoice,
    required this.enableTrueFalse,
    required this.enableFillBlank,
    required this.shuffleQuestions,
    required this.enableHints,
    required this.showCorrectAnswer,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['default_question_count'] = Variable<int>(defaultQuestionCount);
    map['enable_multiple_choice'] = Variable<bool>(enableMultipleChoice);
    map['enable_true_false'] = Variable<bool>(enableTrueFalse);
    map['enable_fill_blank'] = Variable<bool>(enableFillBlank);
    map['shuffle_questions'] = Variable<bool>(shuffleQuestions);
    map['enable_hints'] = Variable<bool>(enableHints);
    map['show_correct_answer'] = Variable<bool>(showCorrectAnswer);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  LearnSettingsCompanion toCompanion(bool nullToAbsent) {
    return LearnSettingsCompanion(
      id: Value(id),
      defaultQuestionCount: Value(defaultQuestionCount),
      enableMultipleChoice: Value(enableMultipleChoice),
      enableTrueFalse: Value(enableTrueFalse),
      enableFillBlank: Value(enableFillBlank),
      shuffleQuestions: Value(shuffleQuestions),
      enableHints: Value(enableHints),
      showCorrectAnswer: Value(showCorrectAnswer),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory LearnSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LearnSetting(
      id: serializer.fromJson<int>(json['id']),
      defaultQuestionCount: serializer.fromJson<int>(
        json['defaultQuestionCount'],
      ),
      enableMultipleChoice: serializer.fromJson<bool>(
        json['enableMultipleChoice'],
      ),
      enableTrueFalse: serializer.fromJson<bool>(json['enableTrueFalse']),
      enableFillBlank: serializer.fromJson<bool>(json['enableFillBlank']),
      shuffleQuestions: serializer.fromJson<bool>(json['shuffleQuestions']),
      enableHints: serializer.fromJson<bool>(json['enableHints']),
      showCorrectAnswer: serializer.fromJson<bool>(json['showCorrectAnswer']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'defaultQuestionCount': serializer.toJson<int>(defaultQuestionCount),
      'enableMultipleChoice': serializer.toJson<bool>(enableMultipleChoice),
      'enableTrueFalse': serializer.toJson<bool>(enableTrueFalse),
      'enableFillBlank': serializer.toJson<bool>(enableFillBlank),
      'shuffleQuestions': serializer.toJson<bool>(shuffleQuestions),
      'enableHints': serializer.toJson<bool>(enableHints),
      'showCorrectAnswer': serializer.toJson<bool>(showCorrectAnswer),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  LearnSetting copyWith({
    int? id,
    int? defaultQuestionCount,
    bool? enableMultipleChoice,
    bool? enableTrueFalse,
    bool? enableFillBlank,
    bool? shuffleQuestions,
    bool? enableHints,
    bool? showCorrectAnswer,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => LearnSetting(
    id: id ?? this.id,
    defaultQuestionCount: defaultQuestionCount ?? this.defaultQuestionCount,
    enableMultipleChoice: enableMultipleChoice ?? this.enableMultipleChoice,
    enableTrueFalse: enableTrueFalse ?? this.enableTrueFalse,
    enableFillBlank: enableFillBlank ?? this.enableFillBlank,
    shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
    enableHints: enableHints ?? this.enableHints,
    showCorrectAnswer: showCorrectAnswer ?? this.showCorrectAnswer,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  LearnSetting copyWithCompanion(LearnSettingsCompanion data) {
    return LearnSetting(
      id: data.id.present ? data.id.value : this.id,
      defaultQuestionCount: data.defaultQuestionCount.present
          ? data.defaultQuestionCount.value
          : this.defaultQuestionCount,
      enableMultipleChoice: data.enableMultipleChoice.present
          ? data.enableMultipleChoice.value
          : this.enableMultipleChoice,
      enableTrueFalse: data.enableTrueFalse.present
          ? data.enableTrueFalse.value
          : this.enableTrueFalse,
      enableFillBlank: data.enableFillBlank.present
          ? data.enableFillBlank.value
          : this.enableFillBlank,
      shuffleQuestions: data.shuffleQuestions.present
          ? data.shuffleQuestions.value
          : this.shuffleQuestions,
      enableHints: data.enableHints.present
          ? data.enableHints.value
          : this.enableHints,
      showCorrectAnswer: data.showCorrectAnswer.present
          ? data.showCorrectAnswer.value
          : this.showCorrectAnswer,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LearnSetting(')
          ..write('id: $id, ')
          ..write('defaultQuestionCount: $defaultQuestionCount, ')
          ..write('enableMultipleChoice: $enableMultipleChoice, ')
          ..write('enableTrueFalse: $enableTrueFalse, ')
          ..write('enableFillBlank: $enableFillBlank, ')
          ..write('shuffleQuestions: $shuffleQuestions, ')
          ..write('enableHints: $enableHints, ')
          ..write('showCorrectAnswer: $showCorrectAnswer, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    defaultQuestionCount,
    enableMultipleChoice,
    enableTrueFalse,
    enableFillBlank,
    shuffleQuestions,
    enableHints,
    showCorrectAnswer,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LearnSetting &&
          other.id == this.id &&
          other.defaultQuestionCount == this.defaultQuestionCount &&
          other.enableMultipleChoice == this.enableMultipleChoice &&
          other.enableTrueFalse == this.enableTrueFalse &&
          other.enableFillBlank == this.enableFillBlank &&
          other.shuffleQuestions == this.shuffleQuestions &&
          other.enableHints == this.enableHints &&
          other.showCorrectAnswer == this.showCorrectAnswer &&
          other.updatedAt == this.updatedAt);
}

class LearnSettingsCompanion extends UpdateCompanion<LearnSetting> {
  final Value<int> id;
  final Value<int> defaultQuestionCount;
  final Value<bool> enableMultipleChoice;
  final Value<bool> enableTrueFalse;
  final Value<bool> enableFillBlank;
  final Value<bool> shuffleQuestions;
  final Value<bool> enableHints;
  final Value<bool> showCorrectAnswer;
  final Value<DateTime?> updatedAt;
  const LearnSettingsCompanion({
    this.id = const Value.absent(),
    this.defaultQuestionCount = const Value.absent(),
    this.enableMultipleChoice = const Value.absent(),
    this.enableTrueFalse = const Value.absent(),
    this.enableFillBlank = const Value.absent(),
    this.shuffleQuestions = const Value.absent(),
    this.enableHints = const Value.absent(),
    this.showCorrectAnswer = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LearnSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.defaultQuestionCount = const Value.absent(),
    this.enableMultipleChoice = const Value.absent(),
    this.enableTrueFalse = const Value.absent(),
    this.enableFillBlank = const Value.absent(),
    this.shuffleQuestions = const Value.absent(),
    this.enableHints = const Value.absent(),
    this.showCorrectAnswer = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<LearnSetting> custom({
    Expression<int>? id,
    Expression<int>? defaultQuestionCount,
    Expression<bool>? enableMultipleChoice,
    Expression<bool>? enableTrueFalse,
    Expression<bool>? enableFillBlank,
    Expression<bool>? shuffleQuestions,
    Expression<bool>? enableHints,
    Expression<bool>? showCorrectAnswer,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (defaultQuestionCount != null)
        'default_question_count': defaultQuestionCount,
      if (enableMultipleChoice != null)
        'enable_multiple_choice': enableMultipleChoice,
      if (enableTrueFalse != null) 'enable_true_false': enableTrueFalse,
      if (enableFillBlank != null) 'enable_fill_blank': enableFillBlank,
      if (shuffleQuestions != null) 'shuffle_questions': shuffleQuestions,
      if (enableHints != null) 'enable_hints': enableHints,
      if (showCorrectAnswer != null) 'show_correct_answer': showCorrectAnswer,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LearnSettingsCompanion copyWith({
    Value<int>? id,
    Value<int>? defaultQuestionCount,
    Value<bool>? enableMultipleChoice,
    Value<bool>? enableTrueFalse,
    Value<bool>? enableFillBlank,
    Value<bool>? shuffleQuestions,
    Value<bool>? enableHints,
    Value<bool>? showCorrectAnswer,
    Value<DateTime?>? updatedAt,
  }) {
    return LearnSettingsCompanion(
      id: id ?? this.id,
      defaultQuestionCount: defaultQuestionCount ?? this.defaultQuestionCount,
      enableMultipleChoice: enableMultipleChoice ?? this.enableMultipleChoice,
      enableTrueFalse: enableTrueFalse ?? this.enableTrueFalse,
      enableFillBlank: enableFillBlank ?? this.enableFillBlank,
      shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
      enableHints: enableHints ?? this.enableHints,
      showCorrectAnswer: showCorrectAnswer ?? this.showCorrectAnswer,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (defaultQuestionCount.present) {
      map['default_question_count'] = Variable<int>(defaultQuestionCount.value);
    }
    if (enableMultipleChoice.present) {
      map['enable_multiple_choice'] = Variable<bool>(
        enableMultipleChoice.value,
      );
    }
    if (enableTrueFalse.present) {
      map['enable_true_false'] = Variable<bool>(enableTrueFalse.value);
    }
    if (enableFillBlank.present) {
      map['enable_fill_blank'] = Variable<bool>(enableFillBlank.value);
    }
    if (shuffleQuestions.present) {
      map['shuffle_questions'] = Variable<bool>(shuffleQuestions.value);
    }
    if (enableHints.present) {
      map['enable_hints'] = Variable<bool>(enableHints.value);
    }
    if (showCorrectAnswer.present) {
      map['show_correct_answer'] = Variable<bool>(showCorrectAnswer.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LearnSettingsCompanion(')
          ..write('id: $id, ')
          ..write('defaultQuestionCount: $defaultQuestionCount, ')
          ..write('enableMultipleChoice: $enableMultipleChoice, ')
          ..write('enableTrueFalse: $enableTrueFalse, ')
          ..write('enableFillBlank: $enableFillBlank, ')
          ..write('shuffleQuestions: $shuffleQuestions, ')
          ..write('enableHints: $enableHints, ')
          ..write('showCorrectAnswer: $showCorrectAnswer, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TestSettingsTable extends TestSettings
    with TableInfo<$TestSettingsTable, TestSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TestSettingsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _defaultQuestionCountMeta =
      const VerificationMeta('defaultQuestionCount');
  @override
  late final GeneratedColumn<int> defaultQuestionCount = GeneratedColumn<int>(
    'default_question_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(20),
  );
  static const VerificationMeta _defaultTimeLimitMinutesMeta =
      const VerificationMeta('defaultTimeLimitMinutes');
  @override
  late final GeneratedColumn<int> defaultTimeLimitMinutes =
      GeneratedColumn<int>(
        'default_time_limit_minutes',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _enableMultipleChoiceMeta =
      const VerificationMeta('enableMultipleChoice');
  @override
  late final GeneratedColumn<bool> enableMultipleChoice = GeneratedColumn<bool>(
    'enable_multiple_choice',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enable_multiple_choice" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _enableTrueFalseMeta = const VerificationMeta(
    'enableTrueFalse',
  );
  @override
  late final GeneratedColumn<bool> enableTrueFalse = GeneratedColumn<bool>(
    'enable_true_false',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enable_true_false" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _enableFillBlankMeta = const VerificationMeta(
    'enableFillBlank',
  );
  @override
  late final GeneratedColumn<bool> enableFillBlank = GeneratedColumn<bool>(
    'enable_fill_blank',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enable_fill_blank" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _shuffleQuestionsMeta = const VerificationMeta(
    'shuffleQuestions',
  );
  @override
  late final GeneratedColumn<bool> shuffleQuestions = GeneratedColumn<bool>(
    'shuffle_questions',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("shuffle_questions" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _shuffleOptionsMeta = const VerificationMeta(
    'shuffleOptions',
  );
  @override
  late final GeneratedColumn<bool> shuffleOptions = GeneratedColumn<bool>(
    'shuffle_options',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("shuffle_options" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showCorrectAfterWrongMeta =
      const VerificationMeta('showCorrectAfterWrong');
  @override
  late final GeneratedColumn<bool> showCorrectAfterWrong =
      GeneratedColumn<bool>(
        'show_correct_after_wrong',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("show_correct_after_wrong" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    defaultQuestionCount,
    defaultTimeLimitMinutes,
    enableMultipleChoice,
    enableTrueFalse,
    enableFillBlank,
    shuffleQuestions,
    shuffleOptions,
    showCorrectAfterWrong,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'test_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<TestSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('default_question_count')) {
      context.handle(
        _defaultQuestionCountMeta,
        defaultQuestionCount.isAcceptableOrUnknown(
          data['default_question_count']!,
          _defaultQuestionCountMeta,
        ),
      );
    }
    if (data.containsKey('default_time_limit_minutes')) {
      context.handle(
        _defaultTimeLimitMinutesMeta,
        defaultTimeLimitMinutes.isAcceptableOrUnknown(
          data['default_time_limit_minutes']!,
          _defaultTimeLimitMinutesMeta,
        ),
      );
    }
    if (data.containsKey('enable_multiple_choice')) {
      context.handle(
        _enableMultipleChoiceMeta,
        enableMultipleChoice.isAcceptableOrUnknown(
          data['enable_multiple_choice']!,
          _enableMultipleChoiceMeta,
        ),
      );
    }
    if (data.containsKey('enable_true_false')) {
      context.handle(
        _enableTrueFalseMeta,
        enableTrueFalse.isAcceptableOrUnknown(
          data['enable_true_false']!,
          _enableTrueFalseMeta,
        ),
      );
    }
    if (data.containsKey('enable_fill_blank')) {
      context.handle(
        _enableFillBlankMeta,
        enableFillBlank.isAcceptableOrUnknown(
          data['enable_fill_blank']!,
          _enableFillBlankMeta,
        ),
      );
    }
    if (data.containsKey('shuffle_questions')) {
      context.handle(
        _shuffleQuestionsMeta,
        shuffleQuestions.isAcceptableOrUnknown(
          data['shuffle_questions']!,
          _shuffleQuestionsMeta,
        ),
      );
    }
    if (data.containsKey('shuffle_options')) {
      context.handle(
        _shuffleOptionsMeta,
        shuffleOptions.isAcceptableOrUnknown(
          data['shuffle_options']!,
          _shuffleOptionsMeta,
        ),
      );
    }
    if (data.containsKey('show_correct_after_wrong')) {
      context.handle(
        _showCorrectAfterWrongMeta,
        showCorrectAfterWrong.isAcceptableOrUnknown(
          data['show_correct_after_wrong']!,
          _showCorrectAfterWrongMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TestSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TestSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      defaultQuestionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_question_count'],
      )!,
      defaultTimeLimitMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_time_limit_minutes'],
      ),
      enableMultipleChoice: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enable_multiple_choice'],
      )!,
      enableTrueFalse: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enable_true_false'],
      )!,
      enableFillBlank: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enable_fill_blank'],
      )!,
      shuffleQuestions: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}shuffle_questions'],
      )!,
      shuffleOptions: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}shuffle_options'],
      )!,
      showCorrectAfterWrong: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_correct_after_wrong'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $TestSettingsTable createAlias(String alias) {
    return $TestSettingsTable(attachedDatabase, alias);
  }
}

class TestSetting extends DataClass implements Insertable<TestSetting> {
  final int id;
  final int defaultQuestionCount;
  final int? defaultTimeLimitMinutes;
  final bool enableMultipleChoice;
  final bool enableTrueFalse;
  final bool enableFillBlank;
  final bool shuffleQuestions;
  final bool shuffleOptions;
  final bool showCorrectAfterWrong;
  final DateTime? updatedAt;
  const TestSetting({
    required this.id,
    required this.defaultQuestionCount,
    this.defaultTimeLimitMinutes,
    required this.enableMultipleChoice,
    required this.enableTrueFalse,
    required this.enableFillBlank,
    required this.shuffleQuestions,
    required this.shuffleOptions,
    required this.showCorrectAfterWrong,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['default_question_count'] = Variable<int>(defaultQuestionCount);
    if (!nullToAbsent || defaultTimeLimitMinutes != null) {
      map['default_time_limit_minutes'] = Variable<int>(
        defaultTimeLimitMinutes,
      );
    }
    map['enable_multiple_choice'] = Variable<bool>(enableMultipleChoice);
    map['enable_true_false'] = Variable<bool>(enableTrueFalse);
    map['enable_fill_blank'] = Variable<bool>(enableFillBlank);
    map['shuffle_questions'] = Variable<bool>(shuffleQuestions);
    map['shuffle_options'] = Variable<bool>(shuffleOptions);
    map['show_correct_after_wrong'] = Variable<bool>(showCorrectAfterWrong);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  TestSettingsCompanion toCompanion(bool nullToAbsent) {
    return TestSettingsCompanion(
      id: Value(id),
      defaultQuestionCount: Value(defaultQuestionCount),
      defaultTimeLimitMinutes: defaultTimeLimitMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultTimeLimitMinutes),
      enableMultipleChoice: Value(enableMultipleChoice),
      enableTrueFalse: Value(enableTrueFalse),
      enableFillBlank: Value(enableFillBlank),
      shuffleQuestions: Value(shuffleQuestions),
      shuffleOptions: Value(shuffleOptions),
      showCorrectAfterWrong: Value(showCorrectAfterWrong),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory TestSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TestSetting(
      id: serializer.fromJson<int>(json['id']),
      defaultQuestionCount: serializer.fromJson<int>(
        json['defaultQuestionCount'],
      ),
      defaultTimeLimitMinutes: serializer.fromJson<int?>(
        json['defaultTimeLimitMinutes'],
      ),
      enableMultipleChoice: serializer.fromJson<bool>(
        json['enableMultipleChoice'],
      ),
      enableTrueFalse: serializer.fromJson<bool>(json['enableTrueFalse']),
      enableFillBlank: serializer.fromJson<bool>(json['enableFillBlank']),
      shuffleQuestions: serializer.fromJson<bool>(json['shuffleQuestions']),
      shuffleOptions: serializer.fromJson<bool>(json['shuffleOptions']),
      showCorrectAfterWrong: serializer.fromJson<bool>(
        json['showCorrectAfterWrong'],
      ),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'defaultQuestionCount': serializer.toJson<int>(defaultQuestionCount),
      'defaultTimeLimitMinutes': serializer.toJson<int?>(
        defaultTimeLimitMinutes,
      ),
      'enableMultipleChoice': serializer.toJson<bool>(enableMultipleChoice),
      'enableTrueFalse': serializer.toJson<bool>(enableTrueFalse),
      'enableFillBlank': serializer.toJson<bool>(enableFillBlank),
      'shuffleQuestions': serializer.toJson<bool>(shuffleQuestions),
      'shuffleOptions': serializer.toJson<bool>(shuffleOptions),
      'showCorrectAfterWrong': serializer.toJson<bool>(showCorrectAfterWrong),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  TestSetting copyWith({
    int? id,
    int? defaultQuestionCount,
    Value<int?> defaultTimeLimitMinutes = const Value.absent(),
    bool? enableMultipleChoice,
    bool? enableTrueFalse,
    bool? enableFillBlank,
    bool? shuffleQuestions,
    bool? shuffleOptions,
    bool? showCorrectAfterWrong,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => TestSetting(
    id: id ?? this.id,
    defaultQuestionCount: defaultQuestionCount ?? this.defaultQuestionCount,
    defaultTimeLimitMinutes: defaultTimeLimitMinutes.present
        ? defaultTimeLimitMinutes.value
        : this.defaultTimeLimitMinutes,
    enableMultipleChoice: enableMultipleChoice ?? this.enableMultipleChoice,
    enableTrueFalse: enableTrueFalse ?? this.enableTrueFalse,
    enableFillBlank: enableFillBlank ?? this.enableFillBlank,
    shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
    shuffleOptions: shuffleOptions ?? this.shuffleOptions,
    showCorrectAfterWrong: showCorrectAfterWrong ?? this.showCorrectAfterWrong,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  TestSetting copyWithCompanion(TestSettingsCompanion data) {
    return TestSetting(
      id: data.id.present ? data.id.value : this.id,
      defaultQuestionCount: data.defaultQuestionCount.present
          ? data.defaultQuestionCount.value
          : this.defaultQuestionCount,
      defaultTimeLimitMinutes: data.defaultTimeLimitMinutes.present
          ? data.defaultTimeLimitMinutes.value
          : this.defaultTimeLimitMinutes,
      enableMultipleChoice: data.enableMultipleChoice.present
          ? data.enableMultipleChoice.value
          : this.enableMultipleChoice,
      enableTrueFalse: data.enableTrueFalse.present
          ? data.enableTrueFalse.value
          : this.enableTrueFalse,
      enableFillBlank: data.enableFillBlank.present
          ? data.enableFillBlank.value
          : this.enableFillBlank,
      shuffleQuestions: data.shuffleQuestions.present
          ? data.shuffleQuestions.value
          : this.shuffleQuestions,
      shuffleOptions: data.shuffleOptions.present
          ? data.shuffleOptions.value
          : this.shuffleOptions,
      showCorrectAfterWrong: data.showCorrectAfterWrong.present
          ? data.showCorrectAfterWrong.value
          : this.showCorrectAfterWrong,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TestSetting(')
          ..write('id: $id, ')
          ..write('defaultQuestionCount: $defaultQuestionCount, ')
          ..write('defaultTimeLimitMinutes: $defaultTimeLimitMinutes, ')
          ..write('enableMultipleChoice: $enableMultipleChoice, ')
          ..write('enableTrueFalse: $enableTrueFalse, ')
          ..write('enableFillBlank: $enableFillBlank, ')
          ..write('shuffleQuestions: $shuffleQuestions, ')
          ..write('shuffleOptions: $shuffleOptions, ')
          ..write('showCorrectAfterWrong: $showCorrectAfterWrong, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    defaultQuestionCount,
    defaultTimeLimitMinutes,
    enableMultipleChoice,
    enableTrueFalse,
    enableFillBlank,
    shuffleQuestions,
    shuffleOptions,
    showCorrectAfterWrong,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TestSetting &&
          other.id == this.id &&
          other.defaultQuestionCount == this.defaultQuestionCount &&
          other.defaultTimeLimitMinutes == this.defaultTimeLimitMinutes &&
          other.enableMultipleChoice == this.enableMultipleChoice &&
          other.enableTrueFalse == this.enableTrueFalse &&
          other.enableFillBlank == this.enableFillBlank &&
          other.shuffleQuestions == this.shuffleQuestions &&
          other.shuffleOptions == this.shuffleOptions &&
          other.showCorrectAfterWrong == this.showCorrectAfterWrong &&
          other.updatedAt == this.updatedAt);
}

class TestSettingsCompanion extends UpdateCompanion<TestSetting> {
  final Value<int> id;
  final Value<int> defaultQuestionCount;
  final Value<int?> defaultTimeLimitMinutes;
  final Value<bool> enableMultipleChoice;
  final Value<bool> enableTrueFalse;
  final Value<bool> enableFillBlank;
  final Value<bool> shuffleQuestions;
  final Value<bool> shuffleOptions;
  final Value<bool> showCorrectAfterWrong;
  final Value<DateTime?> updatedAt;
  const TestSettingsCompanion({
    this.id = const Value.absent(),
    this.defaultQuestionCount = const Value.absent(),
    this.defaultTimeLimitMinutes = const Value.absent(),
    this.enableMultipleChoice = const Value.absent(),
    this.enableTrueFalse = const Value.absent(),
    this.enableFillBlank = const Value.absent(),
    this.shuffleQuestions = const Value.absent(),
    this.shuffleOptions = const Value.absent(),
    this.showCorrectAfterWrong = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TestSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.defaultQuestionCount = const Value.absent(),
    this.defaultTimeLimitMinutes = const Value.absent(),
    this.enableMultipleChoice = const Value.absent(),
    this.enableTrueFalse = const Value.absent(),
    this.enableFillBlank = const Value.absent(),
    this.shuffleQuestions = const Value.absent(),
    this.shuffleOptions = const Value.absent(),
    this.showCorrectAfterWrong = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<TestSetting> custom({
    Expression<int>? id,
    Expression<int>? defaultQuestionCount,
    Expression<int>? defaultTimeLimitMinutes,
    Expression<bool>? enableMultipleChoice,
    Expression<bool>? enableTrueFalse,
    Expression<bool>? enableFillBlank,
    Expression<bool>? shuffleQuestions,
    Expression<bool>? shuffleOptions,
    Expression<bool>? showCorrectAfterWrong,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (defaultQuestionCount != null)
        'default_question_count': defaultQuestionCount,
      if (defaultTimeLimitMinutes != null)
        'default_time_limit_minutes': defaultTimeLimitMinutes,
      if (enableMultipleChoice != null)
        'enable_multiple_choice': enableMultipleChoice,
      if (enableTrueFalse != null) 'enable_true_false': enableTrueFalse,
      if (enableFillBlank != null) 'enable_fill_blank': enableFillBlank,
      if (shuffleQuestions != null) 'shuffle_questions': shuffleQuestions,
      if (shuffleOptions != null) 'shuffle_options': shuffleOptions,
      if (showCorrectAfterWrong != null)
        'show_correct_after_wrong': showCorrectAfterWrong,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TestSettingsCompanion copyWith({
    Value<int>? id,
    Value<int>? defaultQuestionCount,
    Value<int?>? defaultTimeLimitMinutes,
    Value<bool>? enableMultipleChoice,
    Value<bool>? enableTrueFalse,
    Value<bool>? enableFillBlank,
    Value<bool>? shuffleQuestions,
    Value<bool>? shuffleOptions,
    Value<bool>? showCorrectAfterWrong,
    Value<DateTime?>? updatedAt,
  }) {
    return TestSettingsCompanion(
      id: id ?? this.id,
      defaultQuestionCount: defaultQuestionCount ?? this.defaultQuestionCount,
      defaultTimeLimitMinutes:
          defaultTimeLimitMinutes ?? this.defaultTimeLimitMinutes,
      enableMultipleChoice: enableMultipleChoice ?? this.enableMultipleChoice,
      enableTrueFalse: enableTrueFalse ?? this.enableTrueFalse,
      enableFillBlank: enableFillBlank ?? this.enableFillBlank,
      shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
      shuffleOptions: shuffleOptions ?? this.shuffleOptions,
      showCorrectAfterWrong:
          showCorrectAfterWrong ?? this.showCorrectAfterWrong,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (defaultQuestionCount.present) {
      map['default_question_count'] = Variable<int>(defaultQuestionCount.value);
    }
    if (defaultTimeLimitMinutes.present) {
      map['default_time_limit_minutes'] = Variable<int>(
        defaultTimeLimitMinutes.value,
      );
    }
    if (enableMultipleChoice.present) {
      map['enable_multiple_choice'] = Variable<bool>(
        enableMultipleChoice.value,
      );
    }
    if (enableTrueFalse.present) {
      map['enable_true_false'] = Variable<bool>(enableTrueFalse.value);
    }
    if (enableFillBlank.present) {
      map['enable_fill_blank'] = Variable<bool>(enableFillBlank.value);
    }
    if (shuffleQuestions.present) {
      map['shuffle_questions'] = Variable<bool>(shuffleQuestions.value);
    }
    if (shuffleOptions.present) {
      map['shuffle_options'] = Variable<bool>(shuffleOptions.value);
    }
    if (showCorrectAfterWrong.present) {
      map['show_correct_after_wrong'] = Variable<bool>(
        showCorrectAfterWrong.value,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TestSettingsCompanion(')
          ..write('id: $id, ')
          ..write('defaultQuestionCount: $defaultQuestionCount, ')
          ..write('defaultTimeLimitMinutes: $defaultTimeLimitMinutes, ')
          ..write('enableMultipleChoice: $enableMultipleChoice, ')
          ..write('enableTrueFalse: $enableTrueFalse, ')
          ..write('enableFillBlank: $enableFillBlank, ')
          ..write('shuffleQuestions: $shuffleQuestions, ')
          ..write('shuffleOptions: $shuffleOptions, ')
          ..write('showCorrectAfterWrong: $showCorrectAfterWrong, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $UserMistakesTable extends UserMistakes
    with TableInfo<$UserMistakesTable, UserMistake> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserMistakesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wrongCountMeta = const VerificationMeta(
    'wrongCount',
  );
  @override
  late final GeneratedColumn<int> wrongCount = GeneratedColumn<int>(
    'wrong_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _lastMistakeAtMeta = const VerificationMeta(
    'lastMistakeAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastMistakeAt =
      GeneratedColumn<DateTime>(
        'last_mistake_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _promptMeta = const VerificationMeta('prompt');
  @override
  late final GeneratedColumn<String> prompt = GeneratedColumn<String>(
    'prompt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _correctAnswerMeta = const VerificationMeta(
    'correctAnswer',
  );
  @override
  late final GeneratedColumn<String> correctAnswer = GeneratedColumn<String>(
    'correct_answer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userAnswerMeta = const VerificationMeta(
    'userAnswer',
  );
  @override
  late final GeneratedColumn<String> userAnswer = GeneratedColumn<String>(
    'user_answer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extraJsonMeta = const VerificationMeta(
    'extraJson',
  );
  @override
  late final GeneratedColumn<String> extraJson = GeneratedColumn<String>(
    'extra_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    itemId,
    wrongCount,
    lastMistakeAt,
    prompt,
    correctAnswer,
    userAnswer,
    source,
    extraJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_mistakes';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserMistake> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('wrong_count')) {
      context.handle(
        _wrongCountMeta,
        wrongCount.isAcceptableOrUnknown(data['wrong_count']!, _wrongCountMeta),
      );
    }
    if (data.containsKey('last_mistake_at')) {
      context.handle(
        _lastMistakeAtMeta,
        lastMistakeAt.isAcceptableOrUnknown(
          data['last_mistake_at']!,
          _lastMistakeAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastMistakeAtMeta);
    }
    if (data.containsKey('prompt')) {
      context.handle(
        _promptMeta,
        prompt.isAcceptableOrUnknown(data['prompt']!, _promptMeta),
      );
    }
    if (data.containsKey('correct_answer')) {
      context.handle(
        _correctAnswerMeta,
        correctAnswer.isAcceptableOrUnknown(
          data['correct_answer']!,
          _correctAnswerMeta,
        ),
      );
    }
    if (data.containsKey('user_answer')) {
      context.handle(
        _userAnswerMeta,
        userAnswer.isAcceptableOrUnknown(data['user_answer']!, _userAnswerMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('extra_json')) {
      context.handle(
        _extraJsonMeta,
        extraJson.isAcceptableOrUnknown(data['extra_json']!, _extraJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {type, itemId},
  ];
  @override
  UserMistake map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserMistake(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_id'],
      )!,
      wrongCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wrong_count'],
      )!,
      lastMistakeAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_mistake_at'],
      )!,
      prompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt'],
      ),
      correctAnswer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}correct_answer'],
      ),
      userAnswer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_answer'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      extraJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extra_json'],
      ),
    );
  }

  @override
  $UserMistakesTable createAlias(String alias) {
    return $UserMistakesTable(attachedDatabase, alias);
  }
}

class UserMistake extends DataClass implements Insertable<UserMistake> {
  final int id;
  final String type;
  final int itemId;
  final int wrongCount;
  final DateTime lastMistakeAt;
  final String? prompt;
  final String? correctAnswer;
  final String? userAnswer;
  final String? source;
  final String? extraJson;
  const UserMistake({
    required this.id,
    required this.type,
    required this.itemId,
    required this.wrongCount,
    required this.lastMistakeAt,
    this.prompt,
    this.correctAnswer,
    this.userAnswer,
    this.source,
    this.extraJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['item_id'] = Variable<int>(itemId);
    map['wrong_count'] = Variable<int>(wrongCount);
    map['last_mistake_at'] = Variable<DateTime>(lastMistakeAt);
    if (!nullToAbsent || prompt != null) {
      map['prompt'] = Variable<String>(prompt);
    }
    if (!nullToAbsent || correctAnswer != null) {
      map['correct_answer'] = Variable<String>(correctAnswer);
    }
    if (!nullToAbsent || userAnswer != null) {
      map['user_answer'] = Variable<String>(userAnswer);
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    if (!nullToAbsent || extraJson != null) {
      map['extra_json'] = Variable<String>(extraJson);
    }
    return map;
  }

  UserMistakesCompanion toCompanion(bool nullToAbsent) {
    return UserMistakesCompanion(
      id: Value(id),
      type: Value(type),
      itemId: Value(itemId),
      wrongCount: Value(wrongCount),
      lastMistakeAt: Value(lastMistakeAt),
      prompt: prompt == null && nullToAbsent
          ? const Value.absent()
          : Value(prompt),
      correctAnswer: correctAnswer == null && nullToAbsent
          ? const Value.absent()
          : Value(correctAnswer),
      userAnswer: userAnswer == null && nullToAbsent
          ? const Value.absent()
          : Value(userAnswer),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      extraJson: extraJson == null && nullToAbsent
          ? const Value.absent()
          : Value(extraJson),
    );
  }

  factory UserMistake.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserMistake(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      itemId: serializer.fromJson<int>(json['itemId']),
      wrongCount: serializer.fromJson<int>(json['wrongCount']),
      lastMistakeAt: serializer.fromJson<DateTime>(json['lastMistakeAt']),
      prompt: serializer.fromJson<String?>(json['prompt']),
      correctAnswer: serializer.fromJson<String?>(json['correctAnswer']),
      userAnswer: serializer.fromJson<String?>(json['userAnswer']),
      source: serializer.fromJson<String?>(json['source']),
      extraJson: serializer.fromJson<String?>(json['extraJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'itemId': serializer.toJson<int>(itemId),
      'wrongCount': serializer.toJson<int>(wrongCount),
      'lastMistakeAt': serializer.toJson<DateTime>(lastMistakeAt),
      'prompt': serializer.toJson<String?>(prompt),
      'correctAnswer': serializer.toJson<String?>(correctAnswer),
      'userAnswer': serializer.toJson<String?>(userAnswer),
      'source': serializer.toJson<String?>(source),
      'extraJson': serializer.toJson<String?>(extraJson),
    };
  }

  UserMistake copyWith({
    int? id,
    String? type,
    int? itemId,
    int? wrongCount,
    DateTime? lastMistakeAt,
    Value<String?> prompt = const Value.absent(),
    Value<String?> correctAnswer = const Value.absent(),
    Value<String?> userAnswer = const Value.absent(),
    Value<String?> source = const Value.absent(),
    Value<String?> extraJson = const Value.absent(),
  }) => UserMistake(
    id: id ?? this.id,
    type: type ?? this.type,
    itemId: itemId ?? this.itemId,
    wrongCount: wrongCount ?? this.wrongCount,
    lastMistakeAt: lastMistakeAt ?? this.lastMistakeAt,
    prompt: prompt.present ? prompt.value : this.prompt,
    correctAnswer: correctAnswer.present
        ? correctAnswer.value
        : this.correctAnswer,
    userAnswer: userAnswer.present ? userAnswer.value : this.userAnswer,
    source: source.present ? source.value : this.source,
    extraJson: extraJson.present ? extraJson.value : this.extraJson,
  );
  UserMistake copyWithCompanion(UserMistakesCompanion data) {
    return UserMistake(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      wrongCount: data.wrongCount.present
          ? data.wrongCount.value
          : this.wrongCount,
      lastMistakeAt: data.lastMistakeAt.present
          ? data.lastMistakeAt.value
          : this.lastMistakeAt,
      prompt: data.prompt.present ? data.prompt.value : this.prompt,
      correctAnswer: data.correctAnswer.present
          ? data.correctAnswer.value
          : this.correctAnswer,
      userAnswer: data.userAnswer.present
          ? data.userAnswer.value
          : this.userAnswer,
      source: data.source.present ? data.source.value : this.source,
      extraJson: data.extraJson.present ? data.extraJson.value : this.extraJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserMistake(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('itemId: $itemId, ')
          ..write('wrongCount: $wrongCount, ')
          ..write('lastMistakeAt: $lastMistakeAt, ')
          ..write('prompt: $prompt, ')
          ..write('correctAnswer: $correctAnswer, ')
          ..write('userAnswer: $userAnswer, ')
          ..write('source: $source, ')
          ..write('extraJson: $extraJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    itemId,
    wrongCount,
    lastMistakeAt,
    prompt,
    correctAnswer,
    userAnswer,
    source,
    extraJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserMistake &&
          other.id == this.id &&
          other.type == this.type &&
          other.itemId == this.itemId &&
          other.wrongCount == this.wrongCount &&
          other.lastMistakeAt == this.lastMistakeAt &&
          other.prompt == this.prompt &&
          other.correctAnswer == this.correctAnswer &&
          other.userAnswer == this.userAnswer &&
          other.source == this.source &&
          other.extraJson == this.extraJson);
}

class UserMistakesCompanion extends UpdateCompanion<UserMistake> {
  final Value<int> id;
  final Value<String> type;
  final Value<int> itemId;
  final Value<int> wrongCount;
  final Value<DateTime> lastMistakeAt;
  final Value<String?> prompt;
  final Value<String?> correctAnswer;
  final Value<String?> userAnswer;
  final Value<String?> source;
  final Value<String?> extraJson;
  const UserMistakesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.itemId = const Value.absent(),
    this.wrongCount = const Value.absent(),
    this.lastMistakeAt = const Value.absent(),
    this.prompt = const Value.absent(),
    this.correctAnswer = const Value.absent(),
    this.userAnswer = const Value.absent(),
    this.source = const Value.absent(),
    this.extraJson = const Value.absent(),
  });
  UserMistakesCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required int itemId,
    this.wrongCount = const Value.absent(),
    required DateTime lastMistakeAt,
    this.prompt = const Value.absent(),
    this.correctAnswer = const Value.absent(),
    this.userAnswer = const Value.absent(),
    this.source = const Value.absent(),
    this.extraJson = const Value.absent(),
  }) : type = Value(type),
       itemId = Value(itemId),
       lastMistakeAt = Value(lastMistakeAt);
  static Insertable<UserMistake> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<int>? itemId,
    Expression<int>? wrongCount,
    Expression<DateTime>? lastMistakeAt,
    Expression<String>? prompt,
    Expression<String>? correctAnswer,
    Expression<String>? userAnswer,
    Expression<String>? source,
    Expression<String>? extraJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (itemId != null) 'item_id': itemId,
      if (wrongCount != null) 'wrong_count': wrongCount,
      if (lastMistakeAt != null) 'last_mistake_at': lastMistakeAt,
      if (prompt != null) 'prompt': prompt,
      if (correctAnswer != null) 'correct_answer': correctAnswer,
      if (userAnswer != null) 'user_answer': userAnswer,
      if (source != null) 'source': source,
      if (extraJson != null) 'extra_json': extraJson,
    });
  }

  UserMistakesCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<int>? itemId,
    Value<int>? wrongCount,
    Value<DateTime>? lastMistakeAt,
    Value<String?>? prompt,
    Value<String?>? correctAnswer,
    Value<String?>? userAnswer,
    Value<String?>? source,
    Value<String?>? extraJson,
  }) {
    return UserMistakesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      itemId: itemId ?? this.itemId,
      wrongCount: wrongCount ?? this.wrongCount,
      lastMistakeAt: lastMistakeAt ?? this.lastMistakeAt,
      prompt: prompt ?? this.prompt,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      userAnswer: userAnswer ?? this.userAnswer,
      source: source ?? this.source,
      extraJson: extraJson ?? this.extraJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (wrongCount.present) {
      map['wrong_count'] = Variable<int>(wrongCount.value);
    }
    if (lastMistakeAt.present) {
      map['last_mistake_at'] = Variable<DateTime>(lastMistakeAt.value);
    }
    if (prompt.present) {
      map['prompt'] = Variable<String>(prompt.value);
    }
    if (correctAnswer.present) {
      map['correct_answer'] = Variable<String>(correctAnswer.value);
    }
    if (userAnswer.present) {
      map['user_answer'] = Variable<String>(userAnswer.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (extraJson.present) {
      map['extra_json'] = Variable<String>(extraJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserMistakesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('itemId: $itemId, ')
          ..write('wrongCount: $wrongCount, ')
          ..write('lastMistakeAt: $lastMistakeAt, ')
          ..write('prompt: $prompt, ')
          ..write('correctAnswer: $correctAnswer, ')
          ..write('userAnswer: $userAnswer, ')
          ..write('source: $source, ')
          ..write('extraJson: $extraJson')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SrsStateTable srsState = $SrsStateTable(this);
  late final $KanjiSrsStateTable kanjiSrsState = $KanjiSrsStateTable(this);
  late final $KanaSrsStateTable kanaSrsState = $KanaSrsStateTable(this);
  late final $UserProgressTable userProgress = $UserProgressTable(this);
  late final $AttemptTable attempt = $AttemptTable(this);
  late final $AttemptAnswerTable attemptAnswer = $AttemptAnswerTable(this);
  late final $GrammarPointsTable grammarPoints = $GrammarPointsTable(this);
  late final $GrammarExamplesTable grammarExamples = $GrammarExamplesTable(
    this,
  );
  late final $GrammarSrsStateTable grammarSrsState = $GrammarSrsStateTable(
    this,
  );
  late final $GrammarQuestionsTable grammarQuestions = $GrammarQuestionsTable(
    this,
  );
  late final $UserLessonTable userLesson = $UserLessonTable(this);
  late final $UserLessonTermTable userLessonTerm = $UserLessonTermTable(this);
  late final $LearnSessionsTable learnSessions = $LearnSessionsTable(this);
  late final $LearnAnswersTable learnAnswers = $LearnAnswersTable(this);
  late final $TestSessionsTable testSessions = $TestSessionsTable(this);
  late final $TestAnswersTable testAnswers = $TestAnswersTable(this);
  late final $AchievementsTable achievements = $AchievementsTable(this);
  late final $FlashcardSettingsTable flashcardSettings =
      $FlashcardSettingsTable(this);
  late final $LearnSettingsTable learnSettings = $LearnSettingsTable(this);
  late final $TestSettingsTable testSettings = $TestSettingsTable(this);
  late final $UserMistakesTable userMistakes = $UserMistakesTable(this);
  late final LearnDao learnDao = LearnDao(this as AppDatabase);
  late final TestDao testDao = TestDao(this as AppDatabase);
  late final AchievementDao achievementDao = AchievementDao(
    this as AppDatabase,
  );
  late final SrsDao srsDao = SrsDao(this as AppDatabase);
  late final GrammarDao grammarDao = GrammarDao(this as AppDatabase);
  late final MistakeDao mistakeDao = MistakeDao(this as AppDatabase);
  late final KanjiSrsDao kanjiSrsDao = KanjiSrsDao(this as AppDatabase);
  late final KanaSrsDao kanaSrsDao = KanaSrsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    srsState,
    kanjiSrsState,
    kanaSrsState,
    userProgress,
    attempt,
    attemptAnswer,
    grammarPoints,
    grammarExamples,
    grammarSrsState,
    grammarQuestions,
    userLesson,
    userLessonTerm,
    learnSessions,
    learnAnswers,
    testSessions,
    testAnswers,
    achievements,
    flashcardSettings,
    learnSettings,
    testSettings,
    userMistakes,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'grammar_points',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('grammar_examples', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'grammar_points',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('grammar_srs_state', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'grammar_points',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('grammar_questions', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SrsStateTableCreateCompanionBuilder =
    SrsStateCompanion Function({
      Value<int> id,
      required int vocabId,
      Value<int> box,
      Value<int> repetitions,
      Value<double> ease,
      Value<double> stability,
      Value<double> difficulty,
      Value<int> lastConfidence,
      Value<DateTime?> lastReviewedAt,
      required DateTime nextReviewAt,
    });
typedef $$SrsStateTableUpdateCompanionBuilder =
    SrsStateCompanion Function({
      Value<int> id,
      Value<int> vocabId,
      Value<int> box,
      Value<int> repetitions,
      Value<double> ease,
      Value<double> stability,
      Value<double> difficulty,
      Value<int> lastConfidence,
      Value<DateTime?> lastReviewedAt,
      Value<DateTime> nextReviewAt,
    });

class $$SrsStateTableFilterComposer
    extends Composer<_$AppDatabase, $SrsStateTable> {
  $$SrsStateTableFilterComposer({
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

  ColumnFilters<int> get vocabId => $composableBuilder(
    column: $table.vocabId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get box => $composableBuilder(
    column: $table.box,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ease => $composableBuilder(
    column: $table.ease,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastConfidence => $composableBuilder(
    column: $table.lastConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SrsStateTableOrderingComposer
    extends Composer<_$AppDatabase, $SrsStateTable> {
  $$SrsStateTableOrderingComposer({
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

  ColumnOrderings<int> get vocabId => $composableBuilder(
    column: $table.vocabId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get box => $composableBuilder(
    column: $table.box,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ease => $composableBuilder(
    column: $table.ease,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastConfidence => $composableBuilder(
    column: $table.lastConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SrsStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $SrsStateTable> {
  $$SrsStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get vocabId =>
      $composableBuilder(column: $table.vocabId, builder: (column) => column);

  GeneratedColumn<int> get box =>
      $composableBuilder(column: $table.box, builder: (column) => column);

  GeneratedColumn<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ease =>
      $composableBuilder(column: $table.ease, builder: (column) => column);

  GeneratedColumn<double> get stability =>
      $composableBuilder(column: $table.stability, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastConfidence => $composableBuilder(
    column: $table.lastConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => column,
  );
}

class $$SrsStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SrsStateTable,
          SrsStateData,
          $$SrsStateTableFilterComposer,
          $$SrsStateTableOrderingComposer,
          $$SrsStateTableAnnotationComposer,
          $$SrsStateTableCreateCompanionBuilder,
          $$SrsStateTableUpdateCompanionBuilder,
          (
            SrsStateData,
            BaseReferences<_$AppDatabase, $SrsStateTable, SrsStateData>,
          ),
          SrsStateData,
          PrefetchHooks Function()
        > {
  $$SrsStateTableTableManager(_$AppDatabase db, $SrsStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SrsStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SrsStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SrsStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> vocabId = const Value.absent(),
                Value<int> box = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<double> ease = const Value.absent(),
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<int> lastConfidence = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<DateTime> nextReviewAt = const Value.absent(),
              }) => SrsStateCompanion(
                id: id,
                vocabId: vocabId,
                box: box,
                repetitions: repetitions,
                ease: ease,
                stability: stability,
                difficulty: difficulty,
                lastConfidence: lastConfidence,
                lastReviewedAt: lastReviewedAt,
                nextReviewAt: nextReviewAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int vocabId,
                Value<int> box = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<double> ease = const Value.absent(),
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<int> lastConfidence = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                required DateTime nextReviewAt,
              }) => SrsStateCompanion.insert(
                id: id,
                vocabId: vocabId,
                box: box,
                repetitions: repetitions,
                ease: ease,
                stability: stability,
                difficulty: difficulty,
                lastConfidence: lastConfidence,
                lastReviewedAt: lastReviewedAt,
                nextReviewAt: nextReviewAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SrsStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SrsStateTable,
      SrsStateData,
      $$SrsStateTableFilterComposer,
      $$SrsStateTableOrderingComposer,
      $$SrsStateTableAnnotationComposer,
      $$SrsStateTableCreateCompanionBuilder,
      $$SrsStateTableUpdateCompanionBuilder,
      (
        SrsStateData,
        BaseReferences<_$AppDatabase, $SrsStateTable, SrsStateData>,
      ),
      SrsStateData,
      PrefetchHooks Function()
    >;
typedef $$KanjiSrsStateTableCreateCompanionBuilder =
    KanjiSrsStateCompanion Function({
      Value<int> id,
      required int kanjiId,
      Value<double> stability,
      Value<double> difficulty,
      Value<int> lastConfidence,
      Value<DateTime?> lastReviewedAt,
      required DateTime nextReviewAt,
    });
typedef $$KanjiSrsStateTableUpdateCompanionBuilder =
    KanjiSrsStateCompanion Function({
      Value<int> id,
      Value<int> kanjiId,
      Value<double> stability,
      Value<double> difficulty,
      Value<int> lastConfidence,
      Value<DateTime?> lastReviewedAt,
      Value<DateTime> nextReviewAt,
    });

class $$KanjiSrsStateTableFilterComposer
    extends Composer<_$AppDatabase, $KanjiSrsStateTable> {
  $$KanjiSrsStateTableFilterComposer({
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

  ColumnFilters<int> get kanjiId => $composableBuilder(
    column: $table.kanjiId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastConfidence => $composableBuilder(
    column: $table.lastConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KanjiSrsStateTableOrderingComposer
    extends Composer<_$AppDatabase, $KanjiSrsStateTable> {
  $$KanjiSrsStateTableOrderingComposer({
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

  ColumnOrderings<int> get kanjiId => $composableBuilder(
    column: $table.kanjiId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastConfidence => $composableBuilder(
    column: $table.lastConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KanjiSrsStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $KanjiSrsStateTable> {
  $$KanjiSrsStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get kanjiId =>
      $composableBuilder(column: $table.kanjiId, builder: (column) => column);

  GeneratedColumn<double> get stability =>
      $composableBuilder(column: $table.stability, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastConfidence => $composableBuilder(
    column: $table.lastConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => column,
  );
}

class $$KanjiSrsStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KanjiSrsStateTable,
          KanjiSrsStateData,
          $$KanjiSrsStateTableFilterComposer,
          $$KanjiSrsStateTableOrderingComposer,
          $$KanjiSrsStateTableAnnotationComposer,
          $$KanjiSrsStateTableCreateCompanionBuilder,
          $$KanjiSrsStateTableUpdateCompanionBuilder,
          (
            KanjiSrsStateData,
            BaseReferences<
              _$AppDatabase,
              $KanjiSrsStateTable,
              KanjiSrsStateData
            >,
          ),
          KanjiSrsStateData,
          PrefetchHooks Function()
        > {
  $$KanjiSrsStateTableTableManager(_$AppDatabase db, $KanjiSrsStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KanjiSrsStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KanjiSrsStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KanjiSrsStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> kanjiId = const Value.absent(),
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<int> lastConfidence = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<DateTime> nextReviewAt = const Value.absent(),
              }) => KanjiSrsStateCompanion(
                id: id,
                kanjiId: kanjiId,
                stability: stability,
                difficulty: difficulty,
                lastConfidence: lastConfidence,
                lastReviewedAt: lastReviewedAt,
                nextReviewAt: nextReviewAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int kanjiId,
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<int> lastConfidence = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                required DateTime nextReviewAt,
              }) => KanjiSrsStateCompanion.insert(
                id: id,
                kanjiId: kanjiId,
                stability: stability,
                difficulty: difficulty,
                lastConfidence: lastConfidence,
                lastReviewedAt: lastReviewedAt,
                nextReviewAt: nextReviewAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KanjiSrsStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KanjiSrsStateTable,
      KanjiSrsStateData,
      $$KanjiSrsStateTableFilterComposer,
      $$KanjiSrsStateTableOrderingComposer,
      $$KanjiSrsStateTableAnnotationComposer,
      $$KanjiSrsStateTableCreateCompanionBuilder,
      $$KanjiSrsStateTableUpdateCompanionBuilder,
      (
        KanjiSrsStateData,
        BaseReferences<_$AppDatabase, $KanjiSrsStateTable, KanjiSrsStateData>,
      ),
      KanjiSrsStateData,
      PrefetchHooks Function()
    >;
typedef $$KanaSrsStateTableCreateCompanionBuilder =
    KanaSrsStateCompanion Function({
      required String kana,
      required String script,
      Value<int> reps,
      Value<int> lapses,
      Value<double> stability,
      Value<double> difficulty,
      Value<DateTime?> dueAt,
      Value<DateTime?> lastReviewedAt,
      Value<int> rowid,
    });
typedef $$KanaSrsStateTableUpdateCompanionBuilder =
    KanaSrsStateCompanion Function({
      Value<String> kana,
      Value<String> script,
      Value<int> reps,
      Value<int> lapses,
      Value<double> stability,
      Value<double> difficulty,
      Value<DateTime?> dueAt,
      Value<DateTime?> lastReviewedAt,
      Value<int> rowid,
    });

class $$KanaSrsStateTableFilterComposer
    extends Composer<_$AppDatabase, $KanaSrsStateTable> {
  $$KanaSrsStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get kana => $composableBuilder(
    column: $table.kana,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get script => $composableBuilder(
    column: $table.script,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KanaSrsStateTableOrderingComposer
    extends Composer<_$AppDatabase, $KanaSrsStateTable> {
  $$KanaSrsStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get kana => $composableBuilder(
    column: $table.kana,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get script => $composableBuilder(
    column: $table.script,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KanaSrsStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $KanaSrsStateTable> {
  $$KanaSrsStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get kana =>
      $composableBuilder(column: $table.kana, builder: (column) => column);

  GeneratedColumn<String> get script =>
      $composableBuilder(column: $table.script, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get lapses =>
      $composableBuilder(column: $table.lapses, builder: (column) => column);

  GeneratedColumn<double> get stability =>
      $composableBuilder(column: $table.stability, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => column,
  );
}

class $$KanaSrsStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KanaSrsStateTable,
          KanaSrsStateData,
          $$KanaSrsStateTableFilterComposer,
          $$KanaSrsStateTableOrderingComposer,
          $$KanaSrsStateTableAnnotationComposer,
          $$KanaSrsStateTableCreateCompanionBuilder,
          $$KanaSrsStateTableUpdateCompanionBuilder,
          (
            KanaSrsStateData,
            BaseReferences<_$AppDatabase, $KanaSrsStateTable, KanaSrsStateData>,
          ),
          KanaSrsStateData,
          PrefetchHooks Function()
        > {
  $$KanaSrsStateTableTableManager(_$AppDatabase db, $KanaSrsStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KanaSrsStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KanaSrsStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KanaSrsStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> kana = const Value.absent(),
                Value<String> script = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KanaSrsStateCompanion(
                kana: kana,
                script: script,
                reps: reps,
                lapses: lapses,
                stability: stability,
                difficulty: difficulty,
                dueAt: dueAt,
                lastReviewedAt: lastReviewedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String kana,
                required String script,
                Value<int> reps = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KanaSrsStateCompanion.insert(
                kana: kana,
                script: script,
                reps: reps,
                lapses: lapses,
                stability: stability,
                difficulty: difficulty,
                dueAt: dueAt,
                lastReviewedAt: lastReviewedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KanaSrsStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KanaSrsStateTable,
      KanaSrsStateData,
      $$KanaSrsStateTableFilterComposer,
      $$KanaSrsStateTableOrderingComposer,
      $$KanaSrsStateTableAnnotationComposer,
      $$KanaSrsStateTableCreateCompanionBuilder,
      $$KanaSrsStateTableUpdateCompanionBuilder,
      (
        KanaSrsStateData,
        BaseReferences<_$AppDatabase, $KanaSrsStateTable, KanaSrsStateData>,
      ),
      KanaSrsStateData,
      PrefetchHooks Function()
    >;
typedef $$UserProgressTableCreateCompanionBuilder =
    UserProgressCompanion Function({
      Value<int> id,
      required DateTime day,
      Value<int> xp,
      Value<int> streak,
      Value<int> reviewedCount,
      Value<int> reviewAgainCount,
      Value<int> reviewHardCount,
      Value<int> reviewGoodCount,
      Value<int> reviewEasyCount,
    });
typedef $$UserProgressTableUpdateCompanionBuilder =
    UserProgressCompanion Function({
      Value<int> id,
      Value<DateTime> day,
      Value<int> xp,
      Value<int> streak,
      Value<int> reviewedCount,
      Value<int> reviewAgainCount,
      Value<int> reviewHardCount,
      Value<int> reviewGoodCount,
      Value<int> reviewEasyCount,
    });

class $$UserProgressTableFilterComposer
    extends Composer<_$AppDatabase, $UserProgressTable> {
  $$UserProgressTableFilterComposer({
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

  ColumnFilters<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streak => $composableBuilder(
    column: $table.streak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewedCount => $composableBuilder(
    column: $table.reviewedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewAgainCount => $composableBuilder(
    column: $table.reviewAgainCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewHardCount => $composableBuilder(
    column: $table.reviewHardCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewGoodCount => $composableBuilder(
    column: $table.reviewGoodCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewEasyCount => $composableBuilder(
    column: $table.reviewEasyCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProgressTable> {
  $$UserProgressTableOrderingComposer({
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

  ColumnOrderings<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streak => $composableBuilder(
    column: $table.streak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewedCount => $composableBuilder(
    column: $table.reviewedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewAgainCount => $composableBuilder(
    column: $table.reviewAgainCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewHardCount => $composableBuilder(
    column: $table.reviewHardCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewGoodCount => $composableBuilder(
    column: $table.reviewGoodCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewEasyCount => $composableBuilder(
    column: $table.reviewEasyCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProgressTable> {
  $$UserProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get xp =>
      $composableBuilder(column: $table.xp, builder: (column) => column);

  GeneratedColumn<int> get streak =>
      $composableBuilder(column: $table.streak, builder: (column) => column);

  GeneratedColumn<int> get reviewedCount => $composableBuilder(
    column: $table.reviewedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reviewAgainCount => $composableBuilder(
    column: $table.reviewAgainCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reviewHardCount => $composableBuilder(
    column: $table.reviewHardCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reviewGoodCount => $composableBuilder(
    column: $table.reviewGoodCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reviewEasyCount => $composableBuilder(
    column: $table.reviewEasyCount,
    builder: (column) => column,
  );
}

class $$UserProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProgressTable,
          UserProgressData,
          $$UserProgressTableFilterComposer,
          $$UserProgressTableOrderingComposer,
          $$UserProgressTableAnnotationComposer,
          $$UserProgressTableCreateCompanionBuilder,
          $$UserProgressTableUpdateCompanionBuilder,
          (
            UserProgressData,
            BaseReferences<_$AppDatabase, $UserProgressTable, UserProgressData>,
          ),
          UserProgressData,
          PrefetchHooks Function()
        > {
  $$UserProgressTableTableManager(_$AppDatabase db, $UserProgressTable table)
    : super(
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
                Value<int> id = const Value.absent(),
                Value<DateTime> day = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<int> streak = const Value.absent(),
                Value<int> reviewedCount = const Value.absent(),
                Value<int> reviewAgainCount = const Value.absent(),
                Value<int> reviewHardCount = const Value.absent(),
                Value<int> reviewGoodCount = const Value.absent(),
                Value<int> reviewEasyCount = const Value.absent(),
              }) => UserProgressCompanion(
                id: id,
                day: day,
                xp: xp,
                streak: streak,
                reviewedCount: reviewedCount,
                reviewAgainCount: reviewAgainCount,
                reviewHardCount: reviewHardCount,
                reviewGoodCount: reviewGoodCount,
                reviewEasyCount: reviewEasyCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime day,
                Value<int> xp = const Value.absent(),
                Value<int> streak = const Value.absent(),
                Value<int> reviewedCount = const Value.absent(),
                Value<int> reviewAgainCount = const Value.absent(),
                Value<int> reviewHardCount = const Value.absent(),
                Value<int> reviewGoodCount = const Value.absent(),
                Value<int> reviewEasyCount = const Value.absent(),
              }) => UserProgressCompanion.insert(
                id: id,
                day: day,
                xp: xp,
                streak: streak,
                reviewedCount: reviewedCount,
                reviewAgainCount: reviewAgainCount,
                reviewHardCount: reviewHardCount,
                reviewGoodCount: reviewGoodCount,
                reviewEasyCount: reviewEasyCount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProgressTable,
      UserProgressData,
      $$UserProgressTableFilterComposer,
      $$UserProgressTableOrderingComposer,
      $$UserProgressTableAnnotationComposer,
      $$UserProgressTableCreateCompanionBuilder,
      $$UserProgressTableUpdateCompanionBuilder,
      (
        UserProgressData,
        BaseReferences<_$AppDatabase, $UserProgressTable, UserProgressData>,
      ),
      UserProgressData,
      PrefetchHooks Function()
    >;
typedef $$AttemptTableCreateCompanionBuilder =
    AttemptCompanion Function({
      Value<int> id,
      required String mode,
      required String level,
      required DateTime startedAt,
      Value<DateTime?> finishedAt,
      Value<int?> score,
      Value<int?> total,
    });
typedef $$AttemptTableUpdateCompanionBuilder =
    AttemptCompanion Function({
      Value<int> id,
      Value<String> mode,
      Value<String> level,
      Value<DateTime> startedAt,
      Value<DateTime?> finishedAt,
      Value<int?> score,
      Value<int?> total,
    });

final class $$AttemptTableReferences
    extends BaseReferences<_$AppDatabase, $AttemptTable, AttemptData> {
  $$AttemptTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AttemptAnswerTable, List<AttemptAnswerData>>
  _attemptAnswerRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attemptAnswer,
    aliasName: $_aliasNameGenerator(db.attempt.id, db.attemptAnswer.attemptId),
  );

  $$AttemptAnswerTableProcessedTableManager get attemptAnswerRefs {
    final manager = $$AttemptAnswerTableTableManager(
      $_db,
      $_db.attemptAnswer,
    ).filter((f) => f.attemptId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_attemptAnswerRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AttemptTableFilterComposer
    extends Composer<_$AppDatabase, $AttemptTable> {
  $$AttemptTableFilterComposer({
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

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> attemptAnswerRefs(
    Expression<bool> Function($$AttemptAnswerTableFilterComposer f) f,
  ) {
    final $$AttemptAnswerTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attemptAnswer,
      getReferencedColumn: (t) => t.attemptId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptAnswerTableFilterComposer(
            $db: $db,
            $table: $db.attemptAnswer,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AttemptTableOrderingComposer
    extends Composer<_$AppDatabase, $AttemptTable> {
  $$AttemptTableOrderingComposer({
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

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttemptTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttemptTable> {
  $$AttemptTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  Expression<T> attemptAnswerRefs<T extends Object>(
    Expression<T> Function($$AttemptAnswerTableAnnotationComposer a) f,
  ) {
    final $$AttemptAnswerTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attemptAnswer,
      getReferencedColumn: (t) => t.attemptId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptAnswerTableAnnotationComposer(
            $db: $db,
            $table: $db.attemptAnswer,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AttemptTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttemptTable,
          AttemptData,
          $$AttemptTableFilterComposer,
          $$AttemptTableOrderingComposer,
          $$AttemptTableAnnotationComposer,
          $$AttemptTableCreateCompanionBuilder,
          $$AttemptTableUpdateCompanionBuilder,
          (AttemptData, $$AttemptTableReferences),
          AttemptData,
          PrefetchHooks Function({bool attemptAnswerRefs})
        > {
  $$AttemptTableTableManager(_$AppDatabase db, $AttemptTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttemptTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttemptTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttemptTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int?> score = const Value.absent(),
                Value<int?> total = const Value.absent(),
              }) => AttemptCompanion(
                id: id,
                mode: mode,
                level: level,
                startedAt: startedAt,
                finishedAt: finishedAt,
                score: score,
                total: total,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String mode,
                required String level,
                required DateTime startedAt,
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int?> score = const Value.absent(),
                Value<int?> total = const Value.absent(),
              }) => AttemptCompanion.insert(
                id: id,
                mode: mode,
                level: level,
                startedAt: startedAt,
                finishedAt: finishedAt,
                score: score,
                total: total,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttemptTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({attemptAnswerRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (attemptAnswerRefs) db.attemptAnswer,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (attemptAnswerRefs)
                    await $_getPrefetchedData<
                      AttemptData,
                      $AttemptTable,
                      AttemptAnswerData
                    >(
                      currentTable: table,
                      referencedTable: $$AttemptTableReferences
                          ._attemptAnswerRefsTable(db),
                      managerFromTypedResult: (p0) => $$AttemptTableReferences(
                        db,
                        table,
                        p0,
                      ).attemptAnswerRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.attemptId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AttemptTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttemptTable,
      AttemptData,
      $$AttemptTableFilterComposer,
      $$AttemptTableOrderingComposer,
      $$AttemptTableAnnotationComposer,
      $$AttemptTableCreateCompanionBuilder,
      $$AttemptTableUpdateCompanionBuilder,
      (AttemptData, $$AttemptTableReferences),
      AttemptData,
      PrefetchHooks Function({bool attemptAnswerRefs})
    >;
typedef $$AttemptAnswerTableCreateCompanionBuilder =
    AttemptAnswerCompanion Function({
      Value<int> id,
      required int attemptId,
      required int questionId,
      required int selectedIndex,
      required bool isCorrect,
    });
typedef $$AttemptAnswerTableUpdateCompanionBuilder =
    AttemptAnswerCompanion Function({
      Value<int> id,
      Value<int> attemptId,
      Value<int> questionId,
      Value<int> selectedIndex,
      Value<bool> isCorrect,
    });

final class $$AttemptAnswerTableReferences
    extends
        BaseReferences<_$AppDatabase, $AttemptAnswerTable, AttemptAnswerData> {
  $$AttemptAnswerTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AttemptTable _attemptIdTable(_$AppDatabase db) =>
      db.attempt.createAlias(
        $_aliasNameGenerator(db.attemptAnswer.attemptId, db.attempt.id),
      );

  $$AttemptTableProcessedTableManager get attemptId {
    final $_column = $_itemColumn<int>('attempt_id')!;

    final manager = $$AttemptTableTableManager(
      $_db,
      $_db.attempt,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_attemptIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttemptAnswerTableFilterComposer
    extends Composer<_$AppDatabase, $AttemptAnswerTable> {
  $$AttemptAnswerTableFilterComposer({
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

  ColumnFilters<int> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get selectedIndex => $composableBuilder(
    column: $table.selectedIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnFilters(column),
  );

  $$AttemptTableFilterComposer get attemptId {
    final $$AttemptTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attemptId,
      referencedTable: $db.attempt,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptTableFilterComposer(
            $db: $db,
            $table: $db.attempt,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttemptAnswerTableOrderingComposer
    extends Composer<_$AppDatabase, $AttemptAnswerTable> {
  $$AttemptAnswerTableOrderingComposer({
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

  ColumnOrderings<int> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get selectedIndex => $composableBuilder(
    column: $table.selectedIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  $$AttemptTableOrderingComposer get attemptId {
    final $$AttemptTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attemptId,
      referencedTable: $db.attempt,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptTableOrderingComposer(
            $db: $db,
            $table: $db.attempt,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttemptAnswerTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttemptAnswerTable> {
  $$AttemptAnswerTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get selectedIndex => $composableBuilder(
    column: $table.selectedIndex,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  $$AttemptTableAnnotationComposer get attemptId {
    final $$AttemptTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attemptId,
      referencedTable: $db.attempt,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptTableAnnotationComposer(
            $db: $db,
            $table: $db.attempt,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttemptAnswerTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttemptAnswerTable,
          AttemptAnswerData,
          $$AttemptAnswerTableFilterComposer,
          $$AttemptAnswerTableOrderingComposer,
          $$AttemptAnswerTableAnnotationComposer,
          $$AttemptAnswerTableCreateCompanionBuilder,
          $$AttemptAnswerTableUpdateCompanionBuilder,
          (AttemptAnswerData, $$AttemptAnswerTableReferences),
          AttemptAnswerData,
          PrefetchHooks Function({bool attemptId})
        > {
  $$AttemptAnswerTableTableManager(_$AppDatabase db, $AttemptAnswerTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttemptAnswerTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttemptAnswerTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttemptAnswerTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> attemptId = const Value.absent(),
                Value<int> questionId = const Value.absent(),
                Value<int> selectedIndex = const Value.absent(),
                Value<bool> isCorrect = const Value.absent(),
              }) => AttemptAnswerCompanion(
                id: id,
                attemptId: attemptId,
                questionId: questionId,
                selectedIndex: selectedIndex,
                isCorrect: isCorrect,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int attemptId,
                required int questionId,
                required int selectedIndex,
                required bool isCorrect,
              }) => AttemptAnswerCompanion.insert(
                id: id,
                attemptId: attemptId,
                questionId: questionId,
                selectedIndex: selectedIndex,
                isCorrect: isCorrect,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttemptAnswerTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({attemptId = false}) {
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
                    if (attemptId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.attemptId,
                                referencedTable: $$AttemptAnswerTableReferences
                                    ._attemptIdTable(db),
                                referencedColumn: $$AttemptAnswerTableReferences
                                    ._attemptIdTable(db)
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

typedef $$AttemptAnswerTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttemptAnswerTable,
      AttemptAnswerData,
      $$AttemptAnswerTableFilterComposer,
      $$AttemptAnswerTableOrderingComposer,
      $$AttemptAnswerTableAnnotationComposer,
      $$AttemptAnswerTableCreateCompanionBuilder,
      $$AttemptAnswerTableUpdateCompanionBuilder,
      (AttemptAnswerData, $$AttemptAnswerTableReferences),
      AttemptAnswerData,
      PrefetchHooks Function({bool attemptId})
    >;
typedef $$GrammarPointsTableCreateCompanionBuilder =
    GrammarPointsCompanion Function({
      Value<int> id,
      Value<int?> lessonId,
      required String grammarPoint,
      Value<String?> titleEn,
      required String meaning,
      Value<String?> meaningVi,
      Value<String?> meaningEn,
      required String connection,
      Value<String?> connectionEn,
      required String explanation,
      Value<String?> explanationVi,
      Value<String?> explanationEn,
      required String jlptLevel,
      Value<bool> isLearned,
    });
typedef $$GrammarPointsTableUpdateCompanionBuilder =
    GrammarPointsCompanion Function({
      Value<int> id,
      Value<int?> lessonId,
      Value<String> grammarPoint,
      Value<String?> titleEn,
      Value<String> meaning,
      Value<String?> meaningVi,
      Value<String?> meaningEn,
      Value<String> connection,
      Value<String?> connectionEn,
      Value<String> explanation,
      Value<String?> explanationVi,
      Value<String?> explanationEn,
      Value<String> jlptLevel,
      Value<bool> isLearned,
    });

final class $$GrammarPointsTableReferences
    extends BaseReferences<_$AppDatabase, $GrammarPointsTable, GrammarPoint> {
  $$GrammarPointsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$GrammarExamplesTable, List<GrammarExample>>
  _grammarExamplesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.grammarExamples,
    aliasName: $_aliasNameGenerator(
      db.grammarPoints.id,
      db.grammarExamples.grammarId,
    ),
  );

  $$GrammarExamplesTableProcessedTableManager get grammarExamplesRefs {
    final manager = $$GrammarExamplesTableTableManager(
      $_db,
      $_db.grammarExamples,
    ).filter((f) => f.grammarId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _grammarExamplesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GrammarSrsStateTable, List<GrammarSrsStateData>>
  _grammarSrsStateRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.grammarSrsState,
    aliasName: $_aliasNameGenerator(
      db.grammarPoints.id,
      db.grammarSrsState.grammarId,
    ),
  );

  $$GrammarSrsStateTableProcessedTableManager get grammarSrsStateRefs {
    final manager = $$GrammarSrsStateTableTableManager(
      $_db,
      $_db.grammarSrsState,
    ).filter((f) => f.grammarId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _grammarSrsStateRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GrammarQuestionsTable, List<GrammarQuestion>>
  _grammarQuestionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.grammarQuestions,
    aliasName: $_aliasNameGenerator(
      db.grammarPoints.id,
      db.grammarQuestions.grammarId,
    ),
  );

  $$GrammarQuestionsTableProcessedTableManager get grammarQuestionsRefs {
    final manager = $$GrammarQuestionsTableTableManager(
      $_db,
      $_db.grammarQuestions,
    ).filter((f) => f.grammarId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _grammarQuestionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GrammarPointsTableFilterComposer
    extends Composer<_$AppDatabase, $GrammarPointsTable> {
  $$GrammarPointsTableFilterComposer({
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

  ColumnFilters<String> get grammarPoint => $composableBuilder(
    column: $table.grammarPoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleEn => $composableBuilder(
    column: $table.titleEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaningVi => $composableBuilder(
    column: $table.meaningVi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaningEn => $composableBuilder(
    column: $table.meaningEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get connection => $composableBuilder(
    column: $table.connection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get connectionEn => $composableBuilder(
    column: $table.connectionEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanationVi => $composableBuilder(
    column: $table.explanationVi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanationEn => $composableBuilder(
    column: $table.explanationEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jlptLevel => $composableBuilder(
    column: $table.jlptLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLearned => $composableBuilder(
    column: $table.isLearned,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> grammarExamplesRefs(
    Expression<bool> Function($$GrammarExamplesTableFilterComposer f) f,
  ) {
    final $$GrammarExamplesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.grammarExamples,
      getReferencedColumn: (t) => t.grammarId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrammarExamplesTableFilterComposer(
            $db: $db,
            $table: $db.grammarExamples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> grammarSrsStateRefs(
    Expression<bool> Function($$GrammarSrsStateTableFilterComposer f) f,
  ) {
    final $$GrammarSrsStateTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.grammarSrsState,
      getReferencedColumn: (t) => t.grammarId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrammarSrsStateTableFilterComposer(
            $db: $db,
            $table: $db.grammarSrsState,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> grammarQuestionsRefs(
    Expression<bool> Function($$GrammarQuestionsTableFilterComposer f) f,
  ) {
    final $$GrammarQuestionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.grammarQuestions,
      getReferencedColumn: (t) => t.grammarId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrammarQuestionsTableFilterComposer(
            $db: $db,
            $table: $db.grammarQuestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GrammarPointsTableOrderingComposer
    extends Composer<_$AppDatabase, $GrammarPointsTable> {
  $$GrammarPointsTableOrderingComposer({
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

  ColumnOrderings<String> get grammarPoint => $composableBuilder(
    column: $table.grammarPoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleEn => $composableBuilder(
    column: $table.titleEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaningVi => $composableBuilder(
    column: $table.meaningVi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaningEn => $composableBuilder(
    column: $table.meaningEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get connection => $composableBuilder(
    column: $table.connection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get connectionEn => $composableBuilder(
    column: $table.connectionEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanationVi => $composableBuilder(
    column: $table.explanationVi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanationEn => $composableBuilder(
    column: $table.explanationEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jlptLevel => $composableBuilder(
    column: $table.jlptLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLearned => $composableBuilder(
    column: $table.isLearned,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GrammarPointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GrammarPointsTable> {
  $$GrammarPointsTableAnnotationComposer({
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

  GeneratedColumn<String> get grammarPoint => $composableBuilder(
    column: $table.grammarPoint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get titleEn =>
      $composableBuilder(column: $table.titleEn, builder: (column) => column);

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumn<String> get meaningVi =>
      $composableBuilder(column: $table.meaningVi, builder: (column) => column);

  GeneratedColumn<String> get meaningEn =>
      $composableBuilder(column: $table.meaningEn, builder: (column) => column);

  GeneratedColumn<String> get connection => $composableBuilder(
    column: $table.connection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get connectionEn => $composableBuilder(
    column: $table.connectionEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get explanationVi => $composableBuilder(
    column: $table.explanationVi,
    builder: (column) => column,
  );

  GeneratedColumn<String> get explanationEn => $composableBuilder(
    column: $table.explanationEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jlptLevel =>
      $composableBuilder(column: $table.jlptLevel, builder: (column) => column);

  GeneratedColumn<bool> get isLearned =>
      $composableBuilder(column: $table.isLearned, builder: (column) => column);

  Expression<T> grammarExamplesRefs<T extends Object>(
    Expression<T> Function($$GrammarExamplesTableAnnotationComposer a) f,
  ) {
    final $$GrammarExamplesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.grammarExamples,
      getReferencedColumn: (t) => t.grammarId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrammarExamplesTableAnnotationComposer(
            $db: $db,
            $table: $db.grammarExamples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> grammarSrsStateRefs<T extends Object>(
    Expression<T> Function($$GrammarSrsStateTableAnnotationComposer a) f,
  ) {
    final $$GrammarSrsStateTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.grammarSrsState,
      getReferencedColumn: (t) => t.grammarId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrammarSrsStateTableAnnotationComposer(
            $db: $db,
            $table: $db.grammarSrsState,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> grammarQuestionsRefs<T extends Object>(
    Expression<T> Function($$GrammarQuestionsTableAnnotationComposer a) f,
  ) {
    final $$GrammarQuestionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.grammarQuestions,
      getReferencedColumn: (t) => t.grammarId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrammarQuestionsTableAnnotationComposer(
            $db: $db,
            $table: $db.grammarQuestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GrammarPointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GrammarPointsTable,
          GrammarPoint,
          $$GrammarPointsTableFilterComposer,
          $$GrammarPointsTableOrderingComposer,
          $$GrammarPointsTableAnnotationComposer,
          $$GrammarPointsTableCreateCompanionBuilder,
          $$GrammarPointsTableUpdateCompanionBuilder,
          (GrammarPoint, $$GrammarPointsTableReferences),
          GrammarPoint,
          PrefetchHooks Function({
            bool grammarExamplesRefs,
            bool grammarSrsStateRefs,
            bool grammarQuestionsRefs,
          })
        > {
  $$GrammarPointsTableTableManager(_$AppDatabase db, $GrammarPointsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GrammarPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GrammarPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GrammarPointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> lessonId = const Value.absent(),
                Value<String> grammarPoint = const Value.absent(),
                Value<String?> titleEn = const Value.absent(),
                Value<String> meaning = const Value.absent(),
                Value<String?> meaningVi = const Value.absent(),
                Value<String?> meaningEn = const Value.absent(),
                Value<String> connection = const Value.absent(),
                Value<String?> connectionEn = const Value.absent(),
                Value<String> explanation = const Value.absent(),
                Value<String?> explanationVi = const Value.absent(),
                Value<String?> explanationEn = const Value.absent(),
                Value<String> jlptLevel = const Value.absent(),
                Value<bool> isLearned = const Value.absent(),
              }) => GrammarPointsCompanion(
                id: id,
                lessonId: lessonId,
                grammarPoint: grammarPoint,
                titleEn: titleEn,
                meaning: meaning,
                meaningVi: meaningVi,
                meaningEn: meaningEn,
                connection: connection,
                connectionEn: connectionEn,
                explanation: explanation,
                explanationVi: explanationVi,
                explanationEn: explanationEn,
                jlptLevel: jlptLevel,
                isLearned: isLearned,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> lessonId = const Value.absent(),
                required String grammarPoint,
                Value<String?> titleEn = const Value.absent(),
                required String meaning,
                Value<String?> meaningVi = const Value.absent(),
                Value<String?> meaningEn = const Value.absent(),
                required String connection,
                Value<String?> connectionEn = const Value.absent(),
                required String explanation,
                Value<String?> explanationVi = const Value.absent(),
                Value<String?> explanationEn = const Value.absent(),
                required String jlptLevel,
                Value<bool> isLearned = const Value.absent(),
              }) => GrammarPointsCompanion.insert(
                id: id,
                lessonId: lessonId,
                grammarPoint: grammarPoint,
                titleEn: titleEn,
                meaning: meaning,
                meaningVi: meaningVi,
                meaningEn: meaningEn,
                connection: connection,
                connectionEn: connectionEn,
                explanation: explanation,
                explanationVi: explanationVi,
                explanationEn: explanationEn,
                jlptLevel: jlptLevel,
                isLearned: isLearned,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GrammarPointsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                grammarExamplesRefs = false,
                grammarSrsStateRefs = false,
                grammarQuestionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (grammarExamplesRefs) db.grammarExamples,
                    if (grammarSrsStateRefs) db.grammarSrsState,
                    if (grammarQuestionsRefs) db.grammarQuestions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (grammarExamplesRefs)
                        await $_getPrefetchedData<
                          GrammarPoint,
                          $GrammarPointsTable,
                          GrammarExample
                        >(
                          currentTable: table,
                          referencedTable: $$GrammarPointsTableReferences
                              ._grammarExamplesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GrammarPointsTableReferences(
                                db,
                                table,
                                p0,
                              ).grammarExamplesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.grammarId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (grammarSrsStateRefs)
                        await $_getPrefetchedData<
                          GrammarPoint,
                          $GrammarPointsTable,
                          GrammarSrsStateData
                        >(
                          currentTable: table,
                          referencedTable: $$GrammarPointsTableReferences
                              ._grammarSrsStateRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GrammarPointsTableReferences(
                                db,
                                table,
                                p0,
                              ).grammarSrsStateRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.grammarId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (grammarQuestionsRefs)
                        await $_getPrefetchedData<
                          GrammarPoint,
                          $GrammarPointsTable,
                          GrammarQuestion
                        >(
                          currentTable: table,
                          referencedTable: $$GrammarPointsTableReferences
                              ._grammarQuestionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GrammarPointsTableReferences(
                                db,
                                table,
                                p0,
                              ).grammarQuestionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.grammarId == item.id,
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

typedef $$GrammarPointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GrammarPointsTable,
      GrammarPoint,
      $$GrammarPointsTableFilterComposer,
      $$GrammarPointsTableOrderingComposer,
      $$GrammarPointsTableAnnotationComposer,
      $$GrammarPointsTableCreateCompanionBuilder,
      $$GrammarPointsTableUpdateCompanionBuilder,
      (GrammarPoint, $$GrammarPointsTableReferences),
      GrammarPoint,
      PrefetchHooks Function({
        bool grammarExamplesRefs,
        bool grammarSrsStateRefs,
        bool grammarQuestionsRefs,
      })
    >;
typedef $$GrammarExamplesTableCreateCompanionBuilder =
    GrammarExamplesCompanion Function({
      Value<int> id,
      required int grammarId,
      required String japanese,
      required String translation,
      Value<String?> translationVi,
      Value<String?> translationEn,
    });
typedef $$GrammarExamplesTableUpdateCompanionBuilder =
    GrammarExamplesCompanion Function({
      Value<int> id,
      Value<int> grammarId,
      Value<String> japanese,
      Value<String> translation,
      Value<String?> translationVi,
      Value<String?> translationEn,
    });

final class $$GrammarExamplesTableReferences
    extends
        BaseReferences<_$AppDatabase, $GrammarExamplesTable, GrammarExample> {
  $$GrammarExamplesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GrammarPointsTable _grammarIdTable(_$AppDatabase db) =>
      db.grammarPoints.createAlias(
        $_aliasNameGenerator(db.grammarExamples.grammarId, db.grammarPoints.id),
      );

  $$GrammarPointsTableProcessedTableManager get grammarId {
    final $_column = $_itemColumn<int>('grammar_id')!;

    final manager = $$GrammarPointsTableTableManager(
      $_db,
      $_db.grammarPoints,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_grammarIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GrammarExamplesTableFilterComposer
    extends Composer<_$AppDatabase, $GrammarExamplesTable> {
  $$GrammarExamplesTableFilterComposer({
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

  ColumnFilters<String> get japanese => $composableBuilder(
    column: $table.japanese,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translationVi => $composableBuilder(
    column: $table.translationVi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translationEn => $composableBuilder(
    column: $table.translationEn,
    builder: (column) => ColumnFilters(column),
  );

  $$GrammarPointsTableFilterComposer get grammarId {
    final $$GrammarPointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.grammarId,
      referencedTable: $db.grammarPoints,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrammarPointsTableFilterComposer(
            $db: $db,
            $table: $db.grammarPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GrammarExamplesTableOrderingComposer
    extends Composer<_$AppDatabase, $GrammarExamplesTable> {
  $$GrammarExamplesTableOrderingComposer({
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

  ColumnOrderings<String> get japanese => $composableBuilder(
    column: $table.japanese,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translationVi => $composableBuilder(
    column: $table.translationVi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translationEn => $composableBuilder(
    column: $table.translationEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$GrammarPointsTableOrderingComposer get grammarId {
    final $$GrammarPointsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.grammarId,
      referencedTable: $db.grammarPoints,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrammarPointsTableOrderingComposer(
            $db: $db,
            $table: $db.grammarPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GrammarExamplesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GrammarExamplesTable> {
  $$GrammarExamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get japanese =>
      $composableBuilder(column: $table.japanese, builder: (column) => column);

  GeneratedColumn<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get translationVi => $composableBuilder(
    column: $table.translationVi,
    builder: (column) => column,
  );

  GeneratedColumn<String> get translationEn => $composableBuilder(
    column: $table.translationEn,
    builder: (column) => column,
  );

  $$GrammarPointsTableAnnotationComposer get grammarId {
    final $$GrammarPointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.grammarId,
      referencedTable: $db.grammarPoints,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrammarPointsTableAnnotationComposer(
            $db: $db,
            $table: $db.grammarPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GrammarExamplesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GrammarExamplesTable,
          GrammarExample,
          $$GrammarExamplesTableFilterComposer,
          $$GrammarExamplesTableOrderingComposer,
          $$GrammarExamplesTableAnnotationComposer,
          $$GrammarExamplesTableCreateCompanionBuilder,
          $$GrammarExamplesTableUpdateCompanionBuilder,
          (GrammarExample, $$GrammarExamplesTableReferences),
          GrammarExample,
          PrefetchHooks Function({bool grammarId})
        > {
  $$GrammarExamplesTableTableManager(
    _$AppDatabase db,
    $GrammarExamplesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GrammarExamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GrammarExamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GrammarExamplesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> grammarId = const Value.absent(),
                Value<String> japanese = const Value.absent(),
                Value<String> translation = const Value.absent(),
                Value<String?> translationVi = const Value.absent(),
                Value<String?> translationEn = const Value.absent(),
              }) => GrammarExamplesCompanion(
                id: id,
                grammarId: grammarId,
                japanese: japanese,
                translation: translation,
                translationVi: translationVi,
                translationEn: translationEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int grammarId,
                required String japanese,
                required String translation,
                Value<String?> translationVi = const Value.absent(),
                Value<String?> translationEn = const Value.absent(),
              }) => GrammarExamplesCompanion.insert(
                id: id,
                grammarId: grammarId,
                japanese: japanese,
                translation: translation,
                translationVi: translationVi,
                translationEn: translationEn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GrammarExamplesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({grammarId = false}) {
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
                    if (grammarId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.grammarId,
                                referencedTable:
                                    $$GrammarExamplesTableReferences
                                        ._grammarIdTable(db),
                                referencedColumn:
                                    $$GrammarExamplesTableReferences
                                        ._grammarIdTable(db)
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

typedef $$GrammarExamplesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GrammarExamplesTable,
      GrammarExample,
      $$GrammarExamplesTableFilterComposer,
      $$GrammarExamplesTableOrderingComposer,
      $$GrammarExamplesTableAnnotationComposer,
      $$GrammarExamplesTableCreateCompanionBuilder,
      $$GrammarExamplesTableUpdateCompanionBuilder,
      (GrammarExample, $$GrammarExamplesTableReferences),
      GrammarExample,
      PrefetchHooks Function({bool grammarId})
    >;
typedef $$GrammarSrsStateTableCreateCompanionBuilder =
    GrammarSrsStateCompanion Function({
      Value<int> id,
      required int grammarId,
      Value<int> streak,
      Value<double> ease,
      Value<double> stability,
      Value<double> difficulty,
      required DateTime nextReviewAt,
      Value<DateTime?> lastReviewedAt,
      Value<int> ghostReviewsDue,
    });
typedef $$GrammarSrsStateTableUpdateCompanionBuilder =
    GrammarSrsStateCompanion Function({
      Value<int> id,
      Value<int> grammarId,
      Value<int> streak,
      Value<double> ease,
      Value<double> stability,
      Value<double> difficulty,
      Value<DateTime> nextReviewAt,
      Value<DateTime?> lastReviewedAt,
      Value<int> ghostReviewsDue,
    });

final class $$GrammarSrsStateTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $GrammarSrsStateTable,
          GrammarSrsStateData
        > {
  $$GrammarSrsStateTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GrammarPointsTable _grammarIdTable(_$AppDatabase db) =>
      db.grammarPoints.createAlias(
        $_aliasNameGenerator(db.grammarSrsState.grammarId, db.grammarPoints.id),
      );

  $$GrammarPointsTableProcessedTableManager get grammarId {
    final $_column = $_itemColumn<int>('grammar_id')!;

    final manager = $$GrammarPointsTableTableManager(
      $_db,
      $_db.grammarPoints,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_grammarIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GrammarSrsStateTableFilterComposer
    extends Composer<_$AppDatabase, $GrammarSrsStateTable> {
  $$GrammarSrsStateTableFilterComposer({
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

  ColumnFilters<int> get streak => $composableBuilder(
    column: $table.streak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ease => $composableBuilder(
    column: $table.ease,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ghostReviewsDue => $composableBuilder(
    column: $table.ghostReviewsDue,
    builder: (column) => ColumnFilters(column),
  );

  $$GrammarPointsTableFilterComposer get grammarId {
    final $$GrammarPointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.grammarId,
      referencedTable: $db.grammarPoints,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrammarPointsTableFilterComposer(
            $db: $db,
            $table: $db.grammarPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GrammarSrsStateTableOrderingComposer
    extends Composer<_$AppDatabase, $GrammarSrsStateTable> {
  $$GrammarSrsStateTableOrderingComposer({
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

  ColumnOrderings<int> get streak => $composableBuilder(
    column: $table.streak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ease => $composableBuilder(
    column: $table.ease,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ghostReviewsDue => $composableBuilder(
    column: $table.ghostReviewsDue,
    builder: (column) => ColumnOrderings(column),
  );

  $$GrammarPointsTableOrderingComposer get grammarId {
    final $$GrammarPointsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.grammarId,
      referencedTable: $db.grammarPoints,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrammarPointsTableOrderingComposer(
            $db: $db,
            $table: $db.grammarPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GrammarSrsStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $GrammarSrsStateTable> {
  $$GrammarSrsStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get streak =>
      $composableBuilder(column: $table.streak, builder: (column) => column);

  GeneratedColumn<double> get ease =>
      $composableBuilder(column: $table.ease, builder: (column) => column);

  GeneratedColumn<double> get stability =>
      $composableBuilder(column: $table.stability, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ghostReviewsDue => $composableBuilder(
    column: $table.ghostReviewsDue,
    builder: (column) => column,
  );

  $$GrammarPointsTableAnnotationComposer get grammarId {
    final $$GrammarPointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.grammarId,
      referencedTable: $db.grammarPoints,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrammarPointsTableAnnotationComposer(
            $db: $db,
            $table: $db.grammarPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GrammarSrsStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GrammarSrsStateTable,
          GrammarSrsStateData,
          $$GrammarSrsStateTableFilterComposer,
          $$GrammarSrsStateTableOrderingComposer,
          $$GrammarSrsStateTableAnnotationComposer,
          $$GrammarSrsStateTableCreateCompanionBuilder,
          $$GrammarSrsStateTableUpdateCompanionBuilder,
          (GrammarSrsStateData, $$GrammarSrsStateTableReferences),
          GrammarSrsStateData,
          PrefetchHooks Function({bool grammarId})
        > {
  $$GrammarSrsStateTableTableManager(
    _$AppDatabase db,
    $GrammarSrsStateTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GrammarSrsStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GrammarSrsStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GrammarSrsStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> grammarId = const Value.absent(),
                Value<int> streak = const Value.absent(),
                Value<double> ease = const Value.absent(),
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<DateTime> nextReviewAt = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<int> ghostReviewsDue = const Value.absent(),
              }) => GrammarSrsStateCompanion(
                id: id,
                grammarId: grammarId,
                streak: streak,
                ease: ease,
                stability: stability,
                difficulty: difficulty,
                nextReviewAt: nextReviewAt,
                lastReviewedAt: lastReviewedAt,
                ghostReviewsDue: ghostReviewsDue,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int grammarId,
                Value<int> streak = const Value.absent(),
                Value<double> ease = const Value.absent(),
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                required DateTime nextReviewAt,
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<int> ghostReviewsDue = const Value.absent(),
              }) => GrammarSrsStateCompanion.insert(
                id: id,
                grammarId: grammarId,
                streak: streak,
                ease: ease,
                stability: stability,
                difficulty: difficulty,
                nextReviewAt: nextReviewAt,
                lastReviewedAt: lastReviewedAt,
                ghostReviewsDue: ghostReviewsDue,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GrammarSrsStateTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({grammarId = false}) {
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
                    if (grammarId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.grammarId,
                                referencedTable:
                                    $$GrammarSrsStateTableReferences
                                        ._grammarIdTable(db),
                                referencedColumn:
                                    $$GrammarSrsStateTableReferences
                                        ._grammarIdTable(db)
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

typedef $$GrammarSrsStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GrammarSrsStateTable,
      GrammarSrsStateData,
      $$GrammarSrsStateTableFilterComposer,
      $$GrammarSrsStateTableOrderingComposer,
      $$GrammarSrsStateTableAnnotationComposer,
      $$GrammarSrsStateTableCreateCompanionBuilder,
      $$GrammarSrsStateTableUpdateCompanionBuilder,
      (GrammarSrsStateData, $$GrammarSrsStateTableReferences),
      GrammarSrsStateData,
      PrefetchHooks Function({bool grammarId})
    >;
typedef $$GrammarQuestionsTableCreateCompanionBuilder =
    GrammarQuestionsCompanion Function({
      Value<int> id,
      required int grammarId,
      required String type,
      required String question,
      required String correctAnswer,
      Value<String?> optionsJson,
      Value<String?> correctOrderJson,
      Value<String?> explanation,
    });
typedef $$GrammarQuestionsTableUpdateCompanionBuilder =
    GrammarQuestionsCompanion Function({
      Value<int> id,
      Value<int> grammarId,
      Value<String> type,
      Value<String> question,
      Value<String> correctAnswer,
      Value<String?> optionsJson,
      Value<String?> correctOrderJson,
      Value<String?> explanation,
    });

final class $$GrammarQuestionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $GrammarQuestionsTable, GrammarQuestion> {
  $$GrammarQuestionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GrammarPointsTable _grammarIdTable(_$AppDatabase db) =>
      db.grammarPoints.createAlias(
        $_aliasNameGenerator(
          db.grammarQuestions.grammarId,
          db.grammarPoints.id,
        ),
      );

  $$GrammarPointsTableProcessedTableManager get grammarId {
    final $_column = $_itemColumn<int>('grammar_id')!;

    final manager = $$GrammarPointsTableTableManager(
      $_db,
      $_db.grammarPoints,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_grammarIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GrammarQuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $GrammarQuestionsTable> {
  $$GrammarQuestionsTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get question => $composableBuilder(
    column: $table.question,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correctAnswer => $composableBuilder(
    column: $table.correctAnswer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correctOrderJson => $composableBuilder(
    column: $table.correctOrderJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );

  $$GrammarPointsTableFilterComposer get grammarId {
    final $$GrammarPointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.grammarId,
      referencedTable: $db.grammarPoints,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrammarPointsTableFilterComposer(
            $db: $db,
            $table: $db.grammarPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GrammarQuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $GrammarQuestionsTable> {
  $$GrammarQuestionsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get question => $composableBuilder(
    column: $table.question,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correctAnswer => $composableBuilder(
    column: $table.correctAnswer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correctOrderJson => $composableBuilder(
    column: $table.correctOrderJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );

  $$GrammarPointsTableOrderingComposer get grammarId {
    final $$GrammarPointsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.grammarId,
      referencedTable: $db.grammarPoints,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrammarPointsTableOrderingComposer(
            $db: $db,
            $table: $db.grammarPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GrammarQuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GrammarQuestionsTable> {
  $$GrammarQuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get question =>
      $composableBuilder(column: $table.question, builder: (column) => column);

  GeneratedColumn<String> get correctAnswer => $composableBuilder(
    column: $table.correctAnswer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get correctOrderJson => $composableBuilder(
    column: $table.correctOrderJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );

  $$GrammarPointsTableAnnotationComposer get grammarId {
    final $$GrammarPointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.grammarId,
      referencedTable: $db.grammarPoints,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrammarPointsTableAnnotationComposer(
            $db: $db,
            $table: $db.grammarPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GrammarQuestionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GrammarQuestionsTable,
          GrammarQuestion,
          $$GrammarQuestionsTableFilterComposer,
          $$GrammarQuestionsTableOrderingComposer,
          $$GrammarQuestionsTableAnnotationComposer,
          $$GrammarQuestionsTableCreateCompanionBuilder,
          $$GrammarQuestionsTableUpdateCompanionBuilder,
          (GrammarQuestion, $$GrammarQuestionsTableReferences),
          GrammarQuestion,
          PrefetchHooks Function({bool grammarId})
        > {
  $$GrammarQuestionsTableTableManager(
    _$AppDatabase db,
    $GrammarQuestionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GrammarQuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GrammarQuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GrammarQuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> grammarId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> question = const Value.absent(),
                Value<String> correctAnswer = const Value.absent(),
                Value<String?> optionsJson = const Value.absent(),
                Value<String?> correctOrderJson = const Value.absent(),
                Value<String?> explanation = const Value.absent(),
              }) => GrammarQuestionsCompanion(
                id: id,
                grammarId: grammarId,
                type: type,
                question: question,
                correctAnswer: correctAnswer,
                optionsJson: optionsJson,
                correctOrderJson: correctOrderJson,
                explanation: explanation,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int grammarId,
                required String type,
                required String question,
                required String correctAnswer,
                Value<String?> optionsJson = const Value.absent(),
                Value<String?> correctOrderJson = const Value.absent(),
                Value<String?> explanation = const Value.absent(),
              }) => GrammarQuestionsCompanion.insert(
                id: id,
                grammarId: grammarId,
                type: type,
                question: question,
                correctAnswer: correctAnswer,
                optionsJson: optionsJson,
                correctOrderJson: correctOrderJson,
                explanation: explanation,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GrammarQuestionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({grammarId = false}) {
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
                    if (grammarId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.grammarId,
                                referencedTable:
                                    $$GrammarQuestionsTableReferences
                                        ._grammarIdTable(db),
                                referencedColumn:
                                    $$GrammarQuestionsTableReferences
                                        ._grammarIdTable(db)
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

typedef $$GrammarQuestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GrammarQuestionsTable,
      GrammarQuestion,
      $$GrammarQuestionsTableFilterComposer,
      $$GrammarQuestionsTableOrderingComposer,
      $$GrammarQuestionsTableAnnotationComposer,
      $$GrammarQuestionsTableCreateCompanionBuilder,
      $$GrammarQuestionsTableUpdateCompanionBuilder,
      (GrammarQuestion, $$GrammarQuestionsTableReferences),
      GrammarQuestion,
      PrefetchHooks Function({bool grammarId})
    >;
typedef $$UserLessonTableCreateCompanionBuilder =
    UserLessonCompanion Function({
      Value<int> id,
      required String level,
      required String title,
      Value<String> description,
      Value<String> tags,
      Value<bool> isPublic,
      Value<bool> isCustomTitle,
      Value<int> learnTermLimit,
      Value<int> testQuestionLimit,
      Value<int> matchPairLimit,
      Value<DateTime?> updatedAt,
    });
typedef $$UserLessonTableUpdateCompanionBuilder =
    UserLessonCompanion Function({
      Value<int> id,
      Value<String> level,
      Value<String> title,
      Value<String> description,
      Value<String> tags,
      Value<bool> isPublic,
      Value<bool> isCustomTitle,
      Value<int> learnTermLimit,
      Value<int> testQuestionLimit,
      Value<int> matchPairLimit,
      Value<DateTime?> updatedAt,
    });

final class $$UserLessonTableReferences
    extends BaseReferences<_$AppDatabase, $UserLessonTable, UserLessonData> {
  $$UserLessonTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserLessonTermTable, List<UserLessonTermData>>
  _userLessonTermRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userLessonTerm,
    aliasName: $_aliasNameGenerator(
      db.userLesson.id,
      db.userLessonTerm.lessonId,
    ),
  );

  $$UserLessonTermTableProcessedTableManager get userLessonTermRefs {
    final manager = $$UserLessonTermTableTableManager(
      $_db,
      $_db.userLessonTerm,
    ).filter((f) => f.lessonId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userLessonTermRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UserLessonTableFilterComposer
    extends Composer<_$AppDatabase, $UserLessonTable> {
  $$UserLessonTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPublic => $composableBuilder(
    column: $table.isPublic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustomTitle => $composableBuilder(
    column: $table.isCustomTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get learnTermLimit => $composableBuilder(
    column: $table.learnTermLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get testQuestionLimit => $composableBuilder(
    column: $table.testQuestionLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get matchPairLimit => $composableBuilder(
    column: $table.matchPairLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> userLessonTermRefs(
    Expression<bool> Function($$UserLessonTermTableFilterComposer f) f,
  ) {
    final $$UserLessonTermTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userLessonTerm,
      getReferencedColumn: (t) => t.lessonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserLessonTermTableFilterComposer(
            $db: $db,
            $table: $db.userLessonTerm,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserLessonTableOrderingComposer
    extends Composer<_$AppDatabase, $UserLessonTable> {
  $$UserLessonTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPublic => $composableBuilder(
    column: $table.isPublic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustomTitle => $composableBuilder(
    column: $table.isCustomTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get learnTermLimit => $composableBuilder(
    column: $table.learnTermLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get testQuestionLimit => $composableBuilder(
    column: $table.testQuestionLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get matchPairLimit => $composableBuilder(
    column: $table.matchPairLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserLessonTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserLessonTable> {
  $$UserLessonTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<bool> get isPublic =>
      $composableBuilder(column: $table.isPublic, builder: (column) => column);

  GeneratedColumn<bool> get isCustomTitle => $composableBuilder(
    column: $table.isCustomTitle,
    builder: (column) => column,
  );

  GeneratedColumn<int> get learnTermLimit => $composableBuilder(
    column: $table.learnTermLimit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get testQuestionLimit => $composableBuilder(
    column: $table.testQuestionLimit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get matchPairLimit => $composableBuilder(
    column: $table.matchPairLimit,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> userLessonTermRefs<T extends Object>(
    Expression<T> Function($$UserLessonTermTableAnnotationComposer a) f,
  ) {
    final $$UserLessonTermTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userLessonTerm,
      getReferencedColumn: (t) => t.lessonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserLessonTermTableAnnotationComposer(
            $db: $db,
            $table: $db.userLessonTerm,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserLessonTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserLessonTable,
          UserLessonData,
          $$UserLessonTableFilterComposer,
          $$UserLessonTableOrderingComposer,
          $$UserLessonTableAnnotationComposer,
          $$UserLessonTableCreateCompanionBuilder,
          $$UserLessonTableUpdateCompanionBuilder,
          (UserLessonData, $$UserLessonTableReferences),
          UserLessonData,
          PrefetchHooks Function({bool userLessonTermRefs})
        > {
  $$UserLessonTableTableManager(_$AppDatabase db, $UserLessonTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserLessonTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserLessonTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserLessonTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<bool> isPublic = const Value.absent(),
                Value<bool> isCustomTitle = const Value.absent(),
                Value<int> learnTermLimit = const Value.absent(),
                Value<int> testQuestionLimit = const Value.absent(),
                Value<int> matchPairLimit = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => UserLessonCompanion(
                id: id,
                level: level,
                title: title,
                description: description,
                tags: tags,
                isPublic: isPublic,
                isCustomTitle: isCustomTitle,
                learnTermLimit: learnTermLimit,
                testQuestionLimit: testQuestionLimit,
                matchPairLimit: matchPairLimit,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String level,
                required String title,
                Value<String> description = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<bool> isPublic = const Value.absent(),
                Value<bool> isCustomTitle = const Value.absent(),
                Value<int> learnTermLimit = const Value.absent(),
                Value<int> testQuestionLimit = const Value.absent(),
                Value<int> matchPairLimit = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => UserLessonCompanion.insert(
                id: id,
                level: level,
                title: title,
                description: description,
                tags: tags,
                isPublic: isPublic,
                isCustomTitle: isCustomTitle,
                learnTermLimit: learnTermLimit,
                testQuestionLimit: testQuestionLimit,
                matchPairLimit: matchPairLimit,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserLessonTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userLessonTermRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (userLessonTermRefs) db.userLessonTerm,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userLessonTermRefs)
                    await $_getPrefetchedData<
                      UserLessonData,
                      $UserLessonTable,
                      UserLessonTermData
                    >(
                      currentTable: table,
                      referencedTable: $$UserLessonTableReferences
                          ._userLessonTermRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$UserLessonTableReferences(
                            db,
                            table,
                            p0,
                          ).userLessonTermRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.lessonId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$UserLessonTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserLessonTable,
      UserLessonData,
      $$UserLessonTableFilterComposer,
      $$UserLessonTableOrderingComposer,
      $$UserLessonTableAnnotationComposer,
      $$UserLessonTableCreateCompanionBuilder,
      $$UserLessonTableUpdateCompanionBuilder,
      (UserLessonData, $$UserLessonTableReferences),
      UserLessonData,
      PrefetchHooks Function({bool userLessonTermRefs})
    >;
typedef $$UserLessonTermTableCreateCompanionBuilder =
    UserLessonTermCompanion Function({
      Value<int> id,
      required int lessonId,
      Value<String> term,
      Value<String> reading,
      Value<String> definition,
      Value<String> definitionEn,
      Value<String> mnemonicVi,
      Value<String> mnemonicEn,
      Value<String> kanjiMeaning,
      Value<bool> isStarred,
      Value<bool> isLearned,
      Value<int> orderIndex,
    });
typedef $$UserLessonTermTableUpdateCompanionBuilder =
    UserLessonTermCompanion Function({
      Value<int> id,
      Value<int> lessonId,
      Value<String> term,
      Value<String> reading,
      Value<String> definition,
      Value<String> definitionEn,
      Value<String> mnemonicVi,
      Value<String> mnemonicEn,
      Value<String> kanjiMeaning,
      Value<bool> isStarred,
      Value<bool> isLearned,
      Value<int> orderIndex,
    });

final class $$UserLessonTermTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $UserLessonTermTable,
          UserLessonTermData
        > {
  $$UserLessonTermTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UserLessonTable _lessonIdTable(_$AppDatabase db) =>
      db.userLesson.createAlias(
        $_aliasNameGenerator(db.userLessonTerm.lessonId, db.userLesson.id),
      );

  $$UserLessonTableProcessedTableManager get lessonId {
    final $_column = $_itemColumn<int>('lesson_id')!;

    final manager = $$UserLessonTableTableManager(
      $_db,
      $_db.userLesson,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_lessonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserLessonTermTableFilterComposer
    extends Composer<_$AppDatabase, $UserLessonTermTable> {
  $$UserLessonTermTableFilterComposer({
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

  ColumnFilters<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get definitionEn => $composableBuilder(
    column: $table.definitionEn,
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

  ColumnFilters<String> get kanjiMeaning => $composableBuilder(
    column: $table.kanjiMeaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isStarred => $composableBuilder(
    column: $table.isStarred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLearned => $composableBuilder(
    column: $table.isLearned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  $$UserLessonTableFilterComposer get lessonId {
    final $$UserLessonTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lessonId,
      referencedTable: $db.userLesson,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserLessonTableFilterComposer(
            $db: $db,
            $table: $db.userLesson,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserLessonTermTableOrderingComposer
    extends Composer<_$AppDatabase, $UserLessonTermTable> {
  $$UserLessonTermTableOrderingComposer({
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

  ColumnOrderings<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get definitionEn => $composableBuilder(
    column: $table.definitionEn,
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

  ColumnOrderings<String> get kanjiMeaning => $composableBuilder(
    column: $table.kanjiMeaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isStarred => $composableBuilder(
    column: $table.isStarred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLearned => $composableBuilder(
    column: $table.isLearned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserLessonTableOrderingComposer get lessonId {
    final $$UserLessonTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lessonId,
      referencedTable: $db.userLesson,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserLessonTableOrderingComposer(
            $db: $db,
            $table: $db.userLesson,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserLessonTermTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserLessonTermTable> {
  $$UserLessonTermTableAnnotationComposer({
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

  GeneratedColumn<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get definitionEn => $composableBuilder(
    column: $table.definitionEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mnemonicVi => $composableBuilder(
    column: $table.mnemonicVi,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mnemonicEn => $composableBuilder(
    column: $table.mnemonicEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kanjiMeaning => $composableBuilder(
    column: $table.kanjiMeaning,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isStarred =>
      $composableBuilder(column: $table.isStarred, builder: (column) => column);

  GeneratedColumn<bool> get isLearned =>
      $composableBuilder(column: $table.isLearned, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  $$UserLessonTableAnnotationComposer get lessonId {
    final $$UserLessonTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lessonId,
      referencedTable: $db.userLesson,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserLessonTableAnnotationComposer(
            $db: $db,
            $table: $db.userLesson,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserLessonTermTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserLessonTermTable,
          UserLessonTermData,
          $$UserLessonTermTableFilterComposer,
          $$UserLessonTermTableOrderingComposer,
          $$UserLessonTermTableAnnotationComposer,
          $$UserLessonTermTableCreateCompanionBuilder,
          $$UserLessonTermTableUpdateCompanionBuilder,
          (UserLessonTermData, $$UserLessonTermTableReferences),
          UserLessonTermData,
          PrefetchHooks Function({bool lessonId})
        > {
  $$UserLessonTermTableTableManager(
    _$AppDatabase db,
    $UserLessonTermTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserLessonTermTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserLessonTermTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserLessonTermTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> lessonId = const Value.absent(),
                Value<String> term = const Value.absent(),
                Value<String> reading = const Value.absent(),
                Value<String> definition = const Value.absent(),
                Value<String> definitionEn = const Value.absent(),
                Value<String> mnemonicVi = const Value.absent(),
                Value<String> mnemonicEn = const Value.absent(),
                Value<String> kanjiMeaning = const Value.absent(),
                Value<bool> isStarred = const Value.absent(),
                Value<bool> isLearned = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
              }) => UserLessonTermCompanion(
                id: id,
                lessonId: lessonId,
                term: term,
                reading: reading,
                definition: definition,
                definitionEn: definitionEn,
                mnemonicVi: mnemonicVi,
                mnemonicEn: mnemonicEn,
                kanjiMeaning: kanjiMeaning,
                isStarred: isStarred,
                isLearned: isLearned,
                orderIndex: orderIndex,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int lessonId,
                Value<String> term = const Value.absent(),
                Value<String> reading = const Value.absent(),
                Value<String> definition = const Value.absent(),
                Value<String> definitionEn = const Value.absent(),
                Value<String> mnemonicVi = const Value.absent(),
                Value<String> mnemonicEn = const Value.absent(),
                Value<String> kanjiMeaning = const Value.absent(),
                Value<bool> isStarred = const Value.absent(),
                Value<bool> isLearned = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
              }) => UserLessonTermCompanion.insert(
                id: id,
                lessonId: lessonId,
                term: term,
                reading: reading,
                definition: definition,
                definitionEn: definitionEn,
                mnemonicVi: mnemonicVi,
                mnemonicEn: mnemonicEn,
                kanjiMeaning: kanjiMeaning,
                isStarred: isStarred,
                isLearned: isLearned,
                orderIndex: orderIndex,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserLessonTermTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({lessonId = false}) {
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
                    if (lessonId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.lessonId,
                                referencedTable: $$UserLessonTermTableReferences
                                    ._lessonIdTable(db),
                                referencedColumn:
                                    $$UserLessonTermTableReferences
                                        ._lessonIdTable(db)
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

typedef $$UserLessonTermTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserLessonTermTable,
      UserLessonTermData,
      $$UserLessonTermTableFilterComposer,
      $$UserLessonTermTableOrderingComposer,
      $$UserLessonTermTableAnnotationComposer,
      $$UserLessonTermTableCreateCompanionBuilder,
      $$UserLessonTermTableUpdateCompanionBuilder,
      (UserLessonTermData, $$UserLessonTermTableReferences),
      UserLessonTermData,
      PrefetchHooks Function({bool lessonId})
    >;
typedef $$LearnSessionsTableCreateCompanionBuilder =
    LearnSessionsCompanion Function({
      Value<int> id,
      required String sessionId,
      required int lessonId,
      required DateTime startedAt,
      Value<DateTime?> completedAt,
      required int totalQuestions,
      Value<int> correctCount,
      Value<int> wrongCount,
      Value<int> currentRound,
      Value<int> xpEarned,
      Value<bool> isPerfect,
    });
typedef $$LearnSessionsTableUpdateCompanionBuilder =
    LearnSessionsCompanion Function({
      Value<int> id,
      Value<String> sessionId,
      Value<int> lessonId,
      Value<DateTime> startedAt,
      Value<DateTime?> completedAt,
      Value<int> totalQuestions,
      Value<int> correctCount,
      Value<int> wrongCount,
      Value<int> currentRound,
      Value<int> xpEarned,
      Value<bool> isPerfect,
    });

final class $$LearnSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $LearnSessionsTable, LearnSession> {
  $$LearnSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$LearnAnswersTable, List<LearnAnswer>>
  _learnAnswersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.learnAnswers,
    aliasName: $_aliasNameGenerator(
      db.learnSessions.sessionId,
      db.learnAnswers.sessionId,
    ),
  );

  $$LearnAnswersTableProcessedTableManager get learnAnswersRefs {
    final manager = $$LearnAnswersTableTableManager($_db, $_db.learnAnswers)
        .filter(
          (f) => f.sessionId.sessionId.sqlEquals(
            $_itemColumn<String>('session_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_learnAnswersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LearnSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $LearnSessionsTable> {
  $$LearnSessionsTableFilterComposer({
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

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wrongCount => $composableBuilder(
    column: $table.wrongCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentRound => $composableBuilder(
    column: $table.currentRound,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xpEarned => $composableBuilder(
    column: $table.xpEarned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPerfect => $composableBuilder(
    column: $table.isPerfect,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> learnAnswersRefs(
    Expression<bool> Function($$LearnAnswersTableFilterComposer f) f,
  ) {
    final $$LearnAnswersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.learnAnswers,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LearnAnswersTableFilterComposer(
            $db: $db,
            $table: $db.learnAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LearnSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LearnSessionsTable> {
  $$LearnSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wrongCount => $composableBuilder(
    column: $table.wrongCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentRound => $composableBuilder(
    column: $table.currentRound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpEarned => $composableBuilder(
    column: $table.xpEarned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPerfect => $composableBuilder(
    column: $table.isPerfect,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LearnSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LearnSessionsTable> {
  $$LearnSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<int> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wrongCount => $composableBuilder(
    column: $table.wrongCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentRound => $composableBuilder(
    column: $table.currentRound,
    builder: (column) => column,
  );

  GeneratedColumn<int> get xpEarned =>
      $composableBuilder(column: $table.xpEarned, builder: (column) => column);

  GeneratedColumn<bool> get isPerfect =>
      $composableBuilder(column: $table.isPerfect, builder: (column) => column);

  Expression<T> learnAnswersRefs<T extends Object>(
    Expression<T> Function($$LearnAnswersTableAnnotationComposer a) f,
  ) {
    final $$LearnAnswersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.learnAnswers,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LearnAnswersTableAnnotationComposer(
            $db: $db,
            $table: $db.learnAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LearnSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LearnSessionsTable,
          LearnSession,
          $$LearnSessionsTableFilterComposer,
          $$LearnSessionsTableOrderingComposer,
          $$LearnSessionsTableAnnotationComposer,
          $$LearnSessionsTableCreateCompanionBuilder,
          $$LearnSessionsTableUpdateCompanionBuilder,
          (LearnSession, $$LearnSessionsTableReferences),
          LearnSession,
          PrefetchHooks Function({bool learnAnswersRefs})
        > {
  $$LearnSessionsTableTableManager(_$AppDatabase db, $LearnSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LearnSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LearnSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LearnSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int> lessonId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> totalQuestions = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
                Value<int> wrongCount = const Value.absent(),
                Value<int> currentRound = const Value.absent(),
                Value<int> xpEarned = const Value.absent(),
                Value<bool> isPerfect = const Value.absent(),
              }) => LearnSessionsCompanion(
                id: id,
                sessionId: sessionId,
                lessonId: lessonId,
                startedAt: startedAt,
                completedAt: completedAt,
                totalQuestions: totalQuestions,
                correctCount: correctCount,
                wrongCount: wrongCount,
                currentRound: currentRound,
                xpEarned: xpEarned,
                isPerfect: isPerfect,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sessionId,
                required int lessonId,
                required DateTime startedAt,
                Value<DateTime?> completedAt = const Value.absent(),
                required int totalQuestions,
                Value<int> correctCount = const Value.absent(),
                Value<int> wrongCount = const Value.absent(),
                Value<int> currentRound = const Value.absent(),
                Value<int> xpEarned = const Value.absent(),
                Value<bool> isPerfect = const Value.absent(),
              }) => LearnSessionsCompanion.insert(
                id: id,
                sessionId: sessionId,
                lessonId: lessonId,
                startedAt: startedAt,
                completedAt: completedAt,
                totalQuestions: totalQuestions,
                correctCount: correctCount,
                wrongCount: wrongCount,
                currentRound: currentRound,
                xpEarned: xpEarned,
                isPerfect: isPerfect,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LearnSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({learnAnswersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (learnAnswersRefs) db.learnAnswers],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (learnAnswersRefs)
                    await $_getPrefetchedData<
                      LearnSession,
                      $LearnSessionsTable,
                      LearnAnswer
                    >(
                      currentTable: table,
                      referencedTable: $$LearnSessionsTableReferences
                          ._learnAnswersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LearnSessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).learnAnswersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.sessionId == item.sessionId,
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

typedef $$LearnSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LearnSessionsTable,
      LearnSession,
      $$LearnSessionsTableFilterComposer,
      $$LearnSessionsTableOrderingComposer,
      $$LearnSessionsTableAnnotationComposer,
      $$LearnSessionsTableCreateCompanionBuilder,
      $$LearnSessionsTableUpdateCompanionBuilder,
      (LearnSession, $$LearnSessionsTableReferences),
      LearnSession,
      PrefetchHooks Function({bool learnAnswersRefs})
    >;
typedef $$LearnAnswersTableCreateCompanionBuilder =
    LearnAnswersCompanion Function({
      Value<int> id,
      required String sessionId,
      required int questionIndex,
      required int termId,
      required String questionType,
      Value<String?> userAnswer,
      required bool isCorrect,
      required int timeTakenMs,
      required DateTime answeredAt,
    });
typedef $$LearnAnswersTableUpdateCompanionBuilder =
    LearnAnswersCompanion Function({
      Value<int> id,
      Value<String> sessionId,
      Value<int> questionIndex,
      Value<int> termId,
      Value<String> questionType,
      Value<String?> userAnswer,
      Value<bool> isCorrect,
      Value<int> timeTakenMs,
      Value<DateTime> answeredAt,
    });

final class $$LearnAnswersTableReferences
    extends BaseReferences<_$AppDatabase, $LearnAnswersTable, LearnAnswer> {
  $$LearnAnswersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LearnSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.learnSessions.createAlias(
        $_aliasNameGenerator(
          db.learnAnswers.sessionId,
          db.learnSessions.sessionId,
        ),
      );

  $$LearnSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$LearnSessionsTableTableManager(
      $_db,
      $_db.learnSessions,
    ).filter((f) => f.sessionId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LearnAnswersTableFilterComposer
    extends Composer<_$AppDatabase, $LearnAnswersTable> {
  $$LearnAnswersTableFilterComposer({
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

  ColumnFilters<int> get questionIndex => $composableBuilder(
    column: $table.questionIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get termId => $composableBuilder(
    column: $table.termId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionType => $composableBuilder(
    column: $table.questionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userAnswer => $composableBuilder(
    column: $table.userAnswer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeTakenMs => $composableBuilder(
    column: $table.timeTakenMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnFilters(column),
  );

  $$LearnSessionsTableFilterComposer get sessionId {
    final $$LearnSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.learnSessions,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LearnSessionsTableFilterComposer(
            $db: $db,
            $table: $db.learnSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LearnAnswersTableOrderingComposer
    extends Composer<_$AppDatabase, $LearnAnswersTable> {
  $$LearnAnswersTableOrderingComposer({
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

  ColumnOrderings<int> get questionIndex => $composableBuilder(
    column: $table.questionIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get termId => $composableBuilder(
    column: $table.termId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionType => $composableBuilder(
    column: $table.questionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userAnswer => $composableBuilder(
    column: $table.userAnswer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeTakenMs => $composableBuilder(
    column: $table.timeTakenMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$LearnSessionsTableOrderingComposer get sessionId {
    final $$LearnSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.learnSessions,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LearnSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.learnSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LearnAnswersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LearnAnswersTable> {
  $$LearnAnswersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get questionIndex => $composableBuilder(
    column: $table.questionIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get termId =>
      $composableBuilder(column: $table.termId, builder: (column) => column);

  GeneratedColumn<String> get questionType => $composableBuilder(
    column: $table.questionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userAnswer => $composableBuilder(
    column: $table.userAnswer,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  GeneratedColumn<int> get timeTakenMs => $composableBuilder(
    column: $table.timeTakenMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => column,
  );

  $$LearnSessionsTableAnnotationComposer get sessionId {
    final $$LearnSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.learnSessions,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LearnSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.learnSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LearnAnswersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LearnAnswersTable,
          LearnAnswer,
          $$LearnAnswersTableFilterComposer,
          $$LearnAnswersTableOrderingComposer,
          $$LearnAnswersTableAnnotationComposer,
          $$LearnAnswersTableCreateCompanionBuilder,
          $$LearnAnswersTableUpdateCompanionBuilder,
          (LearnAnswer, $$LearnAnswersTableReferences),
          LearnAnswer,
          PrefetchHooks Function({bool sessionId})
        > {
  $$LearnAnswersTableTableManager(_$AppDatabase db, $LearnAnswersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LearnAnswersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LearnAnswersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LearnAnswersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int> questionIndex = const Value.absent(),
                Value<int> termId = const Value.absent(),
                Value<String> questionType = const Value.absent(),
                Value<String?> userAnswer = const Value.absent(),
                Value<bool> isCorrect = const Value.absent(),
                Value<int> timeTakenMs = const Value.absent(),
                Value<DateTime> answeredAt = const Value.absent(),
              }) => LearnAnswersCompanion(
                id: id,
                sessionId: sessionId,
                questionIndex: questionIndex,
                termId: termId,
                questionType: questionType,
                userAnswer: userAnswer,
                isCorrect: isCorrect,
                timeTakenMs: timeTakenMs,
                answeredAt: answeredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sessionId,
                required int questionIndex,
                required int termId,
                required String questionType,
                Value<String?> userAnswer = const Value.absent(),
                required bool isCorrect,
                required int timeTakenMs,
                required DateTime answeredAt,
              }) => LearnAnswersCompanion.insert(
                id: id,
                sessionId: sessionId,
                questionIndex: questionIndex,
                termId: termId,
                questionType: questionType,
                userAnswer: userAnswer,
                isCorrect: isCorrect,
                timeTakenMs: timeTakenMs,
                answeredAt: answeredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LearnAnswersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$LearnAnswersTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$LearnAnswersTableReferences
                                    ._sessionIdTable(db)
                                    .sessionId,
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

typedef $$LearnAnswersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LearnAnswersTable,
      LearnAnswer,
      $$LearnAnswersTableFilterComposer,
      $$LearnAnswersTableOrderingComposer,
      $$LearnAnswersTableAnnotationComposer,
      $$LearnAnswersTableCreateCompanionBuilder,
      $$LearnAnswersTableUpdateCompanionBuilder,
      (LearnAnswer, $$LearnAnswersTableReferences),
      LearnAnswer,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$TestSessionsTableCreateCompanionBuilder =
    TestSessionsCompanion Function({
      Value<int> id,
      required String sessionId,
      required int lessonId,
      required DateTime startedAt,
      Value<DateTime?> completedAt,
      required int totalQuestions,
      required int correctCount,
      required int wrongCount,
      required int score,
      required String grade,
      required int xpEarned,
      Value<int?> timeLimitMinutes,
    });
typedef $$TestSessionsTableUpdateCompanionBuilder =
    TestSessionsCompanion Function({
      Value<int> id,
      Value<String> sessionId,
      Value<int> lessonId,
      Value<DateTime> startedAt,
      Value<DateTime?> completedAt,
      Value<int> totalQuestions,
      Value<int> correctCount,
      Value<int> wrongCount,
      Value<int> score,
      Value<String> grade,
      Value<int> xpEarned,
      Value<int?> timeLimitMinutes,
    });

final class $$TestSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $TestSessionsTable, TestSession> {
  $$TestSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TestAnswersTable, List<TestAnswer>>
  _testAnswersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.testAnswers,
    aliasName: $_aliasNameGenerator(
      db.testSessions.sessionId,
      db.testAnswers.sessionId,
    ),
  );

  $$TestAnswersTableProcessedTableManager get testAnswersRefs {
    final manager = $$TestAnswersTableTableManager($_db, $_db.testAnswers)
        .filter(
          (f) => f.sessionId.sessionId.sqlEquals(
            $_itemColumn<String>('session_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_testAnswersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TestSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $TestSessionsTable> {
  $$TestSessionsTableFilterComposer({
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

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wrongCount => $composableBuilder(
    column: $table.wrongCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xpEarned => $composableBuilder(
    column: $table.xpEarned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeLimitMinutes => $composableBuilder(
    column: $table.timeLimitMinutes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> testAnswersRefs(
    Expression<bool> Function($$TestAnswersTableFilterComposer f) f,
  ) {
    final $$TestAnswersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.testAnswers,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestAnswersTableFilterComposer(
            $db: $db,
            $table: $db.testAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TestSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TestSessionsTable> {
  $$TestSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wrongCount => $composableBuilder(
    column: $table.wrongCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpEarned => $composableBuilder(
    column: $table.xpEarned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeLimitMinutes => $composableBuilder(
    column: $table.timeLimitMinutes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TestSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TestSessionsTable> {
  $$TestSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<int> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wrongCount => $composableBuilder(
    column: $table.wrongCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<int> get xpEarned =>
      $composableBuilder(column: $table.xpEarned, builder: (column) => column);

  GeneratedColumn<int> get timeLimitMinutes => $composableBuilder(
    column: $table.timeLimitMinutes,
    builder: (column) => column,
  );

  Expression<T> testAnswersRefs<T extends Object>(
    Expression<T> Function($$TestAnswersTableAnnotationComposer a) f,
  ) {
    final $$TestAnswersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.testAnswers,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestAnswersTableAnnotationComposer(
            $db: $db,
            $table: $db.testAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TestSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TestSessionsTable,
          TestSession,
          $$TestSessionsTableFilterComposer,
          $$TestSessionsTableOrderingComposer,
          $$TestSessionsTableAnnotationComposer,
          $$TestSessionsTableCreateCompanionBuilder,
          $$TestSessionsTableUpdateCompanionBuilder,
          (TestSession, $$TestSessionsTableReferences),
          TestSession,
          PrefetchHooks Function({bool testAnswersRefs})
        > {
  $$TestSessionsTableTableManager(_$AppDatabase db, $TestSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TestSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TestSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TestSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int> lessonId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> totalQuestions = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
                Value<int> wrongCount = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<String> grade = const Value.absent(),
                Value<int> xpEarned = const Value.absent(),
                Value<int?> timeLimitMinutes = const Value.absent(),
              }) => TestSessionsCompanion(
                id: id,
                sessionId: sessionId,
                lessonId: lessonId,
                startedAt: startedAt,
                completedAt: completedAt,
                totalQuestions: totalQuestions,
                correctCount: correctCount,
                wrongCount: wrongCount,
                score: score,
                grade: grade,
                xpEarned: xpEarned,
                timeLimitMinutes: timeLimitMinutes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sessionId,
                required int lessonId,
                required DateTime startedAt,
                Value<DateTime?> completedAt = const Value.absent(),
                required int totalQuestions,
                required int correctCount,
                required int wrongCount,
                required int score,
                required String grade,
                required int xpEarned,
                Value<int?> timeLimitMinutes = const Value.absent(),
              }) => TestSessionsCompanion.insert(
                id: id,
                sessionId: sessionId,
                lessonId: lessonId,
                startedAt: startedAt,
                completedAt: completedAt,
                totalQuestions: totalQuestions,
                correctCount: correctCount,
                wrongCount: wrongCount,
                score: score,
                grade: grade,
                xpEarned: xpEarned,
                timeLimitMinutes: timeLimitMinutes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TestSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({testAnswersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (testAnswersRefs) db.testAnswers],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (testAnswersRefs)
                    await $_getPrefetchedData<
                      TestSession,
                      $TestSessionsTable,
                      TestAnswer
                    >(
                      currentTable: table,
                      referencedTable: $$TestSessionsTableReferences
                          ._testAnswersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TestSessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).testAnswersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.sessionId == item.sessionId,
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

typedef $$TestSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TestSessionsTable,
      TestSession,
      $$TestSessionsTableFilterComposer,
      $$TestSessionsTableOrderingComposer,
      $$TestSessionsTableAnnotationComposer,
      $$TestSessionsTableCreateCompanionBuilder,
      $$TestSessionsTableUpdateCompanionBuilder,
      (TestSession, $$TestSessionsTableReferences),
      TestSession,
      PrefetchHooks Function({bool testAnswersRefs})
    >;
typedef $$TestAnswersTableCreateCompanionBuilder =
    TestAnswersCompanion Function({
      Value<int> id,
      required String sessionId,
      required int questionIndex,
      required int termId,
      required String questionType,
      Value<String?> userAnswer,
      required bool isCorrect,
      required DateTime answeredAt,
    });
typedef $$TestAnswersTableUpdateCompanionBuilder =
    TestAnswersCompanion Function({
      Value<int> id,
      Value<String> sessionId,
      Value<int> questionIndex,
      Value<int> termId,
      Value<String> questionType,
      Value<String?> userAnswer,
      Value<bool> isCorrect,
      Value<DateTime> answeredAt,
    });

final class $$TestAnswersTableReferences
    extends BaseReferences<_$AppDatabase, $TestAnswersTable, TestAnswer> {
  $$TestAnswersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TestSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.testSessions.createAlias(
        $_aliasNameGenerator(
          db.testAnswers.sessionId,
          db.testSessions.sessionId,
        ),
      );

  $$TestSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$TestSessionsTableTableManager(
      $_db,
      $_db.testSessions,
    ).filter((f) => f.sessionId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TestAnswersTableFilterComposer
    extends Composer<_$AppDatabase, $TestAnswersTable> {
  $$TestAnswersTableFilterComposer({
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

  ColumnFilters<int> get questionIndex => $composableBuilder(
    column: $table.questionIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get termId => $composableBuilder(
    column: $table.termId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionType => $composableBuilder(
    column: $table.questionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userAnswer => $composableBuilder(
    column: $table.userAnswer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TestSessionsTableFilterComposer get sessionId {
    final $$TestSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.testSessions,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestSessionsTableFilterComposer(
            $db: $db,
            $table: $db.testSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TestAnswersTableOrderingComposer
    extends Composer<_$AppDatabase, $TestAnswersTable> {
  $$TestAnswersTableOrderingComposer({
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

  ColumnOrderings<int> get questionIndex => $composableBuilder(
    column: $table.questionIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get termId => $composableBuilder(
    column: $table.termId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionType => $composableBuilder(
    column: $table.questionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userAnswer => $composableBuilder(
    column: $table.userAnswer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TestSessionsTableOrderingComposer get sessionId {
    final $$TestSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.testSessions,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.testSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TestAnswersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TestAnswersTable> {
  $$TestAnswersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get questionIndex => $composableBuilder(
    column: $table.questionIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get termId =>
      $composableBuilder(column: $table.termId, builder: (column) => column);

  GeneratedColumn<String> get questionType => $composableBuilder(
    column: $table.questionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userAnswer => $composableBuilder(
    column: $table.userAnswer,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  GeneratedColumn<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => column,
  );

  $$TestSessionsTableAnnotationComposer get sessionId {
    final $$TestSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.testSessions,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.testSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TestAnswersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TestAnswersTable,
          TestAnswer,
          $$TestAnswersTableFilterComposer,
          $$TestAnswersTableOrderingComposer,
          $$TestAnswersTableAnnotationComposer,
          $$TestAnswersTableCreateCompanionBuilder,
          $$TestAnswersTableUpdateCompanionBuilder,
          (TestAnswer, $$TestAnswersTableReferences),
          TestAnswer,
          PrefetchHooks Function({bool sessionId})
        > {
  $$TestAnswersTableTableManager(_$AppDatabase db, $TestAnswersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TestAnswersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TestAnswersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TestAnswersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int> questionIndex = const Value.absent(),
                Value<int> termId = const Value.absent(),
                Value<String> questionType = const Value.absent(),
                Value<String?> userAnswer = const Value.absent(),
                Value<bool> isCorrect = const Value.absent(),
                Value<DateTime> answeredAt = const Value.absent(),
              }) => TestAnswersCompanion(
                id: id,
                sessionId: sessionId,
                questionIndex: questionIndex,
                termId: termId,
                questionType: questionType,
                userAnswer: userAnswer,
                isCorrect: isCorrect,
                answeredAt: answeredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sessionId,
                required int questionIndex,
                required int termId,
                required String questionType,
                Value<String?> userAnswer = const Value.absent(),
                required bool isCorrect,
                required DateTime answeredAt,
              }) => TestAnswersCompanion.insert(
                id: id,
                sessionId: sessionId,
                questionIndex: questionIndex,
                termId: termId,
                questionType: questionType,
                userAnswer: userAnswer,
                isCorrect: isCorrect,
                answeredAt: answeredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TestAnswersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$TestAnswersTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$TestAnswersTableReferences
                                    ._sessionIdTable(db)
                                    .sessionId,
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

typedef $$TestAnswersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TestAnswersTable,
      TestAnswer,
      $$TestAnswersTableFilterComposer,
      $$TestAnswersTableOrderingComposer,
      $$TestAnswersTableAnnotationComposer,
      $$TestAnswersTableCreateCompanionBuilder,
      $$TestAnswersTableUpdateCompanionBuilder,
      (TestAnswer, $$TestAnswersTableReferences),
      TestAnswer,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$AchievementsTableCreateCompanionBuilder =
    AchievementsCompanion Function({
      Value<int> id,
      required String type,
      Value<int?> lessonId,
      Value<String?> sessionId,
      required int value,
      required DateTime earnedAt,
      Value<bool> isNotified,
    });
typedef $$AchievementsTableUpdateCompanionBuilder =
    AchievementsCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<int?> lessonId,
      Value<String?> sessionId,
      Value<int> value,
      Value<DateTime> earnedAt,
      Value<bool> isNotified,
    });

class $$AchievementsTableFilterComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get earnedAt => $composableBuilder(
    column: $table.earnedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isNotified => $composableBuilder(
    column: $table.isNotified,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AchievementsTableOrderingComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get earnedAt => $composableBuilder(
    column: $table.earnedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isNotified => $composableBuilder(
    column: $table.isNotified,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AchievementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get earnedAt =>
      $composableBuilder(column: $table.earnedAt, builder: (column) => column);

  GeneratedColumn<bool> get isNotified => $composableBuilder(
    column: $table.isNotified,
    builder: (column) => column,
  );
}

class $$AchievementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AchievementsTable,
          Achievement,
          $$AchievementsTableFilterComposer,
          $$AchievementsTableOrderingComposer,
          $$AchievementsTableAnnotationComposer,
          $$AchievementsTableCreateCompanionBuilder,
          $$AchievementsTableUpdateCompanionBuilder,
          (
            Achievement,
            BaseReferences<_$AppDatabase, $AchievementsTable, Achievement>,
          ),
          Achievement,
          PrefetchHooks Function()
        > {
  $$AchievementsTableTableManager(_$AppDatabase db, $AchievementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int?> lessonId = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                Value<int> value = const Value.absent(),
                Value<DateTime> earnedAt = const Value.absent(),
                Value<bool> isNotified = const Value.absent(),
              }) => AchievementsCompanion(
                id: id,
                type: type,
                lessonId: lessonId,
                sessionId: sessionId,
                value: value,
                earnedAt: earnedAt,
                isNotified: isNotified,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                Value<int?> lessonId = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                required int value,
                required DateTime earnedAt,
                Value<bool> isNotified = const Value.absent(),
              }) => AchievementsCompanion.insert(
                id: id,
                type: type,
                lessonId: lessonId,
                sessionId: sessionId,
                value: value,
                earnedAt: earnedAt,
                isNotified: isNotified,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AchievementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AchievementsTable,
      Achievement,
      $$AchievementsTableFilterComposer,
      $$AchievementsTableOrderingComposer,
      $$AchievementsTableAnnotationComposer,
      $$AchievementsTableCreateCompanionBuilder,
      $$AchievementsTableUpdateCompanionBuilder,
      (
        Achievement,
        BaseReferences<_$AppDatabase, $AchievementsTable, Achievement>,
      ),
      Achievement,
      PrefetchHooks Function()
    >;
typedef $$FlashcardSettingsTableCreateCompanionBuilder =
    FlashcardSettingsCompanion Function({
      Value<int> id,
      Value<bool> showTermFirst,
      Value<bool> shuffleCards,
      Value<bool> showStarredOnly,
      Value<DateTime?> updatedAt,
    });
typedef $$FlashcardSettingsTableUpdateCompanionBuilder =
    FlashcardSettingsCompanion Function({
      Value<int> id,
      Value<bool> showTermFirst,
      Value<bool> shuffleCards,
      Value<bool> showStarredOnly,
      Value<DateTime?> updatedAt,
    });

class $$FlashcardSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $FlashcardSettingsTable> {
  $$FlashcardSettingsTableFilterComposer({
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

  ColumnFilters<bool> get showTermFirst => $composableBuilder(
    column: $table.showTermFirst,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get shuffleCards => $composableBuilder(
    column: $table.shuffleCards,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showStarredOnly => $composableBuilder(
    column: $table.showStarredOnly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FlashcardSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $FlashcardSettingsTable> {
  $$FlashcardSettingsTableOrderingComposer({
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

  ColumnOrderings<bool> get showTermFirst => $composableBuilder(
    column: $table.showTermFirst,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get shuffleCards => $composableBuilder(
    column: $table.shuffleCards,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showStarredOnly => $composableBuilder(
    column: $table.showStarredOnly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FlashcardSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FlashcardSettingsTable> {
  $$FlashcardSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get showTermFirst => $composableBuilder(
    column: $table.showTermFirst,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get shuffleCards => $composableBuilder(
    column: $table.shuffleCards,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showStarredOnly => $composableBuilder(
    column: $table.showStarredOnly,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FlashcardSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FlashcardSettingsTable,
          FlashcardSetting,
          $$FlashcardSettingsTableFilterComposer,
          $$FlashcardSettingsTableOrderingComposer,
          $$FlashcardSettingsTableAnnotationComposer,
          $$FlashcardSettingsTableCreateCompanionBuilder,
          $$FlashcardSettingsTableUpdateCompanionBuilder,
          (
            FlashcardSetting,
            BaseReferences<
              _$AppDatabase,
              $FlashcardSettingsTable,
              FlashcardSetting
            >,
          ),
          FlashcardSetting,
          PrefetchHooks Function()
        > {
  $$FlashcardSettingsTableTableManager(
    _$AppDatabase db,
    $FlashcardSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlashcardSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlashcardSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlashcardSettingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> showTermFirst = const Value.absent(),
                Value<bool> shuffleCards = const Value.absent(),
                Value<bool> showStarredOnly = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => FlashcardSettingsCompanion(
                id: id,
                showTermFirst: showTermFirst,
                shuffleCards: shuffleCards,
                showStarredOnly: showStarredOnly,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> showTermFirst = const Value.absent(),
                Value<bool> shuffleCards = const Value.absent(),
                Value<bool> showStarredOnly = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => FlashcardSettingsCompanion.insert(
                id: id,
                showTermFirst: showTermFirst,
                shuffleCards: shuffleCards,
                showStarredOnly: showStarredOnly,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FlashcardSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FlashcardSettingsTable,
      FlashcardSetting,
      $$FlashcardSettingsTableFilterComposer,
      $$FlashcardSettingsTableOrderingComposer,
      $$FlashcardSettingsTableAnnotationComposer,
      $$FlashcardSettingsTableCreateCompanionBuilder,
      $$FlashcardSettingsTableUpdateCompanionBuilder,
      (
        FlashcardSetting,
        BaseReferences<
          _$AppDatabase,
          $FlashcardSettingsTable,
          FlashcardSetting
        >,
      ),
      FlashcardSetting,
      PrefetchHooks Function()
    >;
typedef $$LearnSettingsTableCreateCompanionBuilder =
    LearnSettingsCompanion Function({
      Value<int> id,
      Value<int> defaultQuestionCount,
      Value<bool> enableMultipleChoice,
      Value<bool> enableTrueFalse,
      Value<bool> enableFillBlank,
      Value<bool> shuffleQuestions,
      Value<bool> enableHints,
      Value<bool> showCorrectAnswer,
      Value<DateTime?> updatedAt,
    });
typedef $$LearnSettingsTableUpdateCompanionBuilder =
    LearnSettingsCompanion Function({
      Value<int> id,
      Value<int> defaultQuestionCount,
      Value<bool> enableMultipleChoice,
      Value<bool> enableTrueFalse,
      Value<bool> enableFillBlank,
      Value<bool> shuffleQuestions,
      Value<bool> enableHints,
      Value<bool> showCorrectAnswer,
      Value<DateTime?> updatedAt,
    });

class $$LearnSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $LearnSettingsTable> {
  $$LearnSettingsTableFilterComposer({
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

  ColumnFilters<int> get defaultQuestionCount => $composableBuilder(
    column: $table.defaultQuestionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enableMultipleChoice => $composableBuilder(
    column: $table.enableMultipleChoice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enableTrueFalse => $composableBuilder(
    column: $table.enableTrueFalse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enableFillBlank => $composableBuilder(
    column: $table.enableFillBlank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get shuffleQuestions => $composableBuilder(
    column: $table.shuffleQuestions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enableHints => $composableBuilder(
    column: $table.enableHints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showCorrectAnswer => $composableBuilder(
    column: $table.showCorrectAnswer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LearnSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $LearnSettingsTable> {
  $$LearnSettingsTableOrderingComposer({
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

  ColumnOrderings<int> get defaultQuestionCount => $composableBuilder(
    column: $table.defaultQuestionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enableMultipleChoice => $composableBuilder(
    column: $table.enableMultipleChoice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enableTrueFalse => $composableBuilder(
    column: $table.enableTrueFalse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enableFillBlank => $composableBuilder(
    column: $table.enableFillBlank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get shuffleQuestions => $composableBuilder(
    column: $table.shuffleQuestions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enableHints => $composableBuilder(
    column: $table.enableHints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showCorrectAnswer => $composableBuilder(
    column: $table.showCorrectAnswer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LearnSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LearnSettingsTable> {
  $$LearnSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get defaultQuestionCount => $composableBuilder(
    column: $table.defaultQuestionCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enableMultipleChoice => $composableBuilder(
    column: $table.enableMultipleChoice,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enableTrueFalse => $composableBuilder(
    column: $table.enableTrueFalse,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enableFillBlank => $composableBuilder(
    column: $table.enableFillBlank,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get shuffleQuestions => $composableBuilder(
    column: $table.shuffleQuestions,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enableHints => $composableBuilder(
    column: $table.enableHints,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showCorrectAnswer => $composableBuilder(
    column: $table.showCorrectAnswer,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LearnSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LearnSettingsTable,
          LearnSetting,
          $$LearnSettingsTableFilterComposer,
          $$LearnSettingsTableOrderingComposer,
          $$LearnSettingsTableAnnotationComposer,
          $$LearnSettingsTableCreateCompanionBuilder,
          $$LearnSettingsTableUpdateCompanionBuilder,
          (
            LearnSetting,
            BaseReferences<_$AppDatabase, $LearnSettingsTable, LearnSetting>,
          ),
          LearnSetting,
          PrefetchHooks Function()
        > {
  $$LearnSettingsTableTableManager(_$AppDatabase db, $LearnSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LearnSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LearnSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LearnSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> defaultQuestionCount = const Value.absent(),
                Value<bool> enableMultipleChoice = const Value.absent(),
                Value<bool> enableTrueFalse = const Value.absent(),
                Value<bool> enableFillBlank = const Value.absent(),
                Value<bool> shuffleQuestions = const Value.absent(),
                Value<bool> enableHints = const Value.absent(),
                Value<bool> showCorrectAnswer = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => LearnSettingsCompanion(
                id: id,
                defaultQuestionCount: defaultQuestionCount,
                enableMultipleChoice: enableMultipleChoice,
                enableTrueFalse: enableTrueFalse,
                enableFillBlank: enableFillBlank,
                shuffleQuestions: shuffleQuestions,
                enableHints: enableHints,
                showCorrectAnswer: showCorrectAnswer,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> defaultQuestionCount = const Value.absent(),
                Value<bool> enableMultipleChoice = const Value.absent(),
                Value<bool> enableTrueFalse = const Value.absent(),
                Value<bool> enableFillBlank = const Value.absent(),
                Value<bool> shuffleQuestions = const Value.absent(),
                Value<bool> enableHints = const Value.absent(),
                Value<bool> showCorrectAnswer = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => LearnSettingsCompanion.insert(
                id: id,
                defaultQuestionCount: defaultQuestionCount,
                enableMultipleChoice: enableMultipleChoice,
                enableTrueFalse: enableTrueFalse,
                enableFillBlank: enableFillBlank,
                shuffleQuestions: shuffleQuestions,
                enableHints: enableHints,
                showCorrectAnswer: showCorrectAnswer,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LearnSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LearnSettingsTable,
      LearnSetting,
      $$LearnSettingsTableFilterComposer,
      $$LearnSettingsTableOrderingComposer,
      $$LearnSettingsTableAnnotationComposer,
      $$LearnSettingsTableCreateCompanionBuilder,
      $$LearnSettingsTableUpdateCompanionBuilder,
      (
        LearnSetting,
        BaseReferences<_$AppDatabase, $LearnSettingsTable, LearnSetting>,
      ),
      LearnSetting,
      PrefetchHooks Function()
    >;
typedef $$TestSettingsTableCreateCompanionBuilder =
    TestSettingsCompanion Function({
      Value<int> id,
      Value<int> defaultQuestionCount,
      Value<int?> defaultTimeLimitMinutes,
      Value<bool> enableMultipleChoice,
      Value<bool> enableTrueFalse,
      Value<bool> enableFillBlank,
      Value<bool> shuffleQuestions,
      Value<bool> shuffleOptions,
      Value<bool> showCorrectAfterWrong,
      Value<DateTime?> updatedAt,
    });
typedef $$TestSettingsTableUpdateCompanionBuilder =
    TestSettingsCompanion Function({
      Value<int> id,
      Value<int> defaultQuestionCount,
      Value<int?> defaultTimeLimitMinutes,
      Value<bool> enableMultipleChoice,
      Value<bool> enableTrueFalse,
      Value<bool> enableFillBlank,
      Value<bool> shuffleQuestions,
      Value<bool> shuffleOptions,
      Value<bool> showCorrectAfterWrong,
      Value<DateTime?> updatedAt,
    });

class $$TestSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $TestSettingsTable> {
  $$TestSettingsTableFilterComposer({
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

  ColumnFilters<int> get defaultQuestionCount => $composableBuilder(
    column: $table.defaultQuestionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultTimeLimitMinutes => $composableBuilder(
    column: $table.defaultTimeLimitMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enableMultipleChoice => $composableBuilder(
    column: $table.enableMultipleChoice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enableTrueFalse => $composableBuilder(
    column: $table.enableTrueFalse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enableFillBlank => $composableBuilder(
    column: $table.enableFillBlank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get shuffleQuestions => $composableBuilder(
    column: $table.shuffleQuestions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get shuffleOptions => $composableBuilder(
    column: $table.shuffleOptions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showCorrectAfterWrong => $composableBuilder(
    column: $table.showCorrectAfterWrong,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TestSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $TestSettingsTable> {
  $$TestSettingsTableOrderingComposer({
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

  ColumnOrderings<int> get defaultQuestionCount => $composableBuilder(
    column: $table.defaultQuestionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultTimeLimitMinutes => $composableBuilder(
    column: $table.defaultTimeLimitMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enableMultipleChoice => $composableBuilder(
    column: $table.enableMultipleChoice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enableTrueFalse => $composableBuilder(
    column: $table.enableTrueFalse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enableFillBlank => $composableBuilder(
    column: $table.enableFillBlank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get shuffleQuestions => $composableBuilder(
    column: $table.shuffleQuestions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get shuffleOptions => $composableBuilder(
    column: $table.shuffleOptions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showCorrectAfterWrong => $composableBuilder(
    column: $table.showCorrectAfterWrong,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TestSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TestSettingsTable> {
  $$TestSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get defaultQuestionCount => $composableBuilder(
    column: $table.defaultQuestionCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultTimeLimitMinutes => $composableBuilder(
    column: $table.defaultTimeLimitMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enableMultipleChoice => $composableBuilder(
    column: $table.enableMultipleChoice,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enableTrueFalse => $composableBuilder(
    column: $table.enableTrueFalse,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enableFillBlank => $composableBuilder(
    column: $table.enableFillBlank,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get shuffleQuestions => $composableBuilder(
    column: $table.shuffleQuestions,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get shuffleOptions => $composableBuilder(
    column: $table.shuffleOptions,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showCorrectAfterWrong => $composableBuilder(
    column: $table.showCorrectAfterWrong,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TestSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TestSettingsTable,
          TestSetting,
          $$TestSettingsTableFilterComposer,
          $$TestSettingsTableOrderingComposer,
          $$TestSettingsTableAnnotationComposer,
          $$TestSettingsTableCreateCompanionBuilder,
          $$TestSettingsTableUpdateCompanionBuilder,
          (
            TestSetting,
            BaseReferences<_$AppDatabase, $TestSettingsTable, TestSetting>,
          ),
          TestSetting,
          PrefetchHooks Function()
        > {
  $$TestSettingsTableTableManager(_$AppDatabase db, $TestSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TestSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TestSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TestSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> defaultQuestionCount = const Value.absent(),
                Value<int?> defaultTimeLimitMinutes = const Value.absent(),
                Value<bool> enableMultipleChoice = const Value.absent(),
                Value<bool> enableTrueFalse = const Value.absent(),
                Value<bool> enableFillBlank = const Value.absent(),
                Value<bool> shuffleQuestions = const Value.absent(),
                Value<bool> shuffleOptions = const Value.absent(),
                Value<bool> showCorrectAfterWrong = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => TestSettingsCompanion(
                id: id,
                defaultQuestionCount: defaultQuestionCount,
                defaultTimeLimitMinutes: defaultTimeLimitMinutes,
                enableMultipleChoice: enableMultipleChoice,
                enableTrueFalse: enableTrueFalse,
                enableFillBlank: enableFillBlank,
                shuffleQuestions: shuffleQuestions,
                shuffleOptions: shuffleOptions,
                showCorrectAfterWrong: showCorrectAfterWrong,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> defaultQuestionCount = const Value.absent(),
                Value<int?> defaultTimeLimitMinutes = const Value.absent(),
                Value<bool> enableMultipleChoice = const Value.absent(),
                Value<bool> enableTrueFalse = const Value.absent(),
                Value<bool> enableFillBlank = const Value.absent(),
                Value<bool> shuffleQuestions = const Value.absent(),
                Value<bool> shuffleOptions = const Value.absent(),
                Value<bool> showCorrectAfterWrong = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => TestSettingsCompanion.insert(
                id: id,
                defaultQuestionCount: defaultQuestionCount,
                defaultTimeLimitMinutes: defaultTimeLimitMinutes,
                enableMultipleChoice: enableMultipleChoice,
                enableTrueFalse: enableTrueFalse,
                enableFillBlank: enableFillBlank,
                shuffleQuestions: shuffleQuestions,
                shuffleOptions: shuffleOptions,
                showCorrectAfterWrong: showCorrectAfterWrong,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TestSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TestSettingsTable,
      TestSetting,
      $$TestSettingsTableFilterComposer,
      $$TestSettingsTableOrderingComposer,
      $$TestSettingsTableAnnotationComposer,
      $$TestSettingsTableCreateCompanionBuilder,
      $$TestSettingsTableUpdateCompanionBuilder,
      (
        TestSetting,
        BaseReferences<_$AppDatabase, $TestSettingsTable, TestSetting>,
      ),
      TestSetting,
      PrefetchHooks Function()
    >;
typedef $$UserMistakesTableCreateCompanionBuilder =
    UserMistakesCompanion Function({
      Value<int> id,
      required String type,
      required int itemId,
      Value<int> wrongCount,
      required DateTime lastMistakeAt,
      Value<String?> prompt,
      Value<String?> correctAnswer,
      Value<String?> userAnswer,
      Value<String?> source,
      Value<String?> extraJson,
    });
typedef $$UserMistakesTableUpdateCompanionBuilder =
    UserMistakesCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<int> itemId,
      Value<int> wrongCount,
      Value<DateTime> lastMistakeAt,
      Value<String?> prompt,
      Value<String?> correctAnswer,
      Value<String?> userAnswer,
      Value<String?> source,
      Value<String?> extraJson,
    });

class $$UserMistakesTableFilterComposer
    extends Composer<_$AppDatabase, $UserMistakesTable> {
  $$UserMistakesTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wrongCount => $composableBuilder(
    column: $table.wrongCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastMistakeAt => $composableBuilder(
    column: $table.lastMistakeAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correctAnswer => $composableBuilder(
    column: $table.correctAnswer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userAnswer => $composableBuilder(
    column: $table.userAnswer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extraJson => $composableBuilder(
    column: $table.extraJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserMistakesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserMistakesTable> {
  $$UserMistakesTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wrongCount => $composableBuilder(
    column: $table.wrongCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastMistakeAt => $composableBuilder(
    column: $table.lastMistakeAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correctAnswer => $composableBuilder(
    column: $table.correctAnswer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userAnswer => $composableBuilder(
    column: $table.userAnswer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extraJson => $composableBuilder(
    column: $table.extraJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserMistakesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserMistakesTable> {
  $$UserMistakesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<int> get wrongCount => $composableBuilder(
    column: $table.wrongCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastMistakeAt => $composableBuilder(
    column: $table.lastMistakeAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get prompt =>
      $composableBuilder(column: $table.prompt, builder: (column) => column);

  GeneratedColumn<String> get correctAnswer => $composableBuilder(
    column: $table.correctAnswer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userAnswer => $composableBuilder(
    column: $table.userAnswer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get extraJson =>
      $composableBuilder(column: $table.extraJson, builder: (column) => column);
}

class $$UserMistakesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserMistakesTable,
          UserMistake,
          $$UserMistakesTableFilterComposer,
          $$UserMistakesTableOrderingComposer,
          $$UserMistakesTableAnnotationComposer,
          $$UserMistakesTableCreateCompanionBuilder,
          $$UserMistakesTableUpdateCompanionBuilder,
          (
            UserMistake,
            BaseReferences<_$AppDatabase, $UserMistakesTable, UserMistake>,
          ),
          UserMistake,
          PrefetchHooks Function()
        > {
  $$UserMistakesTableTableManager(_$AppDatabase db, $UserMistakesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserMistakesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserMistakesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserMistakesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> itemId = const Value.absent(),
                Value<int> wrongCount = const Value.absent(),
                Value<DateTime> lastMistakeAt = const Value.absent(),
                Value<String?> prompt = const Value.absent(),
                Value<String?> correctAnswer = const Value.absent(),
                Value<String?> userAnswer = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<String?> extraJson = const Value.absent(),
              }) => UserMistakesCompanion(
                id: id,
                type: type,
                itemId: itemId,
                wrongCount: wrongCount,
                lastMistakeAt: lastMistakeAt,
                prompt: prompt,
                correctAnswer: correctAnswer,
                userAnswer: userAnswer,
                source: source,
                extraJson: extraJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                required int itemId,
                Value<int> wrongCount = const Value.absent(),
                required DateTime lastMistakeAt,
                Value<String?> prompt = const Value.absent(),
                Value<String?> correctAnswer = const Value.absent(),
                Value<String?> userAnswer = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<String?> extraJson = const Value.absent(),
              }) => UserMistakesCompanion.insert(
                id: id,
                type: type,
                itemId: itemId,
                wrongCount: wrongCount,
                lastMistakeAt: lastMistakeAt,
                prompt: prompt,
                correctAnswer: correctAnswer,
                userAnswer: userAnswer,
                source: source,
                extraJson: extraJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserMistakesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserMistakesTable,
      UserMistake,
      $$UserMistakesTableFilterComposer,
      $$UserMistakesTableOrderingComposer,
      $$UserMistakesTableAnnotationComposer,
      $$UserMistakesTableCreateCompanionBuilder,
      $$UserMistakesTableUpdateCompanionBuilder,
      (
        UserMistake,
        BaseReferences<_$AppDatabase, $UserMistakesTable, UserMistake>,
      ),
      UserMistake,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SrsStateTableTableManager get srsState =>
      $$SrsStateTableTableManager(_db, _db.srsState);
  $$KanjiSrsStateTableTableManager get kanjiSrsState =>
      $$KanjiSrsStateTableTableManager(_db, _db.kanjiSrsState);
  $$KanaSrsStateTableTableManager get kanaSrsState =>
      $$KanaSrsStateTableTableManager(_db, _db.kanaSrsState);
  $$UserProgressTableTableManager get userProgress =>
      $$UserProgressTableTableManager(_db, _db.userProgress);
  $$AttemptTableTableManager get attempt =>
      $$AttemptTableTableManager(_db, _db.attempt);
  $$AttemptAnswerTableTableManager get attemptAnswer =>
      $$AttemptAnswerTableTableManager(_db, _db.attemptAnswer);
  $$GrammarPointsTableTableManager get grammarPoints =>
      $$GrammarPointsTableTableManager(_db, _db.grammarPoints);
  $$GrammarExamplesTableTableManager get grammarExamples =>
      $$GrammarExamplesTableTableManager(_db, _db.grammarExamples);
  $$GrammarSrsStateTableTableManager get grammarSrsState =>
      $$GrammarSrsStateTableTableManager(_db, _db.grammarSrsState);
  $$GrammarQuestionsTableTableManager get grammarQuestions =>
      $$GrammarQuestionsTableTableManager(_db, _db.grammarQuestions);
  $$UserLessonTableTableManager get userLesson =>
      $$UserLessonTableTableManager(_db, _db.userLesson);
  $$UserLessonTermTableTableManager get userLessonTerm =>
      $$UserLessonTermTableTableManager(_db, _db.userLessonTerm);
  $$LearnSessionsTableTableManager get learnSessions =>
      $$LearnSessionsTableTableManager(_db, _db.learnSessions);
  $$LearnAnswersTableTableManager get learnAnswers =>
      $$LearnAnswersTableTableManager(_db, _db.learnAnswers);
  $$TestSessionsTableTableManager get testSessions =>
      $$TestSessionsTableTableManager(_db, _db.testSessions);
  $$TestAnswersTableTableManager get testAnswers =>
      $$TestAnswersTableTableManager(_db, _db.testAnswers);
  $$AchievementsTableTableManager get achievements =>
      $$AchievementsTableTableManager(_db, _db.achievements);
  $$FlashcardSettingsTableTableManager get flashcardSettings =>
      $$FlashcardSettingsTableTableManager(_db, _db.flashcardSettings);
  $$LearnSettingsTableTableManager get learnSettings =>
      $$LearnSettingsTableTableManager(_db, _db.learnSettings);
  $$TestSettingsTableTableManager get testSettings =>
      $$TestSettingsTableTableManager(_db, _db.testSettings);
  $$UserMistakesTableTableManager get userMistakes =>
      $$UserMistakesTableTableManager(_db, _db.userMistakes);
}
