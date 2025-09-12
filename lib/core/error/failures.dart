import 'package:equatable/equatable.dart';

/// Lớp cha mô tả lỗi chung trong domain layer.
/// Có thể mở rộng ra nhiều loại Failure (Server, Cache, Network,...)
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Lỗi từ server (API, Firestore,...)
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

/// Lỗi từ cache/local storage
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}
