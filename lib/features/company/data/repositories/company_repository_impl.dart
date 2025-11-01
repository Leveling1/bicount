import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bicount/features/company/domain/entities/company.dart';
import 'package:bicount/features/company/domain/repositories/company_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../core/constants/secrets.dart';
import '../../../../core/errors/failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../../../group/data/models/group.model.dart';
import '../../../project/data/models/project.model.dart';
import '../data_sources/local_datasource/company_local_datasource.dart';
import '../data_sources/remote_datasource/company_remote_datasource.dart';
import '../models/company.model.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyRemoteDataSource remoteDataSource;
  final CompanyLocalDataSource localDataSource;
  CompanyRepositoryImpl(this.remoteDataSource, this.localDataSource);

  final supabaseInstance = Supabase.instance.client;
  String get uid => supabaseInstance.auth.currentUser!.id;
  var uuid = Uuid();
  String? get accessToken => supabaseInstance.auth.currentSession?.accessToken;

  late StreamController<List<CompanyModel>> _company;

  /// For the creation company
  @override
  Future<CompanyEntity> createCompany(CompanyEntity company, File? logoFile) async {
    String cid = uuid.v4();
    try {
      final uri = Uri.parse(Secrets.create_company_endpoint);

      var request = http.MultipartRequest("POST", uri)
        ..fields['name'] = company.name
        ..fields['description'] = company.description ?? ""
        ..fields['uid'] = uid
        ..fields['cid'] = cid
        ..fields['lid'] = uuid.v4()
        ..headers['Authorization'] = 'Bearer $accessToken'
        ..headers['apikey'] = Secrets.supabaseAnonKey;

      if (logoFile != null) {
        final mimeType = lookupMimeType(logoFile.path) ?? 'image/jpeg';
        final fileStream = http.ByteStream(logoFile.openRead());
        final fileLength = await logoFile.length();
        var mimeParts = mimeType.split('/');

        request.files.add(
            http.MultipartFile(
              'logo',
              fileStream,
              fileLength,
              filename: path.basename(logoFile.path),
              contentType: MediaType(mimeParts[0], mimeParts[1]),
            )
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      switch (response.statusCode) {
        case 200:
          try {
            final Map<String, dynamic> responseData = jsonDecode(responseBody);

            // Vérifiez si la réponse contient une erreur
            if (responseData.containsKey('error')) {
              throw ValidationFailure(responseData['error']);
            }

            // Vérifiez si la réponse indique le succès
            if (responseData['success'] != true) {
              final errorMessage = responseData['error'] ?? 'La création a échoué sans message d\'erreur';
              throw ValidationFailure(errorMessage);
            }

            // ⚠️ CORRECTION: Extraire les données de "company" et non de la racine
            final companyData = responseData['company'];
            if (companyData == null) {
              throw DataParsingFailure('Réponse invalide: champ "company" manquant');
            }

            // Vérifiez les champs requis dans companyData
            if (companyData['name'] == null) {
              throw DataParsingFailure('Invalid response format: missing name field in company data');
            }

            final createdCompany = CompanyEntity.fromMap(companyData); // ← Utiliser companyData

            return createdCompany;
          } catch (parseError) {
            throw DataParsingFailure('Error while parsing the server response: $parseError');
          }

        case 400:
          try {
            final errorData = jsonDecode(responseBody);
            final errorMessage = errorData['error'] ?? 'Invalid data';
            throw ValidationFailure(errorMessage);
          } catch (parseError) {
            throw ValidationFailure('Invalid company data');
          }

        case 401:
          throw AuthenticationFailure(message: 'Session expired. Please log in again.');

        case 403:
          throw AuthorizationFailure('You do not have permission to create a company');

        case 413:
          throw ValidationFailure('The logo file is too large. Maximum size: 10MB');

        case 415:
          throw ValidationFailure('Unsupported logo format. Use JPG, PNG, or WebP');

        case 500:
          throw ServerFailure('Internal server error. Please try again later.');

        case 503:
          throw ServerFailure('Service temporarily unavailable. Please try again in a few minutes.');

        default:
          throw ServerFailure('Unexpected network error (${response.statusCode})');
      }

    } on SocketException catch (e) {
      throw NetworkFailure('No internet connection. Check your network.');

    } on TimeoutException catch (e) {
      throw NetworkFailure('Response timed out. Please try again.');

    } on FormatException catch (e) {
      throw DataParsingFailure('Invalid data format');

    } catch (e) {
      if (e is ValidationFailure ||
          e is AuthenticationFailure ||
          e is AuthorizationFailure ||
          e is NetworkFailure ||
          e is ServerFailure ||
          e is DataParsingFailure) {
        rethrow;
      }
      throw UnknownFailure();
    }
  }

  /// To create a feed and have all the user's companies
  @override
  Stream<List<CompanyModel>> getCompanyStream() {
    try {
      final companies = localDataSource.getCompany();
      remoteDataSource.subscribeDeleteChanges();
      return companies;
    } catch (e) {
      return Stream.error(
        MessageFailure(message: "Une erreur s'est produite : ${e.toString()}"),
      );
    }
  }

  /// For the detail company
  @override
  Stream<CompanyEntity> getCompanyDetailStream(String cid) {
    try {
      // Récupérer les trois streams
      Stream<CompanyModel> companyStream = localDataSource.getCompanyDetails(cid);
      Stream<List<ProjectModel>> projectStream = localDataSource.getCompanyProjects(cid);
      Stream<List<GroupModel>> groupStream = localDataSource.getCompanyGroups(cid);

      // CORRECTION: Combiner les trois streams en un seul
      return Rx.combineLatest3<CompanyModel, List<ProjectModel>, List<GroupModel>, CompanyEntity>(
        companyStream,
        projectStream,
        groupStream,
        (CompanyModel company, List<ProjectModel> projects, List<GroupModel> groups) {
          return _convertToEntity(company, projects, groups);
        },
      ).handleError((error) {
        throw MessageFailure(message: "Erreur de combinaison des données: ${error.toString()}");
      });
    } catch (e) {
      return Stream.error(
        MessageFailure(message: "Erreur lors de la récupération des détails: ${e.toString()}"),
      );
    }
  }

// CORRECTION: La méthode prend maintenant les données directement, pas les streams
  CompanyEntity _convertToEntity(
      CompanyModel model,
      List<ProjectModel> projects,
      List<GroupModel> groups
    ) {
    return CompanyEntity(
      cid: model.cid ?? '',
      name: model.name,
      description: model.description,
      image: model.image,
      sales: model.sales ?? 0.0,
      expenses: model.expenses ?? 0.0,
      profit: model.profit ?? 0.0,
      salary: model.salary ?? 0.0,
      equipment: model.equipment ?? 0.0,
      service: model.service ?? 0.0,
      projects: projects.map((project) => project).toList(),
      groups: groups.map((group) => group).toList(),
    );
  }
}