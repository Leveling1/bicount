import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
  WebSocket? _socket; // Plus utilisé
  StreamSubscription? _sseSubscription;
  final _controller = StreamController<List<CompanyModel>>.broadcast();
  final supabaseInstance = Supabase.instance.client;

  String get uid => supabaseInstance.auth.currentUser!.id;
  String? get accessToken => supabaseInstance.auth.currentSession?.accessToken;

  // For the creation company
  @override
  Future<CompanyModel> createCompany(CompanyModel company, File? logoFile) async {
    try {
      final uri = Uri.parse(Secrets.create_company_endpoint);


      final mimeType = lookupMimeType(logoFile!.path) ?? 'image/jpeg';
      final fileStream = http.ByteStream(logoFile.openRead());
      final fileLength = await logoFile.length();
      var mimeParts = mimeType.split('/');

      var request = http.MultipartRequest("POST", uri)
        ..fields['name'] = company.name
        ..fields['description'] = company.description ?? ""
        ..fields['uid'] = uid
        ..headers['Authorization'] = 'Bearer $accessToken'
        ..headers['apikey'] = Secrets.supabaseAnonKey
        ..files.add(
          http.MultipartFile(
            'logo',
            fileStream,
            fileLength,
            filename: path.basename(logoFile.path),
            contentType: MediaType(mimeParts[0], mimeParts[1]),
          ),
        );

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

  // For the stream app with screen
  Stream<List<CompanyModel>> getCompanyStream() {
    final controller = StreamController<List<CompanyModel>>();
    _connectToCompanyStream(controller);
    return controller.stream;
  }

  Future<void> _connectToCompanyStream(StreamController<List<CompanyModel>> controller) async {
    try {
      final url = Uri.parse("${Secrets.company_realtime_stream_endpoint}?uid=$uid");

      final request = http.Request("GET", url)
        ..headers["Accept"] = "text/event-stream"
        ..headers["Authorization"] = "Bearer $accessToken"
        ..headers["apikey"] = Secrets.supabaseAnonKey;

      final response = await request.send();
      final stream = response.stream.transform(utf8.decoder);

      String buffer = "";
      _sseSubscription = stream.listen((chunk) {
        buffer += chunk;

        while (buffer.contains("\n\n")) {
          final index = buffer.indexOf("\n\n");
          final eventString = buffer.substring(0, index).trim();
          buffer = buffer.substring(index + 2);

          String? eventName;
          String? data;

          for (final line in eventString.split("\n")) {
            if (line.startsWith("event:")) {
              eventName = line.replaceFirst("event:", "").trim();
            } else if (line.startsWith("data:")) {
              data = line.replaceFirst("data:", "").trim();
            }
          }

          if (data != null) {
            try {
              final decoded = jsonDecode(data);
              List<CompanyModel> companies = [];

              switch (eventName) {
                case "initial_data":
                  companies = (decoded["companies"] as List)
                      .map((c) => CompanyModel.fromMap(c))
                      .toList();
                  break;

                case "company_change":
                  companies = [CompanyModel.fromMap(decoded["payload"]["new"])];
                  break;

                case "links_change":
                  companies = (decoded["companies"] as List)
                      .map((c) => CompanyModel.fromMap(c))
                      .toList();
                  break;

                default:
                  break;
              }

              if (companies.isNotEmpty && !controller.isClosed) {
                controller.add(companies);
              }
            } catch (e) {
              if (!controller.isClosed) {
                controller.addError(e);
              }
            }
          }
        }
      }, onError: (error) {
        if (!controller.isClosed) controller.addError(error);
      }, onDone: () {
        if (!controller.isClosed) controller.close();
      });
    } catch (e) {
      if (!controller.isClosed) controller.addError(e);
    }
  }

  Future<void> disconnect() async {
    await _sseSubscription?.cancel();
    _sseSubscription = null;
  }
}