import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import 'auth_viewmodel.dart';

enum ResetStatus { initial, loading, codeSent, success, failure }

class PasswordResetState extends Equatable {
  const PasswordResetState({
    this.status = ResetStatus.initial,
    this.errorMessage,
  });

  final ResetStatus status;
  final String? errorMessage;

  bool get isLoading => status == ResetStatus.loading;

  @override
  List<Object?> get props => [status, errorMessage];
}

/// A separate ViewModel from login, so a reset error never touches
/// the login state. autoDispose = state resets when the screens close.
class PasswordResetViewModel extends Notifier<PasswordResetState> {
  @override
  PasswordResetState build() => const PasswordResetState();

  Future<void> requestCode(String email) async {
    state = const PasswordResetState(status: ResetStatus.loading);
    try {
      await ref.read(authRepositoryProvider).requestPasswordReset(email);
      state = const PasswordResetState(status: ResetStatus.codeSent);
    } on AppException catch (e) {
      state = PasswordResetState(
          status: ResetStatus.failure, errorMessage: e.message);
    } catch (_) {
      state = const PasswordResetState(
        status: ResetStatus.failure,
        errorMessage: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<void> reset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    state = const PasswordResetState(status: ResetStatus.loading);
    try {
      await ref.read(authRepositoryProvider).resetPassword(
            email: email,
            code: code,
            newPassword: newPassword,
          );
      state = const PasswordResetState(status: ResetStatus.success);
    } on AppException catch (e) {
      state = PasswordResetState(
          status: ResetStatus.failure, errorMessage: e.message);
    } catch (_) {
      state = const PasswordResetState(
        status: ResetStatus.failure,
        errorMessage: 'Something went wrong. Please try again.',
      );
    }
  }
}

final passwordResetProvider =
    NotifierProvider.autoDispose<PasswordResetViewModel, PasswordResetState>(
  PasswordResetViewModel.new,
);