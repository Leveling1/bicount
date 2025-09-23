import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart' as http;

import '../../../../core/constants/secrets.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/project_model.dart';
import '../../domain/repositories/project_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl();
  final supabaseInstance = Supabase.instance.client;

  String get uid => supabaseInstance.auth.currentUser!.id;
  String? get accessToken => supabaseInstance.auth.currentSession?.accessToken;
  @override
  Future<ProjectModel> createProject(ProjectModel project, File? logoFile) async {
    try {
      final uri = Uri.parse(Secrets.create_project_endpoint);

      var request = http.MultipartRequest("POST", uri)
        ..fields['name'] = project.name
        ..fields['description'] = project.description ?? ""
        ..fields['idCompany'] = "${project.idCompany}"
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

            final createdGroup = ProjectModel.fromMap(responseData);

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
            throw ValidationFailure('Invalid project data');
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
}
