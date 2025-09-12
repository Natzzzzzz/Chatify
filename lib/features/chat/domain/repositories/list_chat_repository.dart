import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat.dart';

abstract class ListChatRepository {
  Stream<Either<Failure, List<Chat>>> getChats(String userId);
}
