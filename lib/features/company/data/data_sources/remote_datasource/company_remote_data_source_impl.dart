import 'package:bicount/core/offline/offline_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bicount/core/offline/repository.dart';
import '../../models/company_with_user_link.model.dart';
import 'company_remote_datasource.dart';

class CompanyRemoteDataSourceImpl implements CompanyRemoteDataSource {
  final supabaseInstance = Supabase.instance.client;

  @override
  void subscribeDeleteChanges() {
    final channel = supabaseInstance.channel('company_change');
    // DELETE
    channel.onPostgresChanges(
      event: PostgresChangeEvent.delete,
      schema: 'public',
      table: 'companies',
      callback: (payload) async {
        final results = await Repository().get<CompanyWithUserLinkModel>(
          policy: OfflineReadPolicy.localOnly,
        );
        if (results.isEmpty) return;
        await Repository().delete<CompanyWithUserLinkModel>(results.first);
      },
    );

    channel.subscribe();
  }
}
