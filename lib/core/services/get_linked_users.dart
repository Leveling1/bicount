import 'package:supabase_flutter/supabase_flutter.dart';

Future<List<User>> linkedUsers(String id) async {
  final supabase = Supabase.instance.client;
  final response = await supabase
      .from('user_links')
      .select('user_a_id, user_b_id')
      .or('user_a_id.eq.$id,user_b_id.eq.$id');

  if (response.isEmpty) {
    return [];
  }

  final linkedIds = response
      .map(
        (link) =>
            link['user_a_id'] == id ? link['user_b_id'] : link['user_a_id'],
      )
      .toSet()
      .toList();

  final usersResponse = await supabase
      .from('users')
      .select()
      .inFilter('id', linkedIds);

  return List<User>.from(usersResponse);
}
