import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart';
import '../db/database_provider.dart';

class Bookmark {
  const Bookmark({required this.kind, required this.ref, required this.createdAt, this.note});
  final BookmarkKind kind;
  final String ref;
  final String? note;
  final DateTime createdAt;
}

/// Bookmarks for ayahs, hadith, duas and Names (see [BookmarkKind] for refs).
class BookmarkRepository {
  BookmarkRepository(this._db);

  final AppDatabase _db;

  Future<void> add(BookmarkKind kind, String ref, {String? note, DateTime? now}) {
    return _db.into(_db.bookmarks).insert(
          BookmarksCompanion.insert(
            kind: kind,
            ref: ref,
            note: Value(note),
            createdAt: now ?? DateTime.now(),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> remove(BookmarkKind kind, String ref) =>
      (_db.delete(_db.bookmarks)..where((t) => t.kind.equalsValue(kind) & t.ref.equals(ref))).go();

  /// Adds or removes; returns true when the item is now bookmarked.
  Future<bool> toggle(BookmarkKind kind, String ref) async {
    final existing = await (_db.select(_db.bookmarks)
          ..where((t) => t.kind.equalsValue(kind) & t.ref.equals(ref)))
        .getSingleOrNull();
    if (existing != null) {
      await remove(kind, ref);
      return false;
    }
    await add(kind, ref);
    return true;
  }

  Future<void> setNote(BookmarkKind kind, String ref, String? note) =>
      (_db.update(_db.bookmarks)..where((t) => t.kind.equalsValue(kind) & t.ref.equals(ref)))
          .write(BookmarksCompanion(note: Value(note?.trim().isEmpty ?? true ? null : note!.trim())));

  /// Newest first.
  Stream<List<Bookmark>> watch(BookmarkKind kind) {
    final q = _db.select(_db.bookmarks)
      ..where((t) => t.kind.equalsValue(kind))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt), (t) => OrderingTerm.desc(t.id)]);
    return q.watch().map((rows) => [
          for (final r in rows) Bookmark(kind: r.kind, ref: r.ref, note: r.note, createdAt: r.createdAt),
        ]);
  }

  Stream<Set<String>> watchRefs(BookmarkKind kind) =>
      watch(kind).map((list) => {for (final b in list) b.ref});
}

final bookmarkRepositoryProvider =
    Provider<BookmarkRepository>((ref) => BookmarkRepository(ref.watch(databaseProvider)));
