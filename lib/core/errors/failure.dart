import 'package:equatable/equatable.dart';
import 'app_exception.dart';

/// User-facing Failure representation mapped from Exceptions
class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  factory Failure.fromException(Object exception) {
    if (exception is AppException) {
      return Failure(message: exception.message, code: exception.code);
    }
    return Failure(message: exception.toString(), code: 'UNKNOWN_ERROR');
  }

  @override
  List<Object?> get props => [message, code];
}
