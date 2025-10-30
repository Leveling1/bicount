import 'dart:async';

import 'package:bicount/features/company/data/models/company.model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../brick/repository.dart';
import '../../../../../core/errors/failure.dart';
import 'company_local_datasource.dart';

class LocalCompanyDataSourceImpl implements CompanyLocalDataSource {
  final supabaseInstance = Supabase.instance.client;
  late String uid = supabaseInstance.auth.currentUser!.id;

  final _members = StreamController<List<CompanyModel>>.broadcast();
  @override
  Stream<List<CompanyModel>> getCompany() {
    try {
      Repository().subscribeToRealtime<CompanyModel>().listen((members) {
        _members.add(members);
      });
      return _members.stream;
    } catch (e) {
      return Stream.error(
        MessageFailure(message: "Une erreur s'est produite : ${e.toString()}"),
      );
    }
  }
}