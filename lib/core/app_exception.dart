import 'package:supabase_flutter/supabase_flutter.dart';

class AppException implements Exception {
  const AppException(this.message);

  final String message;

  factory AppException.from(Object error) {
    if (error is AppException) return error;

    if (error is PostgrestException) {
      final message = error.message;
      if (error.code == '42501' || message.contains('row-level security')) {
        return const PermissionDeniedException();
      }
      switch (error.code) {
        case 'PGRST116':
          return const AppException(
            'That item no longer exists, or you are not allowed to change it.',
          );
        case '23503':
          return const InUseException();
        case '23505':
          return const AppException('That name is already taken.');
        case '23514':
          return const AppException('One of the values is not allowed.');
      }
      return AppException(message);
    }

    if (error is StorageException) {
      if (error.statusCode == '403' ||
          error.message.contains('row-level security')) {
        return const PermissionDeniedException();
      }
      return AppException('Image upload failed: ${error.message}');
    }

    if (error is AuthException) return AppException(error.message);

    final text = error.toString();
    if (text.contains('SocketException') ||
        text.contains('ClientException') ||
        text.contains('Failed host lookup') ||
        text.contains('XMLHttpRequest')) {
      return const NetworkException();
    }
    return AppException(text);
  }

  @override
  String toString() => message;
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException()
      : super('You do not have permission to do that.');
}

class InUseException extends AppException {
  const InUseException()
      : super('This is still used by other records, so it cannot be removed.');
}

class NetworkException extends AppException {
  const NetworkException()
      : super('Could not reach the server. Check your internet connection.');
}

Future<T> guardSupabase<T>(Future<T> Function() action) async {
  try {
    return await action();
  } catch (error) {
    throw AppException.from(error);
  }
}
