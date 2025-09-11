import 'dart:io';

import 'package:bicount/features/company/domain/entities/company_model.dart';
import 'package:bicount/features/company/domain/repositories/company_repository.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/secrets.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  CompanyRepositoryImpl();

  @override
  Future<void> createCompany(CompanyModel company, File? logoFile) async {
    final uri = Uri.parse(Secrets.URLEndpoint_createCompany);

    var request = http.MultipartRequest("POST", uri)
      ..fields['name'] = company.name
      ..fields['description'] = company.description!
      ..fields['email'] = company.email!
      ..fields['phone'] = company.phone!
      ..fields['address'] = company.address!
      ..files.add(await http.MultipartFile.fromPath('logo', company.image!));

    final response = await request.send();

    if (response.statusCode == 200) {
      print("✅ Company created");
      final body = await response.stream.bytesToString();
      print(body);
    } else {
      print("❌ Error: ${response.statusCode}");
      print(await response.stream.bytesToString());
    }
  }


}
