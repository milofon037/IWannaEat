import 'package:dio/dio.dart';
import 'package:i_wanna_eat/core/session/session_controller.dart';
import 'package:i_wanna_eat/core/storage/token_storage.dart';

class DioClientFactory {
  DioClientFactory({
    required this.baseUrl,
    required this.tokenStorage,
    required this.sessionController,
  });

  final String baseUrl;
  final TokenStorage tokenStorage;
  final SessionController sessionController;

  Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        contentType: Headers.jsonContentType,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStorage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            sessionController.notifyUnauthorized();
          }
          handler.next(error);
        },
      ),
    );
    return dio;
  }
}
