import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/chat.dart';
import '../../domain/repositories/list_chat_repository.dart';
import '../datasources/list_chat_remote_data_source.dart';

class ListChatRepositoryImpl implements ListChatRepository {
  final ListChatRemoteDataSource remoteDataSource;

  ListChatRepositoryImpl(this.remoteDataSource);

  @override
  Stream<Either<Failure, List<Chat>>> getChats(String userId) async* {
    try {
      await for (final chats in remoteDataSource.getChats(userId)) {
        yield Right(chats);
      }
    } catch (e) {
      yield Left(ServerFailure(e.toString()));
    }
  }
}
