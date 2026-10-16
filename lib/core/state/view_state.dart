import 'package:equatable/equatable.dart';

/// Standard status enum for asynchronous operations
enum Status {
  idle,
  loading,
  success,
  error,
}

/// Generic ViewState representation to encapsulate state data and failures
class ViewState<T> extends Equatable {
  final Status status;
  final T? data;
  final String? errorMessage;
  final String? errorCode;

  const ViewState._({
    required this.status,
    this.data,
    this.errorMessage,
    this.errorCode,
  });

  const ViewState.idle([T? data])
      : this._(status: Status.idle, data: data);

  const ViewState.loading([T? previousData])
      : this._(status: Status.loading, data: previousData);

  const ViewState.success(T data)
      : this._(status: Status.success, data: data);

  const ViewState.error(String message, {String? code, T? previousData})
      : this._(status: Status.error, errorMessage: message, errorCode: code, data: previousData);

  bool get isIdle => status == Status.idle;
  bool get isLoading => status == Status.loading;
  bool get isSuccess => status == Status.success;
  bool get isError => status == Status.error;

  @override
  List<Object?> get props => [status, data, errorMessage, errorCode];
}
