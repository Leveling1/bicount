import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bicount/features/group/domain/entities/group_model.dart';
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
import '../../../project/domain/entities/project_model.dart';
import '../data_sources/local_datasource/company_local_datasource.dart';
import '../data_sources/remote_datasource/company_remote_datasource.dart';
import '../models/company.model.dart';
import '../models/company_with_user_link.model.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyRemoteDataSource remoteDataSource;
  final CompanyLocalDataSource localDataSource;
  CompanyRepositoryImpl(this.remoteDataSource, this.localDataSource);

  final supabaseInstance = Supabase.instance.client;
  String get uid => supabaseInstance.auth.currentUser!.id;
  var uuid = Uuid();
  String? get accessToken => supabaseInstance.auth.currentSession?.accessToken;

  late StreamController<List<CompanyModel>> _company;

  // For the company detail
  final _companyController = StreamController<CompanyEntity>.broadcast();
  CompanyModel? _currentCompany;
  List<GroupModel> _currentGroups = [];
  List<ProjectModel> _currentProjects = [];

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

  /// For the stream app with screen
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
  Stream<CompanyEntity> getCompanyDetailStream(CompanyModel company) {
    String companyId = company.cid!;
    // Charger les données initiales
    _loadCompanyDetail(companyId);

    // S'abonner aux changements
    _subscribeToCompanyDetailChanges(companyId);
    _subscribeToGroupChanges(companyId);
    _subscribeToProjectChanges(companyId);

    return _companyController.stream;
  }

  Future<void> _loadCompanyDetail(String companyId) async {
    try {
      // 1. Charger la company
      final companyRes = await supabaseInstance
          .from('company')
          .select('*')
          .eq('cid', companyId)
          .maybeSingle();

      if (companyRes == null) return;

      _currentCompany = companyRes as CompanyModel?;

      // 2. Charger les groups liés
      final groupRes = await supabaseInstance
          .from('company_group')
          .select('*')
          .eq('id_company', companyId);

      _currentGroups =
          (groupRes as List).map((g) => GroupModel.fromMap(g)).toList();

      // 3. Charger les projets liés
      final projectRes = await supabaseInstance
          .from('project')
          .select('*')
          .eq('id_company', companyId);

      _currentProjects =
          (projectRes as List).map((p) => ProjectModel.fromMap(p)).toList();

      // 4. Fusionner et émettre le modèle complet
      _emitUpdatedCompany();
    } catch (e) {
      _companyController.addError(e);
    }
  }

  void _emitUpdatedCompany() {
    if (_currentCompany == null) return;

    final updated = CompanyEntity(
      name: _currentCompany!.name,
      description: _currentCompany!.description,
      image: _currentCompany!.image,
      sales: _currentCompany!.sales,
      expenses: _currentCompany!.expenses,
      profit: _currentCompany!.profit,
      salary: _currentCompany!.salary,
      equipment: _currentCompany!.equipment,
      service: _currentCompany!.service,
      projects: _currentProjects,
      groups: _currentGroups,
    );

    _companyController.add(updated);
  }

  void _subscribeToCompanyDetailChanges(String companyId) {
    final channel = supabaseInstance.channel('company_changes');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'company',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'cid',
        value: companyId,
      ),
      callback: (payload) {
        _currentCompany = payload.newRecord as CompanyModel?;
        _emitUpdatedCompany();
      },
    );

    channel.subscribe();
  }

  void _subscribeToGroupChanges(String companyId) {
    final channel = supabaseInstance.channel('group_changes');

    // INSERT
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'company_group',
      callback: (payload) {
        if (payload.newRecord['cid'] == companyId) {
          _currentGroups.add(GroupModel.fromMap(payload.newRecord));
          _emitUpdatedCompany();
        }
      },
    );

    // UPDATE
    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'company_group',
      callback: (payload) {
        if (payload.newRecord['cid'] == companyId) {
          final group = GroupModel.fromMap(payload.newRecord);
          final index =
          _currentGroups.indexWhere((g) => g.id == group.id);
          if (index != -1) {
            _currentGroups[index] = group;
            _emitUpdatedCompany();
          }
        }
      },
    );

    // DELETE
    channel.onPostgresChanges(
      event: PostgresChangeEvent.delete,
      schema: 'public',
      table: 'company_group',
      callback: (payload) {
        if (payload.oldRecord['cid'] == companyId) {
          _currentGroups
              .removeWhere((g) => g.id == payload.oldRecord['id']);
          _emitUpdatedCompany();
        }
      },
    );

    channel.subscribe();
  }

  void _subscribeToProjectChanges(String companyId) {
    final channel = supabaseInstance.channel('project_changes');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'project',
      callback: (payload) {
        if (payload.newRecord['cid'] == companyId) {
          _currentProjects.add(ProjectModel.fromMap(payload.newRecord));
          _emitUpdatedCompany();
        }
      },
    );

    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'project',
      callback: (payload) {
        if (payload.newRecord['cid'] == companyId) {
          final project = ProjectModel.fromMap(payload.newRecord);
          final index =
          _currentProjects.indexWhere((p) => p.id == project.id);
          if (index != -1) {
            _currentProjects[index] = project;
            _emitUpdatedCompany();
          }
        }
      },
    );

    channel.onPostgresChanges(
      event: PostgresChangeEvent.delete,
      schema: 'public',
      table: 'project',
      callback: (payload) {
        if (payload.oldRecord['cid'] == companyId) {
          _currentProjects
              .removeWhere((p) => p.id == payload.oldRecord['id']);
          _emitUpdatedCompany();
        }
      },
    );

    channel.subscribe();
  }
}