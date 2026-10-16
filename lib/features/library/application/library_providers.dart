import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import '../../../data/repositories/bookmark_repository.dart';
import '../domain/library_content.dart';

final duaCatalogProvider = FutureProvider<DuaCatalog>(
  (ref) async => DuaCatalog.fromJson(await rootBundle.loadString('assets/library/duas.json')),
);

final allahNamesProvider = FutureProvider<List<AllahName>>(
  (ref) async => AllahName.listFromJson(await rootBundle.loadString('assets/library/names.json')),
);

final guidesProvider = FutureProvider<List<Guide>>(
  (ref) async => Guide.listFromJson(await rootBundle.loadString('assets/library/guides.json')),
);

final duaBookmarksProvider = StreamProvider<Set<String>>(
  (ref) => ref.watch(bookmarkRepositoryProvider).watchRefs(BookmarkKind.dua),
);

final nameBookmarksProvider = StreamProvider<Set<String>>(
  (ref) => ref.watch(bookmarkRepositoryProvider).watchRefs(BookmarkKind.name),
);
