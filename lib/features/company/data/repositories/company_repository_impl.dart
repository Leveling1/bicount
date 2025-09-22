import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bicount/features/company/domain/entities/company_group_model.dart';
import 'package:bicount/features/company/domain/entities/company_model.dart';
import 'package:bicount/features/company/domain/repositories/company_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../../core/constants/secrets.dart';
import '../../../../core/errors/failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

class CompanyRepositoryImpl implements CompanyRepository {
  CompanyRepositoryImpl();
  final supabaseInstance = Supabase.instance.client;

  String get uid => supabaseInstance.auth.currentUser!.id;
  String? get accessToken => supabaseInstance.auth.currentSession?.accessToken;

  final _controller = StreamController<List<CompanyModel>>.broadcast();
  // Liste locale toujours à jour
  final List<CompanyModel> _currentCompanies = [];

  // For the creation company
  @override
  Future<CompanyModel> createCompany(CompanyModel company, File? logoFile) async {
    try {
      final uri = Uri.parse(Secrets.create_company_endpoint);

      var request = http.MultipartRequest("POST", uri)
        ..fields['name'] = company.name
        ..fields['description'] = company.description ?? ""
        ..fields['uid'] = uid
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

            print("Je suis venue");
            // Vérifiez si la réponse contient une erreur
            if (responseData.containsKey('error')) {
              print("Vérifiez si la réponse contient une erreur");
              throw ValidationFailure(responseData['error']);
            }

            // Vérifiez les champs requis
            if (responseData['name'] == null) {
              print("Vérifiez les champs requis");
              throw DataParsingFailure('Invalid response format: missing name field');
            }

            final createdCompany = CompanyModel.fromMap(responseData);

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
      print(e);
      throw UnknownFailure();
    }
  }

  // For the creation of group company
  @override
  Future<CompanyGroupModel> createCompanyGroup(CompanyGroupModel group, File? logoFile) async {
    try {
      final uri = Uri.parse(Secrets.create_company_group_endpoint);

      var request = http.MultipartRequest("POST", uri)
        ..fields['name'] = group.name
        ..fields['description'] = group.description ?? ""
        ..fields['idCompany'] = "${group.idCompany}"
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

            print("Je suis venue");
            // Vérifiez si la réponse contient une erreur
            if (responseData.containsKey('error')) {
              print("Vérifiez si la réponse contient une erreur");
              throw ValidationFailure(responseData['error']);
            }

            // Vérifiez les champs requis
            if (responseData['name'] == null) {
              print("Vérifiez les champs requis");
              throw DataParsingFailure('Invalid response format: missing name field');
            }

            final createdGroup = CompanyGroupModel.fromMap(responseData);

            return createdGroup;
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
      print(e);
      throw UnknownFailure();
    }
  }

  // For the stream app with screen
  @override
  Stream<List<CompanyModel>> getCompanyStream() {
    // Charger état initial
    _loadInitialCompanies();

    // Abonnement Realtime sur table "company"
    _subscribeToCompanyChanges();

    // Abonnement Realtime sur table "company_with_user_link"
    _subscribeToCompanyLinkChanges();

    return _controller.stream;
  }

  Future<void> _loadInitialCompanies() async {
    try {
      final res = await supabaseInstance.from('company').select('*');
      _currentCompanies
        ..clear()
        ..addAll((res as List).map((c) => CompanyModel.fromMap(c)));
      _controller.add(List.from(_currentCompanies));
    } catch (e) {
      _controller.addError(e);
    }
  }

  void _subscribeToCompanyChanges() {
    final channel = supabaseInstance.channel('company_changes');

    // INSERT
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'company',
      callback: (payload) {
        final company = CompanyModel.fromMap(payload.newRecord);
        _currentCompanies.add(company);
        _controller.add(List.from(_currentCompanies));
            },
    );

    // UPDATE
    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'company',
      callback: (payload) {
        final company = CompanyModel.fromMap(payload.newRecord);
        final index = _currentCompanies.indexWhere((c) => c.id == company.id);
        if (index != -1) {
          _currentCompanies[index] = company; // remplacer l’ancienne
          _controller.add(List.from(_currentCompanies));
        }
            },
    );

    // DELETE
    channel.onPostgresChanges(
      event: PostgresChangeEvent.delete,
      schema: 'public',
      table: 'company',
      callback: (payload) {
        final id = payload.oldRecord['id'];
        _currentCompanies.removeWhere((c) => c.id == id);
        _controller.add(List.from(_currentCompanies));
            },
    );

    channel.subscribe();
  }


  void _subscribeToCompanyLinkChanges() {
    supabaseInstance.channel('company_link_changes')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'company_with_user_link',
      callback: (payload) async {
        // Recharger toutes les companies liées quand un lien change
        try {
          final res = await supabaseInstance.from('company').select('*');
          _currentCompanies
            ..clear()
            ..addAll((res as List).map((c) => CompanyModel.fromMap(c)));
          _controller.add(List.from(_currentCompanies));
        } catch (e) {
          _controller.addError(e);
        }
      },
    )
    .subscribe();
  }

  Future<void> dispose() async {
    await _controller.close();
  }

}