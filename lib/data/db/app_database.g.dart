// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PrayerLogsTable extends PrayerLogs
    with TableInfo<$PrayerLogsTable, PrayerLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrayerLogsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Prayer, String> prayer =
      GeneratedColumn<String>(
        'prayer',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Prayer>($PrayerLogsTable.$converterprayer);
  @override
  late final GeneratedColumnWithTypeConverter<PrayerStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PrayerStatus>($PrayerLogsTable.$converterstatus);
  static const VerificationMeta _markedAtMeta = const VerificationMeta(
    'markedAt',
  );
  @override
  late final GeneratedColumn<DateTime> markedAt = GeneratedColumn<DateTime>(
    'marked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, prayer, status, markedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prayer_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrayerLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('marked_at')) {
      context.handle(
        _markedAtMeta,
        markedAt.isAcceptableOrUnknown(data['marked_at']!, _markedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_markedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {date, prayer},
  ];
  @override
  PrayerLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrayerLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      prayer: $PrayerLogsTable.$converterprayer.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}prayer'],
        )!,
      ),
      status: $PrayerLogsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      markedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}marked_at'],
      )!,
    );
  }

  @override
  $PrayerLogsTable createAlias(String alias) {
    return $PrayerLogsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Prayer, String, String> $converterprayer =
      const EnumNameConverter<Prayer>(Prayer.values);
  static JsonTypeConverter2<PrayerStatus, String, String> $converterstatus =
      const EnumNameConverter<PrayerStatus>(PrayerStatus.values);
}

class PrayerLogRow extends DataClass implements Insertable<PrayerLogRow> {
  final int id;
  final String date;
  final Prayer prayer;
  final PrayerStatus status;
  final DateTime markedAt;
  const PrayerLogRow({
    required this.id,
    required this.date,
    required this.prayer,
    required this.status,
    required this.markedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    {
      map['prayer'] = Variable<String>(
        $PrayerLogsTable.$converterprayer.toSql(prayer),
      );
    }
    {
      map['status'] = Variable<String>(
        $PrayerLogsTable.$converterstatus.toSql(status),
      );
    }
    map['marked_at'] = Variable<DateTime>(markedAt);
    return map;
  }

  PrayerLogsCompanion toCompanion(bool nullToAbsent) {
    return PrayerLogsCompanion(
      id: Value(id),
      date: Value(date),
      prayer: Value(prayer),
      status: Value(status),
      markedAt: Value(markedAt),
    );
  }

  factory PrayerLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrayerLogRow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      prayer: $PrayerLogsTable.$converterprayer.fromJson(
        serializer.fromJson<String>(json['prayer']),
      ),
      status: $PrayerLogsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      markedAt: serializer.fromJson<DateTime>(json['markedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'prayer': serializer.toJson<String>(
        $PrayerLogsTable.$converterprayer.toJson(prayer),
      ),
      'status': serializer.toJson<String>(
        $PrayerLogsTable.$converterstatus.toJson(status),
      ),
      'markedAt': serializer.toJson<DateTime>(markedAt),
    };
  }

