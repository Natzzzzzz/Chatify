import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat.dart';
import '../repositories/list_chat_repository.dart';

class GetChats {
  final ListChatRepository repository;

  GetChats(this.repository);

  Stream<Either<Failure, List<Chat>>> call(String userId) {
    return repository.getChats(userId);
  }
}
