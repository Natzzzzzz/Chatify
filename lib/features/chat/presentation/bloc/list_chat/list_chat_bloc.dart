import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../../domain/entities/chat.dart';
import 'list_chat_event.dart';
import 'list_chat_state.dart';
import '../../../domain/usecases/get_list_chat.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  final GetChats getChats;

  ChatsBloc({required this.getChats}) : super(const ChatsState()) {
    on<LoadChats>(_onLoadChats);
  }

  Future<void> _onLoadChats(LoadChats event, Emitter<ChatsState> emit) async {
    emit(state.copyWith(isLoading: true));

    await emit.forEach<Either<Failure, List<Chat>>>(
      getChats(event.userId),
      onData: (result) => result.fold(
        (failure) => state.copyWith(
          isLoading: false,
          errorMessage: failure.toString(),
        ),
        (chats) => state.copyWith(
          isLoading: false,
          chats: chats,
        ),
      ),
      onError: (error, _) =>
          state.copyWith(isLoading: false, errorMessage: error.toString()),
    );
  }
}
