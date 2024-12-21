class AuthState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  AuthState(
      {this.isLoading = false, this.isSuccess = false, this.errorMessage});
}
