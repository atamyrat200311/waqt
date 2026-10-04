import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:waqt/data/db/app_database.dart';

AppDatabase memoryDb() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}
