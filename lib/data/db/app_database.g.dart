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
  ];
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
}