  PrayerLogRow copyWith({
    int? id,
    String? date,
    Prayer? prayer,
    PrayerStatus? status,
    DateTime? markedAt,
  }) => PrayerLogRow(
    id: id ?? this.id,
    date: date ?? this.date,
    prayer: prayer ?? this.prayer,
    status: status ?? this.status,
    markedAt: markedAt ?? this.markedAt,
  );
  PrayerLogRow copyWithCompanion(PrayerLogsCompanion data) {
    return PrayerLogRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      prayer: data.prayer.present ? data.prayer.value : this.prayer,
      status: data.status.present ? data.status.value : this.status,
      markedAt: data.markedAt.present ? data.markedAt.value : this.markedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrayerLogRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('prayer: $prayer, ')
          ..write('status: $status, ')
          ..write('markedAt: $markedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, prayer, status, markedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrayerLogRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.prayer == this.prayer &&
          other.status == this.status &&
          other.markedAt == this.markedAt);
}

class PrayerLogsCompanion extends UpdateCompanion<PrayerLogRow> {
  final Value<int> id;
  final Value<String> date;
  final Value<Prayer> prayer;
  final Value<PrayerStatus> status;
  final Value<DateTime> markedAt;
  const PrayerLogsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.prayer = const Value.absent(),
    this.status = const Value.absent(),
    this.markedAt = const Value.absent(),
  });
  PrayerLogsCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required Prayer prayer,
    required PrayerStatus status,
    required DateTime markedAt,
  }) : date = Value(date),
       prayer = Value(prayer),
       status = Value(status),
       markedAt = Value(markedAt);
  static Insertable<PrayerLogRow> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? prayer,
    Expression<String>? status,
    Expression<DateTime>? markedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (prayer != null) 'prayer': prayer,
      if (status != null) 'status': status,
      if (markedAt != null) 'marked_at': markedAt,
    });
  }

  PrayerLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<Prayer>? prayer,
    Value<PrayerStatus>? status,
    Value<DateTime>? markedAt,
  }) {
    return PrayerLogsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      prayer: prayer ?? this.prayer,
      status: status ?? this.status,
      markedAt: markedAt ?? this.markedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (prayer.present) {
      map['prayer'] = Variable<String>(
        $PrayerLogsTable.$converterprayer.toSql(prayer.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $PrayerLogsTable.$converterstatus.toSql(status.value),
      );
    }
    if (markedAt.present) {
      map['marked_at'] = Variable<DateTime>(markedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrayerLogsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('prayer: $prayer, ')
          ..write('status: $status, ')
          ..write('markedAt: $markedAt')
          ..write(')'))
        .toString();
  }
}

class $QadaCountsTable extends QadaCounts
    with TableInfo<$QadaCountsTable, QadaCountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QadaCountsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<Prayer, String> prayer =
      GeneratedColumn<String>(
        'prayer',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Prayer>($QadaCountsTable.$converterprayer);
  static const VerificationMeta _remainingMeta = const VerificationMeta(
    'remaining',
  );
  @override
  late final GeneratedColumn<int> remaining = GeneratedColumn<int>(
    'remaining',
    aliasedName,
    false,
    check: () => ComparableExpr(remaining).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [prayer, remaining];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'qada_counts';
  @override
  VerificationContext validateIntegrity(
    Insertable<QadaCountRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('remaining')) {
      context.handle(
        _remainingMeta,
        remaining.isAcceptableOrUnknown(data['remaining']!, _remainingMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {prayer};
  @override
  QadaCountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QadaCountRow(
      prayer: $QadaCountsTable.$converterprayer.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}prayer'],
        )!,
      ),
      remaining: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remaining'],
      )!,
    );
  }

  @override
  $QadaCountsTable createAlias(String alias) {
    return $QadaCountsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Prayer, String, String> $converterprayer =
      const EnumNameConverter<Prayer>(Prayer.values);
}

class QadaCountRow extends DataClass implements Insertable<QadaCountRow> {
  final Prayer prayer;
  final int remaining;
  const QadaCountRow({required this.prayer, required this.remaining});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['prayer'] = Variable<String>(
        $QadaCountsTable.$converterprayer.toSql(prayer),
      );
    }
    map['remaining'] = Variable<int>(remaining);
    return map;
  }

  QadaCountsCompanion toCompanion(bool nullToAbsent) {
    return QadaCountsCompanion(
      prayer: Value(prayer),
      remaining: Value(remaining),
    );
  }

  factory QadaCountRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QadaCountRow(
      prayer: $QadaCountsTable.$converterprayer.fromJson(
        serializer.fromJson<String>(json['prayer']),
      ),
      remaining: serializer.fromJson<int>(json['remaining']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'prayer': serializer.toJson<String>(
        $QadaCountsTable.$converterprayer.toJson(prayer),
      ),
      'remaining': serializer.toJson<int>(remaining),
    };
  }

  QadaCountRow copyWith({Prayer? prayer, int? remaining}) => QadaCountRow(
    prayer: prayer ?? this.prayer,
    remaining: remaining ?? this.remaining,
  );
  QadaCountRow copyWithCompanion(QadaCountsCompanion data) {
    return QadaCountRow(
      prayer: data.prayer.present ? data.prayer.value : this.prayer,
      remaining: data.remaining.present ? data.remaining.value : this.remaining,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QadaCountRow(')
          ..write('prayer: $prayer, ')
          ..write('remaining: $remaining')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(prayer, remaining);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QadaCountRow &&
          other.prayer == this.prayer &&
          other.remaining == this.remaining);
}

class QadaCountsCompanion extends UpdateCompanion<QadaCountRow> {
  final Value<Prayer> prayer;
  final Value<int> remaining;
  final Value<int> rowid;
  const QadaCountsCompanion({
    this.prayer = const Value.absent(),
    this.remaining = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QadaCountsCompanion.insert({
    required Prayer prayer,
    this.remaining = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : prayer = Value(prayer);
  static Insertable<QadaCountRow> custom({
    Expression<String>? prayer,
    Expression<int>? remaining,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (prayer != null) 'prayer': prayer,
      if (remaining != null) 'remaining': remaining,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QadaCountsCompanion copyWith({
    Value<Prayer>? prayer,
    Value<int>? remaining,
    Value<int>? rowid,
  }) {
    return QadaCountsCompanion(
      prayer: prayer ?? this.prayer,
      remaining: remaining ?? this.remaining,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (prayer.present) {
      map['prayer'] = Variable<String>(
        $QadaCountsTable.$converterprayer.toSql(prayer.value),
      );
    }
    if (remaining.present) {
      map['remaining'] = Variable<int>(remaining.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QadaCountsCompanion(')
          ..write('prayer: $prayer, ')
          ..write('remaining: $remaining, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QadaEventsTable extends QadaEvents
    with TableInfo<$QadaEventsTable, QadaEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QadaEventsTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<Prayer, String> prayer =
      GeneratedColumn<String>(
        'prayer',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Prayer>($QadaEventsTable.$converterprayer);
  static const VerificationMeta _deltaMeta = const VerificationMeta('delta');
  @override
  late final GeneratedColumn<int> delta = GeneratedColumn<int>(
    'delta',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<QadaSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<QadaSource>($QadaEventsTable.$convertersource);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, prayer, delta, source, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'qada_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<QadaEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('delta')) {
      context.handle(
        _deltaMeta,
        delta.isAcceptableOrUnknown(data['delta']!, _deltaMeta),
      );
    } else if (isInserting) {
      context.missing(_deltaMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QadaEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QadaEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      prayer: $QadaEventsTable.$converterprayer.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}prayer'],
        )!,
      ),
      delta: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delta'],
      )!,
      source: $QadaEventsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $QadaEventsTable createAlias(String alias) {
    return $QadaEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Prayer, String, String> $converterprayer =
      const EnumNameConverter<Prayer>(Prayer.values);
  static JsonTypeConverter2<QadaSource, String, String> $convertersource =
      const EnumNameConverter<QadaSource>(QadaSource.values);
}

class QadaEventRow extends DataClass implements Insertable<QadaEventRow> {
  final int id;
  final Prayer prayer;

  /// +1 added, −1 made up (or an undo of a "missed" mark).
  final int delta;
  final QadaSource source;
  final DateTime createdAt;
  const QadaEventRow({
    required this.id,
    required this.prayer,
    required this.delta,
    required this.source,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['prayer'] = Variable<String>(
        $QadaEventsTable.$converterprayer.toSql(prayer),
      );
    }
    map['delta'] = Variable<int>(delta);
    {
      map['source'] = Variable<String>(
        $QadaEventsTable.$convertersource.toSql(source),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  QadaEventsCompanion toCompanion(bool nullToAbsent) {
    return QadaEventsCompanion(
      id: Value(id),
      prayer: Value(prayer),
      delta: Value(delta),
      source: Value(source),
      createdAt: Value(createdAt),
    );
  }

  factory QadaEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QadaEventRow(
      id: serializer.fromJson<int>(json['id']),
      prayer: $QadaEventsTable.$converterprayer.fromJson(
        serializer.fromJson<String>(json['prayer']),
      ),
      delta: serializer.fromJson<int>(json['delta']),
      source: $QadaEventsTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'prayer': serializer.toJson<String>(
        $QadaEventsTable.$converterprayer.toJson(prayer),
      ),
      'delta': serializer.toJson<int>(delta),
      'source': serializer.toJson<String>(
        $QadaEventsTable.$convertersource.toJson(source),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  QadaEventRow copyWith({
    int? id,
    Prayer? prayer,
    int? delta,
    QadaSource? source,
    DateTime? createdAt,
  }) => QadaEventRow(
    id: id ?? this.id,
    prayer: prayer ?? this.prayer,
    delta: delta ?? this.delta,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
  );
  QadaEventRow copyWithCompanion(QadaEventsCompanion data) {
    return QadaEventRow(
      id: data.id.present ? data.id.value : this.id,
      prayer: data.prayer.present ? data.prayer.value : this.prayer,
      delta: data.delta.present ? data.delta.value : this.delta,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QadaEventRow(')
          ..write('id: $id, ')
          ..write('prayer: $prayer, ')
          ..write('delta: $delta, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, prayer, delta, source, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QadaEventRow &&
          other.id == this.id &&
          other.prayer == this.prayer &&
          other.delta == this.delta &&
          other.source == this.source &&
          other.createdAt == this.createdAt);
}

class QadaEventsCompanion extends UpdateCompanion<QadaEventRow> {
  final Value<int> id;
  final Value<Prayer> prayer;
  final Value<int> delta;
  final Value<QadaSource> source;
  final Value<DateTime> createdAt;
  const QadaEventsCompanion({
    this.id = const Value.absent(),
    this.prayer = const Value.absent(),
    this.delta = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  QadaEventsCompanion.insert({
    this.id = const Value.absent(),
    required Prayer prayer,
    required int delta,
    required QadaSource source,
    required DateTime createdAt,
  }) : prayer = Value(prayer),
       delta = Value(delta),
       source = Value(source),
       createdAt = Value(createdAt);
  static Insertable<QadaEventRow> custom({
    Expression<int>? id,
    Expression<String>? prayer,
    Expression<int>? delta,
    Expression<String>? source,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (prayer != null) 'prayer': prayer,
      if (delta != null) 'delta': delta,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  QadaEventsCompanion copyWith({
    Value<int>? id,
    Value<Prayer>? prayer,
    Value<int>? delta,
    Value<QadaSource>? source,
    Value<DateTime>? createdAt,
  }) {
    return QadaEventsCompanion(
      id: id ?? this.id,
      prayer: prayer ?? this.prayer,
      delta: delta ?? this.delta,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (prayer.present) {
      map['prayer'] = Variable<String>(
        $QadaEventsTable.$converterprayer.toSql(prayer.value),
      );
    }
    if (delta.present) {
      map['delta'] = Variable<int>(delta.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $QadaEventsTable.$convertersource.toSql(source.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QadaEventsCompanion(')
          ..write('id: $id, ')
          ..write('prayer: $prayer, ')
          ..write('delta: $delta, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses
    with TableInfo<$ExpensesTable, ExpenseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    check: () => ComparableExpr(amountMinor).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('TMT'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ExpenseCategory, String>
  category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ExpenseCategory>($ExpensesTable.$convertercategory);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amountMinor,
    currency,
    category,
    note,
    occurredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      category: $ExpensesTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ExpenseCategory, String, String>
  $convertercategory = const EnumNameConverter<ExpenseCategory>(
    ExpenseCategory.values,
  );
}

class ExpenseRow extends DataClass implements Insertable<ExpenseRow> {
  final int id;

  /// Minor units (1/100). Never floats.
  final int amountMinor;
  final String currency;
  final ExpenseCategory category;
  final String? note;
  final DateTime occurredAt;
  const ExpenseRow({
    required this.id,
    required this.amountMinor,
    required this.currency,
    required this.category,
    this.note,
    required this.occurredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    {
      map['category'] = Variable<String>(
        $ExpensesTable.$convertercategory.toSql(category),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      category: Value(category),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      occurredAt: Value(occurredAt),
    );
  }

  factory ExpenseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseRow(
      id: serializer.fromJson<int>(json['id']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      category: $ExpensesTable.$convertercategory.fromJson(
        serializer.fromJson<String>(json['category']),
      ),
      note: serializer.fromJson<String?>(json['note']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'category': serializer.toJson<String>(
        $ExpensesTable.$convertercategory.toJson(category),
      ),
      'note': serializer.toJson<String?>(note),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  ExpenseRow copyWith({
    int? id,
    int? amountMinor,
    String? currency,
    ExpenseCategory? category,
    Value<String?> note = const Value.absent(),
    DateTime? occurredAt,
  }) => ExpenseRow(
    id: id ?? this.id,
    amountMinor: amountMinor ?? this.amountMinor,
    currency: currency ?? this.currency,
    category: category ?? this.category,
    note: note.present ? note.value : this.note,
    occurredAt: occurredAt ?? this.occurredAt,
  );
  ExpenseRow copyWithCompanion(ExpensesCompanion data) {
    return ExpenseRow(
      id: data.id.present ? data.id.value : this.id,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      category: data.category.present ? data.category.value : this.category,
      note: data.note.present ? data.note.value : this.note,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseRow(')
          ..write('id: $id, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, amountMinor, currency, category, note, occurredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseRow &&
          other.id == this.id &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.category == this.category &&
          other.note == this.note &&
          other.occurredAt == this.occurredAt);
}

class ExpensesCompanion extends UpdateCompanion<ExpenseRow> {
  final Value<int> id;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<ExpenseCategory> category;
  final Value<String?> note;
  final Value<DateTime> occurredAt;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.category = const Value.absent(),
    this.note = const Value.absent(),
    this.occurredAt = const Value.absent(),
  });
  ExpensesCompanion.insert({
    this.id = const Value.absent(),
    required int amountMinor,
    this.currency = const Value.absent(),
    required ExpenseCategory category,
    this.note = const Value.absent(),
    required DateTime occurredAt,
  }) : amountMinor = Value(amountMinor),
       category = Value(category),
       occurredAt = Value(occurredAt);
  static Insertable<ExpenseRow> custom({
    Expression<int>? id,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<String>? category,
    Expression<String>? note,
    Expression<DateTime>? occurredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (category != null) 'category': category,
      if (note != null) 'note': note,
      if (occurredAt != null) 'occurred_at': occurredAt,
    });
  }

  ExpensesCompanion copyWith({
    Value<int>? id,
    Value<int>? amountMinor,
    Value<String>? currency,
    Value<ExpenseCategory>? category,
    Value<String?>? note,
    Value<DateTime>? occurredAt,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      note: note ?? this.note,
      occurredAt: occurredAt ?? this.occurredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $ExpensesTable.$convertercategory.toSql(category.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, TaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 500,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TaskWindow, String> window =
      GeneratedColumn<String>(
        'window',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TaskWindow>($TasksTable.$converterwindow);
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _doneAtMeta = const VerificationMeta('doneAt');
  @override
  late final GeneratedColumn<DateTime> doneAt = GeneratedColumn<DateTime>(
    'done_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    date,
    window,
    done,
    doneAt,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    }
    if (data.containsKey('done_at')) {
      context.handle(
        _doneAtMeta,
        doneAt.isAcceptableOrUnknown(data['done_at']!, _doneAtMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      window: $TasksTable.$converterwindow.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}window'],
        )!,
      ),
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      )!,
      doneAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}done_at'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TaskWindow, String, String> $converterwindow =
      const EnumNameConverter<TaskWindow>(TaskWindow.values);
}

class TaskRow extends DataClass implements Insertable<TaskRow> {
  final int id;
  final String title;
  final String date;
  final TaskWindow window;
  final bool done;
  final DateTime? doneAt;
  final int sortOrder;
  const TaskRow({
    required this.id,
    required this.title,
    required this.date,
    required this.window,
    required this.done,
    this.doneAt,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['date'] = Variable<String>(date);
    {
      map['window'] = Variable<String>(
        $TasksTable.$converterwindow.toSql(window),
      );
    }
    map['done'] = Variable<bool>(done);
    if (!nullToAbsent || doneAt != null) {
      map['done_at'] = Variable<DateTime>(doneAt);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      date: Value(date),
      window: Value(window),
      done: Value(done),
      doneAt: doneAt == null && nullToAbsent
          ? const Value.absent()
          : Value(doneAt),
      sortOrder: Value(sortOrder),
    );
  }

  factory TaskRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      date: serializer.fromJson<String>(json['date']),
      window: $TasksTable.$converterwindow.fromJson(
        serializer.fromJson<String>(json['window']),
      ),
      done: serializer.fromJson<bool>(json['done']),
      doneAt: serializer.fromJson<DateTime?>(json['doneAt']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'date': serializer.toJson<String>(date),
      'window': serializer.toJson<String>(
        $TasksTable.$converterwindow.toJson(window),
      ),
      'done': serializer.toJson<bool>(done),
      'doneAt': serializer.toJson<DateTime?>(doneAt),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  TaskRow copyWith({
    int? id,
    String? title,
    String? date,
    TaskWindow? window,
    bool? done,
    Value<DateTime?> doneAt = const Value.absent(),
    int? sortOrder,
  }) => TaskRow(
    id: id ?? this.id,
    title: title ?? this.title,
    date: date ?? this.date,
    window: window ?? this.window,
    done: done ?? this.done,
    doneAt: doneAt.present ? doneAt.value : this.doneAt,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  TaskRow copyWithCompanion(TasksCompanion data) {
    return TaskRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      date: data.date.present ? data.date.value : this.date,
      window: data.window.present ? data.window.value : this.window,
      done: data.done.present ? data.done.value : this.done,
      doneAt: data.doneAt.present ? data.doneAt.value : this.doneAt,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('window: $window, ')
          ..write('done: $done, ')
          ..write('doneAt: $doneAt, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, date, window, done, doneAt, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.date == this.date &&
          other.window == this.window &&
          other.done == this.done &&
          other.doneAt == this.doneAt &&
          other.sortOrder == this.sortOrder);
}

class TasksCompanion extends UpdateCompanion<TaskRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> date;
  final Value<TaskWindow> window;
  final Value<bool> done;
  final Value<DateTime?> doneAt;
  final Value<int> sortOrder;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.date = const Value.absent(),
    this.window = const Value.absent(),
    this.done = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String date,
    required TaskWindow window,
    this.done = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : title = Value(title),
       date = Value(date),
       window = Value(window);
  static Insertable<TaskRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? date,
    Expression<String>? window,
    Expression<bool>? done,
    Expression<DateTime>? doneAt,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (date != null) 'date': date,
      if (window != null) 'window': window,
      if (done != null) 'done': done,
      if (doneAt != null) 'done_at': doneAt,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  TasksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? date,
    Value<TaskWindow>? window,
    Value<bool>? done,
    Value<DateTime?>? doneAt,
    Value<int>? sortOrder,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      window: window ?? this.window,
      done: done ?? this.done,
      doneAt: doneAt ?? this.doneAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (window.present) {
      map['window'] = Variable<String>(
        $TasksTable.$converterwindow.toSql(window.value),
      );
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (doneAt.present) {
      map['done_at'] = Variable<DateTime>(doneAt.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('window: $window, ')
          ..write('done: $done, ')
          ..write('doneAt: $doneAt, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $AdhkarProgressTable extends AdhkarProgress
    with TableInfo<$AdhkarProgressTable, AdhkarProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdhkarProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AdhkarSet, String> setId =
      GeneratedColumn<String>(
        'set_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AdhkarSet>($AdhkarProgressTable.$convertersetId);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [date, setId, itemId, count];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'adhkar_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdhkarProgressRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date, setId, itemId};
  @override
  AdhkarProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdhkarProgressRow(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      setId: $AdhkarProgressTable.$convertersetId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}set_id'],
        )!,
      ),
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
    );
  }

  @override
  $AdhkarProgressTable createAlias(String alias) {
    return $AdhkarProgressTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AdhkarSet, String, String> $convertersetId =
      const EnumNameConverter<AdhkarSet>(AdhkarSet.values);
}

class AdhkarProgressRow extends DataClass
    implements Insertable<AdhkarProgressRow> {
  final String date;
  final AdhkarSet setId;
  final String itemId;
  final int count;
  const AdhkarProgressRow({
    required this.date,
    required this.setId,
    required this.itemId,
    required this.count,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    {
      map['set_id'] = Variable<String>(
        $AdhkarProgressTable.$convertersetId.toSql(setId),
      );
    }
    map['item_id'] = Variable<String>(itemId);
    map['count'] = Variable<int>(count);
    return map;
  }

  AdhkarProgressCompanion toCompanion(bool nullToAbsent) {
    return AdhkarProgressCompanion(
      date: Value(date),
      setId: Value(setId),
      itemId: Value(itemId),
      count: Value(count),
    );
  }

  factory AdhkarProgressRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdhkarProgressRow(
      date: serializer.fromJson<String>(json['date']),
      setId: $AdhkarProgressTable.$convertersetId.fromJson(
        serializer.fromJson<String>(json['setId']),
      ),
      itemId: serializer.fromJson<String>(json['itemId']),
      count: serializer.fromJson<int>(json['count']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'setId': serializer.toJson<String>(
        $AdhkarProgressTable.$convertersetId.toJson(setId),
      ),
      'itemId': serializer.toJson<String>(itemId),
      'count': serializer.toJson<int>(count),
    };
  }

  AdhkarProgressRow copyWith({
    String? date,
    AdhkarSet? setId,
    String? itemId,
    int? count,
  }) => AdhkarProgressRow(
    date: date ?? this.date,
    setId: setId ?? this.setId,
    itemId: itemId ?? this.itemId,
    count: count ?? this.count,
  );
  AdhkarProgressRow copyWithCompanion(AdhkarProgressCompanion data) {
    return AdhkarProgressRow(
      date: data.date.present ? data.date.value : this.date,
      setId: data.setId.present ? data.setId.value : this.setId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      count: data.count.present ? data.count.value : this.count,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdhkarProgressRow(')
          ..write('date: $date, ')
          ..write('setId: $setId, ')
          ..write('itemId: $itemId, ')
          ..write('count: $count')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, setId, itemId, count);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdhkarProgressRow &&
          other.date == this.date &&
          other.setId == this.setId &&
          other.itemId == this.itemId &&
          other.count == this.count);
}

class AdhkarProgressCompanion extends UpdateCompanion<AdhkarProgressRow> {
  final Value<String> date;
  final Value<AdhkarSet> setId;
  final Value<String> itemId;
  final Value<int> count;
  final Value<int> rowid;
  const AdhkarProgressCompanion({
    this.date = const Value.absent(),
    this.setId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.count = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AdhkarProgressCompanion.insert({
    required String date,
    required AdhkarSet setId,
    required String itemId,
    this.count = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       setId = Value(setId),
       itemId = Value(itemId);
  static Insertable<AdhkarProgressRow> custom({
    Expression<String>? date,
    Expression<String>? setId,
    Expression<String>? itemId,
    Expression<int>? count,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (setId != null) 'set_id': setId,
      if (itemId != null) 'item_id': itemId,
      if (count != null) 'count': count,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AdhkarProgressCompanion copyWith({
    Value<String>? date,
    Value<AdhkarSet>? setId,
    Value<String>? itemId,
    Value<int>? count,
    Value<int>? rowid,
  }) {
    return AdhkarProgressCompanion(
      date: date ?? this.date,
      setId: setId ?? this.setId,
      itemId: itemId ?? this.itemId,
      count: count ?? this.count,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (setId.present) {
      map['set_id'] = Variable<String>(
        $AdhkarProgressTable.$convertersetId.toSql(setId.value),
      );
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdhkarProgressCompanion(')
          ..write('date: $date, ')
          ..write('setId: $setId, ')
          ..write('itemId: $itemId, ')
          ..write('count: $count, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FastsTable extends Fasts with TableInfo<$FastsTable, FastRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FastsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<FastType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<FastType>($FastsTable.$convertertype);
  @override
  late final GeneratedColumnWithTypeConverter<FastStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<FastStatus>($FastsTable.$converterstatus);
  @override
  List<GeneratedColumn> get $columns => [date, type, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fasts';
  @override
  VerificationContext validateIntegrity(
    Insertable<FastRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  FastRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FastRow(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      type: $FastsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      status: $FastsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
    );
  }

  @override
  $FastsTable createAlias(String alias) {
    return $FastsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FastType, String, String> $convertertype =
      const EnumNameConverter<FastType>(FastType.values);
  static JsonTypeConverter2<FastStatus, String, String> $converterstatus =
      const EnumNameConverter<FastStatus>(FastStatus.values);
}

class FastRow extends DataClass implements Insertable<FastRow> {
  final String date;
  final FastType type;
  final FastStatus status;
  const FastRow({required this.date, required this.type, required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    {
      map['type'] = Variable<String>($FastsTable.$convertertype.toSql(type));
    }
    {
      map['status'] = Variable<String>(
        $FastsTable.$converterstatus.toSql(status),
      );
    }
    return map;
  }

  FastsCompanion toCompanion(bool nullToAbsent) {
    return FastsCompanion(
      date: Value(date),
      type: Value(type),
      status: Value(status),
    );
  }

  factory FastRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FastRow(
      date: serializer.fromJson<String>(json['date']),
      type: $FastsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      status: $FastsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'type': serializer.toJson<String>(
        $FastsTable.$convertertype.toJson(type),
      ),
      'status': serializer.toJson<String>(
        $FastsTable.$converterstatus.toJson(status),
      ),
    };
  }

  FastRow copyWith({String? date, FastType? type, FastStatus? status}) =>
      FastRow(
        date: date ?? this.date,
        type: type ?? this.type,
        status: status ?? this.status,
      );
  FastRow copyWithCompanion(FastsCompanion data) {
    return FastRow(
      date: data.date.present ? data.date.value : this.date,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FastRow(')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, type, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FastRow &&
          other.date == this.date &&
          other.type == this.type &&
          other.status == this.status);
}

class FastsCompanion extends UpdateCompanion<FastRow> {
  final Value<String> date;
  final Value<FastType> type;
  final Value<FastStatus> status;
  final Value<int> rowid;
  const FastsCompanion({
    this.date = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FastsCompanion.insert({
    required String date,
    required FastType type,
    required FastStatus status,
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       type = Value(type),
       status = Value(status);
  static Insertable<FastRow> custom({
    Expression<String>? date,
    Expression<String>? type,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FastsCompanion copyWith({
    Value<String>? date,
    Value<FastType>? type,
    Value<FastStatus>? status,
    Value<int>? rowid,
  }) {
    return FastsCompanion(
      date: date ?? this.date,
      type: type ?? this.type,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $FastsTable.$convertertype.toSql(type.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $FastsTable.$converterstatus.toSql(status.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FastsCompanion(')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasbihSessionsTable extends TasbihSessions
    with TableInfo<$TasbihSessionsTable, TasbihSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasbihSessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _phraseMeta = const VerificationMeta('phrase');
  @override
  late final GeneratedColumn<String> phrase = GeneratedColumn<String>(
    'phrase',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalMeta = const VerificationMeta('goal');
  @override
  late final GeneratedColumn<int> goal = GeneratedColumn<int>(
    'goal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, phrase, count, goal, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasbih_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TasbihSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('phrase')) {
      context.handle(
        _phraseMeta,
        phrase.isAcceptableOrUnknown(data['phrase']!, _phraseMeta),
      );
    } else if (isInserting) {
      context.missing(_phraseMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    if (data.containsKey('goal')) {
      context.handle(
        _goalMeta,
        goal.isAcceptableOrUnknown(data['goal']!, _goalMeta),
      );
    } else if (isInserting) {
      context.missing(_goalMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TasbihSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TasbihSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      phrase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phrase'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      goal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}goal'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TasbihSessionsTable createAlias(String alias) {
    return $TasbihSessionsTable(attachedDatabase, alias);
  }
}

class TasbihSessionRow extends DataClass
    implements Insertable<TasbihSessionRow> {
  final int id;
  final String phrase;
  final int count;
  final int goal;
  final DateTime createdAt;
  const TasbihSessionRow({
    required this.id,
    required this.phrase,
    required this.count,
    required this.goal,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['phrase'] = Variable<String>(phrase);
    map['count'] = Variable<int>(count);
    map['goal'] = Variable<int>(goal);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TasbihSessionsCompanion toCompanion(bool nullToAbsent) {
    return TasbihSessionsCompanion(
      id: Value(id),
      phrase: Value(phrase),
      count: Value(count),
      goal: Value(goal),
      createdAt: Value(createdAt),
    );
  }

  factory TasbihSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TasbihSessionRow(
      id: serializer.fromJson<int>(json['id']),
      phrase: serializer.fromJson<String>(json['phrase']),
      count: serializer.fromJson<int>(json['count']),
      goal: serializer.fromJson<int>(json['goal']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'phrase': serializer.toJson<String>(phrase),
      'count': serializer.toJson<int>(count),
      'goal': serializer.toJson<int>(goal),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TasbihSessionRow copyWith({
    int? id,
    String? phrase,
    int? count,
    int? goal,
    DateTime? createdAt,
  }) => TasbihSessionRow(
    id: id ?? this.id,
    phrase: phrase ?? this.phrase,
    count: count ?? this.count,
    goal: goal ?? this.goal,
    createdAt: createdAt ?? this.createdAt,
  );
  TasbihSessionRow copyWithCompanion(TasbihSessionsCompanion data) {
    return TasbihSessionRow(
      id: data.id.present ? data.id.value : this.id,
      phrase: data.phrase.present ? data.phrase.value : this.phrase,
      count: data.count.present ? data.count.value : this.count,
      goal: data.goal.present ? data.goal.value : this.goal,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TasbihSessionRow(')
          ..write('id: $id, ')
          ..write('phrase: $phrase, ')
          ..write('count: $count, ')
          ..write('goal: $goal, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, phrase, count, goal, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TasbihSessionRow &&
          other.id == this.id &&
          other.phrase == this.phrase &&
          other.count == this.count &&
          other.goal == this.goal &&
          other.createdAt == this.createdAt);
}

class TasbihSessionsCompanion extends UpdateCompanion<TasbihSessionRow> {
  final Value<int> id;
  final Value<String> phrase;
  final Value<int> count;
  final Value<int> goal;
  final Value<DateTime> createdAt;
  const TasbihSessionsCompanion({
    this.id = const Value.absent(),
    this.phrase = const Value.absent(),
    this.count = const Value.absent(),
    this.goal = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TasbihSessionsCompanion.insert({
    this.id = const Value.absent(),
    required String phrase,
    required int count,
    required int goal,
    required DateTime createdAt,
  }) : phrase = Value(phrase),
       count = Value(count),
       goal = Value(goal),
       createdAt = Value(createdAt);
  static Insertable<TasbihSessionRow> custom({
    Expression<int>? id,
    Expression<String>? phrase,
    Expression<int>? count,
    Expression<int>? goal,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (phrase != null) 'phrase': phrase,
      if (count != null) 'count': count,
      if (goal != null) 'goal': goal,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TasbihSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? phrase,
    Value<int>? count,
    Value<int>? goal,
    Value<DateTime>? createdAt,
  }) {
    return TasbihSessionsCompanion(
      id: id ?? this.id,
      phrase: phrase ?? this.phrase,
      count: count ?? this.count,
      goal: goal ?? this.goal,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (phrase.present) {
      map['phrase'] = Variable<String>(phrase.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (goal.present) {
      map['goal'] = Variable<int>(goal.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasbihSessionsCompanion(')
          ..write('id: $id, ')
          ..write('phrase: $phrase, ')
          ..write('count: $count, ')
          ..write('goal: $goal, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, BookmarkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<BookmarkKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<BookmarkKind>($BookmarksTable.$converterkind);
  static const VerificationMeta _refMeta = const VerificationMeta('ref');
  @override
  late final GeneratedColumn<String> ref = GeneratedColumn<String>(
    'ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, kind, ref, note, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookmarkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ref')) {
      context.handle(
        _refMeta,
        ref.isAcceptableOrUnknown(data['ref']!, _refMeta),
      );
    } else if (isInserting) {
      context.missing(_refMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {kind, ref},
  ];
  @override
  BookmarkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarkRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: $BookmarksTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      ref: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BookmarkKind, String, String> $converterkind =
      const EnumNameConverter<BookmarkKind>(BookmarkKind.values);
}

class BookmarkRow extends DataClass implements Insertable<BookmarkRow> {
  final int id;
  final BookmarkKind kind;
  final String ref;
  final String? note;
  final DateTime createdAt;
  const BookmarkRow({
    required this.id,
    required this.kind,
    required this.ref,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['kind'] = Variable<String>(
        $BookmarksTable.$converterkind.toSql(kind),
      );
    }
    map['ref'] = Variable<String>(ref);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      id: Value(id),
      kind: Value(kind),
      ref: Value(ref),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory BookmarkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarkRow(
      id: serializer.fromJson<int>(json['id']),
      kind: $BookmarksTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      ref: serializer.fromJson<String>(json['ref']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(
        $BookmarksTable.$converterkind.toJson(kind),
      ),
      'ref': serializer.toJson<String>(ref),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BookmarkRow copyWith({
    int? id,
    BookmarkKind? kind,
    String? ref,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => BookmarkRow(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    ref: ref ?? this.ref,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  BookmarkRow copyWithCompanion(BookmarksCompanion data) {
    return BookmarkRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      ref: data.ref.present ? data.ref.value : this.ref,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('ref: $ref, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kind, ref, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarkRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.ref == this.ref &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class BookmarksCompanion extends UpdateCompanion<BookmarkRow> {
  final Value<int> id;
  final Value<BookmarkKind> kind;
  final Value<String> ref;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  const BookmarksCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.ref = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BookmarksCompanion.insert({
    this.id = const Value.absent(),
    required BookmarkKind kind,
    required String ref,
    this.note = const Value.absent(),
    required DateTime createdAt,
  }) : kind = Value(kind),
       ref = Value(ref),
       createdAt = Value(createdAt);
  static Insertable<BookmarkRow> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<String>? ref,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (ref != null) 'ref': ref,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BookmarksCompanion copyWith({
    Value<int>? id,
    Value<BookmarkKind>? kind,
    Value<String>? ref,
    Value<String?>? note,
    Value<DateTime>? createdAt,
  }) {
    return BookmarksCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      ref: ref ?? this.ref,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $BookmarksTable.$converterkind.toSql(kind.value),
      );
    }
    if (ref.present) {
      map['ref'] = Variable<String>(ref.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('ref: $ref, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $QuranReadsTable extends QuranReads
    with TableInfo<$QuranReadsTable, QuranReadRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuranReadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ayahMeta = const VerificationMeta('ayah');
  @override
  late final GeneratedColumn<int> ayah = GeneratedColumn<int>(
    'ayah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [date, ayah];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quran_reads';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuranReadRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('ayah')) {
      context.handle(
        _ayahMeta,
        ayah.isAcceptableOrUnknown(data['ayah']!, _ayahMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date, ayah};
  @override
  QuranReadRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuranReadRow(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      ayah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah'],
      )!,
    );
  }

  @override
  $QuranReadsTable createAlias(String alias) {
    return $QuranReadsTable(attachedDatabase, alias);
  }
}

class QuranReadRow extends DataClass implements Insertable<QuranReadRow> {
  final String date;
  final int ayah;
  const QuranReadRow({required this.date, required this.ayah});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['ayah'] = Variable<int>(ayah);
    return map;
  }

  QuranReadsCompanion toCompanion(bool nullToAbsent) {
    return QuranReadsCompanion(date: Value(date), ayah: Value(ayah));
  }

  factory QuranReadRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuranReadRow(
      date: serializer.fromJson<String>(json['date']),
      ayah: serializer.fromJson<int>(json['ayah']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'ayah': serializer.toJson<int>(ayah),
    };
  }

  QuranReadRow copyWith({String? date, int? ayah}) =>
      QuranReadRow(date: date ?? this.date, ayah: ayah ?? this.ayah);
  QuranReadRow copyWithCompanion(QuranReadsCompanion data) {
    return QuranReadRow(
      date: data.date.present ? data.date.value : this.date,
      ayah: data.ayah.present ? data.ayah.value : this.ayah,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuranReadRow(')
          ..write('date: $date, ')
          ..write('ayah: $ayah')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, ayah);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuranReadRow &&
          other.date == this.date &&
          other.ayah == this.ayah);
}

class QuranReadsCompanion extends UpdateCompanion<QuranReadRow> {
  final Value<String> date;
  final Value<int> ayah;
  final Value<int> rowid;
  const QuranReadsCompanion({
    this.date = const Value.absent(),
    this.ayah = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuranReadsCompanion.insert({
    required String date,
    required int ayah,
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       ayah = Value(ayah);
  static Insertable<QuranReadRow> custom({
    Expression<String>? date,
    Expression<int>? ayah,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (ayah != null) 'ayah': ayah,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuranReadsCompanion copyWith({
    Value<String>? date,
    Value<int>? ayah,
    Value<int>? rowid,
  }) {
    return QuranReadsCompanion(
      date: date ?? this.date,
      ayah: ayah ?? this.ayah,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (ayah.present) {
      map['ayah'] = Variable<int>(ayah.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuranReadsCompanion(')
          ..write('date: $date, ')
          ..write('ayah: $ayah, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HifzItemsTable extends HifzItems
    with TableInfo<$HifzItemsTable, HifzRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HifzItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _surahMeta = const VerificationMeta('surah');
  @override
  late final GeneratedColumn<int> surah = GeneratedColumn<int>(
    'surah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<HifzStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<HifzStatus>($HifzItemsTable.$converterstatus);
  static const VerificationMeta _stepMeta = const VerificationMeta('step');
  @override
  late final GeneratedColumn<int> step = GeneratedColumn<int>(
    'step',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextReviewMeta = const VerificationMeta(
    'nextReview',
  );
  @override
  late final GeneratedColumn<String> nextReview = GeneratedColumn<String>(
    'next_review',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    surah,
    status,
    step,
    nextReview,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hifz_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<HifzRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('surah')) {
      context.handle(
        _surahMeta,
        surah.isAcceptableOrUnknown(data['surah']!, _surahMeta),
      );
    }
    if (data.containsKey('step')) {
      context.handle(
        _stepMeta,
        step.isAcceptableOrUnknown(data['step']!, _stepMeta),
      );
    }
    if (data.containsKey('next_review')) {
      context.handle(
        _nextReviewMeta,
        nextReview.isAcceptableOrUnknown(data['next_review']!, _nextReviewMeta),
      );
    } else if (isInserting) {
      context.missing(_nextReviewMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {surah};
  @override
  HifzRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HifzRow(
      surah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah'],
      )!,
      status: $HifzItemsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      step: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step'],
      )!,
      nextReview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_review'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $HifzItemsTable createAlias(String alias) {
    return $HifzItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<HifzStatus, String, String> $converterstatus =
      const EnumNameConverter<HifzStatus>(HifzStatus.values);
}

class HifzRow extends DataClass implements Insertable<HifzRow> {
  final int surah;
  final HifzStatus status;

  /// Index into the review ladder (1-3-7-14-30-90 days).
  final int step;

  /// `yyyy-MM-dd` of the next review.
  final String nextReview;
  final DateTime updatedAt;
  const HifzRow({
    required this.surah,
    required this.status,
    required this.step,
    required this.nextReview,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['surah'] = Variable<int>(surah);
    {
      map['status'] = Variable<String>(
        $HifzItemsTable.$converterstatus.toSql(status),
      );
    }
    map['step'] = Variable<int>(step);
    map['next_review'] = Variable<String>(nextReview);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  HifzItemsCompanion toCompanion(bool nullToAbsent) {
    return HifzItemsCompanion(
      surah: Value(surah),
      status: Value(status),
      step: Value(step),
      nextReview: Value(nextReview),
      updatedAt: Value(updatedAt),
    );
  }

  factory HifzRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HifzRow(
      surah: serializer.fromJson<int>(json['surah']),
      status: $HifzItemsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      step: serializer.fromJson<int>(json['step']),
      nextReview: serializer.fromJson<String>(json['nextReview']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'surah': serializer.toJson<int>(surah),
      'status': serializer.toJson<String>(
        $HifzItemsTable.$converterstatus.toJson(status),
      ),
      'step': serializer.toJson<int>(step),
      'nextReview': serializer.toJson<String>(nextReview),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  HifzRow copyWith({
    int? surah,
    HifzStatus? status,
    int? step,
    String? nextReview,
    DateTime? updatedAt,
  }) => HifzRow(
    surah: surah ?? this.surah,
    status: status ?? this.status,
    step: step ?? this.step,
    nextReview: nextReview ?? this.nextReview,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  HifzRow copyWithCompanion(HifzItemsCompanion data) {
    return HifzRow(
      surah: data.surah.present ? data.surah.value : this.surah,
      status: data.status.present ? data.status.value : this.status,
      step: data.step.present ? data.step.value : this.step,
      nextReview: data.nextReview.present
          ? data.nextReview.value
          : this.nextReview,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HifzRow(')
          ..write('surah: $surah, ')
          ..write('status: $status, ')
          ..write('step: $step, ')
          ..write('nextReview: $nextReview, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(surah, status, step, nextReview, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HifzRow &&
          other.surah == this.surah &&
          other.status == this.status &&
          other.step == this.step &&
          other.nextReview == this.nextReview &&
          other.updatedAt == this.updatedAt);
}

class HifzItemsCompanion extends UpdateCompanion<HifzRow> {
  final Value<int> surah;
  final Value<HifzStatus> status;
  final Value<int> step;
  final Value<String> nextReview;
  final Value<DateTime> updatedAt;
  const HifzItemsCompanion({
    this.surah = const Value.absent(),
    this.status = const Value.absent(),
    this.step = const Value.absent(),
    this.nextReview = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  HifzItemsCompanion.insert({
    this.surah = const Value.absent(),
    required HifzStatus status,
    this.step = const Value.absent(),
    required String nextReview,
    required DateTime updatedAt,
  }) : status = Value(status),
       nextReview = Value(nextReview),
       updatedAt = Value(updatedAt);
  static Insertable<HifzRow> custom({
    Expression<int>? surah,
    Expression<String>? status,
    Expression<int>? step,
    Expression<String>? nextReview,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (surah != null) 'surah': surah,
      if (status != null) 'status': status,
      if (step != null) 'step': step,
      if (nextReview != null) 'next_review': nextReview,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  HifzItemsCompanion copyWith({
    Value<int>? surah,
    Value<HifzStatus>? status,
    Value<int>? step,
    Value<String>? nextReview,
    Value<DateTime>? updatedAt,
  }) {
    return HifzItemsCompanion(
      surah: surah ?? this.surah,
      status: status ?? this.status,
      step: step ?? this.step,
      nextReview: nextReview ?? this.nextReview,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (surah.present) {
      map['surah'] = Variable<int>(surah.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $HifzItemsTable.$converterstatus.toSql(status.value),
      );
    }
    if (step.present) {
      map['step'] = Variable<int>(step.value);
    }
    if (nextReview.present) {
      map['next_review'] = Variable<String>(nextReview.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HifzItemsCompanion(')
          ..write('surah: $surah, ')
          ..write('status: $status, ')
          ..write('step: $step, ')
          ..write('nextReview: $nextReview, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $HabitsTable extends Habits with TableInfo<$HabitsTable, HabitRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('star'),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    icon,
    archived,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }
}

class HabitRow extends DataClass implements Insertable<HabitRow> {
  final int id;
  final String title;

  /// Icon key from the habit icon palette (see habits feature).
  final String icon;
  final bool archived;
  final int sortOrder;
  final DateTime createdAt;
  const HabitRow({
    required this.id,
    required this.title,
    required this.icon,
    required this.archived,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['icon'] = Variable<String>(icon);
    map['archived'] = Variable<bool>(archived);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      id: Value(id),
      title: Value(title),
      icon: Value(icon),
      archived: Value(archived),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory HabitRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      icon: serializer.fromJson<String>(json['icon']),
      archived: serializer.fromJson<bool>(json['archived']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'icon': serializer.toJson<String>(icon),
      'archived': serializer.toJson<bool>(archived),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HabitRow copyWith({
    int? id,
    String? title,
    String? icon,
    bool? archived,
    int? sortOrder,
    DateTime? createdAt,
  }) => HabitRow(
    id: id ?? this.id,
    title: title ?? this.title,
    icon: icon ?? this.icon,
    archived: archived ?? this.archived,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  HabitRow copyWithCompanion(HabitsCompanion data) {
    return HabitRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      icon: data.icon.present ? data.icon.value : this.icon,
      archived: data.archived.present ? data.archived.value : this.archived,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('icon: $icon, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, icon, archived, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.icon == this.icon &&
          other.archived == this.archived &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class HabitsCompanion extends UpdateCompanion<HabitRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> icon;
  final Value<bool> archived;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  const HabitsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.icon = const Value.absent(),
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  HabitsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.icon = const Value.absent(),
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
  }) : title = Value(title),
       createdAt = Value(createdAt);
  static Insertable<HabitRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? icon,
    Expression<bool>? archived,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (icon != null) 'icon': icon,
      if (archived != null) 'archived': archived,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  HabitsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? icon,
    Value<bool>? archived,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
  }) {
    return HabitsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      archived: archived ?? this.archived,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('icon: $icon, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $HabitLogsTable extends HabitLogs
    with TableInfo<$HabitLogsTable, HabitLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<int> habitId = GeneratedColumn<int>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES habits (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [habitId, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {habitId, date};
  @override
  HabitLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitLogRow(
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}habit_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
    );
  }

  @override
  $HabitLogsTable createAlias(String alias) {
    return $HabitLogsTable(attachedDatabase, alias);
  }
}

class HabitLogRow extends DataClass implements Insertable<HabitLogRow> {
  final int habitId;
  final String date;
  const HabitLogRow({required this.habitId, required this.date});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['habit_id'] = Variable<int>(habitId);
    map['date'] = Variable<String>(date);
    return map;
  }

  HabitLogsCompanion toCompanion(bool nullToAbsent) {
    return HabitLogsCompanion(habitId: Value(habitId), date: Value(date));
  }

  factory HabitLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitLogRow(
      habitId: serializer.fromJson<int>(json['habitId']),
      date: serializer.fromJson<String>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'habitId': serializer.toJson<int>(habitId),
      'date': serializer.toJson<String>(date),
    };
  }

  HabitLogRow copyWith({int? habitId, String? date}) =>
      HabitLogRow(habitId: habitId ?? this.habitId, date: date ?? this.date);
  HabitLogRow copyWithCompanion(HabitLogsCompanion data) {
    return HabitLogRow(
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitLogRow(')
          ..write('habitId: $habitId, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(habitId, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitLogRow &&
          other.habitId == this.habitId &&
          other.date == this.date);
}

class HabitLogsCompanion extends UpdateCompanion<HabitLogRow> {
  final Value<int> habitId;
  final Value<String> date;
  final Value<int> rowid;
  const HabitLogsCompanion({
    this.habitId = const Value.absent(),
    this.date = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitLogsCompanion.insert({
    required int habitId,
    required String date,
    this.rowid = const Value.absent(),
  }) : habitId = Value(habitId),
       date = Value(date);
  static Insertable<HabitLogRow> custom({
    Expression<int>? habitId,
    Expression<String>? date,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (habitId != null) 'habit_id': habitId,
      if (date != null) 'date': date,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitLogsCompanion copyWith({
    Value<int>? habitId,
    Value<String>? date,
    Value<int>? rowid,
  }) {
    return HabitLogsCompanion(
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (habitId.present) {
      map['habit_id'] = Variable<int>(habitId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitLogsCompanion(')
          ..write('habitId: $habitId, ')
          ..write('date: $date, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PrayerLogsTable prayerLogs = $PrayerLogsTable(this);
  late final $QadaCountsTable qadaCounts = $QadaCountsTable(this);
  late final $QadaEventsTable qadaEvents = $QadaEventsTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $AdhkarProgressTable adhkarProgress = $AdhkarProgressTable(this);
  late final $FastsTable fasts = $FastsTable(this);
  late final $TasbihSessionsTable tasbihSessions = $TasbihSessionsTable(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $QuranReadsTable quranReads = $QuranReadsTable(this);
  late final $HifzItemsTable hifzItems = $HifzItemsTable(this);
  late final $HabitsTable habits = $HabitsTable(this);
  late final $HabitLogsTable habitLogs = $HabitLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    prayerLogs,
    qadaCounts,
    qadaEvents,
    expenses,
    tasks,
    adhkarProgress,
    fasts,
    tasbihSessions,
    bookmarks,
    quranReads,
    hifzItems,
    habits,
    habitLogs,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'habits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('habit_logs', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PrayerLogsTableCreateCompanionBuilder =
    PrayerLogsCompanion Function({
      Value<int> id,
      required String date,
      required Prayer prayer,
      required PrayerStatus status,
      required DateTime markedAt,
    });
typedef $$PrayerLogsTableUpdateCompanionBuilder =
    PrayerLogsCompanion Function({
      Value<int> id,
      Value<String> date,
      Value<Prayer> prayer,
      Value<PrayerStatus> status,
      Value<DateTime> markedAt,
    });

class $$PrayerLogsTableFilterComposer
    extends Composer<_$AppDatabase, $PrayerLogsTable> {
  $$PrayerLogsTableFilterComposer({
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

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Prayer, Prayer, String> get prayer =>
      $composableBuilder(
        column: $table.prayer,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<PrayerStatus, PrayerStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get markedAt => $composableBuilder(
    column: $table.markedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PrayerLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $PrayerLogsTable> {
  $$PrayerLogsTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prayer => $composableBuilder(
    column: $table.prayer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get markedAt => $composableBuilder(
    column: $table.markedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrayerLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrayerLogsTable> {
  $$PrayerLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Prayer, String> get prayer =>
      $composableBuilder(column: $table.prayer, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PrayerStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get markedAt =>
      $composableBuilder(column: $table.markedAt, builder: (column) => column);
}

class $$PrayerLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrayerLogsTable,
          PrayerLogRow,
          $$PrayerLogsTableFilterComposer,
          $$PrayerLogsTableOrderingComposer,
          $$PrayerLogsTableAnnotationComposer,
          $$PrayerLogsTableCreateCompanionBuilder,
          $$PrayerLogsTableUpdateCompanionBuilder,
          (
            PrayerLogRow,
            BaseReferences<_$AppDatabase, $PrayerLogsTable, PrayerLogRow>,
          ),
          PrayerLogRow,
          PrefetchHooks Function()
        > {
  $$PrayerLogsTableTableManager(_$AppDatabase db, $PrayerLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrayerLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrayerLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrayerLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<Prayer> prayer = const Value.absent(),
                Value<PrayerStatus> status = const Value.absent(),
                Value<DateTime> markedAt = const Value.absent(),
              }) => PrayerLogsCompanion(
                id: id,
                date: date,
                prayer: prayer,
                status: status,
                markedAt: markedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                required Prayer prayer,
                required PrayerStatus status,
                required DateTime markedAt,
              }) => PrayerLogsCompanion.insert(
                id: id,
                date: date,
                prayer: prayer,
                status: status,
                markedAt: markedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PrayerLogsTable, PrayerLogRow>(table),
                  BaseReferences<_$AppDatabase, $PrayerLogsTable, PrayerLogRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PrayerLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrayerLogsTable,
      PrayerLogRow,
      $$PrayerLogsTableFilterComposer,
      $$PrayerLogsTableOrderingComposer,
      $$PrayerLogsTableAnnotationComposer,
      $$PrayerLogsTableCreateCompanionBuilder,
      $$PrayerLogsTableUpdateCompanionBuilder,
      (
        PrayerLogRow,
        BaseReferences<_$AppDatabase, $PrayerLogsTable, PrayerLogRow>,
      ),
      PrayerLogRow,
      PrefetchHooks Function()
    >;
typedef $$QadaCountsTableCreateCompanionBuilder =
    QadaCountsCompanion Function({
      required Prayer prayer,
      Value<int> remaining,
      Value<int> rowid,
    });
typedef $$QadaCountsTableUpdateCompanionBuilder =
    QadaCountsCompanion Function({
      Value<Prayer> prayer,
      Value<int> remaining,
      Value<int> rowid,
    });

class $$QadaCountsTableFilterComposer
    extends Composer<_$AppDatabase, $QadaCountsTable> {
  $$QadaCountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<Prayer, Prayer, String> get prayer =>
      $composableBuilder(
        column: $table.prayer,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get remaining => $composableBuilder(
    column: $table.remaining,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QadaCountsTableOrderingComposer
    extends Composer<_$AppDatabase, $QadaCountsTable> {
  $$QadaCountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get prayer => $composableBuilder(
    column: $table.prayer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remaining => $composableBuilder(
    column: $table.remaining,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QadaCountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QadaCountsTable> {
  $$QadaCountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<Prayer, String> get prayer =>
      $composableBuilder(column: $table.prayer, builder: (column) => column);

  GeneratedColumn<int> get remaining =>
      $composableBuilder(column: $table.remaining, builder: (column) => column);
}

class $$QadaCountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QadaCountsTable,
          QadaCountRow,
          $$QadaCountsTableFilterComposer,
          $$QadaCountsTableOrderingComposer,
          $$QadaCountsTableAnnotationComposer,
          $$QadaCountsTableCreateCompanionBuilder,
          $$QadaCountsTableUpdateCompanionBuilder,
          (
            QadaCountRow,
            BaseReferences<_$AppDatabase, $QadaCountsTable, QadaCountRow>,
          ),
          QadaCountRow,
          PrefetchHooks Function()
        > {
  $$QadaCountsTableTableManager(_$AppDatabase db, $QadaCountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QadaCountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QadaCountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QadaCountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<Prayer> prayer = const Value.absent(),
                Value<int> remaining = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QadaCountsCompanion(
                prayer: prayer,
                remaining: remaining,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required Prayer prayer,
                Value<int> remaining = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QadaCountsCompanion.insert(
                prayer: prayer,
                remaining: remaining,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QadaCountsTable, QadaCountRow>(table),
                  BaseReferences<_$AppDatabase, $QadaCountsTable, QadaCountRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QadaCountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QadaCountsTable,
      QadaCountRow,
      $$QadaCountsTableFilterComposer,
      $$QadaCountsTableOrderingComposer,
      $$QadaCountsTableAnnotationComposer,
      $$QadaCountsTableCreateCompanionBuilder,
      $$QadaCountsTableUpdateCompanionBuilder,
      (
        QadaCountRow,
        BaseReferences<_$AppDatabase, $QadaCountsTable, QadaCountRow>,
      ),
      QadaCountRow,
      PrefetchHooks Function()
    >;
typedef $$QadaEventsTableCreateCompanionBuilder =
    QadaEventsCompanion Function({
      Value<int> id,
      required Prayer prayer,
      required int delta,
      required QadaSource source,
      required DateTime createdAt,
    });
typedef $$QadaEventsTableUpdateCompanionBuilder =
    QadaEventsCompanion Function({
      Value<int> id,
      Value<Prayer> prayer,
      Value<int> delta,
      Value<QadaSource> source,
      Value<DateTime> createdAt,
    });

class $$QadaEventsTableFilterComposer
    extends Composer<_$AppDatabase, $QadaEventsTable> {
  $$QadaEventsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<Prayer, Prayer, String> get prayer =>
      $composableBuilder(
        column: $table.prayer,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get delta => $composableBuilder(
    column: $table.delta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<QadaSource, QadaSource, String> get source =>
      $composableBuilder(
        column: $table.source,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QadaEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $QadaEventsTable> {
  $$QadaEventsTableOrderingComposer({
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

  ColumnOrderings<String> get prayer => $composableBuilder(
    column: $table.prayer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get delta => $composableBuilder(
    column: $table.delta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QadaEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QadaEventsTable> {
  $$QadaEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Prayer, String> get prayer =>
      $composableBuilder(column: $table.prayer, builder: (column) => column);

  GeneratedColumn<int> get delta =>
      $composableBuilder(column: $table.delta, builder: (column) => column);

  GeneratedColumnWithTypeConverter<QadaSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$QadaEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QadaEventsTable,
          QadaEventRow,
          $$QadaEventsTableFilterComposer,
          $$QadaEventsTableOrderingComposer,
          $$QadaEventsTableAnnotationComposer,
          $$QadaEventsTableCreateCompanionBuilder,
          $$QadaEventsTableUpdateCompanionBuilder,
          (
            QadaEventRow,
            BaseReferences<_$AppDatabase, $QadaEventsTable, QadaEventRow>,
          ),
          QadaEventRow,
          PrefetchHooks Function()
        > {
  $$QadaEventsTableTableManager(_$AppDatabase db, $QadaEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QadaEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QadaEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QadaEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<Prayer> prayer = const Value.absent(),
                Value<int> delta = const Value.absent(),
                Value<QadaSource> source = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => QadaEventsCompanion(
                id: id,
                prayer: prayer,
                delta: delta,
                source: source,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required Prayer prayer,
                required int delta,
                required QadaSource source,
                required DateTime createdAt,
              }) => QadaEventsCompanion.insert(
                id: id,
                prayer: prayer,
                delta: delta,
                source: source,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QadaEventsTable, QadaEventRow>(table),
                  BaseReferences<_$AppDatabase, $QadaEventsTable, QadaEventRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QadaEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QadaEventsTable,
      QadaEventRow,
      $$QadaEventsTableFilterComposer,
      $$QadaEventsTableOrderingComposer,
      $$QadaEventsTableAnnotationComposer,
      $$QadaEventsTableCreateCompanionBuilder,
      $$QadaEventsTableUpdateCompanionBuilder,
      (
        QadaEventRow,
        BaseReferences<_$AppDatabase, $QadaEventsTable, QadaEventRow>,
      ),
      QadaEventRow,
      PrefetchHooks Function()
    >;
typedef $$ExpensesTableCreateCompanionBuilder =
    ExpensesCompanion Function({
      Value<int> id,
      required int amountMinor,
      Value<String> currency,
      required ExpenseCategory category,
      Value<String?> note,
      required DateTime occurredAt,
    });
typedef $$ExpensesTableUpdateCompanionBuilder =
    ExpensesCompanion Function({
      Value<int> id,
      Value<int> amountMinor,
      Value<String> currency,
      Value<ExpenseCategory> category,
      Value<String?> note,
      Value<DateTime> occurredAt,
    });

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
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

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ExpenseCategory, ExpenseCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
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

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ExpenseCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          ExpenseRow,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (
            ExpenseRow,
            BaseReferences<_$AppDatabase, $ExpensesTable, ExpenseRow>,
          ),
          ExpenseRow,
          PrefetchHooks Function()
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<ExpenseCategory> category = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                amountMinor: amountMinor,
                currency: currency,
                category: category,
                note: note,
                occurredAt: occurredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int amountMinor,
                Value<String> currency = const Value.absent(),
                required ExpenseCategory category,
                Value<String?> note = const Value.absent(),
                required DateTime occurredAt,
              }) => ExpensesCompanion.insert(
                id: id,
                amountMinor: amountMinor,
                currency: currency,
                category: category,
                note: note,
                occurredAt: occurredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExpensesTable, ExpenseRow>(table),
                  BaseReferences<_$AppDatabase, $ExpensesTable, ExpenseRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      ExpenseRow,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (ExpenseRow, BaseReferences<_$AppDatabase, $ExpensesTable, ExpenseRow>),
      ExpenseRow,
      PrefetchHooks Function()
    >;
typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      required String title,
      required String date,
      required TaskWindow window,
      Value<bool> done,
      Value<DateTime?> doneAt,
      Value<int> sortOrder,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> date,
      Value<TaskWindow> window,
      Value<bool> done,
      Value<DateTime?> doneAt,
      Value<int> sortOrder,
    });

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TaskWindow, TaskWindow, String> get window =>
      $composableBuilder(
        column: $table.window,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get doneAt => $composableBuilder(
    column: $table.doneAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get window => $composableBuilder(
    column: $table.window,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get doneAt => $composableBuilder(
    column: $table.doneAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TaskWindow, String> get window =>
      $composableBuilder(column: $table.window, builder: (column) => column);

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<DateTime> get doneAt =>
      $composableBuilder(column: $table.doneAt, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          TaskRow,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (TaskRow, BaseReferences<_$AppDatabase, $TasksTable, TaskRow>),
          TaskRow,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<TaskWindow> window = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<DateTime?> doneAt = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                title: title,
                date: date,
                window: window,
                done: done,
                doneAt: doneAt,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String date,
                required TaskWindow window,
                Value<bool> done = const Value.absent(),
                Value<DateTime?> doneAt = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                title: title,
                date: date,
                window: window,
                done: done,
                doneAt: doneAt,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasksTable, TaskRow>(table),
                  BaseReferences<_$AppDatabase, $TasksTable, TaskRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      TaskRow,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (TaskRow, BaseReferences<_$AppDatabase, $TasksTable, TaskRow>),
      TaskRow,
      PrefetchHooks Function()
    >;
typedef $$AdhkarProgressTableCreateCompanionBuilder =
    AdhkarProgressCompanion Function({
      required String date,
      required AdhkarSet setId,
      required String itemId,
      Value<int> count,
      Value<int> rowid,
    });
typedef $$AdhkarProgressTableUpdateCompanionBuilder =
    AdhkarProgressCompanion Function({
      Value<String> date,
      Value<AdhkarSet> setId,
      Value<String> itemId,
      Value<int> count,
      Value<int> rowid,
    });

class $$AdhkarProgressTableFilterComposer
    extends Composer<_$AppDatabase, $AdhkarProgressTable> {
  $$AdhkarProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AdhkarSet, AdhkarSet, String> get setId =>
      $composableBuilder(
        column: $table.setId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AdhkarProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $AdhkarProgressTable> {
  $$AdhkarProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setId => $composableBuilder(
    column: $table.setId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AdhkarProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $AdhkarProgressTable> {
  $$AdhkarProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AdhkarSet, String> get setId =>
      $composableBuilder(column: $table.setId, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);
}

class $$AdhkarProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AdhkarProgressTable,
          AdhkarProgressRow,
          $$AdhkarProgressTableFilterComposer,
          $$AdhkarProgressTableOrderingComposer,
          $$AdhkarProgressTableAnnotationComposer,
          $$AdhkarProgressTableCreateCompanionBuilder,
          $$AdhkarProgressTableUpdateCompanionBuilder,
          (
            AdhkarProgressRow,
            BaseReferences<
              _$AppDatabase,
              $AdhkarProgressTable,
              AdhkarProgressRow
            >,
          ),
          AdhkarProgressRow,
          PrefetchHooks Function()
        > {
  $$AdhkarProgressTableTableManager(
    _$AppDatabase db,
    $AdhkarProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdhkarProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdhkarProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AdhkarProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<AdhkarSet> setId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdhkarProgressCompanion(
                date: date,
                setId: setId,
                itemId: itemId,
                count: count,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                required AdhkarSet setId,
                required String itemId,
                Value<int> count = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdhkarProgressCompanion.insert(
                date: date,
                setId: setId,
                itemId: itemId,
                count: count,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AdhkarProgressTable, AdhkarProgressRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AdhkarProgressTable,
                    AdhkarProgressRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AdhkarProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AdhkarProgressTable,
      AdhkarProgressRow,
      $$AdhkarProgressTableFilterComposer,
      $$AdhkarProgressTableOrderingComposer,
      $$AdhkarProgressTableAnnotationComposer,
      $$AdhkarProgressTableCreateCompanionBuilder,
      $$AdhkarProgressTableUpdateCompanionBuilder,
      (
        AdhkarProgressRow,
        BaseReferences<_$AppDatabase, $AdhkarProgressTable, AdhkarProgressRow>,
      ),
      AdhkarProgressRow,
      PrefetchHooks Function()
    >;
typedef $$FastsTableCreateCompanionBuilder =
    FastsCompanion Function({
      required String date,
      required FastType type,
      required FastStatus status,
      Value<int> rowid,
    });
typedef $$FastsTableUpdateCompanionBuilder =
    FastsCompanion Function({
      Value<String> date,
      Value<FastType> type,
      Value<FastStatus> status,
      Value<int> rowid,
    });

class $$FastsTableFilterComposer extends Composer<_$AppDatabase, $FastsTable> {
  $$FastsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FastType, FastType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<FastStatus, FastStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$FastsTableOrderingComposer
    extends Composer<_$AppDatabase, $FastsTable> {
  $$FastsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FastsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FastsTable> {
  $$FastsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FastType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FastStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$FastsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FastsTable,
          FastRow,
          $$FastsTableFilterComposer,
          $$FastsTableOrderingComposer,
          $$FastsTableAnnotationComposer,
          $$FastsTableCreateCompanionBuilder,
          $$FastsTableUpdateCompanionBuilder,
          (FastRow, BaseReferences<_$AppDatabase, $FastsTable, FastRow>),
          FastRow,
          PrefetchHooks Function()
        > {
  $$FastsTableTableManager(_$AppDatabase db, $FastsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FastsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FastsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FastsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<FastType> type = const Value.absent(),
                Value<FastStatus> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FastsCompanion(
                date: date,
                type: type,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                required FastType type,
                required FastStatus status,
                Value<int> rowid = const Value.absent(),
              }) => FastsCompanion.insert(
                date: date,
                type: type,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FastsTable, FastRow>(table),
                  BaseReferences<_$AppDatabase, $FastsTable, FastRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FastsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FastsTable,
      FastRow,
      $$FastsTableFilterComposer,
      $$FastsTableOrderingComposer,
      $$FastsTableAnnotationComposer,
      $$FastsTableCreateCompanionBuilder,
      $$FastsTableUpdateCompanionBuilder,
      (FastRow, BaseReferences<_$AppDatabase, $FastsTable, FastRow>),
      FastRow,
      PrefetchHooks Function()
    >;
typedef $$TasbihSessionsTableCreateCompanionBuilder =
    TasbihSessionsCompanion Function({
      Value<int> id,
      required String phrase,
      required int count,
      required int goal,
      required DateTime createdAt,
    });
typedef $$TasbihSessionsTableUpdateCompanionBuilder =
    TasbihSessionsCompanion Function({
      Value<int> id,
      Value<String> phrase,
      Value<int> count,
      Value<int> goal,
      Value<DateTime> createdAt,
    });

class $$TasbihSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $TasbihSessionsTable> {
  $$TasbihSessionsTableFilterComposer({
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

  ColumnFilters<String> get phrase => $composableBuilder(
    column: $table.phrase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasbihSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TasbihSessionsTable> {
  $$TasbihSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get phrase => $composableBuilder(
    column: $table.phrase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasbihSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasbihSessionsTable> {
  $$TasbihSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get phrase =>
      $composableBuilder(column: $table.phrase, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<int> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TasbihSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasbihSessionsTable,
          TasbihSessionRow,
          $$TasbihSessionsTableFilterComposer,
          $$TasbihSessionsTableOrderingComposer,
          $$TasbihSessionsTableAnnotationComposer,
          $$TasbihSessionsTableCreateCompanionBuilder,
          $$TasbihSessionsTableUpdateCompanionBuilder,
          (
            TasbihSessionRow,
            BaseReferences<
              _$AppDatabase,
              $TasbihSessionsTable,
              TasbihSessionRow
            >,
          ),
          TasbihSessionRow,
          PrefetchHooks Function()
        > {
  $$TasbihSessionsTableTableManager(
    _$AppDatabase db,
    $TasbihSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasbihSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasbihSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasbihSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> phrase = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<int> goal = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TasbihSessionsCompanion(
                id: id,
                phrase: phrase,
                count: count,
                goal: goal,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String phrase,
                required int count,
                required int goal,
                required DateTime createdAt,
              }) => TasbihSessionsCompanion.insert(
                id: id,
                phrase: phrase,
                count: count,
                goal: goal,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasbihSessionsTable, TasbihSessionRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TasbihSessionsTable,
                    TasbihSessionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasbihSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasbihSessionsTable,
      TasbihSessionRow,
      $$TasbihSessionsTableFilterComposer,
      $$TasbihSessionsTableOrderingComposer,
      $$TasbihSessionsTableAnnotationComposer,
      $$TasbihSessionsTableCreateCompanionBuilder,
      $$TasbihSessionsTableUpdateCompanionBuilder,
      (
        TasbihSessionRow,
        BaseReferences<_$AppDatabase, $TasbihSessionsTable, TasbihSessionRow>,
      ),
      TasbihSessionRow,
      PrefetchHooks Function()
    >;
typedef $$BookmarksTableCreateCompanionBuilder =
    BookmarksCompanion Function({
      Value<int> id,
      required BookmarkKind kind,
      required String ref,
      Value<String?> note,
      required DateTime createdAt,
    });
typedef $$BookmarksTableUpdateCompanionBuilder =
    BookmarksCompanion Function({
      Value<int> id,
      Value<BookmarkKind> kind,
      Value<String> ref,
      Value<String?> note,
      Value<DateTime> createdAt,
    });

class $$BookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
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

  ColumnWithTypeConverterFilters<BookmarkKind, BookmarkKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BookmarkKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get ref =>
      $composableBuilder(column: $table.ref, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BookmarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarksTable,
          BookmarkRow,
          $$BookmarksTableFilterComposer,
          $$BookmarksTableOrderingComposer,
          $$BookmarksTableAnnotationComposer,
          $$BookmarksTableCreateCompanionBuilder,
          $$BookmarksTableUpdateCompanionBuilder,
          (
            BookmarkRow,
            BaseReferences<_$AppDatabase, $BookmarksTable, BookmarkRow>,
          ),
          BookmarkRow,
          PrefetchHooks Function()
        > {
  $$BookmarksTableTableManager(_$AppDatabase db, $BookmarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<BookmarkKind> kind = const Value.absent(),
                Value<String> ref = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BookmarksCompanion(
                id: id,
                kind: kind,
                ref: ref,
                note: note,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required BookmarkKind kind,
                required String ref,
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
              }) => BookmarksCompanion.insert(
                id: id,
                kind: kind,
                ref: ref,
                note: note,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BookmarksTable, BookmarkRow>(table),
                  BaseReferences<_$AppDatabase, $BookmarksTable, BookmarkRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarksTable,
      BookmarkRow,
      $$BookmarksTableFilterComposer,
      $$BookmarksTableOrderingComposer,
      $$BookmarksTableAnnotationComposer,
      $$BookmarksTableCreateCompanionBuilder,
      $$BookmarksTableUpdateCompanionBuilder,
      (
        BookmarkRow,
        BaseReferences<_$AppDatabase, $BookmarksTable, BookmarkRow>,
      ),
      BookmarkRow,
      PrefetchHooks Function()
    >;
typedef $$QuranReadsTableCreateCompanionBuilder =
    QuranReadsCompanion Function({
      required String date,
      required int ayah,
      Value<int> rowid,
    });
typedef $$QuranReadsTableUpdateCompanionBuilder =
    QuranReadsCompanion Function({
      Value<String> date,
      Value<int> ayah,
      Value<int> rowid,
    });

class $$QuranReadsTableFilterComposer
    extends Composer<_$AppDatabase, $QuranReadsTable> {
  $$QuranReadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayah => $composableBuilder(
    column: $table.ayah,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuranReadsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuranReadsTable> {
  $$QuranReadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayah => $composableBuilder(
    column: $table.ayah,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuranReadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuranReadsTable> {
  $$QuranReadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get ayah =>
      $composableBuilder(column: $table.ayah, builder: (column) => column);
}

class $$QuranReadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuranReadsTable,
          QuranReadRow,
          $$QuranReadsTableFilterComposer,
          $$QuranReadsTableOrderingComposer,
          $$QuranReadsTableAnnotationComposer,
          $$QuranReadsTableCreateCompanionBuilder,
          $$QuranReadsTableUpdateCompanionBuilder,
          (
            QuranReadRow,
            BaseReferences<_$AppDatabase, $QuranReadsTable, QuranReadRow>,
          ),
          QuranReadRow,
          PrefetchHooks Function()
        > {
  $$QuranReadsTableTableManager(_$AppDatabase db, $QuranReadsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuranReadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuranReadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuranReadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<int> ayah = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuranReadsCompanion(date: date, ayah: ayah, rowid: rowid),
          createCompanionCallback:
              ({
                required String date,
                required int ayah,
                Value<int> rowid = const Value.absent(),
              }) => QuranReadsCompanion.insert(
                date: date,
                ayah: ayah,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuranReadsTable, QuranReadRow>(table),
                  BaseReferences<_$AppDatabase, $QuranReadsTable, QuranReadRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuranReadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuranReadsTable,
      QuranReadRow,
      $$QuranReadsTableFilterComposer,
      $$QuranReadsTableOrderingComposer,
      $$QuranReadsTableAnnotationComposer,
      $$QuranReadsTableCreateCompanionBuilder,
      $$QuranReadsTableUpdateCompanionBuilder,
      (
        QuranReadRow,
        BaseReferences<_$AppDatabase, $QuranReadsTable, QuranReadRow>,
      ),
      QuranReadRow,
      PrefetchHooks Function()
    >;
typedef $$HifzItemsTableCreateCompanionBuilder =
    HifzItemsCompanion Function({
      Value<int> surah,
      required HifzStatus status,
      Value<int> step,
      required String nextReview,
      required DateTime updatedAt,
    });
typedef $$HifzItemsTableUpdateCompanionBuilder =
    HifzItemsCompanion Function({
      Value<int> surah,
      Value<HifzStatus> status,
      Value<int> step,
      Value<String> nextReview,
      Value<DateTime> updatedAt,
    });

class $$HifzItemsTableFilterComposer
    extends Composer<_$AppDatabase, $HifzItemsTable> {
  $$HifzItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get surah => $composableBuilder(
    column: $table.surah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<HifzStatus, HifzStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get step => $composableBuilder(
    column: $table.step,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextReview => $composableBuilder(
    column: $table.nextReview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HifzItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $HifzItemsTable> {
  $$HifzItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get surah => $composableBuilder(
    column: $table.surah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get step => $composableBuilder(
    column: $table.step,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextReview => $composableBuilder(
    column: $table.nextReview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HifzItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HifzItemsTable> {
  $$HifzItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get surah =>
      $composableBuilder(column: $table.surah, builder: (column) => column);

  GeneratedColumnWithTypeConverter<HifzStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get step =>
      $composableBuilder(column: $table.step, builder: (column) => column);

  GeneratedColumn<String> get nextReview => $composableBuilder(
    column: $table.nextReview,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$HifzItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HifzItemsTable,
          HifzRow,
          $$HifzItemsTableFilterComposer,
          $$HifzItemsTableOrderingComposer,
          $$HifzItemsTableAnnotationComposer,
          $$HifzItemsTableCreateCompanionBuilder,
          $$HifzItemsTableUpdateCompanionBuilder,
          (HifzRow, BaseReferences<_$AppDatabase, $HifzItemsTable, HifzRow>),
          HifzRow,
          PrefetchHooks Function()
        > {
  $$HifzItemsTableTableManager(_$AppDatabase db, $HifzItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HifzItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HifzItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HifzItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> surah = const Value.absent(),
                Value<HifzStatus> status = const Value.absent(),
                Value<int> step = const Value.absent(),
                Value<String> nextReview = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => HifzItemsCompanion(
                surah: surah,
                status: status,
                step: step,
                nextReview: nextReview,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> surah = const Value.absent(),
                required HifzStatus status,
                Value<int> step = const Value.absent(),
                required String nextReview,
                required DateTime updatedAt,
              }) => HifzItemsCompanion.insert(
                surah: surah,
                status: status,
                step: step,
                nextReview: nextReview,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HifzItemsTable, HifzRow>(table),
                  BaseReferences<_$AppDatabase, $HifzItemsTable, HifzRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HifzItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HifzItemsTable,
      HifzRow,
      $$HifzItemsTableFilterComposer,
      $$HifzItemsTableOrderingComposer,
      $$HifzItemsTableAnnotationComposer,
      $$HifzItemsTableCreateCompanionBuilder,
      $$HifzItemsTableUpdateCompanionBuilder,
      (HifzRow, BaseReferences<_$AppDatabase, $HifzItemsTable, HifzRow>),
      HifzRow,
      PrefetchHooks Function()
    >;
typedef $$HabitsTableCreateCompanionBuilder =
    HabitsCompanion Function({
      Value<int> id,
      required String title,
      Value<String> icon,
      Value<bool> archived,
      Value<int> sortOrder,
      required DateTime createdAt,
    });
typedef $$HabitsTableUpdateCompanionBuilder =
    HabitsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> icon,
      Value<bool> archived,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
    });

final class $$HabitsTableReferences
    extends BaseReferences<_$AppDatabase, $HabitsTable, HabitRow> {
  $$HabitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$HabitLogsTable, List<HabitLogRow>>
  _habitLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.habitLogs,
    aliasName: 'habits__id__habit_logs__habit_id',
  );

  $$HabitLogsTableProcessedTableManager get habitLogsRefs {
    final manager = $$HabitLogsTableTableManager(
      $_db,
      $_db.habitLogs,
    ).filter((f) => f.habitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_habitLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HabitsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> habitLogsRefs(
    Expression<bool> Function($$HabitLogsTableFilterComposer f) f,
  ) {
    final $$HabitLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitLogs,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitLogsTableFilterComposer(
            $db: $db,
            $table: $db.habitLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> habitLogsRefs<T extends Object>(
    Expression<T> Function($$HabitLogsTableAnnotationComposer a) f,
  ) {
    final $$HabitLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitLogs,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.habitLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitsTable,
          HabitRow,
          $$HabitsTableFilterComposer,
          $$HabitsTableOrderingComposer,
          $$HabitsTableAnnotationComposer,
          $$HabitsTableCreateCompanionBuilder,
          $$HabitsTableUpdateCompanionBuilder,
          (HabitRow, $$HabitsTableReferences),
          HabitRow,
          PrefetchHooks Function({bool habitLogsRefs})
        > {
  $$HabitsTableTableManager(_$AppDatabase db, $HabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => HabitsCompanion(
                id: id,
                title: title,
                icon: icon,
                archived: archived,
                sortOrder: sortOrder,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String> icon = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
              }) => HabitsCompanion.insert(
                id: id,
                title: title,
                icon: icon,
                archived: archived,
                sortOrder: sortOrder,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HabitsTable, HabitRow>(table),
                  $$HabitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (habitLogsRefs) db.habitLogs],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (habitLogsRefs)
                    await $_getPrefetchedData<
                      HabitRow,
                      $HabitsTable,
                      HabitLogRow
                    >(
                      currentTable: table,
                      referencedTable: $$HabitsTableReferences
                          ._habitLogsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$HabitsTableReferences(db, table, p0).habitLogsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.habitId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$HabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitsTable,
      HabitRow,
      $$HabitsTableFilterComposer,
      $$HabitsTableOrderingComposer,
      $$HabitsTableAnnotationComposer,
      $$HabitsTableCreateCompanionBuilder,
      $$HabitsTableUpdateCompanionBuilder,
      (HabitRow, $$HabitsTableReferences),
      HabitRow,
      PrefetchHooks Function({bool habitLogsRefs})
    >;
typedef $$HabitLogsTableCreateCompanionBuilder =
    HabitLogsCompanion Function({
      required int habitId,
      required String date,
      Value<int> rowid,
    });
typedef $$HabitLogsTableUpdateCompanionBuilder =
    HabitLogsCompanion Function({
      Value<int> habitId,
      Value<String> date,
      Value<int> rowid,
    });

final class $$HabitLogsTableReferences
    extends BaseReferences<_$AppDatabase, $HabitLogsTable, HabitLogRow> {
  $$HabitLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HabitsTable _habitIdTable(_$AppDatabase db) =>
      db.habits.createAlias('habit_logs__habit_id__habits__id');

  $$HabitsTableProcessedTableManager get habitId {
    final $_column = $_itemColumn<int>('habit_id')!;

    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HabitLogsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitLogsTable> {
  $$HabitLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  $$HabitsTableFilterComposer get habitId {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitLogsTable> {
  $$HabitLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  $$HabitsTableOrderingComposer get habitId {
    final $$HabitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableOrderingComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitLogsTable> {
  $$HabitLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  $$HabitsTableAnnotationComposer get habitId {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitLogsTable,
          HabitLogRow,
          $$HabitLogsTableFilterComposer,
          $$HabitLogsTableOrderingComposer,
          $$HabitLogsTableAnnotationComposer,
          $$HabitLogsTableCreateCompanionBuilder,
          $$HabitLogsTableUpdateCompanionBuilder,
          (HabitLogRow, $$HabitLogsTableReferences),
          HabitLogRow,
          PrefetchHooks Function({bool habitId})
        > {
  $$HabitLogsTableTableManager(_$AppDatabase db, $HabitLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> habitId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitLogsCompanion(
                habitId: habitId,
                date: date,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int habitId,
                required String date,
                Value<int> rowid = const Value.absent(),
              }) => HabitLogsCompanion.insert(
                habitId: habitId,
                date: date,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HabitLogsTable, HabitLogRow>(table),
                  $$HabitLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitId = false}) {
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
                    if (habitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.habitId,
                                referencedTable: $$HabitLogsTableReferences
                                    ._habitIdTable(db),
                                referencedColumn: $$HabitLogsTableReferences
                                    ._habitIdTable(db)
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

typedef $$HabitLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitLogsTable,
      HabitLogRow,
      $$HabitLogsTableFilterComposer,
      $$HabitLogsTableOrderingComposer,
      $$HabitLogsTableAnnotationComposer,
      $$HabitLogsTableCreateCompanionBuilder,
      $$HabitLogsTableUpdateCompanionBuilder,
      (HabitLogRow, $$HabitLogsTableReferences),
      HabitLogRow,
      PrefetchHooks Function({bool habitId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PrayerLogsTableTableManager get prayerLogs =>
      $$PrayerLogsTableTableManager(_db, _db.prayerLogs);
  $$QadaCountsTableTableManager get qadaCounts =>
      $$QadaCountsTableTableManager(_db, _db.qadaCounts);
  $$QadaEventsTableTableManager get qadaEvents =>
      $$QadaEventsTableTableManager(_db, _db.qadaEvents);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$AdhkarProgressTableTableManager get adhkarProgress =>
      $$AdhkarProgressTableTableManager(_db, _db.adhkarProgress);
  $$FastsTableTableManager get fasts =>
      $$FastsTableTableManager(_db, _db.fasts);
  $$TasbihSessionsTableTableManager get tasbihSessions =>
      $$TasbihSessionsTableTableManager(_db, _db.tasbihSessions);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$QuranReadsTableTableManager get quranReads =>
      $$QuranReadsTableTableManager(_db, _db.quranReads);
  $$HifzItemsTableTableManager get hifzItems =>
      $$HifzItemsTableTableManager(_db, _db.hifzItems);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
  $$HabitLogsTableTableManager get habitLogs =>
      $$HabitLogsTableTableManager(_db, _db.habitLogs);
}
