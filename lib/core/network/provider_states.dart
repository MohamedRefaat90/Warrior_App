class ProviderStates {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  ProviderStates(
      {this.isLoading = false, this.isSuccess = false, this.errorMessage});
}
