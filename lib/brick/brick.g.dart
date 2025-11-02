// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_core/query.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_sqlite/db.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_sqlite/brick_sqlite.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:brick_supabase/brick_supabase.dart';
// ignore: unused_import, unused_shown_name, unnecessary_import
import 'package:uuid/uuid.dart';// GENERATED CODE DO NOT EDIT
// ignore: unused_import
import 'dart:convert';
import 'package:brick_sqlite/brick_sqlite.dart' show SqliteModel, SqliteAdapter, SqliteModelDictionary, RuntimeSqliteColumnDefinition, SqliteProvider;
import 'package:brick_supabase/brick_supabase.dart' show SupabaseProvider, SupabaseModel, SupabaseAdapter, SupabaseModelDictionary;
// ignore: unused_import, unused_shown_name
import 'package:brick_offline_first/brick_offline_first.dart' show RuntimeOfflineFirstDefinition;
// ignore: unused_import, unused_shown_name
import 'package:sqflite_common/sqlite_api.dart' show DatabaseExecutor;

import '../features/authentification/data/models/user.model.dart';
import '../features/authentification/data/models/user_links.model.dart';
import '../features/company/data/models/company.model.dart';
import '../features/company/data/models/company_with_user_link.model.dart';
import '../features/group/data/models/group.model.dart';
import '../features/main/data/models/friends.model.dart';
import '../features/main/data/models/user_links.model.dart';
import '../features/project/data/models/project.model.dart';
import '../features/transaction/data/models/transaction.model.dart';

part 'adapters/user_model_adapter.g.dart';
part 'adapters/user_link_model_adapter.g.dart';
part 'adapters/company_model_adapter.g.dart';
part 'adapters/company_with_user_link_model_adapter.g.dart';
part 'adapters/group_model_adapter.g.dart';
part 'adapters/friends_model_adapter.g.dart';
part 'adapters/user_links_model_adapter.g.dart';
part 'adapters/project_model_adapter.g.dart';
part 'adapters/transaction_model_adapter.g.dart';

/// Supabase mappings should only be used when initializing a [SupabaseProvider]
final Map<Type, SupabaseAdapter<SupabaseModel>> supabaseMappings = {
  UserModel: UserModelAdapter(),
  UserLinkModel: UserLinkModelAdapter(),
  CompanyModel: CompanyModelAdapter(),
  CompanyWithUserLinkModel: CompanyWithUserLinkModelAdapter(),
  GroupModel: GroupModelAdapter(),
  FriendsModel: FriendsModelAdapter(),
  UserLinksModel: UserLinksModelAdapter(),
  ProjectModel: ProjectModelAdapter(),
  TransactionModel: TransactionModelAdapter()
};
final supabaseModelDictionary = SupabaseModelDictionary(supabaseMappings);

/// Sqlite mappings should only be used when initializing a [SqliteProvider]
final Map<Type, SqliteAdapter<SqliteModel>> sqliteMappings = {
  UserModel: UserModelAdapter(),
  UserLinkModel: UserLinkModelAdapter(),
  CompanyModel: CompanyModelAdapter(),
  CompanyWithUserLinkModel: CompanyWithUserLinkModelAdapter(),
  GroupModel: GroupModelAdapter(),
  FriendsModel: FriendsModelAdapter(),
  UserLinksModel: UserLinksModelAdapter(),
  ProjectModel: ProjectModelAdapter(),
  TransactionModel: TransactionModelAdapter()
};
final sqliteModelDictionary = SqliteModelDictionary(sqliteMappings);
