class ApiResponse<T> {
  final bool success;
  final T? data;
  final ApiError? error;
  final String? message;
  final int statusCode;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.message,
    required this.statusCode,
  });

  factory ApiResponse.success({
    required T data,
    String? message,
    required int statusCode,
  }) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.failure({
    required ApiError error,
    required int statusCode,
  }) {
    return ApiResponse<T>(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }

  bool get isSuccess => success && error == null;
  bool get isFailure => !success || error != null;
}

class ApiError {
  final String code;
  final String message;
  final dynamic details;

  const ApiError({
    required this.code,
    required this.message,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code']?.toString() ?? 'UNKNOWN_ERROR',
      message: json['message']?.toString() ?? 'An error occurred',
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
        if (details != null) 'details': details,
      };
}
