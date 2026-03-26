import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_education/feature/splash_screen/prsentaion/Bloc/splash_event.dart';
import 'package:project_education/feature/splash_screen/prsentaion/Bloc/splash_state.dart';



class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
  }

  Future<void> _onSplashStarted(
      SplashStarted event,
      Emitter<SplashState> emit,
      ) async {
    await Future.delayed(const Duration(seconds: 10));
    emit(SplashLoaded());
  }
}
