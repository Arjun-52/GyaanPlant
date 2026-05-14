import 'api_response.dart';

class ErrorHandler {
  ErrorHandler._();

  static String fromStatusCode(ApiError error, int statusCode) {
    switch (statusCode) {
      case 400:
        return error.message.isNotEmpty ? error.message : 'Invalid request data.';
      case 401:
        return 'Session expired. Please log in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'Requested resource not found.';
      case 409:
        return error.message.isNotEmpty ? error.message : 'Conflict with existing data.';
      case 422:
        return error.message.isNotEmpty ? error.message : 'Validation failed.';
      case 429:
        return 'Too many requests. Please slow down.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Service temporarily unavailable.';
      case 503:
        return 'Service under maintenance.';
      case 504:
        return 'Gateway timeout. Please retry.';
      default:
        if (statusCode >= 500) return 'A server error occurred.';
        if (statusCode >= 400) {
          return error.message.isNotEmpty ? error.message : 'A client error occurred.';
        }
        return 'Something went wrong.';
    }
  }

  static String fromNetworkError(ApiError error) {
    switch (error.code) {
      case 'NO_INTERNET':
        return 'No internet connection. Please check your network.';
      case 'TIMEOUT':
        return 'Request timed out. Please try again.';
      case 'NETWORK_ERROR':
        return 'Network error. Please check your connection.';
      default:
        return error.message.isNotEmpty ? error.message : 'A network error occurred.';
    }
  }
}
